defmodule Fifi do
  import Integer, only: [mod: 2]

  defstruct n: nil, k: nil

  defp validate_n({n, k}) when is_integer(n) and n>=0, do: {n, k}
  defp validate_n(_), do: raise("invalid integer")

  defp validate_k({n, k}) when is_integer(k) and k>0, do: {n, k}
  defp validate_k(_), do: raise("invalid prime")

  defp validate_closed({n, k}) when n<k, do: {n, k}
  defp validate_closed({n, k}) when n>= k, do: {mod(n, k), k}

  def create_fifi({n, k}), do: %Fifi{n: n, k: k}
  def create_fifi(_), do: raise("invalid finite field element")

  @doc """
  A finite field element is defined by a positive integer n in a set of size k
  """

  ######## INITIALIZATION ########

  def new(n, k) do
    {n, k}
    |> validate_n
    |> validate_k
    |> validate_closed
    |> create_fifi
  end

  def inverse(%Fifi{} = fi), do:
    %Fifi{n: mod(-fi.n, fi.k), k: fi.k}

  ######## ADDITION ########

  def add(%Fifi{} = fa, %Fifi{} = fo) when fa.k == fo.k, do:
    %{fa | n: (fa.n + fo.n) |> mod(fa.k)}

  def add(%Fifi{}, %Fifi{}), do:
    raise("Error: fifis of different size (prime)")

  def subs(%Fifi{} = fa, %Fifi{} = fo) when fa.k == fo.k, do:
    add(fa, inverse(fo))

  ######## PRODUCT ########

  def multiply(n, %Fifi{} = fi) when is_integer(n), do:
    %{fi | n: (n * fi.n) |> mod(fi.k)}

  def multiply(%Fifi{} = fi, n) when is_integer(n), do:
    %{fi | n: (n * fi.n) |> mod(fi.k)}

  def multiply(%Fifi{} = fa, %Fifi{} = fo) when fa.k == fo.k, do:
    %{fa | n: (fa.n * fo.n) |> mod(fa.k)}

  def multiply(%Fifi{}, %Fifi{}), do:
    raise("Error: fifis of different size (prime)")

  def exp(%Fifi{} = fa, m) when is_integer(m) and m>=0, do:
    %{fa | n: (fa.n ** m) |> mod(fa.k)}

  def exp(%Fifi{} = fa, m) when is_integer(m) and m<0, do:
    %{fa | n: (fa.n ** (fa.k-1+m)) |> mod(fa.k)}

  def exp(_, _), do: raise("Error: invalid input")

  def divide(%Fifi{} = fa, %Fifi{} = fo) when fa.k == fo.k, do:
    multiply(fa, exp(fo, fo.k-2))

  ######## FORMATTING ########

  defimpl Inspect, for: Fifi do
    def inspect(fi, _opts) do
      """
      Finite Field Element:
        Number: #{fi.n}
        Field Size: #{fi.k}
      """
    end
  end

  defimpl String.Chars, for: Fifi do
    def to_string(fi), do: "Fifi: {n: #{fi.n}, k: #{fi.k}}"
  end
end
