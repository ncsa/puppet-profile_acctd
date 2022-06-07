# @summary Manage resources related to NCSA acctd.
#
# Manage resources related to NCSA acctd.
#
# @param crons
#   Hash of data for cron resources. Examples included in data/ folder.
#
# @param dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up acctd resources on a node. Should be in the form that would
#   be specified as a requirement ("before") various other resources (e.g.,
#   crons), e.g.:
#     - "Lvm::Logical_volume[root]"
#
# @param required_pkgs
#   Packages that must be installed to run acctd.
#   
# @example
#   include profile_acctd
#
class profile_acctd (

  Hash          $crons,
  Array[String] $dependencies,
  Array[String] $required_pkgs,

) {

  # Ensure required packages
  ensure_packages( $required_pkgs, {'ensure' => 'installed' } )

  # Ensure crons
  Cron {
    user        => 'root',
    environment => [ 'SHELL=/bin/sh', ],
    require     => $dependencies,
  }
  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }

}
