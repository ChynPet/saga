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
    children = [
      # Starts a worker by calling: Saga.Worker.start_link(arg)
      # {Saga.Worker, arg}
      supervisor(GRPC.Server.Supervisor, [{Saga.Endpoint, 50051}])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Saga.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
