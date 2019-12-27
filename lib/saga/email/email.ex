defmodule Email do

  def send_message_email(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.confirm_email, partition, json)
  end

  def answer_email(partition) do
    KafkaEx.produce(Kafka.Topics.answer_email, partition , "{\"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_email, 0)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Email{})
    decode
  end

end
