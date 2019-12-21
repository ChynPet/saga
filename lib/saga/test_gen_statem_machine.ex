# defmodule Sagas.Email.SignUp.Test do
#   use GenStateMachine, callback_mode: :state_functions

#   #API Client

#   def start_link do
#     GenStateMachine.start_link(__MODULE__, {:sign_up, []})
#   end

#   def send_email(pid, user) do
#     GenStateMachine.cast(pid, {:send_email, user})
#   end

#   def email_add(pid, value) do
#     GenStateMachine.cast(pid, {:email_add, value})
#   end

#   def confirm_email(pid, user) do
#     GenStateMachine.cast(pid, {:confirm_email, user})
#   end

#   def email_confirmed(pid, answer) do
#     GenStateMachine.cast(pid, {:email_confirmed, answer})
#   end

#   def send_token(pid, token) do
#     GenStateMachine.cast(pid, {:send_token, token})
#   end

#   def stop(pid) do
#     GenStateMachine.stop(pid)
#   end

#   #Structure for storing information from microservice Authentication
#   defmodule User do
#     @derive [Poison.Encoder]
#     defstruct [:userid, :access_token]
#   end

#   #States FSM
#   defp sign_up(:cast, {:send_email, user}, _loop_data) do
#     user_json = Poison.encode!(user)
#     KafkaEx.produce("test", 0, user_json)
#     {:next_state, :sending_email, user}
#   end

#   defp sending_email(:cast, {:email_add, value}, %Saga.Api.User{email: email, password: password}) do
#     decode = Poison.decode!(value.value, as: %Sagas.Email.SignUp.Test.User{})
#     user = Saga.Api.User.new(user_id: decode.userid, email: email, password: password, token: decode.access_token)
#     {:next_state, :email_added, user}
#   end

#   defp email_added(:cast, {:confirm_email, user}, loop_data) do
#     message = %{email: user.email, user_id: loop_data.user_id}
#     message_json = Poison.encode!(message)
#     KafkaEx.produce("test1", 0, message_json)
#     {:next_state, :confirming_email, user}
#   end

#   defp confirming_email(:cast, {:email_confirmed, answer}, loop_data) do
#     decode = Poison.decode!(answer.value, as: %{answer: answer})
#     {:next_state, :email_added, {loop_data, decode}}
#   end

#   defp email_confirmed(:cast, {:send_token, token}, loop_data) do
#     message = %{token_device: token}
#     message_json = Poison.encode!(message)
#     KafkaEx.produce("test2", 0, message_json)
#     {:next_state, :end, loop_data}
#   end

# end
