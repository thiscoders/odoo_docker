FROM python:3.7.3
MAINTAINER liuye <ye.liu01@hand-china.com>

ENV LANG C.UTF-8

USER root

COPY ./sources.list /etc/apt/sources.list
COPY ./requirements.txt /opt/piplist/requirements.txt

# install common tools
RUN set -x; \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \  
	&& apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        ca-certificates curl node-less python3-pip python3-setuptools python3-renderpm libssl1.0-dev xz-utils python3-watchdog unixodbc-dev \
        postgresql-client-10 default-jdk tree vim htop fontconfig fontconfig-config fonts-dejavu-core fonts-wqy-zenhei \
        python3-dev python2.7-dev libldap2-dev libsasl2-dev slapd ldap-utils python-tox lcov valgrind libaio1 \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install and modify pip package
RUN set -x; \
    pip install --upgrade pip -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
    && pip3 install -r /opt/piplist/requirements.txt -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
    && rm -rf /opt/piplist \
    && rm -rf /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/jasperstarter.jar \
    && rm -rf /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/bin/jasperstarter  \
    && wget -P /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/ https://www.liuye-cloud.top/jasperstarter.jar \
    && wget -P /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/ https://www.liuye-cloud.top/chinesejasperfont.jar \
    && wget -P /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/bin/ https://www.liuye-cloud.top/jasperstarter \
    && chmod 755 /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/bin/jasperstarter 

# install oracle client
RUN set -x; \
    curl -o instantclient.zip -sSL https://www.liuye-cloud.top/instantclient-basic-linux.x64-12.2.0.1.0.zip \ 
    && unzip instantclient.zip -d  /opt/oracle \
    && sh -c "echo /opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    && ldconfig \
    && rm -f instantclient.zip

# set oracle_home env
ENV ORACLE_HOME /opt/oracle/instantclient_12_2

# create odoo group and user
RUN set -x; \
    groupadd -r odoo && useradd -rm -g odoo odoo

# modify timezone
RUN set -x; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

EXPOSE 8069 8072

USER odoo
