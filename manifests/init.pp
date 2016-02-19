class network_config(
  $subnets,
  $ip_ranges,
  $interface_lists
)
{
  $host_type = $hostname.match(/^[a-z]*/)[0]
  $ip = $ip_ranges[$host_type] + $hostname.match(/\d$/)[0]
  $interfaces = $interface_lists[$productname]

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
    dns1 => hiera('dns')[0],
    peerdns => true,
    domain => $domain,
    ipaddress => "${subnets['admin']['prefix']}.${ip}",
    netmask   => $subnets['admin']['mask']
  }
  
  network::if::static { $interfaces['external']:
    ensure => 'up',
    ipaddress => "${subnets['external']['prefix']}.${ip}",
    netmask   => $subnets['external']['mask'],
    gateway => $subnets['external']['gateway']
  }

  network::if::static { $interfaces['manage']:
    ensure => 'up',
    ipaddress => "${subnets['manage']['prefix']}.${ip}",
    netmask   => $subnets['manage']['mask']
  }

  network::if::static { $interfaces['storage']:
    ensure => 'up',
    ipaddress => "${subnets['storage']['prefix']}.${ip}",
    netmask   => $subnets['storage']['mask']
  }

  
}
