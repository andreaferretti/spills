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

var z1 = y.map(proc(f: Foo): float = f.c)

echo z1[1234]

var z2 = y.filter(proc(f: Foo): bool = f.a mod 2 == 0)

echo len(z2)

echo z2[1234]

let sum1 = foldl(z1, a + b)
echo sum1
let sum2 = foldr(z1, a + b)
echo sum2

y.close()
z1.close()
z2.close()

destroySpills()