<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-nxos-config/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-nxos-config/actions/workflows/test.yml)

# Terraform NX-OS Configuration Module

This module can manage a Cisco Nexus 9000 configuration.

## Examples

```hcl

locals {
  model_string = file("${path.module}/nxos_model.yaml")
  model        = yamldecode(local.model_string)
}

module "nxos_config" {
  source  = "netascode/config/nxos"
  version = ">= 0.0.1"

  model = local.model
}
```

Example of `nxos_model.yaml` file

```yaml
hostname: "site-1-leaf-1"
features:
  - ospf
  - bgp
  - interface_vlan
  - vn_segment
  - evpn
  - nv_overlay
fabric_forwarding:
  anycast_gateway_mac: 20:20:00:00:10:12
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
      - address_family: "l2vpn_evpn"
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
          - address_family: "ipv4_unicast"
            send_community_standard: true
            send_community_extended: true
vrfs:
  - name: TENANT-1
    vni: 3901
    route_distinguisher: auto
    address_families:
      - address_family: "ipv4_unicast"
        route_target_both_auto: true
        route_target_both_auto_evpn: true
interfaces_ethernet:
  - id: "1/49"
    description: "uplink 1"
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: "192.168.1.0/31"
    urpf: "loose"
  - id: "1/50"
    description: "uplink 2"
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: "192.168.1.2/31"
  - id: "1/51"
    description: "uplink 3"
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: "192.168.1.4/31"
  - id: "1/52"
    description: "uplink 4"
    layer3: true
    link_debounce_down: 0
    mtu: 9000
    ipv4_address: "192.168.1.6/31"
  - id: "1/48"
    description: "link to load balancer"
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
    ipv4_address: "192.168.1.8/31"
  - id: 3901
    description: L3VNI for vrf TENANT-1
    vrf: TENANT-1
    mtu: 9216
    ip_forward: true
  - id: 101
    description: "Site-local VLAN"
    vrf: TENANT-1
    mtu: 9216
    ipv4_address: "10.1.0.1/24"
  - id: 102
    description: "Stretched VLAN"
    vrf: TENANT-1
    mtu: 9216
    ipv4_address: "10.12.0.1/24"
interface_nve:
  admin_state: true
  hold_down_time: 300
  host_reachability_protocol: bgp
  ingress_replication_protocol_bgp: true
  source_interface: "lo0"
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | >= 0.3.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nxos"></a> [nxos](#provider\_nxos) | >= 0.3.12 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_device"></a> [device](#input\_device) | A device name from the provider configuration. | `string` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | NX-OS configuration model. | `any` | n/a | yes |

## Outputs

No outputs.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nxos_features"></a> [nxos\_features](#module\_nxos\_features) | netascode/features/nxos | >= 0.1.0 |
| <a name="module_nxos_vrf"></a> [nxos\_vrf](#module\_nxos\_vrf) | netascode/vrf/nxos | >= 0.1.2 |
| <a name="module_nxos_interface_ethernet"></a> [nxos\_interface\_ethernet](#module\_nxos\_interface\_ethernet) | netascode/interface-ethernet/nxos | >= 0.1.0 |
| <a name="module_nxos_interface_vlan"></a> [nxos\_interface\_vlan](#module\_nxos\_interface\_vlan) | netascode/interface-vlan/nxos | >= 0.1.0 |
| <a name="module_nxos_interface_loopback"></a> [nxos\_interface\_loopback](#module\_nxos\_interface\_loopback) | netascode/interface-loopback/nxos | >= 0.1.1 |
| <a name="module_nxos_ospf"></a> [nxos\_ospf](#module\_nxos\_ospf) | netascode/ospf/nxos | >= 0.1.0 |
| <a name="module_nxos_bgp"></a> [nxos\_bgp](#module\_nxos\_bgp) | netascode/bgp/nxos | >= 0.1.0 |
| <a name="module_nxos_fabric_forwarding"></a> [nxos\_fabric\_forwarding](#module\_nxos\_fabric\_forwarding) | netascode/fabric-forwarding/nxos | >= 0.1.0 |
| <a name="module_nxos_interface_nve"></a> [nxos\_interface\_nve](#module\_nxos\_interface\_nve) | netascode/interface-nve/nxos | >= 0.1.0 |
| <a name="module_nxos_evpn"></a> [nxos\_evpn](#module\_nxos\_evpn) | ../terraform-nxos-evpn | n/a |

## Resources

| Name | Type |
|------|------|
| [nxos_bridge_domain.l2BD](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/bridge_domain) | resource |
| [nxos_system.topSystem](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/system) | resource |
<!-- END_TF_DOCS -->