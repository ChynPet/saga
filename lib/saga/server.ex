defmodule Saga.Server do

  alias Saga.Apiprocedure.{
    Saga,
    SagaFetchAllRequest,
    SagaFetchAllResponse,
    SagaMobileService
  }

  use GRPC.Server, service: SagaMobileService.Service

  def say_hello(request, _stream) do
    SagaFetchAllResponse.new(message: "Hello #{request.name}")
  end
end
