defmodule Answer.Authentication do
  @derive [Poison.Encoder]
  defstruct [:user_id, :token, :answer]

  @type t :: %Answer.Authentication{user_id: String.t(), token: String.t(), answer: String.t() }
end

defmodule Answer.Email do
  @derive [Poison.Encoder]
  defstruct [:answer]

  @type t :: %Answer.Email{answer: String.t()}
end

defmodule Answer.Facebook.User do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_pic, :profile]

  @type t :: %Answer.Facebook.User{answer: String.t(), user_pic: String.t(), profile: String.t()}
end

defmodule Answer.Facebook do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_id]

  @type t :: %Answer.Facebook{answer: String.t(), user_id: String.t()}
end

defmodule Answer.Photo.API do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_id, :userpic]

  @type t :: %Answer.Photo.API{answer: String.t(), user_id: String.t(), userpic: String.t()}
end

defmodule Answer.Instagram.User do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_pic, :profile]

  @type t :: %Answer.Instagram.User{answer: String.t(), user_pic: String.t(), profile: String.t()}
end

defmodule Answer.Instagram do
  @derive [Poison.Encoder]
  defstruct [:answer, :user_id]

  @type t :: %Answer.Instagram{answer: String.t(), user_id: String.t()}
end

