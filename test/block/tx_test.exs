defmodule TxTest do
    use ExUnit.Case
    
    
    describe "..." do
        test "converters" do
            assert Util.hex_2_little("01000000") == 1
        end

        test "...", %{raw: raw} do
            tx0 = Tx.parse(raw)
            # |> IO.inspect
            assert tx0.version == 1
        end
    end

    describe "varint" do
        test "basic parsing of a binary" do
            rest = "56919960AC691763688D3D3BCE" |> :binary.decode_hex

            assert Tx.parse_varint(:binary.decode_hex("6456919960AC691763688D3D3BCE")) == {100, rest}
            assert Tx.parse_varint(:binary.decode_hex("fdff0056919960AC691763688D3D3BCE")) == {255, rest}
            assert Tx.parse_varint(:binary.decode_hex("fd2b0256919960AC691763688D3D3BCE")) == {555, rest}
            assert Tx.parse_varint(:binary.decode_hex("fe7f11010056919960AC691763688D3D3BCE")) == {70015, rest}
            assert Tx.parse_varint(:binary.decode_hex("ff6dc7ed3e6010000056919960AC691763688D3D3BCE")) == {18005558675309, rest}
        end

        test "basic encoding of an integer as varint" do
            assert Tx.encode_varint(100) == <<0x64>>
            assert Tx.encode_varint(255) |> :binary.encode_hex == "FDFF00"
            assert Tx.encode_varint(555) |> :binary.encode_hex == "FD2B02"
            assert Tx.encode_varint(70015) |> :binary.encode_hex == "FE7F110100"
            assert Tx.encode_varint(18005558675309) |> :binary.encode_hex == "FF6DC7ED3E60100000"
        end
    end

    describe "parse a transaction input" do
        @tag runnable: true
        test "basic case" do
            raw = "010000000456919960AC691763688D3D3BCEA9AD6ECAF875DF5339E148A1
                   FC61C6ED7A069E010000006A47304402204585BCDEF85E6B1C6AF5C2669D
                   4830FF86E42DD205C0E089BC2A821657E951C002201024A10366077F87D6
                   BCE1F7100AD8CFA8A064B39D4E8FE4EA13A7B71AA8180F012102F0DA57E8
                   5EEC2934A82A585EA337CE2F4998B50AE699DD79F5880E253DAFAFB7FEFF
                   FFFFEB8F51F4038DC17E6313CF831D4F02281C2A468BDE0FAFD37F1BF882
                   729E7FD3000000006A47304402207899531A52D59A6DE200179928CA9002
                   54A36B8DFF8BB75F5F5D71B1CDC26125022008B422690B8461CB52C3CC30
                   330B23D574351872B7C361E9AAE3649071C1A7160121035D5C93D9AC9688
                   1F19BA1F686F15F009DED7C62EFE85A872E6A19B43C15A2937FEFFFFFF56
                   7BF40595119D1BB8A3037C356EFD56170B64CBCC160FB028FA10704B45D7
                   75000000006A47304402204C7C7818424C7F7911DA6CDDC59655A70AF1CB
                   5EAF17C69DADBFC74FFA0B662F02207599E08BC8023693AD4E9527DC42C3
                   4210F7A7D1D1DDFC8492B654A11E7620A0012102158B46FBDFF65D0172B7
                   989AEC8850AA0DAE49ABFB84C81AE6E5B251A58ACE5CFEFFFFFFD63A5E6C
                   16E620F86F375925B21CABAF736C779F88FD04DCAD51D26690F7F3450100
                   00006A47304402200633EA0D3314BEA0D95B3CD8DADB2EF79EA8331FFE1E
                   61F762C0F6DAEA0FABDE022029F23B3E9C30F080446150B2385202875163
                   5DCEE2BE669C2A1686A4B5EDF304012103FFD6F4A67E94ABA353A00882E5
                   63FF2722EB4CFF0AD6006E86EE20DFE7520D55FEFFFFFF0251430F000000
                   00001976A914AB0C0B2E98B1AB6DBF67D4750B0A56244948A87988AC005A
                   6202000000001976A9143C82D7DF364EB6C75BE8C80DF2B3EDA8DB573970
                   88AC46430600"
                    |> String.replace(~r/[\n|\s]+/, "")
            
            assert %Tx{} = Tx.parse(raw)
        end
    end

end