defmodule PointffTest do
  use ExUnit.Case
  import Pointff

  setup_all do
    %{k: 223, ec: %Ec{a: 0, b: 7}}
  end

  describe "Check point made of fifis are on an ec" do
    test "a point is created if it is on the curve", %{k: k, ec: ec} do
      assert new(17, 64, 103, ec)
      assert new(192, 105, k, ec)
      assert new(17, 56, k, ec)
      assert new(1, 193, k, ec)
    end

    test "if a new point is not on curve it raises error", %{k: k, ec: ec} do
      assert_raise RuntimeError, fn ->
        new(200, 119, k, ec)
        new(42, 99, k, ec)
      end
    end
  end

  describe "Addition of points on ec on finite field" do
    test "basic addition", %{k: k, ec: ec} do
      p1 = new(170, 142, k, ec)
      q1 = new(60, 139, k, ec)
      assert add(p1, q1) == new(220, 181, k, ec)

      p2 = new(47, 71, k, ec)
      q2 = new(17, 56, k, ec)
      assert add(p2, q2) == new(215, 68, k, ec)

      p3 = new(143, 98, k, ec)
      q3 = new(76, 66, k, ec)
      assert add(p3, q3) == new(47, 71, k, ec)
    end
  end

  describe "scalar multiplication" do
    test "basic dot ops", %{k: k, ec: ec} do
      p = new(192, 105, k, ec)
      assert dot(p, 2) == new(49, 71, k, ec)

      p = new(143, 98, k, ec)
      assert dot(p, 2) == new(64, 168, k, ec)

      p = new(47, 71, k, ec)
      assert dot(p, 2) == new(36, 111, k, ec)

      assert dot(p, 4) == new(194, 51, k, ec)

      assert dot(p, 8) == new(116, 55, k, ec)

      assert dot(p, 21) == inf_point(ec)

      p = new(15, 86, k, ec)
      assert dot(p, 7) == inf_point(ec)
    end

    test "find G with brute approach", %{k: k, ec: ec} do
      assert compute_G(new(15, 86, k, ec)) == 7
    end
  end

end
