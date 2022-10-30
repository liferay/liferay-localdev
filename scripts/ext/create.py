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
create_argsline = os.environ.get("CREATE_ARGS", "")

parser = argparse.ArgumentParser()
parser.add_argument(
    "--workspace-path", help="The workspace relative path", required=True
)
parser.add_argument(
    "--resource-path", help="The resource path inside /repo/resources/", required=True
)
parser.add_argument("--args", action="append", nargs="+")

create_args = vars(parser.parse_args(args=create_argsline.split("|")))
template_args = dict()

for i in create_args["args"]:
    arr = i[0].split("=")
    template_args[arr[0]] = arr[1]

project_path = os.path.join(workspace_base_path, create_args["workspace_path"])
template_path = os.path.join(resources_base_path, create_args["resource_path"])

# overwrite the default copy2 and for client-extension.yaml append instead
def copy3(src, dst):
    if str(src).endswith("client-extension.yaml") and str(dst).endswith(
        "client-extension.yaml"
    ):
        current = ""
        with open(dst) as dstfile:
            current = dstfile.read()
        with open(src) as srcfile:
            new = srcfile.read()
            with open(dst, "w") as dstfile:
                dstfile.write(current + "\n\n" + new)
        return dst
    else:
        return shutil.copy2(src, dst)


shutil.copytree(
    template_path,
    project_path,
    copy_function=copy3,
    dirs_exist_ok=template_path.startswith(resources_base_path + "partial/"),
)

for root, dirs, files in os.walk(project_path):
    for d in dirs:
        dirpath = os.path.join(root, d)
        for key in template_args.keys():
            newdirpath = dirpath.replace("${%s}" % key, template_args[key])
            newdirparentpath = pathlib.Path(newdirpath).parent
            pathlib.Path.mkdir(newdirparentpath, parents=True, exist_ok=True)
            if dirpath != newdirpath and os.path.exists(newdirpath):
                # the rename folder may exist (applying a partial)
                # if so, just copy the tree instead and then remove it
                shutil.copytree(dirpath, newdirpath, dirs_exist_ok=True)
                shutil.rmtree(dirpath)
            else:
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
