defmodule Secp256k1Test do
  use ExUnit.Case

  setup_all do
    Secp256k1.initialize()
  end


  describe "Secp256k1 as defined is correct" do
    test "the g point is on the Secp256k1 curve", %{g: g} do
      assert Ec.is_on_curve(g) == g
    end

    test "n times g is the infinite point", %{g: g, n: n, ec: ec} do
      assert Pointff.dot(g, n) == Pointff.inf_point(ec)
    end

  end
end
