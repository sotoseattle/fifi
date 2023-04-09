defmodule Secp256k1 do
  alias Pointff
  alias Fifi

  def initialize do
    ec = %Ec{a: 0, b: 7}
    k = 2**256 - 2 **32 - 977
    x = Fifi.new(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, k)
    y = Fifi.new(0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8, k)
    n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

    %{ ec: ec, k: k, g: %Pointff{ x: x, y: y, ec: ec}, n: n }
  end

end
