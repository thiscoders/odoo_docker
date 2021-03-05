FROM python:3.7.3
LABEL maintainer="liuye <1621963477@qq.com>"

ENV LANG C.UTF-8

USER root

COPY ./sources.list /etc/apt/sources.list
COPY ./requirements.txt /opt/piplist/requirements.txt
COPY ./README.md /README.md

# install common tools
RUN set -x; \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \  
	&& apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        ca-certificates curl node-less python3-pip python3-setuptools python3-renderpm libssl1.0-dev xz-utils python3-watchdog unixodbc-dev \
        postgresql-client default-jdk tree vim htop fontconfig fontconfig-config fonts-dejavu-core fonts-wqy-zenhei \
        python3-dev python2.7-dev libldap2-dev libsasl2-dev slapd ldap-utils python-tox lcov valgrind libaio1 \
    && curl -o wkhtmltox.deb -sSL https://repo.rocketx.top/docker/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install and modify pip package
RUN set -x; \
    pip install --upgrade pip -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
    && pip3 install -r /opt/piplist/requirements.txt -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
    && rm -rf /opt/piplist

# create odoo group and user
RUN set -x; \
    groupadd -r odoo \
    && useradd -rm -g odoo odoo

# export server port
EXPOSE 8069 8072

# switch user to odoo
USER odoo
