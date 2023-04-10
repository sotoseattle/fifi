defmodule PubKey do
  import Integer, only: [mod: 2]

  @doc """
  Verify that a message was created by the owner of a private key,
  through the use of its related public key and signature data.
  """
  def verify_signature(pub_key, message, signature) do
    n = Pff.n()

    s_inv = Util.inverse_big_int(signature.s, n)
    u = message * s_inv |> mod(n)
    v = signature.r * s_inv |> mod(n)

    total = Pff.add(
      Pff.dot(u, Pff.g()),
      Pff.dot(v, pub_key))

    total.x.n == signature.r
  end
end
