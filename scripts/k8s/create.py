#!/usr/bin/env python3
import ytt
import os

name = os.environ.get("NAME")

tmpfile = "/tmp/.%s.yaml" % name

with open(tmpfile, "w") as f:
    f.write(ytt.generate_workload_yaml())

applied_yaml = os.popen("kubectl apply -oyaml -f %s 2>/dev/null" % tmpfile).read()

print(applied_yaml)
