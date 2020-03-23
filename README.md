# docker squid cache

Work in progress to have a local caching for docker builds based on ideas from https://github.com/jpetazzo/squid-in-a-can

Currently, should cache dev, apk and java downloads.

Hopefully it will also cache anything else that has correct cache headers.

```
docker run -d --restart=always -v /data/squid:/cache --name proxy --net host timhaak/proxy
iptables -A INPUT -p tcp -i docker0 --dport 3129 -j ACCEPT
iptables -A INPUT -p tcp -i lo --dport 3129 -j ACCEPT
iptables -A INPUT -p tcp --dport 3129 -j DROP
```

To remove the proxy use the following


```
iptables -D INPUT -p tcp -i lo --dport 3129 -j ACCEPT
iptables -D INPUT -p tcp -i docker0 --dport 3129 -j ACCEPT
iptables -D INPUT -p tcp --dport 3129 -j DROP
docker stop proxy
docker rm proxy
```
