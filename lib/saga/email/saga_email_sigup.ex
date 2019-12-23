defmodule Sagas.Email.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_up, []})
  end

  def send_email(pid, user) do
    GenStateMachine.cast(pid, {:send_email, user})
  end

  def email_add(pid, value) do
    GenStateMachine.cast(pid, {:email_add, value})
  end

  def confirm_email(pid, user) do
    GenStateMachine.cast(pid, {:confirm_email, user})
  end

  def email_confirmed(pid, answer) do
    GenStateMachine.cast(pid, {:email_confirmed, answer})
  end

  def send_token(pid, token) do
    GenStateMachine.cast(pid, {:send_token, token})
  end

  def get_data (pid) do
    GenStateMachine.call(pid, :get_data)
  end

  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #Structure for storing information from microservice Authentication
  defmodule User do
    @derive [Poison.Encoder]
    defstruct [:userid, :access_token]
  end

  #States FSM

  #Authentication Microservice
  def sign_up(:cast, {:send_email, user}, _loop_data) do
    user_json = Poison.encode!(user)
    KafkaEx.produce(Kafka.Topics.authentication_sign_up, 0, user_json)
    {:next_state, :sending_email, {:sending_email, user}}
  end

  def sign_up(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def sending_email(:cast, {:email_add, value}, {:sending_email, %Saga.Api.User{user_id: user_id, email: email, password: password, token: token}}) do
    decode = Poison.decode!(value.value, as: %Sagas.Email.SignUp.User{})
    user = Saga.Api.User.new(user_id: decode.userid, email: email, password: password, token: decode.access_token)
    {:next_state, :email_added, {:email_added, user}}
  end

  def sending_email(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Email Microservice
  def email_added(:cast, {:confirm_email, user}, {:email_added, loop_data}) do
    message = %{email: user.email, user_id: loop_data.user_id}
    message_json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.confirm_email, 0, message_json)
    {:next_state, :confirming_email, {:confirming_email, loop_data}}
  end

  def email_added(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end
  def confirming_email(:cast, {:email_confirmed, answer},  {:confirming_email, loop_data}) do
    decode = Poison.decode!(answer.value, as: %{answer: answer})
    {:next_state, :email_confirmed, {:email_confirmed, {loop_data, decode}}}
  end

  #Notification
  def email_confirmed(:cast, {:send_token, token}, {:email_confirmed, {loop_data, decode}}) do
    message = %{token_device: token}
    message_json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.save_device_token, 0, message_json)
    {:next_state, :token_sended, {:token_sended, {loop_data, decode}}}
  end


  def token_sended(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def handle_event({:call, from}, :get_data, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

end
