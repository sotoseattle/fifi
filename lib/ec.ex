defmodule Ec do
  alias Point

  defstruct a: nil, b: nil

  def new(a, b) do
    %Ec{a: a, b: b}
  end

  def is_on_curve(%Point{x: nil, y: nil} = p), do: p
  def is_on_curve(%Point{x: x, y: y, ec: c} = p) do
    if (y**2 == x**3 + c.a*x + c.b), do: p,
    else: raise("Invalid point, not on eliptic curve")
  end
end
