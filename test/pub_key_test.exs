defmodule PubKeyTest do
  use ExUnit.Case
  import PubKey


  describe "Secp256k1 as defined is correct" do
    test "the g point is on the Secp256k1 curve" do
      assert PubKey.on_curve(g()) == g()
    end

    test "n times g is the infinite point" do
      assert dot(g(), ng()) == inf_point()
    end
  end

  describe "signature verification" do
    test "verifies indeed" do
      p = PubKey.new(
        0x04519fac3d910ca7e7138f7013706f619fa8f033e6ec6e09370ea38cee6a7574,
        0x82b51eab8c27c66e26c858a079bcdf4f1ada34cec420cafc7eac1a42216fb6c4)
      z = 0xbc62d4b80d9e36da29c16c5d4d9f11731f36052c72401a76c23c0fb5a9b74423
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec

      assert PubKey.verify_signature(p, z, Sign.new(r, s))

      p = PubKey.new(
        0x887387e452b8eacc4acfde10d9aaf7f6d9a0f975aabb10d006e4da568744d06c,
        0x61de6d95231cd89026e286df3b6ae4a894a3378e393e93a0f45b666329a0ae34)
      z = 0xec208baa0fc1c19f708a9ca96fdeff3ac3f230bb4a7ba4aede4942ad003c0f60
      r = 0xac8d1c87e51d0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395
      s = 0x68342ceff8935ededd102dd876ffd6ba72d6a427a3edb13d26eb0781cb423c4

      assert PubKey.verify_signature(p, z, Sign.new(r, s))

      z = 0x7c076ff316692a3d7eb3c3bb0f8b1488cf72e1afcd929e29307032997a838a3d
      r = 0xeff69ef2b1bd93a66ed5219add4fb51e11a840f404876325a1e8ffe0529a2c
      s = 0xc7207fee197d27c618aea621406f6bf5ef6fca38681d82b2f06fddbdce6feab6

      assert PubKey.verify_signature(p, z, Sign.new(r, s))
    end
  end

  describe "serialize SEC" do
    test "serialize uncompressed and parse back" do
      p = PubKey.dot(5_000, PubKey.g())
      p_comp = serialize(p, :sec, compress: false) 
      
      assert p_comp ==
      "04FFE558E388852F0120E46AF2D1B370F85854A8EB0841811ECE0E3E03D282D57C315DC72890A4F10A1481C031B03B351B0DC79901CA18A00CF009DBDB157A1D10"
      assert PubKey.parse(p_comp, :sec) == p

      p = PubKey.dot(2018**5, PubKey.g())
      p_comp = serialize(p, :sec, compress: false)
      assert p_comp ==
      "04027F3DA1918455E03C46F659266A1BB5204E959DB7364D2F473BDF8F0A13CC9DFF87647FD023C13B4A4994F17691895806E1B40B57F4FD22581A4F46851F3B06"
      assert PubKey.parse(p_comp, :sec) == p

      p = PubKey.dot(0xdeadbeef12345, PubKey.g())
      p_comp = serialize(p, :sec, compress: false)
      assert p_comp ==
      "04D90CD625EE87DD38656DD95CF79F65F60F7273B67D3096E68BD81E4F5342691F842EFA762FD59961D0E99803C61EDBA8B3E3F7DC3A341836F97733AEBF987121"
      assert PubKey.parse(p_comp, :sec) == p
    end

    @tag runnable: true
    test "compressed" do
      p = PubKey.dot(5_001, PubKey.g())
      p_comp = serialize(p, :sec, compress: true)
      assert p_comp ==
      "0357A4F368868A8A6D572991E484E664810FF14C05C0FA023275251151FE0E53D1"
      assert PubKey.parse(p_comp, :sec) == p

      p = PubKey.dot(2019**5, PubKey.g())
      p_comp = serialize(p, :sec, compress: true)
      assert p_comp ==
      "02933EC2D2B111B92737EC12F1C5D20F3233A0AD21CD8B36D0BCA7A0CFA5CB8701"
      assert PubKey.parse(p_comp, :sec) == p

      p = PubKey.dot(0xdeadbeef54321, PubKey.g())
      p_comp = serialize(p, :sec, compress: true)
      assert p_comp ==
      "0296BE5B1292F6C856B3C5654E886FC13511462059089CDF9C479623BFCBE77690"
      assert PubKey.parse(p_comp, :sec) == p
    end
  end
end
