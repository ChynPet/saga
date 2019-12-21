use Mix.Config

config :kafka_ex,
  brokers: [
    {"localhost", 9092},
  ],

  consumer_group: "kafka_ex",
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  commit_interval: 5_000,
  commit_threshold: 100,
  use_ssl: false,

  kafka_version: "0.10.1"

env_config = Path.expand("#{Mix.env()}.exs", __DIR__)

if File.exists?(env_config) do
  import_config(env_config)

config :grpc, start_server: true
end
