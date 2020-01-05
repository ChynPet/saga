defmodule Authentication do
  @moduledoc"""
  This module is designed to talk to the Authentication Microservice via Kafka Messenger
  """

  @doc"""
  This module has the following features:
      send_message_authentication_sign_up(message, partition) - sending a message to authentication microservice by user registration theme
      send_message_sign_in(message, partition) - sending a message to authentication microservice by user login theme
      send_message(message, partition) - sending a message to authentication microservice for user which login or registration through Facebook or Instagram
      answer_sign_in(partition) - the function for getting answer from the Authentication Microservice by login theme
      answer_authentication_sign_up(partition) - the function for getting answer from the Authentication Microservice by registration theme
      answer_authentication(partition) - the function for getting answer from the Authentication Microservice by login or registration theme through Facebook or Instagram
  """
  @spec send_message_authentication_sign_up(%{email: String.t(), password: String.t()}, integer) ::
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
  def send_message_authentication_sign_up(message, partition) do
    json = Poison.encode!(message)
    KafkaEx.produce(Kafka.Topics.authentication_sign_up, partition, json)
  end

  @spec send_message_sign_in(%{email: String.t(), password: String.t()}, integer) ::
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
    KafkaEx.produce(Kafka.Topics.authentication_sign_in, partition, json)
  end

  @spec send_message(%{user_id_facebook: String.t()} | %{user_id_instagram: String.t()}, integer) ::
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
    KafkaEx.produce(Kafka.Topics.authentication_token_create, partition, json)
  end

  @spec answer_sign_in(integer) :: Answer.Authentication.t()
  def answer_sign_in(partition) do
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_in, partition, "{\"user_id\": \"5\", \"token\": \"5\", \"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_authentication_sign_in, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Authentication{})
    decode
  end

  @spec answer_authentication_sign_up(integer) :: Answer.Authentication.t()
  def answer_authentication_sign_up(partition) do
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_up, partition , "{\"user_id\": \"5\", \"token\": \"5\", \"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_authentication_sign_up, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Authentication{})
    decode
  end

  @spec answer_authentication(integer) :: Answer.Authentication.t()
  def answer_authentication(partition) do
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_up, partition , "{\"user_id\": \"5\", \"token\": \"5\", \"answer\": \"ok\"}")
    message = KafkaEx.fetch(Kafka.Topics.answer_authentication_sign_up, partition)
    answer = List.to_tuple(List.first(List.first(message).partitions).message_set)
    value = elem(answer, 0).value
    decode = Poison.decode!(value, as: %Answer.Authentication{})
    decode
  end

end
