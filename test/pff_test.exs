defmodule PffTest do
  use ExUnit.Case
  import Pff


  describe "Secp256k1 as defined is correct" do
    test "the g point is on the Secp256k1 curve" do
      assert Pff.is_on_curve(g()) == g()
    end

    test "n times g is the infinite point" do
      assert dot(g(), n()) == inf_point()
    end
  end
end
