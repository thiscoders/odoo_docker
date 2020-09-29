FROM python:3.7.3
MAINTAINER liuye <1621963477@qq.com>

ENV LANG C.UTF-8

USER root

COPY ./requirements.txt /opt/piplist/requirements.txt

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            busybox \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            npm \
            python3-pip \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-vobject \
            python3-watchdog \
            xz-utils \
            python3-dev \
            libxml2-dev \
            libxslt1-dev \
            libsasl2-dev \
            libldap2-dev \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && npm install -g rtlcss

# install latest postgresql-client
RUN set -x; \
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install -y postgresql-client-12 \
        && rm -rf /var/lib/apt/lists/*

# install Python pip and create odoo user
RUN set -x; \
        pip install --upgrade pip \
        && pip3 install -r /opt/piplist/requirements.txt -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
        && rm -rf /opt/piplist \
        && groupadd -r odoo && useradd -rm -g odoo odoo

EXPOSE 8069 8071 8072

# set default user
USER odoo
