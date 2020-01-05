defmodule Instagram do

  @spec send_message_sign_up(%{instagram_token: String.t(), instagram_id: String.t()}, integer) ::
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
  def send_message_sign_up(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.sign_up_instagram, partition, json)
  end

  @spec send_message_sign_in(%{instagram_token: String.t(), instagram_id: String.t()}, integer) ::
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
  def send_message_sign_in(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.sign_in_instagram, partition, json)
  end

  @spec send_message(%{instagram_id: String.t(), user_id: String.t()}, integer) ::
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
    KafkaEx.produce(Kafka.Topics.fetch_userid_instagram, partition, json)
  end

  @spec answer_instagram(integer) :: Answer.Instagram.User.t()
  def answer_instagram(partition) do
    KafkaEx.produce(Kafka.Topics.answer_instagram, partition , "{\"answer\": \"ok\", \"user_pic\": \"qwert\", \"profile\": \"asdf\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_instagram, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Instagram.User{})
    decode
  end

  @spec answer_instagram_id(integer) :: Answer.Instagram.User.t()
  def answer_instagram_id(partition) do
    KafkaEx.produce(Kafka.Topics.instagram_id_answer, partition, "{\"answer\": \"ok\", \"user_id\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.instagram_id_answer, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Instagram{})
    decode
  end
end
