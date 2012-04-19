define dhcp::host (
    $ip,
    $mac,
    $comment  = '',
    $template = undef
  ) {

  $host = $name
  include dhcp::params

  $dhcp_dir = $dhcp::dhcp_dir

  if !$template {
    $real_template = $dhcp::params::host_template
  } else {
    $real_template = $template
  }

  concat::fragment { "dhcp_host_${name}":
      target  => "${dhcp_dir}/dhcpd.hosts",
      content => template($real_template),
      order   => 10,
  }
}

