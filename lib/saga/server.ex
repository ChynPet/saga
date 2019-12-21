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
    check_answer(pid, 0)
    Response.new(res: true)
  end

  def check_answer(pid, n) do
    res = KafkaEx.fetch("test", 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size <= 1 -> check_answer(pid, size)
      size > 1 -> check_answer(pid, answer, size)
    end
  end

  def check_answer(pid, answer, size) do
    value = elem(answer, size-1)
    Sagas.Email.SignUp.email_add(pid, value)
  end
end
