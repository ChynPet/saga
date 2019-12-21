defmodule User do

  alias Saga.Api.{
    User,
    InitialState
  }

  use GenStateMachine

  def sign_up_email(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_up_email(requset)
    reply
  end

  defp create_channel() do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    channel
  end
end
