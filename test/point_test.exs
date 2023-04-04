defmodule PointTest do
  use ExUnit.Case
  import Point
  doctest Point

  describe "create new points" do
    test "points on the curve" do
      {a, b} = {5, 7}
      assert new(-1, 1, a, b)
      assert new(-1, -1, a, b)
      assert new(18, 77, a, b)
    end

    test "points not on the curve" do
      {a, b} = {5, 7}

      assert_raise RuntimeError, fn ->
        new(-1, -2, a, b)
        new(2, 4, a, b)
        new(5, 7, a, b)
      end
    end
  end

  describe "addition" do
    test "When both points have the same x, the addition is at infinity" do
      {a, b} = {5, 7}
      p = new(-1, -1, a, b)
      q = new(-1, 1, a, b)
      assert add(p, q) == new(nil, nil, a, b)
    end

    # the normal case of a line formed by 2 points that intersects the EC 3 times
    # the third point is the addition of the other two
    test "addition intersecting points" do
      {a, b} = {5, 7}

      p = new(2, 5, a, b)
      q = new(-1, -1, a, b)
      assert add(p, q) == new(3, -7, a, b)
    end

    test "When a point is at infinitum, the other is the solution" do
      {a, b} = {5, 7}

      p = new(2, 5, a, b)
      q = new(nil, nil, a, b)
      assert add(p, q) == p
      assert add(q, p) == p
    end

    test "When both points coincide in the tangent and form a vertical line" do
      {a, b} = {1, 0}

      p = new(0, 0, a, b)
      assert add(p, p) == %Point{x: nil, y: nil, a: a, b: b}
    end

    test "addition of tangent points (of the same)" do
      {a, b} = {5, 7}

      p = new(-1, -1, a, b)
      assert add(p, p) == new(18, 77, a, b)
    end
  end
end
