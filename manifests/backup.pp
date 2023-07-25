# @summary Configure acctd backups
#
# @param locations
#   files and directories that are to be backed up#
#   include profile_xcat::master::backup
#
class profile_acctd::backup (
  Array[String]     $locations,
) {
  if ( lookup('profile_backup::client::enabled') ) {
    include profile_backup::client

    profile_backup::client::add_job { 'profile_acctd':
      paths            => $locations,
    }
  }
}
