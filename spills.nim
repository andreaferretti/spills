import os, memfiles, streams, sequtils

type
  UncheckedArray{.unchecked.}[T] = array[1, T]
  Spill*[T] = object
    data: ptr[UncheckedArray[T]]
    underlying: MemFile
  WritableSpill[T] = object
    stream: Stream
    path: string

var
  spillsBaseDir = "/tmp/spills"
  count = 0

proc genId(): string =
  count += 1
  return spillsBaseDir / ("spill_" & $(count))

proc initSpills*(s: string) =
  createDir(s)
  spillsBaseDir = s

proc initSpills*() = createDir(spillsBaseDir)

proc destroySpills*() =
  for i in countdown(count, 0):
    let path = spillsBaseDir / ("spill_" & $(i))
    if fileExists(path):
      removeFile(path)

proc spill*[T](path: string): Spill[T] =
  let f = memfiles.open(path, mode = fmReadWrite)
  return Spill[T](data: cast[ptr[UncheckedArray[T]]](f.mem), underlying: f)

proc spill*[T](s: WritableSpill[T]): Spill[T] = spill[T](s.path)

proc writableSpill*[T](path: string): WritableSpill[T] =
  WritableSpill[T](stream: newFileStream(path, fmWrite), path: path)

proc writableSpill*[T](): WritableSpill[T] =
  writableSpill[T](genId())

proc close*(s: var Spill) = close(s.underlying)
proc close*(s: var WritableSpill) = close(s.stream)

proc len*[T](s: Spill[T]): int = s.underlying.size div sizeof(T)

proc `[]`*[T](s: Spill[T], i: int): T =
  assert i >= 0 and i < len(s)
  return s.data[i]

proc `[]=`*[T](s: var Spill[T], i: int, val: T) =
  assert i >= 0 and i < len(tea)
  s.data[i] = val

proc add*[T](s: var WritableSpill[T], val: T) =
  s.stream.write(val)

iterator items*[T](s: Spill[T]): T {.inline.} =
  for i in 0 .. < len(s):
    yield s.data[i]

iterator pairs*[T](s: Spill[T]): tuple[key: int, val: T] {.inline.} =
  for i in 0 .. < len(s):
    yield (i, s.data[i])

proc map*[T, U](s: Spill[T], f: proc(t: T): U, path: string): Spill[U] =
  var ws = writableSpill[U](path)
  for x in s:
    ws.add(f(x))
  ws.close()
  return spill[U](ws)

proc map*[T, U](s: Spill[T], f: proc(t: T): U): Spill[U] =
  map(s, f, genId())

proc filter*[T](s: Spill[T], f: proc(t: T): bool, path: string): Spill[T] =
  var ws = writableSpill[T](path)
  for x in s:
    if f(x):
      ws.add(x)
  ws.close()
  return spill[T](ws)

proc filter*[T](s: Spill[T], f: proc(t: T): bool): Spill[T] =
  filter(s, f, genId())

proc print*[T](s: Spill[T], maxItems = 30): string =
  var count = 0
  result = "s["
  for x in s:
    if count > 0:
      result &= ", "
    result &= $(x)
    count += 1
    if count >= maxItems:
      result &= ", ..."
      break
  result &= "]"

proc `$`*[T](s: Spill[T]): string = print(s)

export sequtils.foldl, sequtils.foldr