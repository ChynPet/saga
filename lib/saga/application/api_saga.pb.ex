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

defmodule Saga.Api.UserFacebook do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: String.t(),
          user_idfacebook: String.t(),
          user_pic: String.t(),
          token_facebook: String.t(),
          token: String.t()
        }
  defstruct [:user_id, :user_idfacebook, :user_pic, :token_facebook, :token]

  field :user_id, 1, type: :string
  field :user_idfacebook, 2, type: :string
  field :user_pic, 3, type: :string
  field :token_facebook, 4, type: :string
  field :token, 5, type: :string
end

defmodule Saga.Api.UserInstagram do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: String.t(),
          user_idinstagram: String.t(),
          user_pic: String.t(),
          token_instagram: String.t(),
          token: String.t()
        }
  defstruct [:user_id, :user_idinstagram, :user_pic, :token_instagram, :token]

  field :user_id, 1, type: :string
  field :user_idinstagram, 2, type: :string
  field :user_pic, 3, type: :string
  field :token_instagram, 4, type: :string
  field :token, 5, type: :string
end

defmodule Saga.Api.ResponseEmail do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: [Saga.Api.User.t()],
          message: String.t()
        }
  defstruct [:user, :message]

  field :user, 1, repeated: true, type: Saga.Api.User
  field :message, 2, type: :string
end

defmodule Saga.Api.ResponseFacebook do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: [Saga.Api.UserFacebook.t()],
          message: String.t()
        }
  defstruct [:user, :message]

  field :user, 1, repeated: true, type: Saga.Api.UserFacebook
  field :message, 2, type: :string
end

defmodule Saga.Api.ResponseInstagram do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: [Saga.Api.UserInstagram.t()],
          message: String.t()
        }
  defstruct [:user, :message]

  field :user, 1, repeated: true, type: Saga.Api.UserInstagram
  field :message, 2, type: :string
end

defmodule Saga.Api.InitialState.Service do
  @moduledoc false
  use GRPC.Service, name: "saga.api.InitialState"

  rpc :SignUpEmail, Saga.Api.User, stream(Saga.Api.ResponseEmail)
  rpc :SignUpFacebook, Saga.Api.UserFacebook, stream(Saga.Api.ResponseFacebook)
  rpc :SignUpInstagram, Saga.Api.UserInstagram, stream(Saga.Api.ResponseInstagram)
  rpc :SignInEmail, Saga.Api.User, stream(Saga.Api.ResponseEmail)
  rpc :SignInFacebook, Saga.Api.UserFacebook, stream(Saga.Api.ResponseFacebook)
  rpc :SignInInstagram, Saga.Api.UserInstagram, stream(Saga.Api.ResponseInstagram)
end

defmodule Saga.Api.InitialState.Stub do
  @moduledoc false
  use GRPC.Stub, service: Saga.Api.InitialState.Service
end
