FROM public.ecr.aws/ubuntu/ubuntu:22.04 AS builder

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

# We compile 'psycopg' in the build process
# We need 'social-auth-core[all]' in the Docker image. But if we put it in our own requirements-container.txt
# we have potential version conflicts and the build will fail.
# That's why we just replace it in the original requirements.txt.
RUN sed -i -e '/psycopg/d' /requirements.txt \
 && sed -i -e 's/social-auth-core\[openidconnect\]/social-auth-core\[all\]/g' /requirements.txt

RUN /opt/netbox/venv/bin/pip install \
  -r /requirements.txt \
  -r /requirements-container.txt \
  -r /requirements-dpl.txt


FROM public.ecr.aws/ubuntu/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
      ca-certificates \
      curl \
      fonts-noto-cjk \
      graphviz \
      libevent-2.1-7 \
      libffi7 \
      libjpeg-turbo8 \
      libldap-2.5-0 \
      libpq5 \
      libsasl2-2 \
      libssl3 \
      libxslt1.1 \
      libxmlsec1 \
      libxmlsec1-openssl \
      python3 \
      python3-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY netbox/ /opt/netbox/
COPY --from=builder /opt/netbox/venv /opt/netbox/venv

COPY netbox-docker/docker/configuration.docker.py /opt/netbox/netbox/netbox/configuration.py
COPY netbox-docker/docker/docker-entrypoint.sh /opt/netbox/docker-entrypoint.sh
COPY netbox-docker/docker/housekeeping.sh /opt/netbox/housekeeping.sh
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

WORKDIR /opt/netbox/netbox
RUN env SECRET_KEY="dummyKeyWithMinimumLength-------------------------" /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input

ENV HOME /root

VOLUME ["/opt/netbox/netbox/static"]
ENTRYPOINT [ "/entry.sh" ]
CMD [ "/opt/netbox/start.sh" ]
