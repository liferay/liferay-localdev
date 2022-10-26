#!/usr/bin/python3
import ytt
import os
import uuid

tmpfile = "/tmp/create-%s.yaml" % uuid.uuid1()

with open(tmpfile, "w") as f:
    f.write(ytt.generate_workload_yaml())
applied_yaml = os.popen("kubectl create -oyaml -f %s" % tmpfile).read()
os.remove(tmpfile)

print(applied_yaml)
