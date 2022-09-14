virtual_instance_id="dxp.localdev.me"

update_settings(max_parallel_updates=1)
watch_file('k8s/extension/')
watch_file('k8s/extension_job/')

# Tilt methods

def process_extension(
    name, source_deps = [], objects = [], port_forwards = [], resource_deps = [], links = []):
  custom_build(
    name,
    'extensions/%s/build.sh' % name,
    deps=['extensions/%s/src' % name] + source_deps,
    ignore=[]
  )

  k8s_yaml(local(["extensions/%s/yaml.sh" % name, virtual_instance_id]))
  watch_file('extensions/%s/%s.client-extension-config.json' % (name, name))
  watch_file('extensions/%s/yaml.sh' % name)

  k8s_resource(
    labels=['extensions'],
    port_forwards=port_forwards,
    objects=['%s-%s-lxc-ext-provision-metadata:configmap' % (name, virtual_instance_id)] + objects,
    resource_deps=resource_deps,
    workload=name,
    links=links
  )

if config.tilt_subcommand == 'down':
  local('kubectl delete cm -l lxc.liferay.com/metadataType=dxp')
  local('kubectl delete cm -l lxc.liferay.com/metadataType=ext-init')

# Declare extensions

# coupondfn
process_extension(
  name='coupondfn')

# coupondata
process_extension(
  name='coupondata',
  resource_deps=['coupondfn'])

# couponpdf
process_extension(
  name='couponpdf',
  source_deps=[
    'extensions/couponpdf/pom.xml'
  ], 
  objects=[
    'couponpdf:ingress',
    'couponpdf:ingressroute'
  ],
  port_forwards=['8001'],
  resource_deps=['coupondfn'],
  links=[link('https://couponpdf.localdev.me/coupons/print', 'Print a coupon')])

# uscities
process_extension(
  name='uscities',
  source_deps=[
    'extensions/uscities/pom.xml'
  ],
  objects=[
    'uscities:ingress',
    'uscities:ingressroute'
  ],
  port_forwards=['8002'])
