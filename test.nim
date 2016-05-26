import spills

type Foo = object
  a, b: int
  c: float

initSpills()

var (name, x) = writableSpill[Foo]()
for i in 0 .. 1000000:
  x.add(Foo(a: i, b: i + 1, c: i.float))
x.close()

echo name

var y = spill[Foo](name)
echo y
echo y[1234]
y.close()