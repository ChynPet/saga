defmodule Sagas.Instagram.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:registration, []})
  end

  @spec send_in_instagram(pid, Saga.Api.UserInstagram.t()) :: :ok
  def send_in_instagram(pid, data) do
    GenStateMachine.cast(pid, {:send_in_instagram, data})
  end

  @spec send_in_authentication(pid, Saga.Api.UserInstagram.t()) :: :ok
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

  #On instagram Microservice
  @spec registration(:cast, {:send_in_instagram, Saga.Api.UserInstagram.t()}, any) ::
          {:next_state, :creating_token | :error,
            {:creating_token, Answer.Instagram.User.t()} | {:error, String.t()}}
  def registration(:cast, {:send_in_instagram, data}, _loop_data) do
    message = %{instagram_token: data.token_instagram, instagram_id: data.user_idinstagram}
    Instagram.send_message_sign_up(message, 0)
    answer = Instagram.answer_instagram(0)
    case answer.answer do
      "ok" -> {:next_state, :creating_token, {:creating_token, answer}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec registration({:call, any}, :get_data, any) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :creating_token | :error,
       {:creating_token, Answer.Instagram.User.t()} | {:error, String.t()}}
  def registration(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Authentication Microservice
  @spec creating_token(:cast, {:send_in_authentication, Saga.Api.UserInstagram.t()}, {:creating_token, Answer.Instagram.User.t()}) ::
          {:next_state, :addition_userid | :error,
             {:addition_userid, {Saga.Api.UserInstagram.t(), Answer.Authentication.t()}} | {:error, String.t()}}
  def creating_token(:cast, {:send_in_authentication, user}, {:creating_token, answer}) do
    new_user = Saga.Api.UserInstagram.new(user_idinstagram: user.user_idinstagram, token_instagram: user.token_instagram, user_pic: answer.user_pic, user_id: user.user_id, token: user.token)
    message = %{user_id_instagram: new_user.user_idinstagram}
    Authentication.send_message(message, 0)
    answer = Authentication.answer_authentication(0)
    case answer.answer do
      "ok" -> {:next_state, :addition_userid, {:addition_userid, {new_user, answer}}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end

  end

  @spec creating_token( {:call, any}, :get_data, any) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :addition_userid | :error,
       {:addition_userid, {Saga.Api.UserInstagram.t(), Answer.Authentication.t()}} | {:error, String.t()}}
  def creating_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Instagram Microservice
  @spec addition_userid(:cast, {:add_user_id}, {:addition_userid, {Saga.Api.UserInstagram.t(), Answer.Authentication.t()}}) ::
          {:next_state, :add_userpic | :error,
             {:add_userpic, Saga.Api.UserInstagram.t()}
             | {:error, String.t()}}
  def addition_userid(:cast, {:add_user_id}, {:addition_userid, {loop_data, answer}}) do
    new_user = Saga.Api.UserInstagram.new(user_id: answer.user_id, user_idinstagram: loop_data.user_idinstagram, user_pic: loop_data.user_pic, token_instagram: loop_data.token_instagram, token: answer.token)
    message = %{instagram_id: new_user.user_idinstagram, user_id: new_user.user_id}
    Instagram.send_message(message, 0)
    answer = Instagram.answer_instagram_id(0)
    case answer.answer do
      "ok" -> {:next_state, :add_userpic, {:add_userpic, new_user}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec addition_userid({:call, any}, :get_data, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :add_userpic | :error,
             {:add_userpic, Saga.Api.UserInstagram.t()}
             | {:error, String.t()}}
  def addition_userid(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Photo API
  @spec add_userpic(:cast, {:send_userpic}, {:add_userpic, Saga.Api.UserInstagram.t()}) ::
          {:next_state, :error | :save_token,
             {:error, Answer.Photo.API.t()}
             | {:save_token, Saga.Api.UserInstagram.t()}}
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
     {:error, Answer.Photo.API.t()}
     | {:save_token, Saga.Api.UserInstagram.t()}}
  def add_userpic(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #On Push notification
  @spec save_token(:cast, {:send_token}, {:save_token, Saga.Api.UserInstagram.t()}) ::
          {:next_state, :end_fsm, {:end_fsm, Saga.Api.UserInstagram.t()}}
  def save_token(:cast, {:send_token}, {:save_token, loop_data}) do
    message = %{token: loop_data.token, user_id: loop_data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm, loop_data}}
  end

  @spec save_token({:call, any}, :get_data, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :end_fsm, {:end_fsm, Saga.Api.UserInstagram.t()}}
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
