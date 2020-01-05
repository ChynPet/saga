defmodule Facebook do

  @spec send_message_sign_up(any, integer) ::
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
    KafkaEx.produce(Kafka.Topics.sign_up_facebook, partition, json)
  end

  @spec send_message_sign_in(any, integer) ::
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
    KafkaEx.produce(Kafka.Topics.sign_in_facebook, partition, json)
  end

  @spec send_message(any, integer) ::
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
    KafkaEx.produce(Kafka.Topics.fetch_userid_facebook, partition, json)
  end

  @spec answer_facebook(integer) :: Answer.Facebook.User.t()
  def answer_facebook(partition) do
    KafkaEx.produce(Kafka.Topics.answer_facebook, partition , "{\"answer\": \"ok\", \"user_pic\": \"qwert\", \"profile\": \"asdf\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_facebook, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Facebook.User{})
    decode
  end

  @spec answer_facebook_id(integer) :: Answer.Facebook.t
  def answer_facebook_id(partition) do
    KafkaEx.produce(Kafka.Topics.facebook_id_answer, partition, "{\"answer\": \"ok\", \"user_id\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.facebook_id_answer, partition)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Facebook{})
    decode
  end
end
