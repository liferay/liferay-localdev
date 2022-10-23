#!/usr/bin/python3
import ast
import os

cpu=os.environ.get('CPU', None)
envs = ast.literal_eval(os.environ.get('ENVS', None))
lfrdev_domain=os.environ.get('LFRDEV_DOMAIN', 'lfr.dev')
memory=os.environ.get('MEMORY', None)
name=os.environ.get('NAME')
repo=os.environ.get('LOCALDEV_REPO', '/repo')
target_port=os.environ.get('TARGET_PORT', 8080)
tilt_image_0=os.environ['TILT_IMAGE_0']
virtual_instance_id=os.environ.get('VIRTUAL_INSTANCE_ID', 'dxp.lfr.dev')
workload=os.environ.get('WORKLOAD')
workspace=os.environ.get('WORKSPACE', '/workspace')

def generate_yaml():
  init_metadata = False

  if workload != "static":
    init_metadata = True

  ytt_args=[
    'ytt',
    "-f %s/k8s/workloads/%s" % (repo, workload),
    "--data-value-yaml initMetadata=%s" % init_metadata,
    "--data-value image=%s" % tilt_image_0,
    "--data-value serviceId=%s" % name,
    "--data-value-yaml targetPort=%s" % target_port,
    "--data-value virtualInstanceId=%s" % virtual_instance_id,
    "--data-value lfrdevDomain=%s" % lfrdev_domain]

  if cpu:
    ytt_args.append("--data-value-yaml cpu=%s" % cpu)

  if memory:
    ytt_args.append("--data-value-yaml memory=%s" % memory)

  if envs:
    ytt_args.append("--data-value-yaml envs='%s'" % envs)

  find_args=[
    "find %s/client-extensions/%s" % (workspace, name),
    "-name *.client-extension-config.json",
    "-not -path '*/node_modules/*' -not -path '*/node_modules_cache/*'",
    "2>/dev/null"]

  client_extension_config_json_files=os.popen(' '.join(find_args)).read().splitlines()

  for json_file in client_extension_config_json_files:
    ytt_args.append("-f %s" % json_file)

  return os.popen(' '.join(ytt_args)).read()