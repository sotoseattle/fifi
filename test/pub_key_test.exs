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
end
