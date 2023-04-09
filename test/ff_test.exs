defmodule FfTest do
  use ExUnit.Case

  test "kk" do
    x = Ff.new(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798)
    assert Ff.exp(x, 2)
  end
end
