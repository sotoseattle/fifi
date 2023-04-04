defmodule Point do
  defstruct x: nil, y: nil, a: nil, b: nil

  defguard is_inf(p) when p.x == nil and p.y == nil

  defguard on_same_curve(p, q) when p.a == q.a and p.b == q.b

  defp is_on_curve(p) when is_inf(p), do: p
  defp is_on_curve(p) do
    if (p.y**2 == p.x**3 + p.a*p.x + p.b), do: p,
    else: raise("Invalid point, not on eliptic curve")
  end

  def new(x, y, a, b) do
    %Point{x: x, y: y, a: a, b: b}
      |> is_on_curve()
  end

  def are_equal(%Point{} = p, %Point{} = q) when on_same_curve(p, q) do
    p.x == q.x and p.y == q.y
  end

  # When a point is at infinitum, the other is the solution
  def add(p, q) when is_inf(p), do: q
  def add(p, q) when is_inf(q), do: p

  # When both points coincide in the tangent and form a vertical line
  def add(%Point{y: 0} = p, p), do: %Point{p | x: nil, y: nil}

  # When both points coincide in the tangent to the curve
  def add(%Point{} = p, p) do
    s = ((3 * p.x * p.x) + p.a) / (2 * p.y)
    x = (s * s) - (2 * p.x)
    y = s * (p.x - x) - p.y
    new(x, y, p.a, p.b)
  end

  # When both points have the same x, the addition is at infinitum
  def add(%Point{} = p, %Point{} = q)
    when on_same_curve(p, q) and p.x == q.x do
      Point.new(nil, nil, p.a, p.b)
  end

  # the normal case of a line formed by 2 points that intersects the EC 3 times
  # the third point is the addition of the other two
  def add(p, q) when on_same_curve(p, q) do
    s = (q.y - p.y) / (q.x - p.x)
    x = (s*s) - p.x - q.x
    y = (s * (p.x - x)) - p.y
    new(x, y, p.a, p.b)
  end
end
