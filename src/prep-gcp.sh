#!/bin/bash
#   USAGE:
#   Preps the GCP stack that usees Classmethod ELK Ubuntu 2204) a little bit... rest left up to the hero!
#
#   1. apt update 
#   1. apt install socat
#   1. stop elasticsaerch service
#   1. set the security bools 
apt update 
apt install socat
service elasticsearch stop
echo -ne c29jYXQgVENQLUxJU1RFTjo5MjIyLGZvcmsgVENQOjEyNy4wLjAuMTo5MjAwICY= |base64 -d > /tmp/poormans-proxy.sh
echo "xpack.security.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
echo "xpack.security.authc.api_key.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto
bash /tmp/poormans-proxy.sh
