defmodule Saga.Api.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: String.t(),
          email: String.t(),
          password: String.t(),
          token: String.t()
        }
  defstruct [:user_id, :email, :password, :token]

  field :user_id, 1, type: :string
  field :email, 2, type: :string
  field :password, 3, type: :string
  field :token, 4, type: :string
end

defmodule Saga.Api.Response do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: [Saga.Api.User.t()],
          res: boolean
        }
  defstruct [:user, :res]

  field :user, 1, repeated: true, type: Saga.Api.User
  field :res, 2, type: :bool
end

defmodule Saga.Api.InitialState.Service do
  @moduledoc false
  use GRPC.Service, name: "saga.api.InitialState"

  rpc :SignUpEmail, Saga.Api.User, stream(Saga.Api.Response)
end

defmodule Saga.Api.InitialState.Stub do
  @moduledoc false
  use GRPC.Stub, service: Saga.Api.InitialState.Service
end
