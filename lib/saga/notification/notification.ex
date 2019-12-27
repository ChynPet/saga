defmodule Notification do
  def send_message_notification(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.save_device_token, partition, json)
  end
end
