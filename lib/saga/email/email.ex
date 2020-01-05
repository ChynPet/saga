defmodule Email do
  @moduledoc"""
  This module is designed to talk to the Email Microservice via Kafka Messenger
  """
  @doc"""
  This module has the following features:
      send_message_email(messagem patition) - the function to send email to the email microservice
      answer_email(partition) - the function to get response from the Email microservice
  """

  @spec send_message_email(%{email: String.t(), user_id: String.t()}, integer) ::
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
  def send_message_email(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.confirm_email, partition, json)
  end

  @spec answer_email(integer) :: Answer.Email.t()
  def answer_email(partition) do
    KafkaEx.produce(Kafka.Topics.answer_email, partition , "{\"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_email, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Email{})
    decode
  end

end
