#!/usr/bin/env python3
import argparse
import fileinput
import os
import pathlib
import shutil

workspace_base_path = os.environ.get(
    "WORKSPACE_BASE_PATH", "/workspace/client-extensions/"
)
resources_base_path = os.environ.get("RESOURCES_BASE_PATH", "/repo/resources/")

parser = argparse.ArgumentParser()
parser.add_argument(
    "--workspace-path", help="The workspace relative path", required=True
)
parser.add_argument(
    "--resource-path", help="The resource path inside /repo/resources/", required=True
)
parser.add_argument('--template-args', action='append', nargs='+')

known_args, unknown = parser.parse_known_args()
create_args = vars(known_args)
template_args = dict()

for i in create_args['template_args']:
  arr = i[0].split('=')
  template_args[arr[0]] = arr[1]

project_path = os.path.join(workspace_base_path, create_args["workspace_path"])
template_path = os.path.join(resources_base_path, create_args["resource_path"])

shutil.copytree(template_path, project_path)

for root, dirs, files in os.walk(project_path):
    for d in dirs:
        dirpath = os.path.join(root, d)
        for key in template_args.keys():
            newdirpath = dirpath.replace("${%s}" % key, template_args[key])
            newdirparentpath = pathlib.Path(newdirpath).parent
            pathlib.Path.mkdir(newdirparentpath, parents=True, exist_ok=True)
            os.rename(dirpath, newdirpath)
            dirpath = newdirpath

for root, dirs, files in os.walk(project_path):
    for f in files:
        filepath = os.path.join(root, f)
        try:
            with open(filepath) as r:
                text = r.read()
                for key in template_args.keys():
                    text = text.replace("${%s}" % key, template_args[key])
            with open(filepath, "w") as w:
                w.write(text)
        except UnicodeDecodeError:
            pass
        for key in template_args.keys():
            newfilepath = filepath.replace("${%s}" % key, template_args[key])
            newfileparentpath = pathlib.Path(newfilepath).parent
            pathlib.Path.mkdir(newfileparentpath, parents=True, exist_ok=True)
            os.rename(filepath, newfilepath)
            filepath = newfilepath
