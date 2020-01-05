defmodule Notification do

  @spec send_message_notification(%{token: String.t(), user_id: String.t()}, integer) ::
          :leader_not_available
          | nil
          | :ok
          | binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            )
          | {:error, any}
          | {:ok, integer}
  def send_message_notification(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.save_device_token, partition, json)
  end
end
