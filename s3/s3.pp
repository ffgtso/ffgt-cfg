class { 'ff_gln_gw::params':
  router_id => "10.255.144.18", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  wan_devices => ['eth2'],  # A array of devices which should be in the wan zone
  include_dn42_routes => "no",  # yes/no(default) to include routes from DN42
  include_chaos_routes => "no"  # yes/no(default) to include routes from ChaosVPN

}

ff_gln_gw::gateway { 's3':
      mesh_name    => "Freifunk Guetersloh",
      mesh_code    => "ffgt",
      range_ipv6   => "2001:bf7:1310::/44",
      range_ipv4   => "10.255.0.0/16",
      local_ipv6   => "2001:bf7:1310:300::aff:6003", # local v6 IP
      mesh_peerings => "",
      have_mesh_peerings => "no"
} ->
ff_gln_gw::named::listen_v4 { "mesh_ffgt":
  ipv4_address => '10.255.144.18; 10.255.128.53'
}

#ff_gln_gw::batman-adv { 'ffgt': mesh_code => "ffgt" }

ff_gln_gw::dhcpd { "br-ffgt":
    mesh_code    => "ffgt",
    ipv4_address => "10.255.144.18",
    ipv4_network => "10.255.0.0",
    ipv4_netmask => "255.255.248.0",
    ranges       => [ '10.255.0.33 10.255.7.254'],
    dns_servers  => [ '10.255.128.53' ],
    supply_own_file => '/root/dhcp-ffgt.conf'
}

ff_gln_gw::bird4::ospf {
  'ospf-${mesh_code}':
    mesh_code => "ffgt",
    range_ipv4 => "10.255.0.0/16",
    ospf_peerings => "/root/ospf-peerings-s3.yaml",
    have_ospf_peerings => "no",
    ospf_links    => "/root/ospf-links-s3.yaml",
    ospf_type     => "leaf",
    have_ospf_links => "yes"
}

ff_gln_gw::bird4::anycast {
  'dns':
    mesh_code    => "ffgt",
    anycast_ipv4 => "10.255.128.53",
    anycast_if => "br-anycast"
}

ff_gln_gw::gre::tunnel  {
  'ffgt':
    gre_yaml => "/root/gre-tunnel-s3.yaml",
}

#class { 'ff_gln_gw::alfred': master => false }

class { 'ff_gln_gw::etckeeper': }

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

ff_gln_gw::monitor::vnstat::device { 'eth0': }

