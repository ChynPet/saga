defmodule Saga.Server do

  alias Saga.Api.{
    User,
    Response,
    InitialState
  }

  use GRPC.Server, service: InitialState.Service

  @spec sign_up_email(Saga.Api.User.t, GRPC.Server.Stream.t) :: Saga.Api.Response.t
  def sign_up_email(request, _stream) do
    Response.new(user: request, res: true)
  end
end
