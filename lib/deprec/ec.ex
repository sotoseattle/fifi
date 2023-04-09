defmodule Ec do
  alias Point
  alias Fifi

  defstruct a: nil, b: nil

  def new(a, b) do
    %Ec{a: a, b: b}
  end

  def is_on_curve(%Point{x: nil, y: nil} = p), do: p
  def is_on_curve(%Point{x: x, y: y, ec: c} = p) do
    if (y**2 == x**3 + c.a*x + c.b), do: p,
    else: raise("Invalid point, not on eliptic curve")
  end

  def is_on_curve(%Pointff{ x: %Fifi{n: nil}, y: %Fifi{n: nil}} = p), do: p
  def is_on_curve(%Pointff{x: x, y: y, ec: c} = p) do
    left = Fifi.exp(y, 2)
    right = Fifi.exp(x, 3)
      |> Fifi.add(Fifi.multiply(x, c.a))
      |> Fifi.add(c.b)
    # y^2 == x^3 + x * c.a + c.b
    if left == right, do: p,
    else: raise("Invalid point, not on eliptic curve")
  end

  defimpl String.Chars, for: Ec do
    def to_string(ec), do:
      "Elliptic Curve: (#{ec.a}, #{ec.b})"
  end
end
