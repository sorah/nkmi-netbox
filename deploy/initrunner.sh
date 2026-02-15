#!/bin/bash
set -e

function_name="$1"
if [ -z "$function_name" ]; then
  echo "Usage: $0 <function_name>" >&2
  exit 1
fi

cd "$(dirname "$0")"

set -x
ruby lambrunner.rb "$function_name" /opt/netbox/netbox/manage.py migrate --no-input
ruby lambrunner.rb "$function_name" /opt/netbox/netbox/manage.py trace_paths --no-input
ruby lambrunner.rb "$function_name" /opt/netbox/netbox/manage.py remove_stale_contenttypes --no-input
ruby lambrunner.rb "$function_name" /opt/netbox/netbox/manage.py clearsessions
ruby lambrunner.rb "$function_name" /opt/netbox/netbox/manage.py reindex --lazy
