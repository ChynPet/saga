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

  def sign_in_email(requset) do
    channel = create_channel()
    {:ok, reply} = channel |> InitialState.Stub.sign_in_email(requset)
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

  def create_channel() do
    # ssl_cert = Path.expand(Application.get_env(:saga, :ssl_cert), :code.priv_dir(:saga))
    # ssl_key = Path.expand(Application.get_env(:saga, :ssl_key), :code.priv_dir(:saga))
    # ssl = [certfile: ssl_cert, keyfile: ssl_key]
    # cred = GRPC.Credential.new(ssl: ssl)

    # host = Application.get_env(:saga, :grpc_host)
    # port = Application.get_env(:saga, :grpc_port)
    # interceptors = [
    #   GRPC.Logger.Client,
    #   Saga.Interceptors.AuthClient
    # ]
    # {:ok, channel} = GRPC.Stub.connect(
    #   "#{host}:#{port}",
    #   interceptors: interceptors,
    #   cred: cred,
    #   timeout: 20_000,
    #   deadline: 20_000)

    # channel



    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    channel
  end
end
