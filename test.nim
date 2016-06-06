import unittest, spills, spills/varchar

type Foo = object
  a, b: int
  c: float

initSpills()

suite "spills":
  var x = writableSpill[Foo]()
  for i in 0 .. 100:
    x.add(Foo(a: i, b: i + 1, c: i.float))
  x.close()

  test "spill creation":
    var y = spill(x)
    check y[10] == Foo(a: 10, b: 11, c: 10.0)
    y.close()
  test "map operation":
    var
      y = spill(x)
      z = y.map(proc(f: Foo): float = f.c)
    check z[25] == 25.0
    y.close()
    z.close()
  test "filter operation":
    var
      y = spill(x)
      z = y.filter(proc(f: Foo): bool = f.a mod 2 == 0)
    check z[25] == Foo(a: 50, b: 51, c: 50.0)
    y.close()
    z.close()
  test "length operation":
    var
      y = spill(x)
      z = y.filter(proc(f: Foo): bool = f.a mod 2 == 0)
    check y.len == 101
    check z.len == 51
    y.close()
    z.close()
  test "fold operations":
    var
      y = spill(x)
      z = y.map(proc(f: Foo): float = f.c)
      s1 = foldl(z, a + b)
      s2 = foldr(z, a + b)
    check s1 == 5050.0
    check s2 == 5050.0
    y.close()
    z.close()
  test "seq conversions":
    var
      s = @[
        Foo(a: 2, b: 5, c: 3.14),
        Foo(a: 3, b: 2, c: 1.0)
      ]
      t = s.toSpill()
      u = t.toSeq()

    check s == u

destroySpills()