defmodule Tx do
    defstruct version: nil, tx_in: [], tx_out: [], locktime: nil, testnet: false

    def new(), do: %Tx{}

    def parse(raw_hex) do
        %{tx: Tx.new, hex_blob: raw_hex}
            |> parse_version
            |> parse_inputs
            |> parse_outputs
            |> parse_locktime
            |> check_nothing_left
    end

    defp parse_version(%{tx: tx, hex_blob: raw}) do
        <<v::little-size(32), rest::binary>> = :binary.decode_hex(raw)
        %{
            tx: %Tx{ tx  | version: v }, 
            hex_blob: rest
        }
    end

    def parse_inputs(%{tx: tx, hex_blob: raw}) do
        {n_inputs, rest} = parse_varint(raw)
        {tx_ins, rest} = TxIn.parse_an_input(rest, [], n_inputs)
        %{
            tx: %Tx{ tx | tx_in: tx_ins },
            hex_blob: rest
        }
    end

    def parse_outputs(%{tx: tx, hex_blob: raw}) do
        {n_outputs, rest} = parse_varint(raw)
        {tx_outs, rest} = TxOut.parse_an_output(rest, [], n_outputs)
        %{
            tx: %Tx{ tx | tx_out: tx_outs },
            hex_blob: rest
        }
    end

    def parse_locktime(%{tx: tx, hex_blob: raw}) do
        <<lock::little-size(32), rest::binary>> = raw
        %{
            tx: %Tx{ tx  | locktime: lock }, 
            hex_blob: rest
        }
    end

    def check_nothing_left(%{tx: tx, hex_blob: <<>>}), do: tx
    def check_nothing_left(_), do: raise "Error parsing Tx: stuff left to process."

    # parse binary and extract the varint as an integer
    def parse_varint(<<n::size(8), rest::binary>>) when n < 253,  do: {n, rest}
    def parse_varint(<<0xfd, n::little-size(16), rest::binary>>), do: {n, rest}
    def parse_varint(<<0xfe, n::little-size(32), rest::binary>>), do: {n, rest}
    def parse_varint(<<0xff, n::little-size(64), rest::binary>>), do: {n, rest}

    # encode int to binary
    def encode_varint(n) when n < 0xfd, do: <<n::little-size(8)>>
    def encode_varint(n) when n < 0x10000, do: <<0xfd, n::little-size(16)>>
    def encode_varint(n) when n < 0x100000000, do: <<0xfe, n::little-size(32)>>
    def encode_varint(n), do: <<0xff, n::little-size(64)>>

end