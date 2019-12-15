defmodule Saga.Apiprocedure.Saga do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }
  defstruct [:id, :name]

  field :id, 1, type: :string
  field :name, 2, type: :string
end

defmodule Saga.Apiprocedure.SagaFetchAllRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          page_size: integer,
          page_token: String.t()
        }
  defstruct [:page_size, :page_token]

  field :page_size, 1, type: :int32
  field :page_token, 2, type: :string
end

defmodule Saga.Apiprocedure.SagaFetchAllResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          sagas: [Saga.Apiprocedure.Saga.t()],
          response: String.t()
        }
  defstruct [:sagas, :response]

  field :sagas, 1, repeated: true, type: Saga.Apiprocedure.Saga
  field :response, 2, type: :string
end

defmodule Saga.Apiprocedure.SagaMobileService.Service do
  @moduledoc false
  use GRPC.Service, name: "saga.apiprocedure.SagaMobileService"

  rpc :say_hello, Saga.Apiprocedure.Saga, stream(Saga.Apiprocedure.SagaFetchAllResponse)
end

defmodule Saga.Apiprocedure.SagaMobileService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Saga.Apiprocedure.SagaMobileService.Service
end
