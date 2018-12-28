FROM python:latest
MAINTAINER liuye <ye.liu01@hand-china.com>

ENV LANG C.UTF-8

USER root

COPY ./sources.list /etc/apt/sources.list
COPY ./requirements.txt /opt/piplist/requirements.txt

RUN groupadd -r odoo && useradd -rm -g odoo odoo

RUN	set -x; \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \  
	&& apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
		ca-certificates \
		curl \
		node-less \
		python3-pip \
		python3-setuptools \
		python3-renderpm \
		libssl1.0-dev \
		xz-utils \
		python3-watchdog \
		unixodbc-dev \
		postgresql-client-10 \
		default-jdk \
		tree \
		vim \
		fontconfig \
		fontconfig-config \
		fonts-dejavu-core \
		fonts-wqy-zenhei \
		python3-dev python2.7-dev libldap2-dev libsasl2-dev slapd ldap-utils python-tox lcov valgrind \
	&& curl -o wkhtmltox.tar.xz -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
	&& echo '3f923f425d345940089e44c1466f6408b9619562 wkhtmltox.tar.xz' | sha1sum -c - \
	&& tar xvf wkhtmltox.tar.xz \
	&& cp wkhtmltox/lib/* /usr/local/lib/ \
	&& cp wkhtmltox/bin/* /usr/local/bin/ \
	&& cp -r wkhtmltox/share/man/man1 /usr/local/share/man/

RUN pip3 install -r /opt/piplist/requirements.txt -i https://pypi.douban.com/simple --trusted-host=pypi.douban.com \
	&& rm -rf /opt/piplist

RUN set -x; \
	rm -rf /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/jasperstarter.jar \
	&& wget -P /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/ http://www.liuye-cloud.top:18080/jasperstarter.jar \
	&& wget -P /usr/local/lib/python3.7/site-packages/pyreportjasper/jasperstarter/lib/ http://www.liuye-cloud.top:18080/chinesejasperfont.jar

EXPOSE 8069 8072

USER odoo
