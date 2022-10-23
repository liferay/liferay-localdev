#!/usr/bin/python3
import generate
import os

yaml=generate.yaml()

os.popen("kubectl delete -f-").writelines(yaml)

print(yaml)