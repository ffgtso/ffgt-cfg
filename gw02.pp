# Global parameters for this host
class { 'ff_gln_gw::params':
  router_id => "10.255.0.12", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  wan_devices => ['eth0'],  # A array of devices which should be in the wan zone
  include_dn42_routes => "no",  # yes/no(default) to include routes from DN42
  include_chaos_routes => "no"  # yes/no(default) to include routes from ChaosVPN
}

# You can repeat this mesh block for every community you support
ff_gln_gw::mesh { 'mesh_ffgt':
      mesh_name    => "Freifunk Guetersloh",
      mesh_code    => "ffgt",
      mesh_as      => 65533,
      mesh_mac     => "de:ad:be:ef:02:02",
      mesh_ipv6    => "fd42:ffee:ff12:aff::202/64",
      mesh_ipv4    => "10.255.0.12/20",
      mesh_mtu     => "1426",
      range_ipv4   => "10.255.0.0/16",
      mesh_peerings => "/root/mesh-peerings_ffgt.yaml",
      have_mesh_peerings => "no",
      use_blacklist => "yes",
      fastd_secret => "/root/fastd-secret-gw02.key",
      fastd_port   => 10000,
      fastd_peers_git => 'https://github.com/ffgtso/fastd-peers-gt.git',
      fastd_bb_git => 'https://github.com/ffgtso/fastd-backbone-gt.git',

      dhcp_relays => [ '10.255.129.18' ],
      dhcp_relay_id => "gw02",
      dhcp_relay_if => 'eth-s3'
} ->
ff_gln_gw::named::listen_v4 { "mesh_ffgt":
  ipv4_address => '10.255.0.12'
}


ff_gln_gw::bird4::ospf {
  'ospf-${mesh_code}':
    mesh_code => "ffgt",
    range_ipv4 => "10.255.0.0/16",
    ospf_peerings => "/root/ospf-peerings-gw02.yaml",
    have_ospf_peerings => "no",
    ospf_links    => "/root/ospf-links-gw02.yaml",
    have_ospf_links => "yes",
    ospf_type => "leaf",
    announce_rid => "no" 
}

ff_gln_gw::bird6::ospf {
  'ospf-${mesh_code}':
    mesh_code => "ffgt",
    range_ipv6 => "2a03:2260:117:1::/64",
    ospf_peerings => "/root/ospf-peerings-gw02.yaml",
    have_ospf_peerings => "no",
    ospf_links    => "/root/ospf-links-gw02.yaml",
    have_ospf_links => "yes",
    ospf_type => "leaf"
}

ff_gln_gw::gre::tunnel  {
  'ffgt':
    gre_yaml => 'gre-tunnel-gw02.yaml',
}

#class {
#  'ff_gln_gw::monitor::munin':
#    host => '10.35.31.1'
#}

class { 'ff_gln_gw::alfred': master => false }

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

class { 'ff_gln_gw::etckeeper': }

ff_gln_gw::monitor::vnstat::device { 'eth0': }


ff_gln_gw::monitor::rrd_traffic { "rrd_traffic":
  rrd_interfaces => "rrd-traffic.yaml",
  rrd_upload_url => "http://guetersloh.freifunk.net/rrd_traffic_upload.php"
}
