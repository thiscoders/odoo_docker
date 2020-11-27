FROM daocloud.io/xiaoshayu/odoo:12.0
MAINTAINER liuye <ye.liu01@hand-china.com>

ENV LANG C.UTF-8

USER root

COPY ./README.md /README.md

# get interpreter
RUN set -x; \
    mv /usr/local/bin/python3.7 /root/python3.7.bck \
    && curl -o /usr/local/bin/python3.7 -sSL https://repo.rocketx.top/docker/python3.7 \ 
    && chmod 755 /usr/local/bin/python3.7

# modify timezone to utc
RUN set -x; \
    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && echo "Etc/UTC" > /etc/timezone

# switch user to odoo
USER odoo
