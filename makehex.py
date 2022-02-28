#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv

binfile = argv[1]

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) % 4 == 0

for i in range(len(bindata)):
    if i < len(bindata) // 8:
        w = bindata[8*i : 8*i+8]
        print("%02x%02x%02x%02x%02x%02x%02x%02x" % (w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7]))
