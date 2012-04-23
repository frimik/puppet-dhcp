define dhcp::pool (
  $network,
  $mask,
  $range = undef,
  $gateway,
  $template = undef,
  $options = undef
) {

  include dhcp::params

  $dhcp_dir = $dhcp::dhcp_dir

  if !$template {
    $real_template = $dhcp::params::pool_template
  } else {
    $real_template = $template
  }

  concat::fragment { "dhcp_pool_${name}":
    target  => "${dhcp_dir}/dhcpd.pools",
    content => template($real_template);
  }

}

