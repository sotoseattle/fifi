defmodule SerializeTest do
  use ExUnit.Case

  describe "as_SEC SEC" do
    test "as_SEC uncompressed and parse_sec back" do
      p = PubKey.dot(5_000, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: false) 
      
      assert p_comp ==
      "04FFE558E388852F0120E46AF2D1B370F85854A8EB0841811ECE0E3E03D282D57C315DC72890A4F10A1481C031B03B351B0DC79901CA18A00CF009DBDB157A1D10"
      assert Serialize.parse_sec(p_comp) == p

      p = PubKey.dot(2018**5, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: false)
      assert p_comp ==
      "04027F3DA1918455E03C46F659266A1BB5204E959DB7364D2F473BDF8F0A13CC9DFF87647FD023C13B4A4994F17691895806E1B40B57F4FD22581A4F46851F3B06"
      assert Serialize.parse_sec(p_comp) == p

      p = PubKey.dot(0xdeadbeef12345, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: false)
      assert p_comp ==
      "04D90CD625EE87DD38656DD95CF79F65F60F7273B67D3096E68BD81E4F5342691F842EFA762FD59961D0E99803C61EDBA8B3E3F7DC3A341836F97733AEBF987121"
      assert Serialize.parse_sec(p_comp) == p
    end

    test "compressed" do
      p = PubKey.dot(5_001, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: true)
      assert p_comp ==
      "0357A4F368868A8A6D572991E484E664810FF14C05C0FA023275251151FE0E53D1"
      assert Serialize.parse_sec(p_comp) == p

      p = PubKey.dot(2019**5, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: true)
      assert p_comp ==
      "02933EC2D2B111B92737EC12F1C5D20F3233A0AD21CD8B36D0BCA7A0CFA5CB8701"
      assert Serialize.parse_sec(p_comp) == p

      p = PubKey.dot(0xdeadbeef54321, PubKey.g())
      p_comp = Serialize.as_SEC(p, compress: true)
      assert p_comp ==
      "0296BE5B1292F6C856B3C5654E886FC13511462059089CDF9C479623BFCBE77690"
      assert Serialize.parse_sec(p_comp) == p
    end
  end

  describe "serialize addresses of public keys with SEC into 20 bytes and base58" do
    @tag runnable: true
    test "basic case" do
      p = PubKey.dot(5_002, PubKey.g())
      p_comp = Serialize.address(p, compress: false, testnet: true) 
      assert p_comp == "mmTPbXQFxboEtNRkwfh6K51jvdtHLxGeMA"

      p = PubKey.dot(2020**5, PubKey.g())
      p_comp = Serialize.address(p, compress: true, testnet: true) 
      assert p_comp == "mopVkxp8UhXqRYbCYJsbeE1h1fiF64jcoH"

      p = PubKey.dot(0x12345deadbeef, PubKey.g())
      p_comp = Serialize.address(p, compress: true, testnet: false) 
      assert p_comp == "1F1Pn2y6pDb68E5nYJJeba4TLg2U7B6KF1"
    end

  end

  describe "Serialize a signature" do
    test "basic case" do
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      serial = Sign.new(r, s) |> Serialize.as_DER(:der)
    
      assert serial == "3045022037206A0610995C58074999CB9767B87AF4C4978DB68C06E8E6E81D282047A7C60221008CA63759C1157EBEAEC0D03CECCA119FC9A75BF8E6D0FA65C841C8E2738CDAEC"
    end
  end

  describe "Conversion to Base58" do
    test "basic case" do
      hex = "7c076ff316692a3d7eb3c3bb0f8b1488cf72e1afcd929e29307032997a838a3d"
      assert Serialize.hex_2_b58(hex) == "9MA8fRQrT4u8Zj8ZRd6MAiiyaxb2Y1CMpvVkHQu5hVM6"

      hex = "eff69ef2b1bd93a66ed5219add4fb51e11a840f404876325a1e8ffe0529a2c"
      assert Serialize.hex_2_b58(hex) == "4fE3H2E6XMp4SsxtwinF7w9a34ooUrwWe4WsW1458Pd"

      hex = "c7207fee197d27c618aea621406f6bf5ef6fca38681d82b2f06fddbdce6feab6"
      assert Serialize.hex_2_b58(hex) == "EQJsjkd6JaGwxrjEhfeqPenqHwrBmPQZjJGNSCHBkcF7"
    end

    test "maintain the leading zeroes" do
      hex = "000000c7207fee197d27c618aea621406f6bf5ef6fca38681d82b2f06fddbdce6feab6"
      assert Serialize.hex_2_b58(hex) == "111EQJsjkd6JaGwxrjEhfeqPenqHwrBmPQZjJGNSCHBkcF7"
    end
  end
end