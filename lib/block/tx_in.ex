defmodule TxIn do
    defstruct id: nil, index: nil, script_sig: nil, sequence: nil

    def new(), do: %TxIn{}

    def parse_an_input(inputo, acc, 0), do: {Enum.reverse(acc), inputo}
    def parse_an_input(inputo, acc, c) do
        {txin, rest} = 
            {TxIn.new(), inputo}
            |> parse_txin_id
            |> parse_txin_index
            |> parse_txin_script_signature
            |> parse_txin_sequence
        
        parse_an_input(rest, [txin | acc], c-1)
    end

    def parse_txin_id({txin, bin}) do
        <<id::little-size(256), rest::binary>> = bin
        {%TxIn{txin | id: id}, rest}
    end
    def parse_txin_index({txin, bin}) do
        <<idx::little-size(32), rest::binary>> = bin
        {%TxIn{txin | index: idx}, rest}
    end
    def parse_txin_script_signature({txin, bin}) do
        {n, bin_wip} = Tx.parse_varint(bin)
        <<script::little-size(n*8), rest::binary>> = bin_wip 
        {%TxIn{txin | script_sig: script}, rest}
    end
    def parse_txin_sequence({txin, bin}) do
        <<seq::little-size(32), rest::binary>> = bin
        {%TxIn{txin | sequence: seq}, rest}
    end

end