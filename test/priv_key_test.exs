defmodule PrivKeyTest do
  use ExUnit.Case

  describe "signing" do
    test "signing and verifying" do
      sec_key = :crypto.hash(:sha256, "my secret key") |> Util.to_int

      message = :crypto.hash(:sha256, "hola caracola") |> Util.to_int

      signature = PrivKey.sign(sec_key, message)

      pub_key = PrivKey.pub_key(sec_key)

      PubKey.verify_signature(pub_key, message, signature)
    end

    test "the hash of the message is a double hash" do
      z = PrivKey.hasha256x2("Programming Bitcoin!")
      |> :binary.decode_unsigned(:big)

      assert z == 0x969f6056aa26f7d2795fd013fe88868d09c9f6aed96965016e1936ae47060d48
    end
  end
end
