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

To avoid breaking with empty spills, the library always create spills with a
magic number header, so that even an empty spill does not correspond to an
empty file. To read files without this header (perhaps written by some external
tool) one can do something like

```nim
var y = spill[char]("some file", hasHeader = false)
...
y.close()
```

## Managing resources

Since spills are associated to files, there are two concerns:

* closing streams and other objects to make sure that changes to disk are
  flushed and resources released
* removing intermediate temporary files.

Spills are written to a temporary directory by default. To set this directory
and create it, call `initSpills(dir)`. Just calling `initSpills()` will use a
default directory of `/tmp/spills`.

Every method that creates a new spill object optionally accepts a path parameter.
If this parameter is missing, files are created in the temporary directory.
At the end, you can call `destroySpills()` to remove the files generated in this
directory. In this way, you can choose which files to persist across sessions,
and which ones to remove.

Finally, spills (both simple and writable) have a close method that will unmap
the file from memory (respectively, close the associated stream).

## Sequence operations

Spills admit a few standard sequence operations. Other than reading and writing
single items, there are `map`, `filter`, `foldl` and `foldr`. These work as the
similar operations in `sequtils`, except that `map` and `filter` optionally
take a path parameter.

There are also functions `toSpill[T](s: seq[T]): Spill[T]` and
`toSeq[T](s: Spill[T]): seq[T]` to convert back and forth from sequences.

## Strings

Strings are variable-length, and as such cannot be stored into spills. Since
they are quite a common type, we provide a `VarChar[N]` type under `spills/varchar`.

`VarChar[N]` is a wrapper over an array of `N` chars and a length field. If you
know beforehand that all your strings will not be longer than `N`, you can use
it instead. One can convert back and forth using

```nim
import spills/varchar

let
  a = "Hello, world"
  b = a.varchar(15)
  c = $b

assert a == c
```