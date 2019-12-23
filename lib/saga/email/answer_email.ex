defmodule Email.Answer do
  def answer_authentication(pid) do
    KafkaEx.produce(Kafka.Topics.authentication_token_create, 0 , "{\"userid\": \"5\", \"access_token\": \"5\"}")
    res = KafkaEx.fetch(Kafka.Topics.authentication_token_create, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_authentication(pid)
      size >= 1 -> answer_authentication(pid, answer)
    end
  end

  def answer_authentication(pid, answer) do
    value = elem(answer, 0)
    Sagas.Email.SignUp.email_add(pid, value)
  end

  def answer_email(pid) do
    KafkaEx.produce(Kafka.Topics.answer_email, 0 , "{\"answer\": \"ok\"}")
    res = KafkaEx.fetch(Kafka.Topics.answer_email, 0)
    answer = List.to_tuple(List.first(List.first(res).partitions).message_set)
    size = tuple_size(answer)
    cond do
      size == 0 -> answer_email(pid)
      size >= 1 -> answer_email(pid, answer)
    end
  end

  def answer_email(pid, answer) do
    value = elem(answer, 0)
    Sagas.Email.SignUp.email_confirmed(pid, value)
  end
end
