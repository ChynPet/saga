defmodule Sagas.Facebook.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:registration, []})
  end

  @spec send_in_facebook(pid, Saga.Api.UserFacebook.t()) :: :ok
  def send_in_facebook(pid, data) do
    GenStateMachine.cast(pid, {:send_in_facebook, data})
  end

  @spec send_in_authentication(pid, Saga.Api.UserFacebook.t()) :: :ok
  def send_in_authentication(pid, data) do
    GenStateMachine.cast(pid, {:send_in_authentication, data})
  end

  @spec add_user_id(pid) :: :ok
  def add_user_id(pid) do
    GenStateMachine.cast(pid, {:add_user_id})
  end

  @spec send_userpic(pid) :: :ok
  def send_userpic(pid) do
    GenStateMachine.cast(pid, {:send_userpic})
  end

  @spec send_token(pid) :: :ok
  def send_token(pid) do
    GenStateMachine.cast(pid, {:send_token})
  end

  @spec get_data(pid) :: any
  def get_data (pid) do
    GenStateMachine.call(pid, :get_data)
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  #On Facebook Microservice

  @spec registration(:cast, {:send_in_facebook, Saga.Api.UserFacebook.t()}, {:registration, []}) ::
          {:next_state, :creating_token | :error, {:creating_token, Answer.Facebook.User.t()} | {:error, String.t()}}
  def registration(:cast, {:send_in_facebook, data}, _loop_data) do
    message = %{facebook_token: data.token_facebook, facebook_id: data.user_idfacebook}
    Facebook.send_message_sign_up(message, 0)
    answer = Facebook.answer_facebook(0)
    case answer.answer do
      "ok" -> {:next_state, :creating_token, {:creating_token, answer}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec registration(
          :cast | {:call, any},
          :get_data | {:send_in_facebook, atom | %{token_facebook: any, user_idfacebook: any}},
          any
        ) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :creating_token | :error,
             {:creating_token, false | nil | true | %{answer: any}} | {:error, any}}
  def registration(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Authentication Microservice
  @spec creating_token(:cast, {:send_in_authentication, Saga.Api.UserFacebook.t()}, {:creating_token, Answer.Facebook.User.t()}) ::
        {:next_state, :addition_userid | :error,
        {:addition_userid, {Saga.Api.UserFacebook.t(), Answer.Authentication.t()}} |
        {:error, String.t()}}
  def creating_token(:cast, {:send_in_authentication, user}, {:creating_token, answer}) do
    new_user = Saga.Api.UserFacebook.new(user_idfacebook: user.user_idfacebook, token_facebook: user.token_facebook, user_pic: answer.user_pic, user_id: user.user_id, token: user.token)
    message = %{user_id_facebook: new_user.user_idfacebook}
    Authentication.send_message(message, 0)
    answer = Authentication.answer_authentication(0)
    case answer.answer do
      "ok" -> {:next_state, :addition_userid, {:addition_userid, {new_user, answer}}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end

  end

  @spec creating_token(
    :cast | {:call, any},
    :get_data
    | {:send_in_authentication,
       atom | %{token: any, token_facebook: any, user_id: any, user_idfacebook: any}},
    any
  ) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :addition_userid | :error,
       {:addition_userid, {atom | map, map}} | {:error, binary}}
  def creating_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Facebook Microservice

  @spec addition_userid(:cast, {:add_user_id}, {:addition_userid, {Saga.Api.UserFacebook.t(), Answer.Authentication.t()}}) ::
           {:next_state, :add_userpic | :error,
             {:add_userpic,Saga.Api.UserFacebook.t()} | {:error, binary}}
  def addition_userid(:cast, {:add_user_id}, {:addition_userid, {loop_data, answer}}) do
    new_user = Saga.Api.UserFacebook.new(user_id: answer.user_id, user_idfacebook: loop_data.user_idfacebook, user_pic: loop_data.user_pic, token_facebook: loop_data.token_facebook, token: answer.token)
    message = %{facebook_id: new_user.user_idfacebook, user_id: new_user.user_id}
    Facebook.send_message(message, 0)
    answer = Facebook.answer_facebook_id(0)
    case answer.answer do
      "ok" -> {:next_state, :add_userpic, {:add_userpic, new_user}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end


  @spec addition_userid({:call, any}, :get_data, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :add_userpic | :error,
             {:add_userpic, atom | %{user_id: any, user_idfacebook: any}} | {:error, binary}}
  def addition_userid(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Photo API
  @spec add_userpic(:cast, {:send_userpic}, {:add_userpic,Saga.Api.UserFacebook.t()}) ::
          {:next_state, :error | :save_token,
             {:error, false | nil | true | %{answer: any}}
             | {:save_token, Saga.Api.UserFacebook.t()}}
  def add_userpic(:cast, {:send_userpic}, {:add_userpic, data}) do
    message = %{user_id: data.user_id, userpic: data.user_pic}
    Photo.API.send_message(message, 0)
    answer = Photo.API.answer(0)
    case answer.answer do
      "ok" -> {:next_state, :save_token, {:save_token, data}}
      _ -> {:next_state, :error, {:error, answer}}
    end
  end

  @spec add_userpic({:call, any}, :get_data, any) ::
  {:keep_state_and_data, [{:reply, any, any}, ...]}
  | {:next_state, :error | :save_token,
     {:error, false | nil | true | %{answer: any}}
     | {:save_token, atom | %{user_id: any, user_pic: any}}}
  def add_userpic(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Push notification
  @spec save_token(:cast, {:send_token}, {:save_token, Saga.Api.UserFacebook.t()}) ::
         {:next_state, :end_fsm, {:end_fsm, Saga.Api.UserFacebook.t()}}
  def save_token(:cast, {:send_token}, {:save_token, loop_data}) do
    message = %{token: loop_data.token, user_id: loop_data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm, loop_data}}
  end

  @spec save_token({:call, any}, :get_data, any) ::
  {:keep_state_and_data, [{:reply, any, any}, ...]}
  | {:next_state, :end_fsm, {:end_fsm, atom | %{token: any, user_id: any}}}
  def save_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec end_fsm({:call, any}, :get_data, any) :: {:keep_state_and_data, [{:reply, any, any}, ...]}
  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec error({:call, any}, :get_data, any) :: {:keep_state_and_data, [{:reply, any, any}, ...]}
  def error(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec handle_event({:call, any}, :get_data, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
  def handle_event({:call, from}, :get_data, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

end
