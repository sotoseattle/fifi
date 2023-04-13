defmodule TxOut do
    defstruct amount: nil, script_pubkey: nil

    def new(), do: %TxOut{}

    def parse_an_output(inputo, acc, 0), do: {Enum.reverse(acc), inputo}
    def parse_an_output(inputo, acc, c) do
        {txout, rest} = 
            {TxOut.new(), inputo}
            |> parse_txout_amount
            |> parse_txout_script_key
        
        parse_an_output(rest, [txout | acc], c-1)
    end

    def parse_txout_amount({txout, bin}) do
        <<amount::little-size(64), rest::binary>> = bin
        {%TxOut{txout | amount: amount}, rest}
    end
    
    def parse_txout_script_key({txout, bin}) do
        {n, bin_wip} = Tx.parse_varint(bin)
        <<script::little-size(n*8), rest::binary>> = bin_wip 
        {%TxOut{txout | script_pubkey: script}, rest}
    end
    

end