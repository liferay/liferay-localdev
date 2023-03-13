#!/usr/bin/env python3
import ytt
import os

name = os.environ.get("NAME")

tmpfile = "/tmp/.%s.yaml" % name

with open(tmpfile, "w") as f:
    f.write(ytt.generate_workload_yaml())

applied_yaml = os.popen("kubectl create -oyaml -f %s" % tmpfile).read()

print(applied_yaml)
