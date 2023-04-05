defmodule Pointff do
  import Bitwise

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
  #                    DOT PRODUCT USING BINARY EXPANSION                     #
  #############################################################################

  defp rightmost_bit(int), do: int |> Integer.digits(2) |> List.last()

  def dot(%Pointff{} = p, m) when is_integer(m) and m>1 do
    dot(p, inf_point(p.ec), m, rightmost_bit(m))
  end

  defp dot(_, acc, 0, _), do: acc

  defp dot(p, acc, m, 0) when m>0 do
    m = m >>> 1
    dot(add(p, p), acc, m, rightmost_bit(m))
  end

  defp dot(p, acc, m, 1) when m>0 do
    m = m >>> 1
    dot(add(p, p), Pointff.add(acc, p), m, rightmost_bit(m))
  end

  def compute_G(%Pointff{} = p) do
    inf = Pointff.inf_point(p.ec)

    Enum.reduce_while(1..100, p, fn x, acc ->
      if acc == inf, do: {:halt, x},
      else: {:cont, Pointff.add(acc, p)}
    end)
  end


  #############################################################################
  #                                FORMATING T                                #
  #############################################################################

  defimpl String.Chars, for: Pointff do
    def to_string(%Pointff{x: nil, y: nil} = p), do:
      "Infinity point in elliptic curve #{p.ec}"

    def to_string(p), do:
      "Pointff: (#{p.x}, #{p.y}) on field: #{p.x.k} & ec: #{p.ec}"
  end
end
