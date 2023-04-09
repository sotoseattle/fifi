defmodule Ff do
  @moduledoc """
  Finite Field Element defined over a specific size set,
  compatible with secp256k1.
  Size is a prime number so we can use Fermat's Little Theorem.
  """

  import Integer, only: [mod: 2]

  defstruct n: nil

  @field_size 2**256 - 2 **32 - 977

  defp cast(n), do: mod(n, @field_size)

  def new(n), do: %Ff{n: cast(n)}

  def uno(), do: new(1)

  def neg(%Ff{} = f), do: %Ff{f | n: cast(-f.n)}

  #############################################################################
  #                                  ADDITION                                 #
  #############################################################################

  def add(%Ff{} = fa, %Ff{} = fo), do:
    new(fa.n + fo.n)

  def add(%Ff{} = fa, m) when is_number(m), do:
    new(fa.n + m)

  def add(m, %Ff{} = fa) when is_number(m), do:
    new(fa.n + m)

  def subs(%Ff{} = fa, %Ff{} = fo), do:
    add(fa, neg(fo))

  #############################################################################
  #                              BINARY EXPANSION                             #
  #############################################################################

  def exp_bexp(fi, exponent) do
    Util.bep(
      fi,
      Ff.uno(),
      exponent,
      Util.rightmost_bit(exponent),
      &Ff.multiply(&1, &2))
  end

  #############################################################################
  #                             MULTIPLICATION OPS                            #
  #############################################################################

  def multiply(n, %Ff{} = fi) when is_integer(n), do: new(n * fi.n)

  def multiply(%Ff{} = fi, n) when is_integer(n), do: new(n * fi.n)

  def multiply(%Ff{} = fa, %Ff{} = fo), do: new(fa.n * fo.n)

  def inverse(%Ff{} = fi), do: Ff.exp(fi, @field_size-2)

  def exp(%Ff{}, 0), do: Ff.uno()

  def exp(%Ff{} = fa, m) when is_integer(m) and m>0, do:
    Ff.exp_bexp(fa, m)

  def exp(%Ff{} = fa, m) when is_integer(m) and m<0 do
    exponent = @field_size - 1 + m
    Ff.exp_bexp(fa, exponent)
  end

  def exp(_, _), do: raise("Error: invalid input")

  def divide(%Ff{} = fa, %Ff{} = fo) do
    fo
      |> inverse()
      |> multiply(fa)
  end

  #############################################################################
  #                                FORMATING                                  #
  #############################################################################
  defimpl Inspect, for: Ff do
    def inspect(fi, _opts) do
      """
      Finite Field Element:
        Number: #{fi.n}
        Field Size: 2**256 - 2 **32 - 977
      """
    end
  end

  defimpl String.Chars, for: Ff do
    def to_string(fi), do: "Ff: #{fi.n} on field k: 2**256 - 2 **32 - 977}"
  end
end
