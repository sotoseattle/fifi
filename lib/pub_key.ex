defmodule PubKey do
  import Integer, only: [mod: 2]
  @moduledoc """
  Public keys are points on the curve secp256k1,
  its coordinates are finite field elements.
  """

  defstruct x: nil, y: nil

  #############################################################################
  #                               PARAMETERS                                  #
  #############################################################################

  @ec %Ec{a: 0, b: 7}

  def g() do
    new(
      0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
      0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
    end

  # Order size of all the dot products over g. A prime number.
  def ng(), do:
    0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

  defguard is_inf(p) when p.x == nil and p.y == nil

  def inf_point(), do: %PubKey{x: nil, y: nil}

  def new(x, y) when is_integer(x) and is_integer(y) do
    %PubKey{ x: Ff.new(x), y: Ff.new(y) }
    |> on_curve()
  end

  def new(%Ff{} = x, %Ff{} = y) do
    %PubKey{ x: x, y: y }
    |> on_curve()
  end

  # y^2 == x^3 + x * c.a + c.b
  def on_curve(%PubKey{x: nil, y: nil} = p), do: p
  def on_curve(%PubKey{x: x, y: y} = p) do
    left = Ff.exp(y, 2)
    right = Ff.exp(x, 3)
      |> Ff.add(Ff.multiply(x, @ec.a))
      |> Ff.add(@ec.b)
    if left == right, do: p,
    else: raise("Error: Point is not on eliptic curve SECP256K1")
  end

  #############################################################################
  #                                 ADDITION                                  #
  #  The two sumands form a line that intersects the curve in a third one,    #
  #  which is the result of the addition.                                     #
  #############################################################################

  # When a point is the infinite point
  def add(p, q) when is_inf(p), do: q
  def add(p, q) when is_inf(q), do: p

  # When both points coincide and y = 0
  def add(%PubKey{y: y} = p, p) when y.n == 0, do: inf_point()

  # When both points coincide anywhere in the curve (form a tangent)
  def add(%PubKey{} = p, p) do
    s = p.x
      |> Ff.exp(2)
      |> Ff.multiply(3)
      |> Ff.add(@ec.a)
      |> Ff.divide(Ff.multiply(p.y, 2))
    x = s
      |> Ff.exp(2)
      |> Ff.subs(Ff.multiply(p.x, 2))
    y = p.x
      |> Ff.subs(x)
      |> Ff.multiply(s)
      |> Ff.subs(p.y)
    new(x, y)
  end

  # When both points are in a vertical line
  def add(%PubKey{} = p, %PubKey{} = q) when p.x == q.x do
      inf_point()
  end

  # Any other case, the non-edge case
  def add(p, q) do
    s = q.y
      |> Ff.subs(p.y)
      |> Ff.divide(Ff.subs(q.x, p.x))
    x = s
      |> Ff.exp(2)
      |> Ff.subs(p.x)
      |> Ff.subs(q.x)
    y = p.x
      |> Ff.subs(x)
      |> Ff.multiply(s)
      |> Ff.subs(p.y)
    new(x, y)
  end

  #############################################################################
  #                              BINARY EXPANSION                             #
  #############################################################################

  # Binary expansion of iterative addition of a public key point
  defp dot_bexp(point_ff, times) do
    Util.bep(
      point_ff,
      inf_point(),
      times,
      Util.rightmost_bit(times),
      &add(&1, &2))
  end

  # Binary expansion of iterative product of a big number. It computes
  #   - the inverse through exp -2
  #   - the mod over N (order size of G)
  def inverse_big_int(big_int, big_e) do
    Util.bep(
        big_int,
        1,
        big_e-2,
        Util.rightmost_bit(big_e-2),
        &mod(&1 * &2, big_e))
  end

  #############################################################################
  #                                DOT PRODUCT                                #
  #############################################################################

  def dot(m, %PubKey{} = p) when is_integer(m) and m>1, do: dot_bexp(p, m)

  def dot(%PubKey{} = p, m) when is_integer(m) and m>1, do: dot_bexp(p, m)

  def dot(%Ff{n: m}, %PubKey{} = p), do: dot_bexp(p, m)

  def dot(%PubKey{} = p, %Ff{n: m}), do: dot_bexp(p, m)

  #############################################################################
  #                                SIGNATURE                                  #
  #   Verify that a message was created by the owner of a private key         #
  #   through the use of its related public key and signature data.           #
  #############################################################################

  def verify_signature(pub_key, message, signature) do
    ng = PubKey.ng()

    s_inv = inverse_big_int(signature.s, ng)
    u = message * s_inv |> mod(ng)
    v = signature.r * s_inv |> mod(ng)

    total = PubKey.add(
      PubKey.dot(u, PubKey.g()),
      PubKey.dot(v, pub_key))

    total.x.n == signature.r
  end

  #############################################################################
  #                              SERIALIZATION                                #
  #############################################################################

  def serialize(%PubKey{} = p, :sec, compress: false) do
    <<0x04, p.x.n::big-size(256), p.y.n::big-size(256)>>
    |> :binary.encode_hex
  end

  def serialize(%PubKey{} = p, :sec, compress: true) do
    header = if mod(p.y.n, 2) == 0, do: 0x02, else: 0x03
    <<header, p.x.n::big-size(256)>>
    |> :binary.encode_hex
  end




  #############################################################################
  #                                FORMATING                                  #
  #############################################################################

  defimpl String.Chars, for: PubKey do
    def to_string(%PubKey{x: nil, y: nil}), do:
      "Infinity point in elliptic curve secp256k1"

    def to_string(p), do:
      "PubKey, point (#{p.x}, #{p.y}) on curve secp256k1"
  end
end
