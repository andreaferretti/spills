import spills

type Foo = object
  a, b: int
  c: float

initSpills()

var x = writableSpill[Foo]()
for i in 0 .. 1000000:
  x.add(Foo(a: i, b: i + 1, c: i.float))
x.close()

var y = spill(x)
echo y
echo y[1234]

var z = y.map(proc(f: Foo): float = f.c)

echo z[1234]

y.close()
z.close()

destroySpills()