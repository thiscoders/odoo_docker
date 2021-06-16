FROM python:2.7.15
LABEL maintainer="liuye <ye.liu01@hand-china.com>"
ENV LANG C.UTF-8

COPY ./sources.list /etc/apt/sources.list
COPY ./requirements.txt /opt/piplist/requirements.txt
COPY ./README.md /README.md

RUN set -x; \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
	&& apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
		ca-certificates \
		unixodbc-dev \
		postgresql-client-9.5 \
		default-jdk \
		tree \
		curl \
		vim \
		node-less \
		xz-utils \
		fontconfig \
		fontconfig-config \
		fonts-dejavu-core \
		fonts-wqy-zenhei \
		python-gevent \
		python-pip \
		python-renderpm \
		python-watchdog \
		python2.7-dev libldap2-dev libsasl2-dev slapd ldap-utils python-tox lcov valgrind \
	&& curl -o wkhtmltox.tar.xz -SL https://repo.rocketx.top/docker/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
	&& echo '3f923f425d345940089e44c1466f6408b9619562 wkhtmltox.tar.xz' | sha1sum -c - \
	&& tar xvf wkhtmltox.tar.xz \
	&& cp wkhtmltox/lib/* /usr/local/lib/ \
	&& cp wkhtmltox/bin/* /usr/local/bin/ \
	&& cp -r wkhtmltox/share/man/man1 /usr/local/share/man/ 

RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple \
	&& pip install -r /opt/piplist/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
	&& rm -rf /opt/piplist \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 8069 8072

# create odoo group and user
RUN set -x; \
    groupadd -r odoo \
    && useradd -rm -g odoo odoo

USER odoo
