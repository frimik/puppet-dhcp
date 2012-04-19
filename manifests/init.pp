# = Class: dhcp
#
# Set up a dhcp server
#
# == Parameters
#
# [*dnsdomain*]
#   array
#   creates one zone statement per domain
#
# [*nameservers*]
#   array 
#   used as domain-name-servers option
#   first nameserver in array will be configured primary for ddns zones
#   if dnsupdatekey is provided.
#
# [*ntpservers*]
#   array
#   used in ntp-servers option
#
# [*interfaces*]
#   array
#   required on debian
#
# [*dnsupdatekey*]
#   string
#   this is the path to a key to include in dhcpd.conf
#   if this parameter is present, ddns-statements will be enabled.
#
# [*pxeserver*]
#
# [*pxefilename*]
#
# [*logfacility*]
#   string
#   default: +local7+
#
# [*default_lease_time*]
#   int
#   default: <tt>3600</tt>
#
# [*max_lease_time*]
#   int
#   default: <tt>86400</tt>
#
# [*packagename*]
#   string
#   optional alternative packagename. (perhaps you build your own dhcp package).
#
# [*servicename*]
#   string
#   optional alternative servicename. For weird setups.
#
# [*dhcp_dir*]
#   string
#   if your dhcp configuration is not in one of the usual locations
#   defaults: 
#     debian: <tt>/etc/dhcp</tt>
#     ubuntu: <tt>/etc/dhcp3</tt>
#     darwin: <tt>/usr/local/etc/dhcp</tt>
#    freebsd: <tt>/usr/local/etc</tt>
#       rhel: <tt>/etc/dhcp</tt>
#
# [*template*]
#   string
#   specify the path to an override dhcpd.conf.erb template.
#   Example: <tt>template => ${module_name}/my.conf.erb</tt>
#   
#
# == Examples
#   
#   class my_dhcp::production {
#   
#     # set up dhcpd.conf:
#   
#     class { 'dhcp':
#       dnsdomain => [
#         'example.com',
#       ],
#       nameservers => [
#         'ns2.example.com',
#         'ns3.example.com',
#         'ns1.example.com',
#       ],
#       ntpservers => [
#         'ntp1.example.com',
#         'ntp2.example.com',
#       ],
#       template => "${module_name}/dhcpd.conf.erb",
#       dhcp_dir      => "/tmp/dhcp",
#     }
#   
#     # set up defaults for these /24 pools:
#     Dhcp::Pool {
#       mask     => '255.255.0.0',
#       template => "${module_name}/dhcpd.pool.erb",
#     }
#   
#     # all the pools I could find in the cage 60 racks doc:
#     $pools = {
#   
#       'vlan 100 - production (legacy)' => {
#         network                        => '10.100.0.0',
#         gateway                        => '10.100.0.1',
#       },
#   
#       'vlan 600 - database rack 1'     => {
#         network                        => '10.61.0.0',
#         gateway                        => '10.61.0.1',
#       },
#   
#       'vlan 603 - hadoop rack 1'       => {
#         network                        => '10.61.3.0',
#         gateway                        => '10.61.3.1',
#       },
#   
#     }
#   
#     # create all the resources
#     create_resources('dhcp::pool', $pools)
#   
#   }
#   
# == Authors
# Zach Leslie zach.leslie@gmail.com
# Ben Hughes git@mumble.org.uk
# Mikael Fridh <mfridh@marinsoftware.com>
#
class dhcp (
  $dnsdomain,
  $nameservers,
  $ntpservers,
  $interfaces         = undef,
  $interface          = undef,
  $dnsupdatekey       = undef,
  $pxeserver          = undef,
  $pxefilename        = undef,
  $logfacility        = 'local7',
  $default_lease_time = 3600,
  $max_lease_time     = 86400,
  $packagename        = $dhcp::params::packagename,
  $servicename        = $dhcp::params::servicename,
  $dhcp_dir           = $dhcp::params::dhcp_dir,
  $template           = undef
) inherits dhcp::params {

  # Incase people set interface instead of interfaces work around
  # that. If they set both, use interfaces and the user is a unwise
  # and deserves what they get.
  if $interface != undef and $interfaces == undef {
    $dhcp_interfaces = [ $interface ]
  } elsif $interface == undef and $interfaces == undef {
    case $::operatingsystem {
      ubuntu, debian: {
        fail ("You need to set \$interfaces in $module_name")
      }
    }
  } else {
    $dhcp_interfaces = $interfaces
  }

  if !$template {
    $real_template = $dhcp::params::template
  } else {
    $real_template = $template
  }

  package { $packagename:
      ensure => installed,
      provider => $operatingsystem ? {
        default => undef,
        darwin  => macports
      }
  }

  file { "${dhcp_dir}/dhcpd.conf":
      owner   => root,
      group   => 0,
      mode    => 644,
      require => Package[$packagename],
      content => template($real_template);
  }

  # Only debian and ubuntu have this style of defaults for startup.
  case $operatingsystem {
    'debian','ubuntu': {
      file{ '/etc/default/isc-dhcp-server':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        before  => Package[$packagename],
        notify  => Service[$servicename],
        content => template("${module_name}/debian/default_isc-dhcp-server"),
      }
    }
  }

  include concat::setup
  concat { "${dhcp_dir}/dhcpd.pools": }

  concat { "${dhcp_dir}/dhcpd.hosts": }
  concat::fragment { 'dhcp-hosts-header':
    target  => "${dhcp_dir}/dhcpd.hosts",
    content => "# static DHCP hosts\n",
    order   => 01,
  }

  service { $servicename:
      enable    => "true",
      ensure    => "running",
      hasstatus => true,
      subscribe => [Concat["${dhcp_dir}/dhcpd.pools"], Concat["${dhcp_dir}/dhcpd.hosts"], File["${dhcp_dir}/dhcpd.conf"]],
      require   => Package[$packagename];
  }

}

