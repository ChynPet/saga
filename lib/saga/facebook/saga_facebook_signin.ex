defmodule Sagas.Facebook.SignIn do

  use GenStateMachine, callback_mode: :state_functions
  #API Client
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_in, []})
  end

  def mouth(pid, user) do
    GenStateMachine.cast(pid, {:mouth, user})
  end

  def send_token(pid, data) do
    GenStateMachine.cast(pid, {:send_token, data})
  end

  def get_data(pid) do
    GenStateMachine.call(pid, {:get_data})
  end

  def reset(pid) do
    GenStateMachine.cast(pid, {:reset})
  end

  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  defmodule Answer_Authentication do
    @derive [Poison.Encoder]
    defstruct [:user_id, :token, :answer]
  end
  #States FSM

  def sign_in(:cast, {:mouth, user}, _loop_data) do
    struct_message = %{id: user.user_idfacebook, token: user.token_facebook}
    message = Poison.encode!(struct_message)
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_in, 0, message)
    res = answer_authentication()
    {:next_state, :departure_token_device, {:departure_token_device}}
  end

  def sign_in(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def answer_authentication do
    KafkaEx.produce(Kafka.Topics.sign_in_facebook, 0 , "{\"user_id\": \"1\", \"token\": \"5\", \"answer\": \"ok\"}")
    res = KafkaEx.fetch(Kafka.Topics.sign_in_facebook, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_authentication()
      size >= 1 -> answer_authentication(answer)
    end
  end

  def answer_authentication(answer) do
      value = elem(answer, 0)
      decode = Poison.decode!(value.value, as: %Answer_Authentication{})
      decode
  end

  def departure_token_device(:cast, {:send_token, data}, {:departure_token_device}) do
    structe_for_notifiaction = %{token: data.token, user_id: data.user_id}
    json = Poison.encode!(structe_for_notifiaction)
    KafkaEx.produce(Kafka.Topics.save_device_token, 0, json)
    {:next_state, :end_fsm, {:end_fsm}}
  end

  def departure_token_device(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end
  def error(:cast, {:reset}, _loop_data) do
    {:next_state, :sign_in, {:sign_in, []}}
  end
  def error(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def handle_event({:call, from}, {:get_data}, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end
end
