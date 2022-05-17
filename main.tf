resource "nxos_system" "topSystem" {
  count = contains(keys(var.model), "hostname") ? 1 : 0
  name  = var.model.hostname
}

module "nxos_features" {
  source            = "netascode/features/nxos"
  version           = ">= 0.1.0"
  count             = contains(keys(var.model), "features") ? 1 : 0
  bfd               = contains(var.model.features, "bfd")
  bgp               = contains(var.model.features, "bgp")
  dhcp              = contains(var.model.features, "dhcp")
  evpn              = contains(var.model.features, "evpn")
  fabric_forwarding = contains(var.model.features, "fabric_forwarding")
  hsrp              = contains(var.model.features, "hsrp")
  interface_vlan    = contains(var.model.features, "interface_vlan")
  isis              = contains(var.model.features, "isis")
  lacp              = contains(var.model.features, "lacp")
  lldp              = contains(var.model.features, "lldp")
  nv_overlay        = contains(var.model.features, "nv_overlay")
  ospf              = contains(var.model.features, "ospf")
  ospfv3            = contains(var.model.features, "ospfv3")
  pim               = contains(var.model.features, "pim")
  ptp               = contains(var.model.features, "ptp")
  pvlan             = contains(var.model.features, "pvlan")
  ssh               = contains(var.model.features, "ssh")
  tacacs            = contains(var.model.features, "tacacs")
  telnet            = contains(var.model.features, "telnet")
  udld              = contains(var.model.features, "udld")
  vn_segment        = contains(var.model.features, "vn_segment")
  vpc               = contains(var.model.features, "vpc")
}

resource "nxos_bridge_domain" "l2BD" {
  for_each     = contains(keys(var.model), "vlans") ? { for v in var.model.vlans : v.id => v } : {}
  fabric_encap = "vlan-${each.value.id}"
  access_encap = contains(keys(each.value), "vn_segment") ? "vxlan-${each.value.vn_segment}" : "unknown"
  name         = lookup(each.value, "name", "")

  depends_on = [
    module.nxos_features
  ]
}

module "nxos_vrf" {
  source = "netascode/vrf/nxos"
  # source = "../terraform-nxos-vrf"
  version             = ">= 0.1.2"
  for_each            = { for v in var.model.vrfs : v.name => v }
  name                = each.value.name
  description         = lookup(each.value, "description", "")
  vni                 = lookup(each.value, "vni", null)
  route_distinguisher = lookup(each.value, "route_distinguisher", null)
  address_families    = lookup(each.value, "address_families", null)

  depends_on = [
    module.nxos_features
  ]
}

module "nxos_interface_ethernet" {
  source                   = "netascode/interface-ethernet/nxos"
  version                  = ">= 0.1.0"
  for_each                 = contains(keys(var.model), "interfaces_ethernet") ? { for v in var.model.interfaces_ethernet : v.id => v } : {}
  id                       = each.value.id
  access_vlan              = lookup(each.value, "access_vlan", 1)
  admin_state              = lookup(each.value, "admin_state", true)
  auto_negotiation         = lookup(each.value, "auto_negotiation", "on")
  bandwidth                = lookup(each.value, "bandwidth", 0)
  delay                    = lookup(each.value, "delay", 1)
  description              = lookup(each.value, "description", "")
  duplex                   = lookup(each.value, "duplex", "auto")
  fec_mode                 = lookup(each.value, "fec_mode", "auto")
  layer3                   = lookup(each.value, "layer3", false)
  link_debounce_down       = lookup(each.value, "link_debounce_down", 100)
  link_debounce_up         = lookup(each.value, "link_debounce_up", 0)
  link_logging             = lookup(each.value, "link_logging", "default")
  medium                   = lookup(each.value, "medium", "broadcast")
  mode                     = lookup(each.value, "mode", "access")
  mtu                      = lookup(each.value, "mtu", 1500)
  native_vlan              = lookup(each.value, "native_vlan", 1)
  speed                    = lookup(each.value, "speed", "auto")
  speed_group              = lookup(each.value, "speed_group", "auto")
  trunk_vlans              = lookup(each.value, "trunk_vlans", "1-4094")
  uni_directional_ethernet = lookup(each.value, "uni_directional_ethernet", "disable")
  urpf                     = lookup(each.value, "urpf", "disabled")
  vrf                      = lookup(each.value, "vrf", "default")
  ip_unnumbered            = lookup(each.value, "ip_unnumbered", "unspecified")
  ipv4_address             = lookup(each.value, "ipv4_address", null)

  depends_on = [
    module.nxos_vrf
  ]
}

module "nxos_interface_vlan" {
  source        = "netascode/interface-vlan/nxos"
  version       = ">= 0.1.0"
  for_each      = contains(keys(var.model), "interfaces_vlan") ? { for v in var.model.interfaces_vlan : v.id => v } : {}
  id            = each.value.id
  admin_state   = lookup(each.value, "admin_state", true)
  delay         = lookup(each.value, "delay", 1)
  description   = lookup(each.value, "description", "")
  bandwidth     = lookup(each.value, "bandwidth", 1000000)
  ip_forward    = lookup(each.value, "ip_forward", false)
  ip_drop_glean = lookup(each.value, "ip_drop_glean", false)
  medium        = lookup(each.value, "medium", "bcast")
  mtu           = lookup(each.value, "mtu", 1500)
  vrf           = lookup(each.value, "vrf", "default")
  ipv4_address  = lookup(each.value, "ipv4_address", null)

  depends_on = [
    module.nxos_vrf
  ]
}

module "nxos_interface_loopback" {
  source       = "netascode/interface-loopback/nxos"
  version      = ">= 0.1.1"
  for_each     = contains(keys(var.model), "interfaces_loopback") ? { for v in var.model.interfaces_loopback : v.id => v } : {}
  id           = each.value.id
  admin_state  = lookup(each.value, "admin_state", true)
  description  = lookup(each.value, "description", "")
  vrf          = lookup(each.value, "vrf", "default")
  ipv4_address = lookup(each.value, "ipv4_address", null)

  depends_on = [
    module.nxos_vrf
  ]
}

module "nxos_ospf" {
  # source = "../terraform-nxos-ospf"
  source   = "netascode/ospf/nxos"
  version  = ">= 0.1.0"
  for_each = contains(keys(var.model), "ospf") ? { for v in var.model.ospf : v.name => v } : {}
  name     = each.value.name
  vrfs     = each.value.vrfs

  depends_on = [
    module.nxos_interface_ethernet,
    module.nxos_interface_vlan,
    module.nxos_interface_loopback
  ]
}

module "nxos_bgp" {
  source                  = "netascode/bgp/nxos"
  version                 = ">= 0.1.0"
  count                   = contains(keys(var.model), "bgp") ? 1 : 0
  asn                     = var.model.bgp.asn
  enhanced_error_handling = lookup(var.model.bgp, "enhanced_error_handling", true)
  template_peers          = lookup(var.model.bgp, "template_peers", null)
  vrfs                    = lookup(var.model.bgp, "vrfs", null)

  depends_on = [
    module.nxos_interface_ethernet,
    module.nxos_interface_vlan,
    module.nxos_interface_loopback

  ]
}

module "nxos_fabric_forwarding" {
  source              = "netascode/fabric-forwarding/nxos"
  version             = ">= 0.1.0"
  count               = contains(keys(var.model), "fabric_forwarding") ? 1 : 0
  anycast_gateway_mac = var.model.fabric_forwarding.anycast_gateway_mac
  vlan_interfaces     = [for v in var.model.fabric_forwarding.anycast_gateway_vlans : { "id" = v }]

  depends_on = [
    nxos_bridge_domain.l2BD,
    module.nxos_interface_vlan
  ]
}

module "nxos_interface_nve" {
  source                           = "netascode/interface-nve/nxos"
  version                          = ">= 0.1.0"
  admin_state                      = lookup(var.model.interface_nve, "admin_state", false)
  advertise_virtual_mac            = lookup(var.model.interface_nve, "advertise_virtual_mac", false)
  hold_down_time                   = lookup(var.model.interface_nve, "hold_down_time", 180)
  host_reachability_protocol       = lookup(var.model.interface_nve, "host_reachability_protocol", "Flood-and-learn")
  ingress_replication_protocol_bgp = lookup(var.model.interface_nve, "ingress_replication_protocol_bgp", false)
  multicast_group_l2               = lookup(var.model.interface_nve, "multicast_group_l2", "0.0.0.0")
  multicast_group_l3               = lookup(var.model.interface_nve, "multicast_group_l3", "0.0.0.0")
  multisite_source_interface       = lookup(var.model.interface_nve, "multisite_source_interface", "unspecified")
  source_interface                 = lookup(var.model.interface_nve, "source_interface", "unspecified")
  suppress_arp                     = lookup(var.model.interface_nve, "suppress_arp", false)
  suppress_mac_route               = lookup(var.model.interface_nve, "suppress_mac_route", false)
  vnis                             = lookup(var.model.interface_nve, "vnis", [])

  depends_on = [
    nxos_bridge_domain.l2BD
  ]
}

module "nxos_evpn" {
  # source                           = "netascode/interface-nve/nxos"
  source = "../terraform-nxos-evpn"
  # version                          = ">= 0.1.0"
  count = contains(keys(var.model), "evpn") ? 1 : 0
  vnis  = contains(keys(var.model), "evpn") ? lookup(var.model.evpn, "vnis", []) : []

  depends_on = [
    nxos_bridge_domain.l2BD
  ]
}

