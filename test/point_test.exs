defmodule PointTest do
  use ExUnit.Case
  import Point
  doctest Point

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

  test "addition intersecting points" do
    {a, b} = {5, 7}

    p = new(2, 5, a, b)
    q = new(-1, -1, a, b)
    assert add(p, q) == new(3, -7, a, b)
  end

  test "addition of tangent points (of the same)" do
    {a, b} = {5, 7}

    p = new(-1, -1, a, b)
    assert add(p, p) == new(18, 77, a, b)
  end
end
