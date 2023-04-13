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

  
  
  def hashash256(message) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, message))
  end
  
  def hash160(message) do
    :crypto.hash(:ripemd160, :crypto.hash(:sha256, message))
  end
  
  
  #############################################################################
  #                             BINARY CONVERSIONS                            #
  #############################################################################
  
  def hex_2_big(hex) do
    hex |> :binary.decode_unsigned(:big)
  end

  def hex_2_little(hex) do
    hex |> :binary.decode_hex |> :binary.decode_unsigned(:little)
  end


end
