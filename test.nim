import spills

const name = "foo.spill"
type Foo = object
  a, b: int
  c: float

var x = writableSpill[Foo](name)
for i in 0 .. 1000000:
  x.add(Foo(a: i, b: i + 1, c: i.float))
x.close()

var y = spill[Foo](name)
echo y
echo y[1234]
y.close()