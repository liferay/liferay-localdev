#!/usr/bin/python3
import generate
import os
import uuid

tmp_filename = "/tmp/create-%s.yaml" % uuid.uuid1()

with open(tmp_filename, "w") as f:
    f.write(generate.generate_yaml())
applied_yaml = os.popen("kubectl create -oyaml -f %s" % tmp_filename).read()
os.remove(tmp_filename)

print(applied_yaml)
