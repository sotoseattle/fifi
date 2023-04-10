defmodule Util do
  import Integer, only: [mod: 2]
  import Bitwise

  def rightmost_bit(int) do
    int
    |> Integer.digits(2)
    |> List.last()
  end

  # Binary Expansion Operation
  def bep(_, acc, 0, _, _), do: acc

  def bep(p, acc, m, 0, fun) when m>0 do
    m = m >>> 1
    bep(fun.(p, p), acc, m, rightmost_bit(m), fun)
  end

  def bep(p, acc, m, 1, fun) when m>0 do
    m = m >>> 1
    bep(fun.(p, p), fun.(acc, p), m, rightmost_bit(m), fun)
  end

  def inverse_big_int(big_n, big_e) do
    Util.bep(
        big_n,
        1,
        big_e-2,
        Util.rightmost_bit(big_e-2),
        &mod(&1 * &2, big_e))
  end

  def to_int(bin) do
    :binary.decode_unsigned(bin, :big)
    # bin |> Base.encode16 |> Integer.parse(16) |> elem(0)
  end
end
