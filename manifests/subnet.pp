# = Definition: dhcp::subnet
#
# == Parameters
#
# === Required parameters
#
# $network:: Network, example: <tt>10.0.0.0</tt>
# $netmask:: Netmask, example: <tt>255.255.255.0</tt>
# $gateway:: Gateway, example: <tt>10.0.0.1</tt>
#
# === Optional parameters
#
# $domain::     Domain name, example: <tt>example.com</tt>
# $parameters:: Optional *array* of subnet parameters.
# $pools::      Optional parameter containing pools to configure. See Pools.
# 
# === Pools
#
# The pools parameter should point to an anonymous hash containing a hash of
# options:
#
#   $pools = {
#     'Unknown clients get this pool.' => {
#       nameservers => [
#         'bogus.example.com',
#       ],
#       parameters => [
#         'max-lease-time 300',
#         'allow unknown-clients',
#       ],
#       ranges => [
#         '10.0.0.200 10.0.0.253',
#       ],
#     },
#     'Known clients get this pool.' => {
#       parameters => [ 'foobarparam 1' ],
#     }
#   }
#  
#
# == Examples
#
# Provide some examples on how to use this type:
#
# === Simple example
#
#   dhcp::subnet{'my simple subnet':
#     network => '10.0.0.0',
#     netmask => '255.255.255.0',
#     gateway => '10.0.0.1',
#   }
#
# === Extended example
#
#   dhcp::subnet{'my extended subnet':
#     network    => '10.0.0.0',
#     netmask    => '255.255.255.0',
#     gateway    => '10.0.0.1',
#     domain     => 'extended.example.com',
#     parameters => [ 'max-lease-time 300','deny unknown-clients'],
#   }
# 
# === Example including pools
#
#   $my_pools = {
#     'Unknown clients get this pool.' => {
#       nameservers                    => [ 'bogus.example.com' ],
#       parameters                     => [ 'max-lease-time 252' ],
#       ranges                         => [ '10.0.0.55 10.0.0.65' ],
#     },
#     'Known clients get this pool.' => {
#       parameters                   => [ 'max-lease-time 86400' ],
#       ranges                       => [ '10.0.0.70 10.0.0.75' ],
#     },
#   }
#
#   dhcp::subnet{'my pool subnet':
#     network    => '10.0.0.0',
#     netmask    => '255.255.255.0',
#     gateway    => '10.0.0.1',
#     domain     => 'extended.example.com',
#     parameters => [ 'max-lease-time 300','deny unknown-clients'],
#     pools      => $my_pools,
#   }
#
# === Example using create_resource
#
#    $subnets = {
#      'the main subnet' => {
#        network => '10.0.0.0',
#        netmask => '255.255.255.0',
#        gateway => '10.0.0.1',
#        domain => 'example.com',
#        parameters => [ ],
#        pools => {
#          'Unknown clients get this pool.' => {
#            nameservers => [
#              'bogus.example.com',
#            ],
#            parameters => [
#              'max-lease-time 300',
#              'allow unknown-clients',
#            ],
#            ranges => [
#              '10.0.0.200 10.0.0.253',
#            ],
#          },
#  
#          'Known clients get this pool.' => {
#            nameservers => [
#              'ns1.example.com',
#              'ns2.example.com',
#            ],
#            parameters => [
#              'max-lease-time 28800',
#              'deny unknown-clients',
#            ],
#            ranges => [
#              '10.0.0.5 10.0.0.199',
#            ],
#          },
#        },
#      },
#    }
#  
#
define dhcp::subnet (
  $network,
  $netmask,
  $gateway,
  $domain = undef,
  $parameters = undef,
  $pools = undef,
  $template = $dhcp::params::subnet_template
) {

  include dhcp::params

  $dhcp_dir = $dhcp::dhcp_dir

  concat::fragment { "dhcp_pool_${name}":
    target  => "${dhcp_dir}/dhcpd.subnets",
    content => template($real_template);
  }

}

