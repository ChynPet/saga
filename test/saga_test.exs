defmodule SagasTest do
  use ExUnit.Case

  require Logger

  test "Email SignUp SingIn" do
    user = Saga.Api.User.new(email: "chynnyk@vivaldi.net", password: "2222")
    KafkaEx.produce(Kafka.Topics.answer_authentication_sign_in, 0 , "{\"user_id\": \"1\", \"token\": \"5\", \"answer\": \"ok\"}")
    res =  User.sign_up_email(user)
    [h | t] = res
    [b | e] = h.user
    assert b.email == "chynnyk@vivaldi.net"
    assert b.token == "5"
  end

  test "Facebook SignUp SignIn" do
    user = Saga.Api.UserFacebook.new(user_idfacebook: "5", password: "2222")
    KafkaEx.produce(Kafka.Topics.answer_facebook, 0 , "{\"user_id\": \"1\", \"user_pic\": \"5\", \"token\": \"5\"}")
    KafkaEx.produce(Kafka.Topics.authentication_token_create, 0 , "{\"user_id\": \"1\", \"facebook_userid\": \"5\", \"token\": \"5\"}")
    res =  User.sign_up_facebook(user)
    [h | t] = res
    [b | e] = h.user
    assert b.token == "aa"
    assert b.token_facebook == "5"
  end

  test "Instagram SignUp SignIn" do
    user = Saga.Api.UserInstagram.new(user_idinstagram: "5", password: "2222")
    KafkaEx.produce(Kafka.Topics.answer_instagram, 0 , "{\"user_id\": \"1\", \"user_pic\": \"5\", \"token\": \"5\"}")
    KafkaEx.produce(Kafka.Topics.authentication_token_create, 0 , "{\"user_id\": \"1\", \"instagram_userid\": \"5\", \"token\": \"aa\"}")
    res =  User.sign_up_instagram(user)
    [h | t] = res
    [b | e] = h.user
    assert b.token == "aa"
    assert b.token_instagram == "5"
  end

end
