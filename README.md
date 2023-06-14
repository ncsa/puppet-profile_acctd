# profile_acctd

![pdk-validate](https://github.com/ncsa/puppet-profile_acctd/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_acctd/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - manage resources related to NCSA acctd
 
## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Reference](#reference)

## Description

This Puppet profile installs dependencies and manages resources related to NCSA acctd.

## Setup

For the bare minimum (RPM dependencies) do the following:
```puppet
include ::profile_acctd
```

## Usage

It is recommended to have this profile enforce cron resources related to acctd:
```yaml
profile_acctd::crons:
  "acctd-cron":
    command: "/root/acctd/cron/acctd-cron"
    environment:
      - "SHELL=/bin/sh"
    hour: "*"
    minute: 5  # pick something unique to avoid overlap with other clusters
    month: "*"
    monthday: "*"
    weekday: "*"
    user: "root"
  "ou_sync-cron":
    command: "/root/acctd/cron/ou_sync-cron"
    environment:
      - "SHELL=/bin/sh"
    hour: "*"
    minute: "*/10"
    month: "*"
    monthday: "*"
    weekday: "*"
    user: "root"
  "grace-archive":
    command: "/root/acctd/cron/grace-archive"
    environment:
      - "SHELL=/bin/sh"
    hour: [9, 15]
    minute: 20  # avoid overlap with other clusters
    month: "*"
    monthday: "*"
    weekday: "*"
    user: "root"
  "archive-data-sweeper":
    command: "/root/acctd/cron/archive-data-sweeper"
    environment:
      - "SHELL=/bin/sh"
    hour: [10, 16]
    minute: 25  # avoid overlap with other clusters
    month: "*"
    monthday: "*"
    weekday: "*"
    user: "root"
  "profile_acctd_logs_mgmt_script.sh":
    command: "/root/cron_scripts/profile_acctd_logs_mgmt_script.sh"
    environment:
      - "SHELL=/bin/sh"
    hour: "*"
    minute: 35  # avoid running too soon after the main acctd cron
    month: "*"
    monthday: "*"
    weekday: "1"
    user: "root"
  "send-jobs-cron":
    command: "/root/acctd/cron/sendjobs-cron"
    environment:
      - "SHELL=/bin/sh"
    hour: "*"
    minute: 42  # avoid overlap with other clusters
    month: "*"
    monthday: "*"
    weekday: "*"
    user: "root"
```

If you want the profile_acctd_logs_mgmt_script.sh to archive the oldest log
files (instead of just leaving them in place indefinitely after compressing),
make sure to define the following:
```yaml
profile_acctd::logs_archive_dir: "/taiga/some/path/to/archive/folder"
```

You can list resources managed by other Puppet modules that need to be in place before this
module does its work (e.g., before it enables crons):
```yaml
profile_acctd::dependencies:
  - "Lvm::Logical_volume[root]"
```

This profile does NOT manage rsyslog. But here are changes you'd currently want
to make in Hiera related to
[profile_rsyslog](https://github.com/ncsa/puppet-profile_rsyslog) to improve
logging config. Some or all of this will likely get rolled into profile_rsyslog
shortly (see [SVCPLAN-3616](https://jira.ncsa.illinois.edu/browse/SVCPLAN-3616)).
And hopefully anything acctd-related can be added to this profile and merged in.
```yaml
lookup_options:
  profile_rsyslog::config_global:
    merge:
      strategy: "deep"
  profile_rsyslog::config_modules:
    merge:
      strategy: "deep"
...
profile_rsyslog::config_global:
  maxMessageSize:
    value: "128k"
profile_rsyslog::config_modules:
  imjournal:
    config:
      Ratelimit.Interval: 5
profile_rsyslog::config_rulesets:
  localhost_messages:
    rules:
      - action:
          name: "01_all_generic_message_logs"
          type: "omfile"
          facility: "*.info;mail.none;authpriv.none;cron.none;local1.*"
          config:
            file: "/var/log/messages"
...
... # include standard actions 02-06 ...
...
      - action:
          name: "07_acctd"
          type: "omfile"
          facility: "local2.*"
          config:
            file: "/var/log/acctd"
...
... # include standard action "forward-to-log-collector-server-relp" ...
```

## Reference

See: [REFERENCE.md](REFERENCE.md)

