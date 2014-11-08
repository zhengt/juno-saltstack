# http://docs.openstack.org/juno/install-guide/install/yum/content/keystone-install.html

{% from "mariadb/map.jinja" import mysql with context %}

{% set mysql_host = salt['pillar.get']('openstack:controller') %}
{% set controller = salt['pillar.get']('openstack:controller') %}
{% set admin_token = salt['pillar.get']('openstack:ADMIN_TOKEN') %}
{% set mysql_root_password = salt['pillar.get']('mariadb:root_password') %}

{% set admin_pass = salt['pillar.get']('openstack:ADMIN_PASS') %}
{% set demo_pass = salt['pillar.get']('openstack:DEMO_PASS') %}

{% set keystone_dbpass = salt['pillar.get']('openstack:KEYSTONE_DBPASS') %}

# To configure prerequisites

keystone_db:
  mysql_database.present:
    - name: keystone
    - host: {{ mysql_host }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
      - pkg: {{ mysql.python }}
      {%- if mysql_root_password %}
      - cmd: mysql_root_password 
      {%- endif %}

keystone_grant_localhost:
  mysql_user.present:
    - name: keystone
    - host: localhost
    - password: {{ keystone_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
      - pkg: {{ mysql.python }}
      {%- if mysql_root_password %}
      - cmd: mysql_root_password
      {%- endif %}

  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: localhost
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
      - pkg: {{ mysql.python }}
      {%- if mysql_root_password %}
      - cmd: mysql_root_password
      {%- endif %}

keystone_grant_all:
  mysql_user.present:
    - name: keystone
    - host: '%'
    - password: {{ keystone_dbpass }}
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
      - pkg: {{ mysql.python }}
      {%- if mysql_root_password %}
      - cmd: mysql_root_password
      {%- endif %}

  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '%'
    - connection_user: root
    - connection_pass: '{{ mysql_root_password }}'
    - connection_charset: utf8
    - require:
      - service: {{ mysql.service }}
      - pkg: {{ mysql.python }}
      {%- if mysql_root_password %}
      - cmd: mysql_root_password
      {%- endif %}

### To install and configure the components
#### 1. Run the following command to install the packages:

openstack-keystone:
  pkg.installed:
    - name: openstack-keystone

python-keystoneclient:
  pkg.installed:
    - name: python-keystoneclient

#### 2. Edit the /etc/keystone/keystone.conf file and complete the following actions:

#### a.

keystone_conf_admin_token:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: DEFAULT
    - parameter: admin_token
    - value: {{ admin_token }}

#### b.

keystone_conf_database_connection:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: database
    - parameter: connection
    - value: 'mysql://keystone:{{ keystone_dbpass }}@{{ mysql_host }}/keystone'     

#### c.

keystone_conf_token_provider:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: token
    - parameter: provider
    - value: keystone.token.providers.uuid.Provider

keystone_conf_token_driver:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: token
    - parameter: driver
    - value: keystone.token.persistence.backends.sql.Token

#### d.

keystone_conf_:
  openstack_config.present:
    - filename: /etc/keystone/keystone.conf
    - section: DEFAULT
    - parameter: verbose
    - value: 'True'


#### 3. Create generic certificates and keys and restrict access to the associated files:

keystone_pki_setup:
  cmd.run:
    - name: keystone-manage pki_setup --keystone-user keystone --keystone-group keystone

keystone_pki_setup_ssl:
  file.directory:
    - name: /etc/keystone/ssl
    - user: keystone
    - group: keystone
    - mode: 750
    - recurse:
      - user
      - group

/var/log/keystone:
  file.directory:
    - user: keystone
    - group: keystone
    - mode: 750
    - create: True

/var/log/keystone/keystone.log:
  file.managed:
    - user: keystone
    - group: keystone
    - mode: '644'
    - create: True

#### 4. 

keystone_db_sync:
  cmd.run:
    - name: keystone-manage db_sync

### To finalize installation

#### 1. Start the Identity service and configure it to start when the system boots:

keystone_enabled_on_boot:
  service.enabled:
    - name: openstack-keystone
    - enabled: True

keystone_service:
  service.running:
    - name: openstack-keystone
    - enable: True

#keystone_conf_:
#  openstack_config.present:
#    - filename: /etc/keystone/keystone.conf
#    - section: 
#    - parameter: 
#    - value:

# http://docs.openstack.org/juno/install-guide/install/yum/content/keystone-users.html

keystone_tenants:
  keystone.tenant_present:
    - names:
      - admin
      - demo
      - service
    - connection_token: {{ admin_token }}

keystone_roles:
  keystone.role_present:
    - names:
      - admin
      - _member_
    - connection_token: {{ admin_token }}

keystone_admin:
  keystone.user_present:
    - name: admin
    - password: {{ admin_pass }}
    - email: devops@workstation-02.mgmt
    - roles:
      - admin:   # tenants
        - admin  # roles
      - service:
        - admin
        - _member_
      - require:
        - keystone: keystone_tenants
        - keystone: keystone_roles
    - connection_token: {{ admin_token }}

keystone_demo:
  keystone.user_present:
    - name: demo
    - password: {{ demo_pass }}
    - email: devops@workstation-02.mgmt
    - roles:
      - demo:
        - _member_
      - require:
        - keystone: keystone_tenants
        - keystone: keystone_roles
    - connection_token: {{ admin_token }}

## http://docs.openstack.org/juno/install-guide/install/yum/content/keystone-services.html

keystone_identity_service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: 'Service Tenant'
    - connection_token: {{ admin_token }}

keystone_api_endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: 'http://{{ controller }}:5000/v2.0'
    - internalurl: 'http://{{ controller }}:5000/v2.0'
    - adminurl: 'http://{{ controller }}:35357/v2.0'
    - region: regionOne
    - connection_token: {{ admin_token }}
