defmodule PointTest do
  use ExUnit.Case
  import Point
  doctest Point

  setup_all do
    %{ec: %Ec{a: 5, b: 7}}
  end

  describe "create new points" do
    test "points on the curve", %{ec: ec} do
      assert Point.new(-1, 1, ec)
      assert Point.new(-1, -1, ec)
      assert Point.new(18, 77, ec)
    end

    test "points not on the curve", %{ec: ec} do
      assert_raise RuntimeError, fn ->
        Point.new(-1, -2, ec)
        Point.new(2, 4, ec)
        Point.new(5, 7, ec)
      end
    end
  end

  describe "addition" do
    test "When both points have the same x, the addition is at infinity", %{ec: ec} do
      p = Point.new(-1, -1, ec)
      q = Point.new(-1, 1, ec)
      assert add(p, q) == new(nil, nil, ec)
    end

    # the normal case of a line formed by 2 points that intersects the EC 3 times
    # the third point is the addition of the other two
    test "addition intersecting points", %{ec: ec} do
      p = Point.new(2, 5, ec)
      q = Point.new(-1, -1, ec)
      assert add(p, q) == new(3, -7, ec)
    end

    test "When a point is at infinitum, the other is the solution", %{ec: ec} do
      p = Point.new(2, 5, ec)
      q = Point.new(nil, nil, ec)
      assert add(p, q) == p
      assert add(q, p) == p
    end

    test "When both points coincide in the tangent forming a vertical line" do
      nc = Ec.new(1, 0)
      p = Point.new(0, 0, nc)
      assert add(p, p) == %Point{x: nil, y: nil, ec: nc}
    end

    test "addition of tangent points (of the same)", %{ec: ec} do
      p = Point.new(-1, -1, ec)
      assert add(p, p) == Point.new(18, 77, ec)
    end
  end
end
