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
    status = case Sagas.Email.SignUp.registraion(pid, user) do
      :ok -> case Sagas.Email.SignUp.get_data(pid) do
              {:confirm_email, _} -> case Sagas.Email.SignUp.add_email(pid, user) do
                                      :ok -> case Sagas.Email.SignUp.get_data(pid) do
                                              {:add_token, _} -> case Sagas.Email.SignUp.save_token_device(pid) do
                                                                    :ok -> Sagas.Email.SignUp.get_data(pid)
                                                                 end
                                              _ -> {:error, "Error Confirm Email"}
                                             end
                                     end
              _ -> {:error, "Error Authentication"}
             end
    end
    result = case status do
      {:end_fsm, _} -> ResponseEmail.new(user: [elem(status, 1)], message: "ok")
      _ -> ResponseEmail.new(user: [user], message: elem(status, 1))
    end
    Sagas.Email.SignUp.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end

  def sign_in_email(user, stream) do
    {:ok, pid} = Sagas.Email.SignIn.start_link
    Sagas.Email.SignIn.login(pid, user)
    status = case Sagas.Email.SignIn.get_data(pid) do
      {:save_token} -> Sagas.Email.SignIn.save_device_token(pid, user)
      _ -> {:error, "Error SignIn"}
    end
    result = case status do
      :ok -> ResponseEmail.new(user: [user], message: "ok")
      _ -> ResponseEmail.new(user: [user], message: elem(status, 1))
    end
    Sagas.Email.SignIn.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end

  def sign_up_facebook(user, stream) do
    {:ok, pid} = Sagas.Facebook.SignUp.start_link
    Sagas.Facebook.SignUp.send_in_facebook(pid, user)
    Sagas.Facebook.SignUp.send_in_authentication(pid)
    Sagas.Facebook.SignUp.add_user_id(pid, user)
    Sagas.Facebook.SignUp.send_userpic(pid,user)
    Sagas.Facebook.SignUp.send_token(pid, user)
    user = Sagas.Facebook.SignUp.get_data(pid)

    result = ResponseFacebook.new(user: [elem(user, 1)], message: "ok")
    Sagas.Facebook.SignUp.stop(pid)
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
    Sagas.Instagram.SignUp.stop(pid)
    result = ResponseInstagram.new(user: [elem(user, 1)], message: "ok")
    GRPC.Server.send_reply(stream, result)
  end


  def sign_in_facebook(user, stream) do
    {:ok, pid} = Sagas.Facebook.SignIn.start_link
    Sagas.Facebook.SignIn.mouth(pid, user)
    Sagas.Facebook.SignIn.send_token(pid, user)
    result = ResponseFacebook.new(user: [user], message: "ok")
    GRPC.Server.send_reply(stream, result)
  end
  def sign_in_instagram(user, stream) do
    {:ok, pid} = Sagas.Instagram.SignIn.start_link
    Sagas.Instagram.SignIn.mouth(pid, user)
    Sagas.Instagram.SignIn.send_token(pid, user)
    result = ResponseInstagram.new(user: [user], message: "ok")
    GRPC.Server.send_reply(stream, result)
  end
end
