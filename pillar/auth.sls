# openssl rand -hex 10

mariadb:
  root_password: mariadb

openstack:
  METADATA_SECRET: 0cb2bb516881d71eff88
  ADMIN_TOKEN: 016389abda0579b560c0

  RABBIT_PASS: guest
#  RABBIT_PASS: 9b38ae1e7e75e5576ee2
  KEYSTONE_DBPASS: 376ebc0ee6649544c178
  DEMO_PASS: 6efd10a180784267be4c
  ADMIN_PASS: 94bcee677185fee9c0bf
  GLANCE_DBPASS: 6d44ef12b707316851f2
  GLANCE_PASS: d6b6ed7dac1e80c684e8
  NOVA_DBPASS: efc32b404d4f285c1a5a
  NOVA_PASS: a1b587dd687cff6a6dff
  DASH_DBPASS: f0baa153daac61a24102
  CINDER_DBPASS: 5680258bb2c2b4dee1ee
  CINDER_PASS: c9f59d5c328fc3977297
  NEUTRON_DBPASS: f06432c2e047666d99e3
  NEUTRON_PASS: b398f7d80d20b77e238c
  HEAT_DBPASS: a99a98179f6edb0ca113
  HEAT_PASS: c6adaa597fbce9289f90
  CEILOMETER_DBPASS: 55a0690b47fec6f98a31
  CEILOMETER_PASS: d16c43e1a962a554c948
  TROVE_DBPASS: 8d2f0c22de016fe093f4
  TROVE_PASS: 18c357877c7120e6cca4
  SWIFT_PASS: 0d882fe21dfe142ea3df

  controller: controller1
  network: network1

  ## TODO: make this a grain. This k/v is required when setting up neutron
  service_tenant_id: 78b364cc0fab41ba9091eab5b7b6eebb


