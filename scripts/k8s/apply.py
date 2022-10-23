#!/usr/bin/python3
import generate
import os

yaml=generate.yaml()

with open('/tmp/apply.yaml', 'w') as f:
    f.write(yaml)

os.popen("kubectl apply -f /tmp/apply.yaml").read()

print(yaml)