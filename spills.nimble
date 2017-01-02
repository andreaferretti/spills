mode = ScriptMode.Verbose

version       = "0.1.1"
author        = "Andrea Ferretti"
description   = "Disk-baked sequences"
license       = "Apache2"
skipFiles      = @["test.nim"]

requires "nim >= 0.13.0"

task tests, "run tests":
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --path: "."
  --run
  setCommand "c", "test.nim"

task test, "run tests":
  setCommand "tests"

task gendoc, "generate documentation":
  --docSeeSrcUrl: https://github.com/andreaferretti/spills/blob/master
  --project
  setCommand "doc2", "spills"