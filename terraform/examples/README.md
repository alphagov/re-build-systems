# Example configuration

## Overview

This is an example of a configuration where the state (i.e. details of the AWS cloud infrastructure) for both DNS and Jenkins is contained within one S3 bucket.

_This is not necessarily desirable. For most cases, it is a good idea to separate these states out so they are kept in separate S3 buckets._

## How to use

Pass in the `allowed_ips` and `ssh_public_key_file` variables in a variables file, along the lines of:

```

```
