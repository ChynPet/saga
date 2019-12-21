defmodule Saga.Server do

  alias Saga.Api.{
    User,
    Response,
    InitialState
  }

  use GRPC.Server, service: InitialState.Service

  @spec sign_up_email(Saga.Api.User.t, GRPC.Server.Stream.t) :: Saga.Api.Response.t
  def sign_up_email(user, _stream) do
    {:ok, pid} = Sagas.Email.SignUp.start_link
    Sagas.Email.SignUp.send_email(pid, user)
    Email.Answer.answer_authentication(pid)
    Sagas.Email.SignUp.confirm_email(pid, user)
    Email.Answer.answer_email(pid)
    Sagas.Email.SignUp.send_token(pid, "aaaa")
    result = Sagas.Email.SignUp.get_data(pid)
    Sagas.Email.SignUp.stop(pid)
    Response.new(res: true)

  end

end
