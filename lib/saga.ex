defmodule Saga do

  alias Saga.Apiprocedure.{
    Saga,
    SagaFetchAllRequest,
    SagaFetchAllResponse,
    SagaMobileService
  }

  def say_hello(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> SagaMobileService.Stub.say_hello(requset)
    reply
  end

  defp create_channel() do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    channel
  end
end
