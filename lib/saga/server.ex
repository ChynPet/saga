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
    status = case Sagas.Facebook.SignUp.send_in_facebook(pid, user) do
      :ok -> case Sagas.Facebook.SignUp.get_data(pid) do
              {:creating_token, _} -> case Sagas.Facebook.SignUp.send_in_authentication(pid, user) do
                                        :ok -> case Sagas.Facebook.SignUp.get_data(pid) do
                                                  {:addition_userid, _} -> case Sagas.Facebook.SignUp.add_user_id(pid) do
                                                                            :ok -> case Sagas.Facebook.SignUp.get_data(pid) do
                                                                                    {:add_userpic, _} -> case Sagas.Facebook.SignUp.send_userpic(pid) do
                                                                                                          :ok -> case Sagas.Facebook.SignUp.get_data(pid) do
                                                                                                                  {:save_token, _} -> case Sagas.Facebook.SignUp.send_token(pid) do
                                                                                                                                          :ok -> Sagas.Facebook.SignUp.get_data(pid)
                                                                                                                                         end
                                                                                                                  _ -> {:error, "Error add userpic"}
                                                                                                                 end
                                                                                                         end
                                                                                    _ -> {:error, "Error addition userid"}
                                                                                   end
                                                                            end
                                                  _ -> {:error, "Error Authentication"}
                                               end
                                       end
              _ -> {:error, "Error Facebook Microservice"}
             end
    end

    result = case status do
      {:end_fsm, _} -> ResponseFacebook.new(user: [elem(status, 1)], message: "ok")
      _ -> ResponseFacebook.new(user: [user], message: elem(status,1))
    end

    Sagas.Facebook.SignUp.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end

  def sign_in_facebook(user, stream) do
    {:ok, pid} = Sagas.Facebook.SignIn.start_link
    status = case Sagas.Facebook.SignIn.login(pid, user) do
      :ok -> case Sagas.Facebook.SignIn.get_data(pid) do
              {:authentication, _} -> case Sagas.Facebook.SignIn.create_token(pid, user) do
                                        :ok -> case Sagas.Facebook.SignIn.get_data(pid) do
                                                {:save_token, _} -> case Sagas.Facebook.SignIn.save_token_notification(pid, user) do
                                                                      :ok -> Sagas.Facebook.SignIn.get_data(pid)
                                                                    end
                                                _ -> {:error, "Error authentication"}
                                               end
                                       end
              _ -> {:error, "Error in Facebook token"}
             end
    end

    result = case status do
      {:end_fsm} -> ResponseFacebook.new(user: [user], message: "ok")
      _ -> ResponseFacebook.new(user: [user], message: elem(status, 1))
    end
    Sagas.Facebook.SignIn.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end

  def sign_up_instagram(user, stream) do
    {:ok, pid} = Sagas.Instagram.SignUp.start_link
    status = case Sagas.Instagram.SignUp.send_in_instagram(pid, user) do
      :ok -> case Sagas.Instagram.SignUp.get_data(pid) do
              {:creating_token, _} -> case Sagas.Instagram.SignUp.send_in_authentication(pid, user) do
                                        :ok -> case Sagas.Instagram.SignUp.get_data(pid) do
                                                  {:addition_userid, _} -> case Sagas.Instagram.SignUp.add_user_id(pid) do
                                                                            :ok -> case Sagas.Instagram.SignUp.get_data(pid) do
                                                                                    {:add_userpic, _} -> case Sagas.Instagram.SignUp.send_userpic(pid) do
                                                                                                          :ok -> case Sagas.Instagram.SignUp.get_data(pid) do
                                                                                                                  {:save_token, _} -> case Sagas.Instagram.SignUp.send_token(pid) do
                                                                                                                                          :ok -> Sagas.Instagram.SignUp.get_data(pid)
                                                                                                                                         end
                                                                                                                  _ -> {:error, "Error add userpic"}
                                                                                                                 end
                                                                                                         end
                                                                                    _ -> {:error, "Error addition userid"}
                                                                                   end
                                                                            end
                                                  _ -> {:error, "Error Authentication"}
                                               end
                                       end
              _ -> {:error, "Error Instagram Microservice"}
             end
    end

    result = case status do
      {:end_fsm, _} -> ResponseInstagram.new(user: [elem(status, 1)], message: "ok")
      _ -> ResponseInstagram.new(user: [user], message: elem(status,1))
    end
    Sagas.Instagram.SignUp.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end



  def sign_in_instagram(user, stream) do
    {:ok, pid} = Sagas.Instagram.SignIn.start_link
    status = case Sagas.Instagram.SignIn.login(pid, user) do
      :ok -> case Sagas.Instagram.SignIn.get_data(pid) do
              {:authentication, _} -> case Sagas.Instagram.SignIn.create_token(pid, user) do
                                        :ok -> case Sagas.Instagram.SignIn.get_data(pid) do
                                                {:save_token, _} -> case Sagas.Instagram.SignIn.save_token_notification(pid, user) do
                                                                      :ok -> Sagas.Instagram.SignIn.get_data(pid)
                                                                    end
                                                _ -> {:error, "Error authentication"}
                                               end
                                       end
              _ -> {:error, "Error in Instagram token"}
             end
    end

    result = case status do
      {:end_fsm} -> ResponseInstagram.new(user: [user], message: "ok")
      _ -> ResponseInstagram.new(user: [user], message: elem(status, 1))
    end

    Sagas.Instagram.SignIn.stop(pid)
    GRPC.Server.send_reply(stream, result)
  end
end
