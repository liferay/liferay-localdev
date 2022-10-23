#!/usr/bin/python3
import generate
import os
import uuid

tmp_filename="/tmp/apply-%s.yaml" % uuid.uuid1()

def apply_yaml(yaml):
  with open(tmp_filename, 'w') as f:
    f.write(yaml)
  applied_yaml=os.popen("kubectl create -oyaml -f %s" % tmp_filename).read()
  os.remove(tmp_filename)
  return applied_yaml

print(apply_yaml(generate.generate_yaml()))
#apply_yaml(generate.configmap_yaml())

#print(workload_yaml)