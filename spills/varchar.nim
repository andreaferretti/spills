type VarChar*[N: static[int]] = object
  length: range[0 .. (N-1)]
  data: array[N, char]

proc varchar*(s: string, N: static[int]): VarChar[N] =
  let L = len(s)
  doAssert(L <= N)
  result.length = L
  copyMem(unsafeAddr result.data, unsafeAddr s[0], L)

proc `$`*[N: static[int]](v: VarChar[N]): string =
  result = newString(v.length)
  copyMem(unsafeAddr result[0], unsafeAddr v.data, v.length)

proc len*[N: static[int]](v: VarChar[N]): Natural =
  v.length

proc `==`*[N: static[int]](v, w: VarChar[N]): bool =
  if v.length != w.length:
    return false
  for i in 0 ..< v.length:
    if v.data[i] != w.data[i]:
      return false
  return true