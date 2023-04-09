defmodule Pointff do

  defstruct x: nil, y: nil, ec: nil

  defguard is_inf(p) when p.x == nil and p.y == nil

  defguard on_same_curve(p, q) when p.ec == q.ec

  def inf_point(ec) do
    %Pointff{x: nil, y: nil, ec: ec}
  end

  def new(x, y, k, %Ec{} = ec) do
    %Pointff{
      x: Fifi.new(x, k),
      y: Fifi.new(y, k),
      ec: ec}
    |> Ec.is_on_curve()
  end

  def are_equal(%Pointff{} = p, %Pointff{} = q)
    when on_same_curve(p, q), do:
      p.x == q.x and p.y == q.y

  #############################################################################
  #                                 ADDITION                                  #
  #############################################################################

  def add(p, q) when is_inf(p), do: q
  def add(p, q) when is_inf(q), do: p

  def add(%Pointff{y: y} = p, p) when y.n == 0 do
    inf_point(p.ec)
  end

# When both points coincide in the tangent to the curve
  def add(%Pointff{} = p, p) do
    s = p.x
      |> Fifi.exp(2)
      |> Fifi.multiply(3)
      |> Fifi.add(p.ec.a)
      |> Fifi.divide(Fifi.multiply(p.y, 2))
    x = s
      |> Fifi.exp(2)
      |> Fifi.subs(Fifi.multiply(p.x, 2))
    y = p.x
      |> Fifi.subs(x)
      |> Fifi.multiply(s)
      |> Fifi.subs(p.y)
    %Pointff{ p | x: x, y: y }
  end

  def add(%Pointff{} = p, %Pointff{} = q)
    when on_same_curve(p, q) and p.x == q.x do
      inf_point(p.ec)
  end

  def add(p, q) when on_same_curve(p, q) do
    s = q.y
      |> Fifi.subs(p.y)
      |> Fifi.divide(Fifi.subs(q.x, p.x))
    x = s
      |> Fifi.exp(2)
      |> Fifi.subs(p.x)
      |> Fifi.subs(q.x)
    y = p.x
      |> Fifi.subs(x)
      |> Fifi.multiply(s)
      |> Fifi.subs(p.y)
    %Pointff{ p | x: x, y: y }
  end

  #############################################################################
  #                              BINARY EXPANSION                             #
  #############################################################################

  defp dot_bep(pointff, times) do
    Util.bep(
      pointff,
      inf_point(pointff.ec),
      times,
      Util.rightmost_bit(times),
      &Pointff.add(&1, &2))
  end

  #############################################################################
  #                                DOT PRODUCT                                #
  #############################################################################

  def dot(m, %Pointff{} = p) when is_integer(m) and m>1, do:
    dot_bep(p, m)

  def dot(%Pointff{} = p, m) when is_integer(m) and m>1, do:
    dot_bep(p, m)

  #############################################################################
  #                                FORMATING                                  #
  #############################################################################

  defimpl String.Chars, for: Pointff do
    def to_string(%Pointff{x: nil, y: nil} = p), do:
      "Infinity point in elliptic curve #{p.ec}"

    def to_string(p), do:
      "Pointff: (#{p.x}, #{p.y}) on field: #{p.x.k} & ec: #{p.ec}"
  end
end
