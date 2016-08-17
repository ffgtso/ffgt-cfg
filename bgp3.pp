class { 'ff_gln_gw::params':
  router_id => "10.255.144.9", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  wan_devices => ['eth0', "eth1", "eth2"],  # A array of devices which should be in the wan zone
  include_dn42_routes => "no",  # yes/no(default) to include routes from DN42
  include_chaos_routes => "no"  # yes/no(default) to include routes from ChaosVPN
}

ff_gln_gw::gateway { 'mesh_ffgt':
      mesh_name    => "Freifunk Guetersloh",
      mesh_code    => "ffgt",
      range_ipv6   => "2001:bf7:1310::/44",
      range_ipv4   => "10.255.0.0/16",
      local_ipv6   => "2001:bf7:1310:300::aff:9007",
      mesh_peerings => "/root/mesh-peerings_bgp3.yaml",
      have_mesh_peerings => "no",
}

ff_gln_gw::icvpn::setup {
  'gueterslohbgp3':
    mesh_code => "ffgt",
    icvpn_as => 65533,
    icvpn_ipv4_address => "10.207.0.132",
    icvpn_ipv6_address => "fec0::a:cf:0:84",
    icvpn_exclude_peerings     => [guetersloh],
    tinc_keyfile       => "/root/tinc_rsa_key-bgp3.priv"
}

ff_gln_gw::bird4::ospf {
  'ospf-ffgt':
    mesh_code => "ffgt",
    range_ipv4 => "10.255.0.0/16",
    ospf_peerings => "/root/ospf-peerings_bgp3.yaml",
    have_ospf_peerings => "yes",
    ospf_links    => "/root/ospf-links_bgp3.yaml",
    have_ospf_links => "yes"
}

ff_gln_gw::gre::tunnel  {
  'ffgt':
    gre_yaml => "/root/gre-tunnel-bgp3.yaml",
}

#class { 'ff_gln_gw::alfred': master => false }

class { 'ff_gln_gw::etckeeper': }

#ff_gln_gw::uplink::static {
#  'susan':
#    endpoint_ip => '192.251.226.65',
#    do_nat => "no"
#}

#class {
#  'ff_gln_gw::uplink::bgp':
#    do_nat => "no"
#}

#class {
#  'ff_gln_gw::uplink::ip':
#    nat_network => '192.251.226.225/32', # network of IPv4 addresses usable for NAT
#    tunnel_network => '100.64.0.0/24', # network of tunnel IPs to exclude from NAT
#}
#
#ff_gln_gw::uplink::tunnel {
#    'vpn01':
#      local_public_ip   => '5.9.167.218',      # local public IPv4 of this gateway
#      remote_public_ip  => '192.251.226.125',   # remote public IPv4 of the tunnel endpoint
#      local_ipv4        => '100.64.0.5/31',  # tunnel IPv4 on our side in CIDR notation
#      remote_ip         => '100.64.0.4', # tunnel IPv4 on the remote side, again as CIDR
#      remote_as         => '65533',       # ASN of the BGP server announcing a default route for you
#}

class {
  'ff_gln_gw::uplink::ip':
    nat_network => '185.66.193.66/32', # network of IPv4 addresses usable for NAT
    tunnel_network => '100.64.0.0/24', # network of tunnel IPs to exclude from NAT
}

ff_gln_gw::uplink::tunnel {
    'ber-a':
      local_public_ip   => '5.9.167.218',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.195.0',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.1.145/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.1.144',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'ber-b':
      local_public_ip   => '5.9.167.218',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.195.1',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.1.149/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.1.148',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'dus-a':
      local_public_ip   => '5.9.167.218',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.193.0',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.1.153/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.1.152',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'dus-b':
      local_public_ip   => '5.9.167.218',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.193.1',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.1.157/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.1.156',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
}

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

