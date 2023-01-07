defmodule BasicServerTest do
  use ExUnit.Case
  doctest TcpEcho

  test "greets the world" do
    assert TcpEcho.hello() == :world
  end
end
