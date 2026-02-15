FROM public.ecr.aws/ubuntu/ubuntu:24.04 AS builder

WORKDIR /opt/netbox

ARG BRANCH=v2.10.4
ARG URL=https://github.com/netbox-community/netbox.git

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
      build-essential \
      pkg-config \
      ca-certificates \
      fonts-noto-cjk \
      graphviz \
      libevent-dev \
      libffi-dev \
      libjpeg-turbo8-dev \
      libldap2-dev \
      libpq-dev \
      libsasl2-dev \
      libssl-dev \
      libxslt-dev \
      libxmlsec1-dev \
      python3-all-dev \
      python3-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/netbox/venv \
  && /opt/netbox/venv/bin/python3 -m pip install --upgrade \
    pip \
    setuptools \
    wheel
COPY netbox-docker/requirements-container.txt /
COPY netbox/requirements.txt /
COPY requirements.txt /requirements-dpl.txt

# We need 'social-auth-core[all]' for full SSO support,
# and 'django-storages[boto3]' for S3 media storage.
RUN sed -i -e 's/social-auth-core/social-auth-core\[all\]/g' /requirements.txt \
 && sed -i -e 's/django-storages/django-storages\[boto3\]/g' /requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  /opt/netbox/venv/bin/pip install \
  -r /requirements.txt \
  -r /requirements-container.txt \
  -r /requirements-dpl.txt


FROM public.ecr.aws/ubuntu/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
      ca-certificates \
      curl \
      fonts-noto-cjk \
      graphviz \
      libevent-2.1-7t64 \
      libffi8 \
      libjpeg-turbo8 \
      libldap2 \
      libpq5 \
      libsasl2-2 \
      libssl3t64 \
      libxslt1.1 \
      libxmlsec1t64 \
      libxmlsec1t64-openssl \
      python3 \
      python3-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/netbox/venv /opt/netbox/venv

COPY netbox-docker/docker/configuration.docker.py /opt/netbox/netbox/netbox/configuration.py
COPY netbox-docker/docker/docker-entrypoint.sh /opt/netbox/docker-entrypoint.sh
COPY netbox-docker/docker/launch-netbox.sh /opt/netbox/launch-netbox.sh
COPY netbox-docker/docker/ldap_config.docker.py /opt/netbox/netbox/netbox/ldap_config.py
COPY netbox-docker/configuration/ /etc/netbox/config/

COPY entry.sh /entry.sh
COPY start.sh /opt/netbox/start.sh
COPY prelude.sh /opt/netbox/prelude.sh
COPY gunicorn.py /opt/netbox/gunicorn.py
COPY extra.py /etc/netbox/config/extra.py

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY ssh_config /root/.ssh/config

COPY netbox/ /opt/netbox/

RUN sed -i'' -e "s|SecurityMiddleware',|SecurityMiddleware', 'whitenoise.middleware.WhiteNoiseMiddleware',|" /opt/netbox/netbox/netbox/settings.py

WORKDIR /opt/netbox/netbox
RUN env DEBUG="true" SECRET_KEY="dummyKeyWithMinimumLength-------------------------" /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input

ENV HOME=/root

VOLUME ["/opt/netbox/netbox/static"]
ENTRYPOINT [ "/entry.sh" ]
CMD [ "/opt/netbox/start.sh" ]
