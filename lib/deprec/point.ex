defmodule Point do
  defstruct x: nil, y: nil, ec: nil

  defguard is_inf(p) when p.x == nil and p.y == nil

  defguard on_same_curve(p, q) when p.ec == q.ec

  def new(x, y, %Ec{} = ec), do:
    %Point{x: x, y: y, ec: ec} |> Ec.on_curve()

  def are_equal(%Point{} = p, %Point{} = q) when on_same_curve(p, q), do:
    p.x == q.x and p.y == q.y

  def add(p, q) when is_inf(p), do: q
  def add(p, q) when is_inf(q), do: p

  def add(%Point{y: 0} = p, p), do: %Point{p | x: nil, y: nil}

  # When both points coincide in the tangent to the curve
  def add(%Point{} = p, p) do
    s = ((3 * p.x * p.x) + p.ec.a) / (2 * p.y)
    x = (s * s) - (2 * p.x)
    y = s * (p.x - x) - p.y
    new(x, y, p.ec)
  end

  def add(%Point{} = p, %Point{} = q)
    when on_same_curve(p, q) and p.x == q.x do
      Point.new(nil, nil, p.ec)
  end

  def add(p, q) when on_same_curve(p, q) do
    s = (q.y - p.y) / (q.x - p.x)
    x = (s * s) - p.x - q.x
    y = (s * (p.x - x)) - p.y
    new(x, y, p.ec)
  end
end
