#!/bin/bash
set -e
source /opt/netbox/venv/bin/activate
/opt/netbox/prelude.sh
export PYTHONPATH="/opt/netbox:${PYTHONPATH}"
exec python -m awslambdaric "${APP_HANDLER}"
