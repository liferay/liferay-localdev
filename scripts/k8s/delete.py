#!/usr/bin/env python3
import ytt
import os
import uuid

tmpfile = "/tmp/delete-%s.yaml" % uuid.uuid1()

with open(tmpfile, "w") as f:
    f.write(ytt.generate_workload_yaml())
os.popen("kubectl delete --ignore-not-found --wait -f %s" % tmpfile).read()
os.remove(tmpfile)
