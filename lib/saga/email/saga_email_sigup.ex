defmodule Sagas.Email.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_up, []})
  end

  @spec registraion(pid, Saga.Api.User.t()) :: :ok
  def registraion(pid, user) do
    GenStateMachine.cast(pid, {:registration, user})
  end

  @spec add_email(pid, Saga.Api.User.t()) :: :ok
  def add_email(pid, user) do
    GenStateMachine.cast(pid, {:add_email, user})
  end

  @spec save_token_device(pid) :: :ok
  def save_token_device(pid) do
    GenStateMachine.cast(pid, {:save_token_device})
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

  #Authentication Microservice
  @spec sign_up(:cast, {:registration,Saga.Api.User.t()}, {:sign_up, []}) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :confirm_email | :error,
             {:confirm_email, Answer.Authentication.t()} | {:error, String.t()}}
  def sign_up(:cast, {:registration, user}, _loop_data) do
    message = %{email: user.email, password: user.password}
    Authentication.send_message_authentication_sign_up(message, 0)
    answer = Authentication.answer_authentication_sign_up(0)
    case answer.answer do
      "ok" -> {:next_state, :confirm_email, {:confirm_email, answer}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec sign_up({:call, any}, :get_data, any) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :confirm_email | :error,
       {:confirm_email, Answer.Authentication.t()} | {:error, String.t()}}
  def sign_up(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Email Microservice
  @spec confirm_email(:cast, {:add_email, Saga.Api.User.t()}, {:confirm_email, Answer.Authentication.t()}) ::
          {:next_state, :add_token | :error,
             {:add_token, Saga.Api.User.t()} | {:error, String.t()}}
  def confirm_email(:cast, {:add_email, user}, {:confirm_email, loop_data}) do
    update_user = Saga.Api.User.new(user_id: loop_data.user_id, email: user.email, password: user.password, token: loop_data.token)
    message = %{email: update_user.email, user_id: update_user.user_id}
    Email.send_message_email(message, 0)
    answer = Email.answer_email(0)
    case answer.answer do
      "ok" -> {:next_state, :add_token, {:add_token, update_user}}
      _   -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  @spec confirm_email({:call, any}, :get_data, any) ::
    {:keep_state_and_data, [{:reply, any, any}, ...]}
    | {:next_state, :add_token | :error,
       {:add_token, atom | %{email: binary, user_id: binary}} | {:error, String.t()}}
  def confirm_email(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Notification
  @spec add_token(:cast, {:save_token_device}, {:add_token, Saga.Api.User.t()}) ::
          {:next_state, :end_fsm, {:end_fsm, Saga.Api.User.t()}}
  def add_token(:cast, {:save_token_device}, {:add_token, loop_data}) do
    message = %{token: loop_data.token, user_id: loop_data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm, loop_data}}
  end

  @spec add_token({:call, any}, :get_data, any) ::
  {:keep_state_and_data, [{:reply, any, any}, ...]}
  | {:next_state, :end_fsm, {:end_fsm, Saga.Api.User.t()}}
  def add_token(event_type, event_content, data) do
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
