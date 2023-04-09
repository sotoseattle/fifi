defmodule UtilTest do
  use ExUnit.Case

  describe "An integer expressed in binary bits" do
    test "has a 0 rightmost bit" do
      assert Util.rightmost_bit(0) == 0
      assert Util.rightmost_bit(10) == 0
      assert Util.rightmost_bit(2) == 0
    end
    test "has a 1 rightmost bit" do
      assert Util.rightmost_bit(11) == 1
      assert Util.rightmost_bit(199) == 1
      assert Util.rightmost_bit(3) == 1
    end
  end


end
