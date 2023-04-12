defmodule Serialize do
  import Integer, only: [mod: 2]

  @base58_alphabet Enum.zip(
      (0..58),
      String.graphemes("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
    ) |> Map.new


  #############################################################################
  #                          SEC - PUBLIC KEY                                 #
  #                             65 bytes -> uncompressed (x & y)              #
  #                             33 bytes -> compressed (x)                    #
  #               address ----> 20 bytes -> compressed & hashed & base58      #
  #############################################################################

  def as_SEC(%PubKey{} = p, compress: false) do
    <<0x04, p.x.n::big-size(256), p.y.n::big-size(256)>>
    |> :binary.encode_hex
  end

  def as_SEC(%PubKey{} = p, compress: true) 
    when Integer.is_even(p.y.n) do
      <<0x02, p.x.n::big-size(256)>> |> :binary.encode_hex
  end

  def as_SEC(%PubKey{} = p, compress: true) do
      <<0x03, p.x.n::big-size(256)>> |> :binary.encode_hex
  end
  
  def parse_sec("02" <> hex) do
    <<x::big-size(256)>> = :binary.decode_hex(hex)
    y = x |> derive_y() |> choose_y("02")
    PubKey.new(x, y)
  end
  
  def parse_sec("03" <> hex) do
    <<x::big-size(256)>> = :binary.decode_hex(hex)    
    y = x |> derive_y() |> choose_y("03")
    PubKey.new(x, y)
  end

  def parse_sec("04" <> hex) do
    <<x::big-size(256), y::big-size(256)>> = :binary.decode_hex(hex)
    PubKey.new(x, y)
  end

  defp derive_y(x) do
    Ff.new(x)
      |> PubKey.eq_right_side() 
      |> Ff.exp_bexp(Integer.floor_div(Ff.field_size + 1, 4)) 
      |> Map.fetch!(:n)
  end

  defp pick_other(y) do
    Ff.new(y)
      |> Ff.neg 
      |> Ff.add(Ff.field_size) 
      |> Map.fetch!(:n)
  end

  defp choose_y(y, "03") when Integer.is_even(y), do: pick_other(y)
  defp choose_y(y, "03"), do: y
  defp choose_y(y, "02") when Integer.is_even(y), do: y
  defp choose_y(y, "02"), do: pick_other(y)



  defp prepend_net(bin, true), do: <<0x6f, bin::binary>>
  defp prepend_net(bin, false), do: <<0x00, bin::binary>>

  defp checksum_b58(bin) do
    checksum = bin |> Util.hashash256() |> binary_part(0, 4)

    bin <> checksum
      |> :binary.encode_hex
      |> hex_2_b58()
  end

  def address(%PubKey{} = p, compress: bool1, testnet: bool2) do
    p
      |> as_SEC(compress: bool1)
      |> :binary.decode_hex
      |> Util.hash160
      |> prepend_net(bool2)
      |> checksum_b58
  end



  #############################################################################
  #               SERIALIZATION OF SIGNATURES • DER FORMAT                    #
  #############################################################################

  defp der_prefix(bin, first) when first <= 80, do: <<byte_size(bin)>>
  defp der_prefix(bin, _), do: <<byte_size(bin) + 1, 0>>
  
  defp derify(bin) do
    <<0x02>> <>
    der_prefix(bin, :binary.first(bin)) <>
    bin
  end

  def as_DER(%Sign{r: r, s: s}, :der) do
    bin = derify(<<r::big-size(256)>>) <> derify(<<s::big-size(256)>>)
    <<0x30, byte_size(bin), bin::binary>> |> :binary.encode_hex
  end

  #############################################################################
  #                   CONVERSION TO BASE 58 • PUBLIC KEYS                     #
  #   Like base 64 but without 0 and letters O, l, I (to avoid confussion)    #
  #############################################################################

  defp get_prefix_00("00" <> rest, zeroes), do: get_prefix_00(rest, zeroes+1)
  defp get_prefix_00(hex, zeroes), do: {hex, zeroes}

  defp translate_hex({hex, zeroes}) do
    hex = 
      hex
      |> Integer.parse(16) |> elem(0)
      |> map_to_base58([]) 
    {hex, zeroes}
  end

  defp map_to_base58(0, acc), do: Enum.join(acc)
  defp map_to_base58(n, acc) do
    div = Integer.floor_div(n, 58)
    chr = Map.fetch!(@base58_alphabet, mod(n, 58))
    map_to_base58(div, [chr | acc])
  end

  defp add_prefix_1({b58_string, zeroes}), do:
     "#{String.duplicate("1", zeroes)}#{b58_string}"

  def hex_2_b58(hex) do
    hex
      |> get_prefix_0s(0)
      |> translate_hex
      |> add_prefix_1
  end

end