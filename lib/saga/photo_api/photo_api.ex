defmodule Photo.API do

  @spec send_message(%{user_id: String.t(), userpic: String.t()}, integer) ::
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
  def send_message(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.photo_api, partition, json)
  end

  @spec answer(integer) :: Answer.Photo.API.t()
  def answer(partition) do
    KafkaEx.produce(Kafka.Topics.answer_photo_api, partition, "{\"answer\": \"ok\", \"user_id\": \"4\", \"userpic\": \"25\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_photo_api, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Photo.API{})
    decode
  end

end
