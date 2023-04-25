#!/usr/bin/env python3
import json
import os
import yaml

lfrdev_domain = os.environ.get("LFRDEV_DOMAIN", "lfr.dev")
name = os.environ.get("NAME")
project_path = os.environ.get("PROJECT_PATH")
repo = os.environ.get("LOCALDEV_REPO", "/repo")
tilt_image_0 = os.environ.get("TILT_IMAGE_0", "default")
virtual_instance_id = os.environ.get("VIRTUAL_INSTANCE_ID", "dxp.lfr.dev")
workspace = os.environ.get("WORKSPACE", "/workspace")


def generate_workload_yaml():
    cpu = "100m"
    envs = []
    memory = "50M"
    readyPath = ""
    targetPort = 80
    workload = "static"
    init_metadata = "False"
    schedule = None

    # check for a LCP.json to determine workload type
    # if LCP.json doesn't exist then just default to "static" workload
    lcp_json_file = "%s/%s/build/liferay-client-extension-build/LCP.json" % (workspace, project_path)

    # check if lcp.json exists
    if os.path.exists(lcp_json_file):
        f = open(lcp_json_file)
        lcp_json = json.load(f)
        kind = lcp_json.get("kind", None)
        if kind == "Deployment":
            workload = "deployment"
            readyPath = "/ready"
        elif kind == "Job":
            workload = "job"
        elif kind == "CronJob":
            workload = "cronjob"
            schedule = lcp_json.get("schedule", "* * * * *")
        lcpMemory = lcp_json.get("memory", None)
        if lcpMemory:
            memory = "%sM" % lcpMemory
        lcpCpu = lcp_json.get("cpu", None)
        if lcpCpu:
            cpu = "%sm" % (lcpCpu * 1000)
        lcpEnv = lcp_json.get("env", None)
        if lcpEnv:
            envs = lcpEnv
        lcpLoadBalancer = lcp_json.get("loadBalancer", None)
        if lcpLoadBalancer:
            lcpTargetPort = lcpLoadBalancer.get("targetPort", None)
            if lcpTargetPort:
                targetPort = lcpTargetPort
        f.close()

    client_extension_yaml_file = "%s/%s/client-extension.yaml" % (
        workspace,
        project_path,
    )

    if os.path.exists(client_extension_yaml_file):
        f = open(client_extension_yaml_file)
        client_extension_object = yaml.safe_load(f)

        for key in client_extension_object:
            client_extension = client_extension_object.get(key)
            if isinstance(client_extension, dict):
                client_extension_type = client_extension.get("type", None)
                if client_extension_type and client_extension_type.startswith(
                    "oAuthApplication"
                ):
                    init_metadata = "True"
                    break
        f.close()

    ytt_args = [
        "ytt",
        "-f %s/k8s/workloads/%s" % (repo, workload),
        "--data-value-yaml initMetadata=%s" % init_metadata,
        "--data-value image=%s" % tilt_image_0,
        "--data-value serviceId=%s" % name,
        "--data-value-yaml targetPort=%s" % targetPort,
        "--data-value virtualInstanceId=%s" % virtual_instance_id,
        "--data-value lfrdevDomain=%s" % lfrdev_domain,
    ]

    if cpu:
        ytt_args.append("--data-value cpu=%s" % cpu)

    if memory:
        ytt_args.append("--data-value-yaml memory=%s" % memory)

    if envs:
        ytt_args.append("--data-value-yaml envs='%s'" % envs)

    if readyPath:
        ytt_args.append("--data-value readyPath=%s" % readyPath)

    if schedule:
        ytt_args.append("--data-value schedule='%s'" % schedule)

    find_args = [
        "fdfind",
        "--exclude 'build'",
        "--exclude 'node_modules'",
        "--exclude 'node_modules_cache'",
        "--glob '*.client-extension-config.json'",
        "--no-ignore",
        "%s/%s" % (workspace, project_path),
        "%s/%s/build/liferay-client-extension-build" % (workspace, project_path),
        "2>/dev/null",
    ]

    client_extension_config_json_files = (
        os.popen(" ".join(find_args)).read().splitlines()
    )

    for json_file in client_extension_config_json_files:
        ytt_args.append("-f %s" % json_file)

    cmd = " ".join(ytt_args)

    tmpfile = "/tmp/.%s.yttc" % name

    with open(tmpfile, "w") as f:
        f.write(cmd)

    return os.popen(cmd).read()
