# Spills

Spills are sequences that spill to disk when they do not fit in memory. They
are simply represented by a memory-mapped file, hence they are to be used with
type that are flat - that is, they are obtained by combining primitive types,
objects and arrays, but do not involve seqs, strings or references to heap
memory. In short, you should be able to compute their size statically.

Spills work in two modes:

* writable spills wrap a stream, and one can `add` to them, which just amounts
  to writing to the stream;
* normal spills are fixed-size. You can read and write their elements, iterate
  over them and so on, but cannot grow.

Usually, one first populates a writable spills, then obtains the corresponding
spill from that, and works from there.

An example:

```nim
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

echo z1[1234]

y.close()
z.close()
```