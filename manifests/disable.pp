class dhcp::disable inherits dhcp::params {

  package { $packagename:
      ensure  => absent,
      require => Service[$servicename],
  }

  service { $servicename:
      enable    => false,
      ensure    => "stopped",
      hasstatus => true,
  }

}

