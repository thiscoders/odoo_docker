FROM python:3.7.3
MAINTAINER liuye <ye.liu01@hand-china.com>

ENV LANG C.UTF-8

USER root

COPY ./sources.list /etc/apt/sources.list
COPY ./requirements.txt /opt/piplist/requirements.txt

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl1.0-dev \
            node-less \
            python3-pip \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-vobject \
            python3-watchdog \
            xz-utils \
            libsasl2-dev python-dev libldap2-dev \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb\
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN set -x; \
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --armor --export "${repokey}" | apt-key add - \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install -y postgresql-client \
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian stretch)
RUN set -x;\
        echo "deb http://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --armor --export "${repokey}" | apt-key add - \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update \
        && apt-get install -y nodejs \
        && npm install -g rtlcss \
        && rm -rf /var/lib/apt/lists/*

# Install Python pip and create odoo user
RUN set -x; \
        pip install --upgrade pip \
        && pip3 install -r /opt/piplist/requirements.txt -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
        && rm -rf /opt/piplist \
        && groupadd -r odoo && useradd -rm -g odoo odoo

EXPOSE 8069 8072

USER odoo
