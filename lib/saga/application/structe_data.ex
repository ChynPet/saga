defmodule Answer.Authentication do
  @derive [Poison.Encoder]
  defstruct [:user_id, :token, :answer]
end

defmodule Answer.Email do
  @derive [Poison.Encoder]
  defstruct [:answer]
end

defmodule Answer.Facebook.User do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_pic, :profile]
end

defmodule Answer.Facebook do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_id]
end

defmodule Answer.Photo.API do
  @derive [Poison.Encoder]
  defstruct [:user_id, :userpic]
end

defmodule Answer.Instagram.User do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_pic, :profile]
end

defmodule Answer.Instagram do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_id]
end

