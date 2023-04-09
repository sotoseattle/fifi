defmodule Pff do
  @moduledoc """
  Point on the curve secp256k1,
  defined with coordinates set as finite field elemennts.
  """

  defstruct x: nil, y: nil

  @ec %Ec{a: 0, b: 7}

  defguard is_inf(p) when p.x == nil and p.y == nil

  def g() do
    new(
      0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
      0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
  end

  def n(), do:
    0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

  def inf_point(), do: %Pff{x: nil, y: nil}

  def new(x, y) do
    %Pff{ x: Ff.new(x), y: Ff.new(y) }
    |> Pff.is_on_curve()
  end

  def are_equal(%Pff{} = p, %Pff{} = q), do:
      p.x == q.x and p.y == q.y

  # y^2 == x^3 + x * c.a + c.b
  def is_on_curve(%Pff{x: nil, y: nil} = p), do: p
  def is_on_curve(%Pff{x: x, y: y} = p) do
    left = Ff.exp(y, 2)
    right = Ff.exp(x, 3)
      |> Ff.add(Ff.multiply(x, @ec.a))
      |> Ff.add(@ec.b)
    if left == right, do: p,
    else: raise("Invalid point, not on eliptic curve")
  end

  #############################################################################
  #                                 ADDITION                                  #
  #############################################################################

  def add(p, q) when is_inf(p), do: q
  def add(p, q) when is_inf(q), do: p

  def add(%Pff{y: y} = p, p) when y.n == 0 do
    inf_point()
  end

# When both points coincide in the tangent to the curve
  def add(%Pff{} = p, p) do
    s = p.x
      |> Ff.exp(2)
      |> Ff.multiply(3)
      |> Ff.add(@ec.a)
      |> Ff.divide(Ff.multiply(p.y, 2))
    x = s
      |> Ff.exp(2)
      |> Ff.subs(Ff.multiply(p.x, 2))
    y = p.x
      |> Ff.subs(x)
      |> Ff.multiply(s)
      |> Ff.subs(p.y)
    %Pff{ p | x: x, y: y }
  end

  def add(%Pff{} = p, %Pff{} = q) when p.x == q.x do
      inf_point()
  end

  def add(p, q) do
    s = q.y
      |> Ff.subs(p.y)
      |> Ff.divide(Ff.subs(q.x, p.x))
    x = s
      |> Ff.exp(2)
      |> Ff.subs(p.x)
      |> Ff.subs(q.x)
    y = p.x
      |> Ff.subs(x)
      |> Ff.multiply(s)
      |> Ff.subs(p.y)
    %Pff{ p | x: x, y: y }
  end

  #############################################################################
  #                              BINARY EXPANSION                             #
  #############################################################################

  defp dot_bexp(point_ff, times) do
    Util.bep(
      point_ff,
      inf_point(),
      times,
      Util.rightmost_bit(times),
      &Pff.add(&1, &2))
  end

  #############################################################################
  #                                DOT PRODUCT                                #
  #############################################################################

  def dot(m, %Pff{} = p) when is_integer(m) and m>1, do:
    dot_bexp(p, m)

  def dot(%Pff{} = p, m) when is_integer(m) and m>1, do:
    dot_bexp(p, m)

  #############################################################################
  #                                FORMATING                                  #
  #############################################################################

  defimpl String.Chars, for: Pff do
    def to_string(%Pff{x: nil, y: nil}), do:
      "Infinity point in elliptic curve secp256k1"

    def to_string(p), do:
      "Pff: (#{p.x}, #{p.y}) on curve secp256k1"
  end
end
