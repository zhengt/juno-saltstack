
{% set ipaddr = salt['grains.get']('openstack_mgmt_ip') %}

enp0s20f0:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: {{ ipaddr }}
    - netmask: 255.255.255.0

{% set ipaddr = salt['grains.get']('openstack_pub_ip') %}

enp0s20f1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: {{ ipaddr }}
    - netmask: 255.255.255.0
