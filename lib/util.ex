defmodule Util do
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

end
