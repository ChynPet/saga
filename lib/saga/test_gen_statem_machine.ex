defmodule Sagas.Email.SignUp.Test do
  use GenStateMachine, callback_mode: :state_functions

  defmodule User do
    @derive [Poison.Encoder]
    defstruct [:userid, :access_token]
  end

  def sign_up(:cast, {:send_email, user}, _loop_data) do
    user_json = Poison.encode!(user)
    KafkaEx.produce("test", 0, user_json)
    {:next_state, :sending_email, user}
  end

  def sending_email(:cast, {:email_add, value}, %Saga.Api.User{user_id: user_id, email: email, password: password, token: token}) do
    decode = Poison.decode!(value.value, as: %Sagas.Email.SignUp.Test.User{})
    user = Saga.Api.User.new(user_id: decode.userid, email: email, password: password, token: decode.access_token)
    {:next_state, :email_added, user}
  end

  def email_added(:cast, {:confirm_email, user}, loop_data) do
    message = %{email: user.email, user_id: loop_data.user_id}
    message_json = Poison.encode!(message)
    KafkaEx.produce("test1", 0, message_json)
    {:next_state, :confirming_email, user}
  end

  def confirming_email(:cast, {:email_confirmed, answer}, loop_data) do
    decode = Poison.decode!(answer.value, as: %{answer: answer})
    {:next_state, :email_added, {loop_data, decode}}
  end

  def email_confirmed(:cast, {:send_token, token}, loop_data) do
    message = %{token_device: token}
    message_json = Poison.encode!(message)
    KafkaEx.produce("test2", 0, message_json)
    {:next_state, :end, loop_data}
  end

  # def sign_up(event_type, event_content, data) do
  #   handle_event(event_type, event_content, data)
  # end
end
