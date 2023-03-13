#!/usr/bin/env python3
import os

name = os.environ.get("NAME")

tmpfile = "/tmp/.%s.yaml" % name

if os.path.exists(tmpfile):
    os.popen("kubectl delete --ignore-not-found --wait -f %s" % tmpfile).read()
    os.remove(tmpfile)
    os.remove("/tmp/.%s.yttc" % name)
