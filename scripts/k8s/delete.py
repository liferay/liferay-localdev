#!/usr/bin/python3
import generate
import os
import uuid

tmp_filename="/tmp/delete-%s.yaml" % uuid.uuid1()

with open(tmp_filename, 'w') as f:
  f.write(generate.generate_yaml())
os.popen("kubectl delete --ignore-not-found --wait -f %s" % tmp_filename).read()
os.remove(tmp_filename)