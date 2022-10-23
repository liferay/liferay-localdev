#!/usr/bin/python3
import generate
import os

import generate
import os
import uuid

tmp_filename="/tmp/delete-%s.yaml" % uuid.uuid1()

def delete_yaml(yaml):
  with open(tmp_filename, 'w') as f:
    f.write(yaml)
  os.popen("kubectl delete --ignore-not-found --wait -f %s" % tmp_filename).read()
  os.remove(tmp_filename)

delete_yaml(generate.generate_yaml())