defmodule FfTest do
  use ExUnit.Case

  test "exponentiation works!" do
    fi =
    0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
      |> Ff.new()
      |> Ff.exp(2)

    assert is_integer(fi.n)
  end
end
