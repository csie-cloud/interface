class network_config(
  $subnets,
  $ip_ranges,
  $interface_lists,
  $dnss
)
{
  $host_type = $hostname.match(/^[a-z]*/)[0]
  $ip = $ip_ranges[$host_type] + $hostname.match(/\d$/)[0]
  $interfaces = $interface_lists[$productname]

  $ip_admin = "${subnets['admin']['prefix']}.${ip}"
  $ip_manage = "${subnets['manage']['prefix']}.${ip}"
  $ip_storage = "${subnets['storage']['prefix']}.${ip}"
  $ip_external = "${subnets['external']['prefix']}.${ip}"
  
  if( $interfaces == undef ){
    fail("productname: '${productname}' not in the interface manpping. Try to edit hiera data to fix it.")
  }
  
  notify{ 'hostname':
    message => " Hostname: ${hostname}, Host Type: ${host_type}, IP surfix: $ip, using mapping ${interfaces}"
  }

  class { 'network::global':
    vlan => 'yes',
  }
  
  network::if::static { $interfaces['admin']:
    ensure    => 'up',
    dns1 => $dnss[0],
    peerdns => true,
    domain => $domain,
    ipaddress => $ip_admin,
    netmask   => $subnets['admin']['mask']
  }
  
  network::if::static { $interfaces['external']:
    ensure => 'up',
    ipaddress => $ip_external,
    netmask   => $subnets['external']['mask'],
    gateway => $subnets['external']['gateway']
  }

  network::if::static { $interfaces['manage']:
    ensure => 'up',
    ipaddress => $ip_manage,
    netmask   => $subnets['manage']['mask']
  }

  network::if::static { $interfaces['storage']:
    ensure => 'up',
    ipaddress => $ip_storage,
    netmask   => $subnets['storage']['mask']
  }

  
}
