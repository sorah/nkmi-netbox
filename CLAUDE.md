# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

nkmi-netbox is a custom NetBox deployment packaged as a Docker image, built on top of the official NetBox (v4.6.2) and netbox-docker (5.0.1) projects included as git submodules. It adds AWS-specific deployment configuration including S3 storage, ECR-based CI/CD, and Gunicorn with WhiteNoise for serving.

## Repository Structure

- `Dockerfile` — Multi-stage build: builder stage compiles Python deps, runtime stage assembles the final image from `netbox/` source + `netbox-docker/` configuration + custom files
- `extra.py` — Django settings override: configures S3 storage backend via `django-storages`
- `gunicorn.py` — Gunicorn config (bind :8001, 2 workers, 2 threads, 120s timeout)
- `entry.sh` — Entrypoint: activates venv then execs the given command
- `start.sh` — Default CMD: runs prelude then launches Gunicorn
- `prelude.sh` — Pre-startup: injects SSH ed25519 key from `$NETBOX_SSH_ID_ED25519` env var
- `requirements.txt` — Additional pip dependencies (gunicorn, whitenoise)
- `netbox/` — Git submodule: NetBox core (Django app)
- `netbox-docker/` — Git submodule: official Docker support files (entrypoint scripts, configuration templates)

## Build

```bash
docker build -t netbox .
```

The Dockerfile patches NetBox's `settings.py` at build time to inject WhiteNoise middleware and runs `collectstatic`.

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) builds and pushes to AWS ECR on push to `main` or `test` branches. Uses OIDC-based AWS authentication.

## Key Customizations Over Stock netbox-docker

1. Uses Gunicorn instead of Nginx Unit as the application server
2. WhiteNoise middleware for static file serving (injected via `sed` in Dockerfile)
3. S3 storage backend for media files (`extra.py`)
4. SSH key injection at startup for private git operations (`prelude.sh`)
5. Custom Ubuntu 22.04 base image from public ECR (not the upstream netbox-docker image)
