#!/usr/bin/env python3

from shutil import copytree, ignore_patterns, make_archive
import os
import tempfile

workspace_base_path = "/workspace"
client_extensions_path = "/workspace/client-extensions/"

# python create a user temp dir and delete it when done
tempDir = tempfile.TemporaryDirectory()

# python copy directory tree following symbolic links
archiveBasePath = copytree(
    "/workspace",
    os.path.join(tempDir.name, "liferay-workspace"),
    ignore=ignore_patterns(
        ".*",
        "Dockerfile.ext",
        "GETTING_STARTED.markdown",
        "build*",
        "configs",
        "modules",
        "node_modules*",
        "package.json",
        "platform.bndrun",
        "themes",
        "yarn.lock",
    ),
)

# zip a directory
make_archive(
    base_dir="liferay-workspace",
    base_name="/workspace/client-extensions/liferay-workspace",
    format="zip",
    root_dir=tempDir.name,
)
