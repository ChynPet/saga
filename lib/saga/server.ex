defmodule Saga.Server do

  alias Saga.Api.{
    User,
    ResponseEmail,
    ResponseFacebook,
    ResponseInstagram,
    InitialState
  }

  use GRPC.Server, service: InitialState.Service

  @spec sign_up_email(Saga.Api.User.t, GRPC.Server.Stream.t) :: Saga.Api.Response.t
  def sign_up_email(user, stream) do
    {:ok, pid} = Sagas.Email.SignUp.start_link
    Sagas.Email.SignUp.send_email(pid, user)
    Email.Answer.answer_authentication(pid)
    Sagas.Email.SignUp.confirm_email(pid, user)
    Email.Answer.answer_email(pid)
    Sagas.Email.SignUp.send_token(pid, "aaaa")
    user = Sagas.Email.SignUp.get_data(pid)
    Sagas.Email.SignUp.stop(pid)
    result = ResponseEmail.new(user: [elem(elem(user, 1),0)], res: true)
    GRPC.Server.send_reply(stream, result)
  end

  @spec sign_up_email(Saga.Api.UserFacebook.t, GRPC.Server.Stream.t) :: Saga.Api.Response.t
  def sign_up_facebook(user, stream) do
    {:ok, pid} = Sagas.Facebook.SignUp.start_link
    Sagas.Facebook.SignUp.send_in_facebook(pid, user)
    Sagas.Facebook.SignUp.send_in_authentication(pid)
    Sagas.Facebook.SignUp.add_user_id(pid, user)
    Sagas.Facebook.SignUp.send_userpic(pid,user)
    Sagas.Facebook.SignUp.send_token(pid, user)
    user = Sagas.Facebook.SignUp.get_data(pid)
    result = ResponseFacebook.new(user: [elem(user, 1)], res: true)
    GRPC.Server.send_reply(stream, result)
  end

  def sign_up_instagram(user, stream) do
    {:ok, pid} = Sagas.Instagram.SignUp.start_link
    Sagas.Instagram.SignUp.send_in_instagram(pid, user)
    Sagas.Instagram.SignUp.send_in_authentication(pid)
    Sagas.Instagram.SignUp.add_user_id(pid, user)
    Sagas.Instagram.SignUp.send_userpic(pid,user)
    Sagas.Instagram.SignUp.send_token(pid, user)
    user = Sagas.Instagram.SignUp.get_data (pid)
    result = ResponseInstagram.new(user: [elem(user, 1)], res: true)
    GRPC.Server.send_reply(stream, result)
  end

end
