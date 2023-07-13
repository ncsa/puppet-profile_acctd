# @summary Manage resources related to NCSA acctd.
#
# Manage resources related to NCSA acctd.
#
# @param crons
#   Hash of data for cron resources. Examples included in data/ folder.
#
# @param custom_files
#   Hash of key (file name) and values (params for file resource). Generally used
#   to manage custom scripts and config files.
#
# @param dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up acctd resources on a node. Should be in the form that would
#   be specified as a requirement ("before") various other resources (e.g.,
#   crons), e.g.:
#     - "Lvm::Logical_volume[root]"
#
# @param logs_archive_after_days
#   Archive logs after they are this old (based on mtime).
#
# @param logs_archive_dir
#   Where to archive older logs.
#
# @param logs_compress_after_days
#   Compress logs after they are this old (based on mtime).
#
# @param logs_mgmt_script_path
#   Path to the logs mgmt script.
#
# @param logs_path
#   Where are logs located?
#
# @param required_pkgs
#   Packages that must be installed to run acctd.
#   
# @example
#   include profile_acctd
#
class profile_acctd (

  Hash              $crons,
  Hash              $custom_files,
  Array[String]     $dependencies,
  Integer           $logs_archive_after_days,
  Integer           $logs_compress_after_days,
  String            $logs_mgmt_script_path,
  String            $logs_path,
  Array[String]     $required_pkgs,
  Optional[String]  $logs_archive_dir = undef,

) {
  # Ensure required packages
  ensure_packages ($required_pkgs, { 'ensure' => 'installed' })

  # Ensure log management script
  file { $logs_mgmt_script_path:
    ensure  => file,
    content => epp( 'profile_acctd/logs_mgmt_script' ),
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
  }

  # Ensure custom files
  $custom_files.each | $k, $v | {
    file { $k: * => $v }
  }

  # Ensure crons
  Cron {
    user        => 'root',
    environment => ['SHELL=/bin/sh',],
    require     => $dependencies,
  }
  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }
}
