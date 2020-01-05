defmodule Sagas.Email.SignIn do

  use GenStateMachine, callback_mode: :state_functions
  #API Client
  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_in, []})
  end

  @spec login(pid, Saga.Api.User.t()) :: :ok
  def login(pid, user) do
    GenStateMachine.cast(pid, {:login, user})
  end

  @spec save_device_token(pid, Saga.Api.User.t()) :: :ok
  def save_device_token(pid, data) do
    GenStateMachine.cast(pid, {:save_device_token, data})
  end


  @spec get_data(pid) :: any
  def get_data(pid) do
    GenStateMachine.call(pid, {:get_data})
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  @spec sign_in(:cast, {:login, Saga.Api.User.t()}, {:sign_in, []}) ::
            {:next_state, :error | :save_token, {:save_token} | {:error, String.t()}}
  def sign_in(:cast, {:login, user}, _loop_data) do
    message = %{email: user.email, password: user.password}
    Authentication.send_message_sign_in(message, 0)
    answer = Authentication.answer_sign_in(0)
    case answer.answer do
      "ok" -> {:next_state, :save_token, {:save_token}}
      _ -> {:next_state, :error, {:error, "Error SignIn"}}
    end
  end

  @spec sign_in({:call, any}, {:get_data}, any) ::
          {:keep_state_and_data, [{:reply, any, any}, ...]}
          | {:next_state, :error | :save_token, {:save_token} | {:error, <<_::96>>}}
  def sign_in(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  @spec save_token(:cast, {:save_device_token, Saga.Api.User.t()}, {:save_token}) ::
    {:next_state, :end_fsm, {:end_fsm}}
  def save_token(:cast, {:save_device_token, data}, {:save_token}) do
    message = %{token: data.token, user_id: data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm}}
  end

  @spec save_token({:call, any}, {:get_data}, any) ::
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
