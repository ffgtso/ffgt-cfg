class { 'ff_gln_gw::params':
  router_id => "192.251.226.125", # The id of this router, probably the ipv4 address
                            # of the mesh device of the providing community
  icvpn_as => "65533",      # The as of the providing community
  wan_devices => ['eth0', 'eth1', 'eth2'],  # A array of devices which should be in the wan zone
  provides_uplink => "yes"
}

class {
  'ff_gln_gw::uplink::provide':
    #nat_network => '192.251.226.224/29', # network of IPv4 addresses usable for NAT
    nat_network => '192.251.226.0/24',
    tunnel_network => '100.64.0.0/24', # network of tunnel IPs to exclude from NAT
    uplink_as => "65533"
}

ff_gln_gw::uplink::tunnel {
    'gw04':
      local_public_ip   => '192.251.226.125', # local public IPv4 of this gateway
      remote_public_ip  => '5.9.167.221',   # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.0.2/31', # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.0.3', # tunnel IPv4 on the remote side
      remote_as         => '65533',         # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'bgp3':
      local_public_ip   => '192.251.226.125', # local public IPv4 of this gateway
      remote_public_ip  => '5.9.167.218',   # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.0.4/31', # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.0.5', # tunnel IPv4 on the remote side
      remote_as         => '65533',         # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'bgp1':
      local_public_ip   => '192.251.226.125', # local public IPv4 of this gateway
      remote_public_ip  => '192.251.226.114',   # remote public IPv4 of the tunnel endpoint
      local_ipv4        => '100.64.0.6/31', # tunnel IPv4 on our side in CIDR notation
      remote_ip         => '100.64.0.7', # tunnel IPv4 on the remote side
      remote_as         => '65533',         # ASN of the BGP server announcing a default route for you
}

ff_gln_gw::uplink::tunnel {
    'bgp2':
      local_public_ip   => '192.251.226.125',
      remote_public_ip  => '192.251.226.102',
      local_ipv4        => '100.64.0.8/31',
      remote_ip         => '100.64.0.9',
      remote_as         => '65533',
}

class {
  'ff_gln_gw::monitor::nrpe':
    allowed_hosts => '192.251.226.107'
}

##class { 'ff_gln_gw::alfred': master => false }

class { 'ff_gln_gw::etckeeper': }

ff_gln_gw::monitor::vnstat::device { 'eth2': }

