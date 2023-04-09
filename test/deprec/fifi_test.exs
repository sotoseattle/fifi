defmodule FifiTest do
  use ExUnit.Case
  import Fifi
  doctest Fifi

  describe "Create valid fifis" do
    test "with valid integers" do
      assert new(2, 17) == %Fifi{n: 2, k: 17}
      assert new(0, 17) == %Fifi{n: 0, k: 17}
    end

    test "if n >= k it just projects with modulo" do
      assert new(17, 17) == %Fifi{n: 0, k: 17}
      assert new(18, 17) == %Fifi{n: 1, k: 17}
    end

    test "but just a nil with invalid inputs" do
      assert_raise RuntimeError, fn -> new("hola", 17) end
      assert_raise RuntimeError, fn -> new(0.76, 17) end
      assert_raise RuntimeError, fn -> new(-2, 17) end
    end
  end

  describe "fifi adition" do
    test "basic case" do
      assert add(new(2, 7), new(1, 7)) == %Fifi{n: 3, k: 7}
      assert_raise FunctionClauseError, fn -> add(new(2, 7), nil) end
    end

    test "identity" do
      k = 7777
      f0 = new(0, k)
      f1 = new(Enum.random(1..k-1), k)
      assert add(f0, f1) == f1
    end

    test "remains closed" do
      f0 = new(7770, 7777)
      fad = add(f0, f0)
      refute nil == fad

      assert fad.n < f0.k
      assert fad.n < f0.n
      assert fad.k == f0.k
    end

    test "commutative property" do
      f0 = new(2, 17)
      f1 = new(3, 17)
      assert add(f0, f1) == add(f0, f1)
    end

    test "inverse" do
      assert inverse(new(9, 19)) == %Fifi{n: 10, k: 19}
      assert inverse(new(0, 19)) == %Fifi{n: 0, k: 19}
      assert inverse(new(18, 19)) == %Fifi{n: 1, k: 19}
      assert_raise FunctionClauseError, fn ->
        inverse("pepe")
      end
    end

    test "subtraction" do
      f0 = new(2, 17)
      f1 = new(3, 17)
      refute subs(f0, f1) == subs(f1, f0)
      assert subs(f1, f0) == new(1, 17)
      assert subs(f0, f1) == new(16, 17)
      assert_raise FunctionClauseError, fn ->
        subs(f0, 8)
      end
    end
  end

  describe "multiplication" do
    test "basic case" do
      assert new(2, 7)
        |> multiply(new(1, 7))
        == %Fifi{n: 2, k: 7}

      assert new(95,97)
        |> multiply(45)
        |> multiply(31)
        == %Fifi{n: 23, k: 97}

      assert new(17,97)
        |> multiply(13)
        |> multiply(19)
        |> multiply(44)
        == %Fifi{n: 68, k: 97}

      assert_raise FunctionClauseError, fn -> multiply(new(2,7), nil) end
    end

    test "identity" do
      k = 7777
      f1 = new(1, k)
      fi = new(Enum.random(1..k-1), k)
      assert multiply(f1, fi) == fi
    end

    test "remains closed" do
      f0 = new(7770, 7777)
      fad = multiply(f0, f0)
      refute nil == fad

      assert fad.n < f0.k
      assert fad.n < f0.n
      assert fad.k == f0.k
    end

    test "commutative property" do
      f0 = new(2, 17)
      f1 = new(3, 17)
      assert multiply(f0, f1) == multiply(f0, f1)
    end

    test "exponentiation" do
      f0 = new(1, 17)
      assert exp(f0, 8) == f0
      assert exp(f0, 0) == %Fifi{n: 1, k: f0.k}
      assert exp(new(3, 17), 2) == new(9, 17)

      assert exp(new(17, 31), -3) == new(29, 31)
      assert exp(new(7,13), -3) == new(8, 13)

      assert new(4, 31)
        |> exp(-4)
        |> multiply(new(11, 31))
        == new(13, 31)

      assert new(12, 97)
        |> exp(7)
        |> multiply(exp(new(77, 97), 49))
        == new(63, 97)

      assert_raise RuntimeError, fn ->
        exp(f0, nil)
        exp(f0, -3)
        exp(1, 3)
      end
    end
  end

  describe "mental experiments" do
    # only if k is prime, we know for sure that multiplying any number
    # in the set by a coef, it will give me a different number.
    # That doesn't mean that two coefs cannot arrive at the same output
    # when applied on equal or different fifis
    test "why k needs to be prime" do
      multiply_all_fifis = fn(size) ->
        coefs = Enum.map([1, 2, 3, 7, 13, 14, size-1], fn(x) -> new(x, size) end)
        f_list = Enum.map((1..size-1), fn(x) -> new(x, size) end)

        coefs
          |> Enum.map(
            fn(c) ->
              Enum.map(f_list, fn(fi) -> multiply(fi, c).n end)
              |> Enum.sort
            end)
          |> Enum.uniq
      end

      sol = multiply_all_fifis.(19)
      assert length(sol) == 1
      assert List.first(sol) == Enum.to_list(1..18)
      # IO.inspect(sol)

      sol = multiply_all_fifis.(20)
      refute length(sol) == 1
      # IO.inspect(sol)
    end

    test "for any n, n^(k-1) projected into a field of size k is always 1 if k is prime" do
      # For p = 7, 11, 17, 31, what is this set in Fp?
      # {1(p – 1), 2(p – 1), 3(p – 1), 4(p – 1), ... (p – 1)(p – 1)}
      # This comes from Fermat's Little Theorem

      set = fn(k) ->
        Enum.map((1..k-1), fn(i) -> new(i ** (k-1), k).n end)
      end

      assert [7, 11, 17, 31]
      |> Enum.map(fn(x) -> set.(x) end)
      # |> IO.inspect
      |> List.flatten
      |> Enum.uniq
      == [1]

      refute [6, 12, 25, 33]
      |> Enum.map(fn(x) -> set.(x) end)
      # |> IO.inspect
      |> List.flatten
      |> Enum.uniq
      == [1]
    end
  end

  describe "division" do
    @tag runnable: true
    test "basic case" do
      assert new(2, 19)
        |> divide(new(7, 19))
        == %Fifi{n: 3, k: 19}

      assert new(7, 19)
        |> divide(new(5, 19))
        == %Fifi{n: 9, k: 19}

      assert new(3, 31)
        |> divide(new(24, 31))
        == %Fifi{n: 4, k: 31}
    end
  end
end
