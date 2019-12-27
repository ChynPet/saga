defmodule Sagas.Email.SignUp do
  use GenStateMachine, callback_mode: :state_functions

  #API Client

  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_up, []})
  end

  def registraion(pid, user) do
    GenStateMachine.cast(pid, {:registration, user})
  end

  def add_email(pid, user) do
    GenStateMachine.cast(pid, {:add_email, user})
  end

  def save_token_device(pid) do
    GenStateMachine.cast(pid, {:save_token_device})
  end

  def get_data (pid) do
    GenStateMachine.call(pid, :get_data)
  end

  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  #Authentication Microservice
  def sign_up(:cast, {:registration, user}, _loop_data) do
    message = %{email: user.email, password: user.password}
    Authentication.send_message_authentication(message, 0)
    answer = Authentication.answer_authentication(0)
    case answer.answer do
      "ok" -> {:next_state, :confirm_email, {:confirm_email, answer}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  def sign_up(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Email Microservice
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

  def confirm_email(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Notification
  def add_token(:cast, {:save_token_device}, {:add_token, loop_data}) do
    message = %{token: loop_data.token, user_id: loop_data.user_id}
    Notification.send_message_notification(message, 0)
    {:next_state, :end_fsm, {:end_fsm, loop_data}}
  end

  def add_token(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def end_fsm(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def error(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def handle_event({:call, from}, :get_data, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

end
