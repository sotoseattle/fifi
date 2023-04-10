defmodule PrivKey do
  import Integer, only: [mod: 2]

  def pub_key(private_key) do
    private_key |> PubKey.dot(PubKey.g())
  end

  def hashash256(message) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, message))
  end

  # Adapted from Curvy: https://github.com/libitx/curvy (deterministic_k))
  # Implements RFC 6979 {r,s} values from deterministically generated k
  # Added s > n/2 because "It turns out that using low values of s will get
  # miner nodes to relay transactions instead of commit them."
  def sign(private_key, hash) do
    xoxo = :binary.encode_unsigned(hash)

    v = :binary.copy(<<1>>, 32)
    k = :binary.copy(<<0>>, 32)

    k =
      :crypto.mac(
        :hmac,
        :sha256,
        k,
        <<v::binary, 0, private_key::big-size(256), xoxo::binary>>
      )

    v = :crypto.mac(:hmac, :sha256, k, v)

    k =
      :crypto.mac(
        :hmac,
        :sha256,
        k,
        <<v::binary, 1, private_key::big-size(256), xoxo::binary>>
      )

    v = :crypto.mac(:hmac, :sha256, k, v)
    ng = PubKey.ng()
    g = PubKey.g()

    Enum.reduce_while(0..1000, {k, v}, fn i, {k, v} ->
      if i == 1000, do: throw({:error, "tried 1000 k values, all were invalid"})
      v = :crypto.mac(:hmac, :sha256, k, v)

      case v do
        <<t::big-size(256)>> when 0 < t and t < ng ->
          r = PubKey.dot(t, g).x.n

          s = (PubKey.inverse_big_int(t, ng) * (hash + r * private_key)) |> mod(ng)

          if r == 0 or s == 0 or s > ng / 2,
            do: {:cont, {k, v}},
            else: {:halt, Sign.new(r, s)}

        _ ->
          k = :crypto.mac(:hmac, :sha256, k, <<v::binary, 0>>)
          v = :crypto.mac(:hmac, :sha256, k, v)
          {:cont, {k, v}}
      end
    end)
  end
end
