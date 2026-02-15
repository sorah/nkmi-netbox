#!/bin/bash
set -e
export HOME=/tmp/home
mkdir -p /tmp/home
source /opt/netbox/venv/bin/activate
/opt/netbox/prelude.sh
export PYTHONPATH="/opt/netbox:${PYTHONPATH}"
exec python -m awslambdaric "${APP_HANDLER}"
