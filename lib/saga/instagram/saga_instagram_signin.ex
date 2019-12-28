defmodule Sagas.Instagram.SignIn do

  use GenStateMachine, callback_mode: :state_functions
  #API Client
  def start_link do
    GenStateMachine.start_link(__MODULE__, {:sign_in, []})
  end

  def login(pid, user) do
    GenStateMachine.cast(pid, {:login, user})
  end

  def create_token(pid, data) do
    GenStateMachine.cast(pid, {:create_token, data})
  end

  def save_token_notification(pid, data) do
    GenStateMachine.cast(pid, {:save_token_notification, data})
  end

  def get_data(pid) do
    GenStateMachine.call(pid, {:get_data})
  end

  def stop(pid) do
    GenStateMachine.stop(pid)
  end

  #States FSM

  #Send on instagram
  def sign_in(:cast, {:login, user}, _loop_data) do
    message = %{instagram_token: user.token_instagram, instagram_id: user.user_idinstagram}
    Instagram.send_message_sign_in(message, 0)
    answer = Instagram.answer_instagram_id(0)
    case answer.answer do
      "ok" -> {:next_state, :authentication, {:authentication, user}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end

  end

  def sign_in(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Send on Authetication

  def authentication(:cast, {:create_token, data}, {:authentication, _loop_data}) do
    message = %{user_id_instagram: data.user_idinstagram}
    Authentication.send_message(message, 0)
    answer = Authentication.answer_authentication(0)
    case answer.answer do
      "ok" -> {:next_state, :save_token, {:save_token, data}}
      _ -> {:next_state, :error, {:error, answer.answer}}
    end
  end

  def authentication(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  #Send on Notification
  def save_token(:cast, {:save_token_notification, data}, {:save_token, _loop_data}) do
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
