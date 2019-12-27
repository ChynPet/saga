defmodule Answer.Authentication do
  @derive [Poison.Encoder]
  defstruct [:user_id, :token, :answer]
end

defmodule Answer.Email do
  @derive [Poison.Encoder]
  defstruct [:answer]
end

