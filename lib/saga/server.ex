defmodule Saga.Server do

  alias Saga.Api.{
    User,
    Response,
    InitialState
  }

  use GRPC.Server, service: InitialState.Service

  @spec sign_up_email(Saga.Api.User.t, GRPC.Server.Stream.t) :: Saga.Api.Response.t
  def sign_up_email(user, _stream) do
    {:ok, pid} = GenStateMachine.start_link(Sagas.Email.SignUp.Test, {:sign_up, []})
    GenStateMachine.cast(pid, {:send_email, user})
    # check_answer(0)
    Response.new(res: true)
  end

  defp check_answer(n) when n < 3 do
    res = KafkaEx.fetch("test", 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> check_answer(n+1)
      size != 0 -> check_answer(:added, answer)
    end
  end

  defp check_answer(n) when n == 0 do
    res = KafkaEx.fetch("test", 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> check_answer(n+1)
      size != 0 -> check_answer(:added, answer)
    end
  end

  defp check_answer(:added, answer) do
    value = elem(answer, 0)
    Sagas.Email.SignUp.email_add(value)
  end
end
