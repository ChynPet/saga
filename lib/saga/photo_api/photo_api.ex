defmodule Photo.API do

  def send_message(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.photo_api, partition, json)
  end

  def answer(partition) do
    KafkaEx.produce(Kafka.Topics.answer_photo_api, partition, "{\"user_id\": \"4\", \"userpic\": \"25\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_photo_api, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Photo.API{})
    decode
  end

end
