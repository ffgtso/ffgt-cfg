include apt
# Global parameters for this host
class { 'ff_gln_gw::params':
  router_id => "10.255.144.1", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  wan_devices => ['eth1'],   # A array of devices which should be in the wan zone
  include_dn42_routes => "yes",  # yes/no(default) to include routes from DN42
  include_chaos_routes => "no"  # yes/no(default) to include routes from ChaosVPN
}

ff_gln_gw::gateway { 'mesh_ffgt':
      mesh_name    => "Freifunk Guetersloh",
      mesh_code    => "ffgt",
      range_ipv6   => "2001:bf7:1310::/44",
      range_ipv4   => "10.255.0.0/16",
      local_ipv6   => "2001:bf7:1310:300::aff:9001", # local v6 IP
      mesh_peerings => "/root/mesh_peerings_bgp1.yaml",
      have_mesh_peerings => "no",
}

ff_gln_gw::icvpn::setup {
  'gueterslohbgp1':
    icvpn_as => 65533,
    icvpn_ipv4_address => "10.207.0.136",
    icvpn_ipv6_address => "fec0::a:cf:0:88",
    icvpn_exclude_peerings     => [guetersloh],
    mesh_code    => "ffgt",
    tinc_keyfile       => "/root/tinc_rsa_key-bgp2.priv"
}

ff_gln_gw::bird4::ospf {
  'ospf-ffgt':
    mesh_code => "ffgt",
    range_ipv4 => "10.255.0.0/16",
    ospf_peerings => "/root/ospf_peerings_bgp1.yaml",
    have_ospf_peerings => "yes",
    ospf_links    => "/root/ospf_links_bgp1.yaml",
    have_ospf_links => "yes"
}

ff_gln_gw::bird6::ospf {
  'ospf-ffgt':
    mesh_code => "ffgt",
    range_ipv6 => "2a03:2260:117:1::/64",
    ospf_peerings => "/root/ospf_peerings_bgp1.yaml",
    have_ospf_peerings => "yes",
    ospf_links    => "/root/ospf_links_bgp1.yaml",
    have_ospf_links => "yes"
}

ff_gln_gw::gre::tunnel  {
  'ffgt':
    gre_yaml => "/root/gre-tunnel-bgp1.yaml",
}

##class { 'ff_gln_gw::alfred': master => false }

class { 'ff_gln_gw::etckeeper': }

class {
  'ff_gln_gw::uplink::ip':
#    nat_network => '185.66.193.64/32', # network of IPv4 addresses usable for NAT
    nat_network => '192.251.226.81/32',
    tunnel_network => '100.64.0.0/24', # network of tunnel IPs to exclude from NAT
}

#ff_gln_gw::uplink::tunnel {
#    'fra-a':
#      local_public_ip   => '192.251.226.114',  # local public IPv4 of this gateway
#      remote_public_ip  => '185.66.194.0',     # remote public IPv4 of the tunnel endpoint
#      local_ipv4        => '100.64.0.179/31',  # tunnel IPv4 on our side in CIDR notation
#      remote_ip         => '100.64.0.178',     # tunnel IPv4 on the remote side
#      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
#}

#ff_gln_gw::uplink::tunnel {
#    'dus-a':
#      local_public_ip   => '192.251.226.114',  # local public IPv4 of this gateway
#      remote_public_ip  => '185.66.193.0',     # remote public IPv4 of the tunnel endpoint
#      local_ipv4        => '100.64.0.181/31',  # tunnel IPv4 on our side in CIDR notation
#      remote_ip         => '100.64.0.180',     # tunnel IPv4 on the remote side
#      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
#}

ff_gln_gw::uplink::tunnel {
    'vpn01':
      local_public_ip   => '192.251.226.114',
      remote_public_ip  => '192.251.226.125',
      local_ipv4        => '100.64.0.7/31',
      remote_ip         => '100.64.0.6',
      remote_as         => '65533',
}

#ff_gln_gw::bird4::local { 'local': }

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

ff_gln_gw::monitor::vnstat::device { 'eth1': }


ff_gln_gw::monitor::rrd_traffic { "rrd_traffic":
  rrd_interfaces => "rrd-traffic.yaml",
  rrd_upload_url => "http://guetersloh.freifunk.net/rrd_traffic_upload.php"
}
