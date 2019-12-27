defmodule User do

  alias Saga.Api.{
    User,
    InitialState
  }

  use GenStateMachine

  def sign_up_email(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_up_email(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end

  def sign_up_facebook(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_up_facebook(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end

  def sign_up_instagram(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_up_instagram(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end

  def sign_in_email(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_in_email(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end

  def sign_in_facebook(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_in_facebook(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end

  def sign_in_instagram(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_in_instagram(requset)
    res = Enum.to_list(reply)
    |> Enum.map(&(elem(&1, 1)))

    GRPC.Stub.disconnect(channel)
    res
  end
  defp create_channel() do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    channel
  end
end
