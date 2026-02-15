import os
import sys
import json
import time
import subprocess

import boto3


def _load_ssm_secrets():
    ssm = boto3.client("ssm")
    prefix = "SSM_SECRET__"
    params = {}
    for key, value in os.environ.items():
        if key.startswith(prefix):
            target_name = key[len(prefix):]
            params[value] = target_name

    arns = list(params.keys())
    for i in range(0, len(arns), 10):
        batch = arns[i:i + 10]
        resp = ssm.get_parameters(Names=batch, WithDecryption=True)
        for p in resp["Parameters"]:
            os.environ[params[p["ARN"]]] = p["Value"]


_load_ssm_secrets()

sys.path.insert(0, "/opt/netbox/netbox")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "netbox.settings")

from django.core.wsgi import get_wsgi_application
from apig_wsgi import make_lambda_handler

application = get_wsgi_application()
_apig_handler = make_lambda_handler(application)


def wsgi_handler(event, context):
    return _apig_handler(event, context)


def command_handler(event, context):
    cmd = event.get("run")
    if not cmd:
        raise ValueError("No command provided")

    cmd = list(cmd)
    if not all(isinstance(arg, str) for arg in cmd):
        raise ValueError("All command arguments must be strings")

    print(f"RUNCMD {context.aws_request_id} {json.dumps(cmd)}")
    t = time.monotonic()

    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    buf = b""
    for line in iter(proc.stdout.readline, b""):
        buf += line
        sys.stdout.buffer.write(line)
        sys.stdout.buffer.flush()

    proc.wait()
    duration = time.monotonic() - t
    print(f"RUNCMD-OK {context.aws_request_id}")

    output = buf.decode("utf-8", errors="replace")
    if len(buf) > 5_000_000:
        output = buf[:5_000_000].decode("utf-8", errors="replace")

    return {
        "ok": proc.returncode == 0,
        "duration": duration,
        "output": output,
        "status": proc.returncode if proc.returncode >= 0 else None,
        "signal": -proc.returncode if proc.returncode < 0 else None,
    }
