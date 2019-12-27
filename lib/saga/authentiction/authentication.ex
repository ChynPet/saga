defmodule Authentication do

  def send_message_authentication(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.authentication_sign_up, partition, json)
  end

  def send_message_sign_in(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.authentication_sign_in, partition, json)
  end

  def answer_sign_in(partition) do
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_in, partition, "{\"user_id\": \"5\", \"token\": \"5\", \"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_authentication_sign_in, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Authentication{})
    decode
  end

  def answer_authentication(partition) do
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_up, partition , "{\"user_id\": \"5\", \"token\": \"5\", \"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_authentication_sign_up, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Authentication{})
    decode
  end

end
