import Supervisor.Spec

defmodule Saga.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Logger.Server
  run Saga.Server
end

defmodule Saga.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    # consumer_group_opts = [
    #   # setting for the ConsumerGroup
    #   heartbeat_interval: 1_000,
    #   # this setting will be forwarded to the GenConsumer
    #   commit_interval: 1_000
    # ]

    # gen_consumer_impl = ExampleGenConsumer
    # consumer_group_name = "example_group"
    # topic_names = ["example_topic"]

    children = [
      # Starts a worker by calling: Saga.Worker.start_link(arg)
      # {Saga.Worker, arg}
      supervisor(GRPC.Server.Supervisor, [{Saga.Endpoint, 50051}]),
      # supervisor(
      #   KafkaEx.ConsumerGroup,
      #   [gen_consumer_impl, consumer_group_name, topic_names, consumer_group_opts])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Saga.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

