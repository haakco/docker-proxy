FROM alpine:edge

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm"

RUN apk upgrade -U -l && \
    apk --update add squid perl && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

ADD ./squid_config /squid_config
ADD ./start.sh /start.sh

RUN chmod u+x  /start.sh /squid_config/rewrite.sh && \
    chown -R squid:squid /squid_config

EXPOSE 3129 3142 3143 4827

#PARENT_PROXY="https://username:proxypassword@proxy.example.net:3128" \
#SIBLING_PROXIES="https://username:proxypassword@proxy.example.net:3128" \

ENV PARENT_PROXY="" \
    SIBLING_PROXIES="" \
    EXTRA_HTTPS_PORTS="10443" \
    ENABLE_PROXY="TRUE" \
    ENABLE_ACCEL="FALSE" \
    ENABLE_INTERCEPT="TRUE" \
    EXTRA_HTTPS_PORTS="10443" \
    ALLOWED_NETWORKS="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

VOLUME ["/cache"]

CMD ["/start.sh"]
