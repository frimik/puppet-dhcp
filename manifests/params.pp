class dhcp::params {

  $conf_template = "${module_name}/dhcpd.conf.erb"
  $host_template = "${module_name}/dhcpd.host.erb"
  $pool_template = "${module_name}/dhcpd.pool.erb"

  case $operatingsystem {
    'debian': {
      $dhcp_dir    = "/etc/dhcp"
      $packagename = "isc-dhcp-server"
      $servicename = "isc-dhcp-server"
    }
    'ubuntu': {
      $dhcp_dir    = "/etc/dhcp3"
      $packagename = "isc-dhcp-server"
      $servicename = "isc-dhcp-server"
    }
    'darwin': {
      $dhcp_dir    = "/opt/local/etc/dhcp"
      $packagename = "dhcp"
      $servicename = "org.macports.dhcpd"
    }
    'freebsd': {
      $dhcp_dir    = "/usr/local/etc"
      $packagename = "net/isc-dhcp42-server"
      $servicename = "isc-dhcpd"
    }
    'centos', 'redhat', 'oel', 'scientific': {
      $dhcp_dir    = "/etc/dhcp"
      $packagename = "dhcp"
      $servicename = "dhcpd"
    }
  }

}
