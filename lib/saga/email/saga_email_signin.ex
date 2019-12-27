defmodule Sagas.Email.SignIn do

  use GenStateMachine, callback_mode: :state_functions
  #API Client
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_in, []})
  end

  def login(pid, user) do
    GenStateMachine.cast(pid, {:login, user})
  end

  def save_device_token(pid, data) do
    GenStateMachine.cast(pid, {:save_device_token, data})
  end

  def get_data(pid) do
    GenStateMachine.call(pid, {:get_data})
  end

  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  def sign_in(:cast, {:login, user}, _loop_data) do
    message = %{email: user.email, password: user.password}
    Authentication.send_message_sign_in(message, 0)
    answer = Authentication.answer_sign_in(0)
    case answer.answer do
      "ok" -> {:next_state, :save_token, {:save_token}}
      _ -> {:next_state, :error, {:error, "Error SignIn"}}
    end
  end

  def sign_in(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def save_token(:cast, {:save_device_token, data}, {:save_token}) do
    message = %{token: data.token, user_id: data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm}}
  end

  def save_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def error(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def handle_event({:call, from}, {:get_data}, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end
end
