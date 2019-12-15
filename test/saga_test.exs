defmodule SagaTest do
  use ExUnit.Case
  doctest Saga

  test "greets the world" do
    assert Saga.hello() == :world
  end
end
