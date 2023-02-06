#!/usr/bin/env python3
import os
import shutil

debugDxpDir = os.path.join(
    "/workspace/client-extensions/%s" % os.environ.get("projectName", "debug-dxp")
)

if os.path.exists(debugDxpDir):
    print("%s folder already exists" % debugDxpDir)
    exit(1)

# copy /repo/docker/images/localdev-server/workspace to client-extensions folder and call it debug-dxp
localdevRepo = os.environ.get("LOCALDEV_REPO", "/repo")
localdevWorkspaceDir = os.path.join(
    localdevRepo, "docker/images/localdev-server/workspace"
)

# copy just gradle files
shutil.copytree(
    os.path.join(localdevWorkspaceDir, "gradle"), os.path.join(debugDxpDir, "gradle")
)
shutil.copy2(
    os.path.join(localdevWorkspaceDir, "gradle.properties"),
    os.path.join(debugDxpDir, "gradle.properties"),
)
shutil.copy2(
    os.path.join(localdevWorkspaceDir, "gradlew"), os.path.join(debugDxpDir, "gradlew")
)
shutil.copy2(
    os.path.join(localdevWorkspaceDir, "settings.gradle"),
    os.path.join(debugDxpDir, "settings.gradle"),
)

# append the text "target.platform.index.sources=true" to the end of gradle.properties
with open(os.path.join(debugDxpDir, "gradle.properties"), "a") as f:
    f.write("\ntarget.platform.index.sources=true")
