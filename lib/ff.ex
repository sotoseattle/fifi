defmodule Ff do
  @moduledoc """
  Finite Field Element defined over a specific size set.
  The size of the field is compatible with secp256k1 and
  a prime number so we can use Fermat's Little Theorem.
  """
  import Integer, only: [mod: 2]

  defstruct n: nil

  @field_size 2**256 - 2 **32 - 977

  defp cast(n), do: mod(n, @field_size)

  def new(n), do: %Ff{n: cast(n)}

  def uno(), do: new(1)

  @doc """
  The negative of a finite field element
  """
  def neg(%Ff{} = f1), do: %Ff{f1 | n: cast(-f1.n)}

  #############################################################################
  #                                  ADDITION                                 #
  #############################################################################

  def add(%Ff{} = f1, %Ff{} = f2), do: new(f1.n + f2.n)

  def add(%Ff{} = f1, m) when is_number(m), do: new(f1.n + m)

  def add(m, %Ff{} = f1) when is_number(m), do: add(f1, m)

  def subs(%Ff{} = f1, %Ff{} = f2), do: add(f1, neg(f2))

  #############################################################################
  #                              BINARY EXPANSION                             #
  #############################################################################

  # Binary expansion of iterative product of a finite field element
  def exp_bexp(f1, exponent) do
    Util.bep(
      f1,
      Ff.uno(),
      exponent,
      Util.rightmost_bit(exponent),
      &Ff.multiply(&1, &2))
  end

  #############################################################################
  #                             MULTIPLICATION OPS                            #
  #############################################################################

  def multiply(n, %Ff{} = f1) when is_integer(n), do: new(n * f1.n)

  def multiply(%Ff{} = f1, n) when is_integer(n), do: multiply(n, f1)

  def multiply(%Ff{} = f1, %Ff{} = f2), do: new(f1.n * f2.n)

  def inverse(%Ff{} = f1), do: Ff.exp(f1, @field_size - 2)

  def exp(%Ff{}, 0), do: Ff.uno()

  def exp(%Ff{} = f1, m) when is_integer(m) and m>0, do: Ff.exp_bexp(f1, m)

  def exp(%Ff{} = f1, m) when is_integer(m) and m<0 do
    Ff.exp_bexp(f1, @field_size - 1 + m)
  end

  def divide(%Ff{} = f1, %Ff{} = f2), do: f2 |> inverse() |> multiply(f1)

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
