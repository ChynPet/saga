defmodule Sagas.Facebook.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  def start_link do
    GenStateMachine.start_link(__MODULE__, {:registration, []})
  end

  def send_in_facebook(pid, data) do
    GenStateMachine.cast(pid, {:send_in_facebook, data})
  end

  def send_in_authentication(pid) do
    GenStateMachine.cast(pid, {:send_in_authentication})
  end

  def add_user_id(pid, data) do
    GenStateMachine.cast(pid, {:add_user_id, data})
  end

  def send_userpic(pid, data) do
    GenStateMachine.cast(pid, {:send_userpic, data})
  end

  def send_token(pid, data) do
    GenStateMachine.cast(pid, {:send_token, data})
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
    defstruct [:user_id, :user_pic, :token]
  end

  defmodule Authentication do
    @derive [Poison.Encoder]
    defstruct [:user_id, :facebook_userid, :token]
  end

  defmodule PhotoAPI do
    @derive [Poison.Encoder]
    defstruct [:user_id, :userpic]
  end
  #States FSM

  #On Facebook Microservice
  def registration(:cast, {:send_in_facebook, data}, _loop_data) do
    struct_facebook = %{token: data.token_facebook, fuser_id: data.user_idfacebook}
    encode_json = Poison.encode!(struct_facebook)
    KafkaEx.produce(Kafka.Topics.sign_up_facebook, 0, encode_json)
    res = answer_facebook()
    case res do
      %User{} -> {:next_state, :creating_token, {:creating_token, {data, res}}}
      _ -> {:next_state, :error, {:error, "Not exists user"}}
    end
  end

  def registration(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def answer_facebook do
    KafkaEx.produce(Kafka.Topics.answer_facebook, 0 , "{\"user_id\": \"1\", \"user_pic\": \"5\", \"token\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_facebook, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_facebook()
      size >= 1 -> answer_facebook(answer)
    end
  end

  def answer_facebook(answer) do
      value = elem(answer, 0)
      decode = Poison.decode!(value.value, as: %User{})
      decode
  end

  #On Authentication Microservice
  def creating_token(:cast, {:send_in_authentication}, {:creating_token, {data, res}}) do
    user = Saga.Api.UserFacebook.new(user_idfacebook: res.user_id, token_facebook: res.token, user_pic: res.user_pic, user_id: data.user_id, token: data.token)
    structure_message = %{fuser_id: user.user_idfacebook}
    message = Poison.encode!(structure_message)
    KafkaEx.produce(Kafka.Topics.authentication_token_create, 0, message)
    answer = answer_authentication()
    case answer do
      %Authentication{} -> {:next_state, :addition_userid, {:addition_userid, {user, answer}}}
      _ -> {:next_state, :error, {:error, "Not exists user"}}
    end

  end

  def creating_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def answer_authentication do
    KafkaEx.produce(Kafka.Topics.authentication_token_create, 0 , "{\"user_id\": \"1\", \"facebook_userid\": \"5\", \"token\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.authentication_token_create, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_authentication()
      size >= 1 -> answer_authentication(answer)
    end
  end

  def answer_authentication(answer) do
      value = elem(answer, 0)
      decode = Poison.decode!(value.value, as: %Authentication{})
      decode
  end

   #On Facebook Microservice
  def addition_userid(:cast, {:add_user_id, _data}, {:addition_userid, {loop_data, res}}) do
    user = Saga.Api.UserFacebook.new(user_id: "1", user_idfacebook: loop_data.user_idfacebook, user_pic: loop_data.user_pic, token_facebook: loop_data.token_facebook, token: "aa")
    struct_facebook = %{token: user.token_facebook, fuser_id: user.user_idfacebook}
    encode_json = Poison.encode!(struct_facebook)
    KafkaEx.produce(Kafka.Topics.fetch_userid_facebook, 0, encode_json)
    res = answer_facebook()
    case res do
      %User{} -> {:next_state, :departure_userpic, {:departure_userpic, user}}
      _ -> {:next_state, :error, {:error, "Not exists user"}}
    end

  end

  def addition_userid(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Photo API
  def departure_userpic(:cast, {:send_userpic, _user}, {:departure_userpic, data}) do
    struct_photo = %{user_id: data.user_id, userpic: data.user_pic}
    json = Poison.encode!(struct_photo)
    KafkaEx.produce(Kafka.Topics.photo_api, 0, json)
    answer = answer_photo_api()
    case answer do
      %PhotoAPI{} -> {:next_state, :departure_token_device, {:departure_token_device, data}}
    end

  end

  def departure_userpic(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def answer_photo_api do
    KafkaEx.produce(Kafka.Topics.answer_photo_api, 0 , "{\"user_id\": \"1\", \"userppic\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_photo_api, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_photo_api()
      size >= 1 -> answer_photo_api(answer)
    end
  end

  def answer_photo_api(answer) do
      value = elem(answer, 0)
      decode = Poison.decode!(value.value, as: %PhotoAPI{})
      decode
  end

  #On Push notification
  def departure_token_device(:cast, {:send_token, data}, {:departure_token_device, loop_data}) do
    structe_for_notifiaction = %{token: data.token, user_id: data.user_id}
    json = Poison.encode!(structe_for_notifiaction)
    KafkaEx.produce(Kafka.Topics.save_device_token, 0, json)
    {:next_state, :end_fsm, {:end_fsm, loop_data}}
  end

  def departure_token_device(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end
  def handle_event({:call, from}, :get_data, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

end
