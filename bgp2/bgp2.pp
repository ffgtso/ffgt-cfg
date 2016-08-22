class { 'ff_gln_gw::params':
  router_id => "10.255.144.2", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  include_dn42_routes => "yes",  # yes/no(default) to include routes from DN42
  include_chaos_routes => "no",  # yes/no(default) to include routes from ChaosVPN
  wan_devices => ['eth1']   # A array of devices which should be in the wan zone
}

ff_gln_gw::gateway { 'mesh_ffgt':
      mesh_name    => "Freifunk Guetersloh",
      mesh_code    => "ffgt",
      range_ipv6   => "2001:bf7:1310::/44",
      range_ipv4   => "10.255.0.0/16",
      local_ipv6   => "2001:bf7:1310:300::aff:9002", # local v6 IP
      mesh_peerings => "/root/mesh-peerings_bgp2.yaml",
      have_mesh_peerings => "no",
}

ff_gln_gw::icvpn::setup {
  'gueterslohbgp2':
    icvpn_as => 65533,
    icvpn_ipv4_address => "10.207.0.133",
    icvpn_ipv6_address => "fec0::a:cf:0:85",
    icvpn_exclude_peerings     => [guetersloh],
    mesh_code    => "ffgt",
    tinc_keyfile       => "/root/tinc_rsa_key-bgp2.priv"
}

ff_gln_gw::bird4::ospf {
  'ospf-ffgt':
    mesh_code => "ffgt",
    range_ipv4 => "10.255.0.0/16",
    ospf_peerings => "/root/ospf-peerings_bgp2.yaml",
    have_ospf_peerings => "yes",
    ospf_links    => "/root/ospf-links_bgp2.yaml",
    have_ospf_links => "yes"
}

ff_gln_gw::gre::tunnel  {
  'ffgt':
    gre_yaml => "/root/gre-tunnel-bgp2.yaml",
}

#class {
#  'ff_gln_gw::monitor::munin':
#    host => '10.35.31.1'
#}

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

#class { 'ff_gln_gw::alfred': master => false }

class { 'ff_gln_gw::etckeeper': }

class {
  'ff_gln_gw::uplink::natip':
}

ff_gln_gw::uplink::nattunnel {
    'dus-b':
      local_public_ip   => '192.251.226.102',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.193.1',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.0.183/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.0.182',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
      nat_network       => '185.66.193.65/32',
}

ff_gln_gw::uplink::nattunnel {
    'ber-b':
      local_public_ip   => '192.251.226.102',  # local public IPv4 of this gateway
      remote_public_ip  => '185.66.195.1',     # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.0.185/31',  # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.0.184',     # tunnel IPv4 on the remote side
      remote_as         => '201701',           # ASN of the BGP server announcing a default route for you
      nat_network       => '185.66.193.65/32',
}

ff_gln_gw::uplink::nattunnel {
    'vpn01':
      local_public_ip   => '192.251.226.102',
      remote_public_ip  => '192.251.226.125',
      local_ipv4        => '100.64.0.9/31',
      remote_ip         => '100.64.0.8',
      remote_as         => '65533',
      nat_network       => '192.251.226.82/32',
      bgp_local_pref    => '500',
}

ff_gln_gw::monitor::vnstat::device { 'eth0': }

ff_gln_gw::monitor::vnstat::device { 'eth1': }


ff_gln_gw::monitor::rrd_traffic { "rrd_traffic":
  rrd_interfaces => "rrd-traffic.yaml",
  rrd_upload_url => "http://guetersloh.freifunk.net/rrd_traffic_upload.php"
}
