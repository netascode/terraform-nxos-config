<!-- BEGIN_TF_DOCS -->
# NX-OS OSPF Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

```hcl

locals {
  model_string = file("${path.module}/nxos_model.yaml")
  model        = yamldecode(local.model_string)
}

module "nxos_config" {
  source  = "netascode/config/nxos"
  version = ">= 0.1.0"

  model = local.model
}
```

Example of `nxos_model.yaml` file

```yaml
hostname: 'site-1-leaf-1'
features:
  - ospf
  - bgp
  - interface_vlan
  - vn_segment
  - evpn
  - nv_overlay
fabric_forwarding:
  anycast_gateway_mac: '20:20:00:00:10:12'
  anycast_gateway_vlans:
    - 101
    - 102
evpn:
  vnis:
    - vni: 101
      route_distinguisher: auto
      route_target_both_auto: true
    - vni: 102
      route_distinguisher: auto
      route_target_both_auto: true
ospf:
  - name: underlay
    vrfs:
      - vrf: default
        router_id: 172.16.1.1
        bandwidth_reference: 1000
        banwidth_reference_unit: gbps
        interfaces:
          - interface: eth1/49
            area: 0.0.0.0
            network_type: p2p
          - interface: eth1/50
            area: 0.0.0.0
            network_type: p2p
bgp:
  asn: 65001
  enhanced_error_handling: false
  template_peers:
    - name: SPINE-PEERS
      asn: 65001
      description: Spine Peers template
      source_interface: lo0
      address_families:
        - address_family: 'l2vpn_evpn'
          send_community_standard: true
          send_community_extended: true
  vrfs:
    - vrf: default
      router_id: 172.16.1.1
      log_neighbor_changes: true
      graceful_restart_stalepath_time: 600
      neighbors:
        - ip: 172.16.1.201
          description: site-1-spine-1
          inherit_peer: SPINE-PEERS
        - ip: 172.16.1.202
          description: site-1-spine-2
          inherit_peer: SPINE-PEERS
    - vrf: TENANT-1
      router_id: 172.16.1.1
      log_neighbor_changes: true
      graceful_restart_stalepath_time: 600
      neighbors:
        - ip: 100.1.1.1
          description: External peer
          asn: 65010
          address_families:
            - address_family: 'ipv4_unicast'
              send_community_standard: true
              send_community_extended: true
vrfs:
  - name: default
  - name: TENANT-1
    vni: 3901
    route_distinguisher: auto
    address_families:
      - address_family: 'ipv4_unicast'
        route_target_both_auto: true
        route_target_both_auto_evpn: true
interfaces_ethernet:
  - id: '1/49'
    description: 'uplink 1'
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: '192.168.1.0/31'
    urpf: 'loose'
  - id: '1/50'
    description: 'uplink 2'
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: '192.168.1.2/31'
  - id: '1/51'
    description: 'uplink 3'
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: '192.168.1.4/31'
  - id: '1/52'
    description: 'uplink 4'
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: '192.168.1.6/31'
  - id: '1/48'
    description: 'link to load balancer'
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: 100.1.1.0/31
    vrf: TENANT-1
interfaces_loopback:
  - id: 0
    description: BGP peering
    ipv4_address: 172.16.1.1/32
  - id: 1
    description: NVE interface
    ipv4_address: 172.17.1.1/32
interfaces_vlan:
  - id: 3900
    admin_state: false
    description: OSPF backup link via peer-link
    mtu: 9216
    ipv4_address: '192.168.1.8/31'
  - id: 3901
    description: L3VNI for vrf TENANT-1
    vrf: TENANT-1
    mtu: 9216
    ip_forward: true
  - id: 101
    description: 'Site-local VLAN'
    vrf: TENANT-1
    mtu: 9216
    ipv4_address: '10.1.0.1/24'
  - id: 102
    description: 'Stretched VLAN'
    vrf: TENANT-1
    mtu: 9216
    ipv4_address: '10.12.0.1/24'
interface_nve:
  admin_state: true
  hold_down_time: 300
  host_reachability_protocol: bgp
  ingress_replication_protocol_bgp: true
  source_interface: 'lo0'
  vnis:
    - vni: 101
    - vni: 102
    - vni: 3901
      associate_vrf: true
vlans:
  - id: 3900
    name: L3_Backup_routing
  - id: 3901
    vn_segment: 3901
  - id: 101
    vn_segment: 101
    name: server_vlan_site_1
  - id: 102
    vn_segment: 102
    name: server_vlan_stretched
```
<!-- END_TF_DOCS -->