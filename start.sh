#!/bin/bash -e
/opt/netbox/prelude.sh
exec gunicorn --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi
