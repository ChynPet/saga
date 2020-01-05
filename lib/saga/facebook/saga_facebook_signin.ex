defmodule Sagas.Facebook.SignIn do

  use GenStateMachine, callback_mode: :state_functions

  #API Client
  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_in, []})
  end

  @spec login(pid(), Saga.Api.UserFacebook.t()) :: :ok
  def login(pid, user) do
    GenStateMachine.cast(pid, {:login, user})
  end

  @spec create_token(pid(), Saga.Api.UserFacebook.t()) :: :ok
  def create_token(pid, data) do
    GenStateMachine.cast(pid, {:create_token, data})
  end

  @spec save_token_notification(pid(), Saga.Api.UserFacebook.t()) :: :ok
  def save_token_notification(pid, data) do
    GenStateMachine.cast(pid, {:save_token_notification, data})
  end

  @spec get_data(pid()) :: any
  def get_data(pid) do
    GenStateMachine.call(pid, {:get_data})
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  #Send on Facebook
  @spec sign_in( :cast, {:login, Saga.Api.UserFacebook.t()}, {:sign_in, []}) ::
            {:next_state, :authentication | :error,
            {:authentication, Saga.Api.UserFacebook.t()} | {:error, String.t()}}
  def sign_in(:cast, {:login, user}, _loop_data) do
    message = %{facebook_token: user.token_facebook, facebook_id: user.user_idfacebook}
    Facebook.send_message_sign_in(message, 0)
    answer = Facebook.answer_facebook_id(0)
    case answer.answer do
      "ok" -> {:next_state, :authentication, {:authentication, user}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end

  end

  @spec sign_in(
    :cast | {:call, any},
    {:get_data} | {:login, atom | %{token_facebook: any, user_idfacebook: any}},
    any
  ) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :authentication | :error,
       {:authentication, atom | %{token_facebook: any, user_idfacebook: any}}
       | {:error, any}}
  def sign_in(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Send on Authetication

  @spec authentication(:cast, {:create_token, Saga.Api.UserFacebook.t()}, {:authentication, Saga.Api.UserFacebook.t()}) ::
            {:next_state, :error | :save_token,
            {:error, String.t()} | {:save_token, Saga.Api.UserFacebook.t()}}
  def authentication(:cast, {:create_token, data}, {:authentication, _loop_data}) do
    message = %{user_id_facebook: data.user_idfacebook}
    Authentication.send_message(message, 0)
    answer = Authentication.answer_authentication(0)
    case answer.answer do
      "ok" -> {:next_state, :save_token, {:save_token, data}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec authentication(
    :cast | {:call, any},
    {:get_data} | {:create_token, atom | %{user_idfacebook: binary}},
    any
  ) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :error | :save_token,
       {:error, binary} | {:save_token, atom | %{user_idfacebook: binary}}}
  def authentication(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Send on Notification

  @spec save_token( :cast, {:save_token_notification, Saga.Api.UserFacebook.t()}, {:save_token, Saga.Api.UserFacebook.t()}) ::
  {:next_state, :end_fsm, {:end_fsm}}
  def save_token(:cast, {:save_token_notification, data}, {:save_token, _loop_data}) do
    message = %{token: data.token, user_id: data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm}}
  end

  @spec save_token(
    :cast | {:call, any},
    {:get_data} | {:save_token_notification, atom | %{token: any, user_id: any}},
    any
  ) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]} | {:next_state, :end_fsm, {:end_fsm}}
  def save_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec end_fsm({:call, any}, {:get_data}, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec error({:call, any}, {:get_data}, any) :: {:keep_state_and_data, [{:reply, any, any}, ...]}
  def error(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec handle_event({:call, any}, {:get_data}, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
  def handle_event({:call, from}, {:get_data}, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end
end
