#!/bin/bash
# VERSION: 20211111 - use sed to bump /etc/logstash/jvm.options heap to 2g
# USAGE:
#   - Setup ELK stack 7.X latest via yum repo
#### PREP THE YUM REPOR FOR 7.X 
sudo yum -y update && sudo yum -y upgrade
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[logstash-8.x]" > /tmp/elastic.repo
echo 'name=Elastic repository for 8.x packages' >> /tmp/elastic.repo
echo 'baseurl=https://artifacts.elastic.co/packages/8.x/yum' >> /tmp/elastic.repo
echo 'gpgcheck=1' >> /tmp/elastic.repo
echo 'gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch' >> /tmp/elastic.repo
echo 'enabled=1' >> /tmp/elastic.repo
echo 'autorefresh=1' >> /tmp/elastic.repo
echo 'type=rpm-md' >> /tmp/elastic.repo


#### LOGSTASH LOGS TO S3 - good for testing filebeat/fleet S3+SQS input 
echo 'aW5wdXQgewoJIyBzdWNrIHVwIGFsbCB2YXIgbG9nIG1lc3NhZ2VzCglmaWxlIHsKCQlwYXRoID0+IFsKCQkJIi92YXIvbG9nLyoiLAoJCQkiL3Zhci9sb2cvKi8qLmxvZyIKCQldCgkJdGFncyA9PiAibG9nc3Rhc2gtZmlsZS1pbnB1dCIKCX0KfQpvdXRwdXQgewoJczMgewoJCWNvZGVjID0+IGpzb25fbGluZXMKCQlyZWdpb24gPT4gInVzLWVhc3QtMSIKCQlidWNrZXQgPT4gImxvZ3N0YXNoLXByb2R1Y2VycyIKCQlwcmVmaXggPT4gInZhcmxvZy8leytZWVlZfS8leytNTX0vJXsrZGR9LyIKCQkjcm90YXRpb25fc3RyYXRlZ3kgPT4gInRpbWUiCgkJc2l6ZV9maWxlID0+IDIwNDgKICAgICAgICAgICAgICAgIGVuY29kaW5nID0+ICJnemlwIgoJfQp9Cg==' > /tmp/logstash.conf.b64

#### OPTIONAL: If aribtrary outbound ssh is allowed outbound, add a pubkey of your chose to the host... foregoes setup in AWS 
#echo 'ssh-rsa SOMEPUBKEYHERE elliot@evilvorp.com' >> /home/ec2-user/.ssh/authorized_keys
#echo 'ssh-rsa SOMEPUBKEYHERE elliot@evilvorp.com' >> /root/.ssh/authorized_keys


# genlogs.sh script for generating 500K line log files in /var/log hat can be consumed by the logstash => s3 conf above
echo 'IyEvYmluL2Jhc2gKIyBVU0FHRTogZ2VuZXJhdCA1MDBLIGxvZ3MgYmFzZWQgb24ga2V5d29yZApLRVlXT1JEPSQxCmZvciBpIGluIHsxLi41MDAwMDB9IDsgZG8gZWNobyAkS0VZV09SRCRpID4+IC92YXIvbG9nLyRLRVlXT1JEIDsgZG9uZQo=' > /tmp/genlogs.sh.b64
base64 -d < /tmp/genlogs.sh.b64 > /tmp/genlogs.sh
sudo cp /tmp/elastic.repo /etc/yum.repos.d/
sudo yum update  -y
sudo yum -y install logstash jq elasticsearch kibana
base64 -d < /tmp/logstash.conf.b64 > /tmp/logstash.conf
sudo cp /tmp/logstash.conf /etc/logstash/conf.d/

#### BUMP THE LOGSTASH JVM TO USE 2G HEAP if you use anything above t3 medium
sudo sed -i 's/-Xms1g/-Xms2g/g' /etc/logstash/jvm.options && sed -i 's/-Xmx1g/-Xmx2g/g' /etc/logstash/jvm.options
sudo chmod o+r /var/log/*


#### update the elasticsearch config to enable security and generate passwords 
#echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
#echo 'xpack.security.authc.api_key.enabled: true' >> /etc/elasticsearch/elasticsearch.yml

#### start elasticsearch so we can bootstrap passwords 
PASS_FILE=/tmp/passwords.txt
PASS_ELASTIC=/tmp/elastic.password
PASS_KIBANA_SYSTEM=/tmp/kibana_system.password
service elasticsearch start 
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b > /tmp/elastic.password
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -b > /tmp/kibana_system.password
KIBANA_SYS_PASS=`grep 'New value' /tmp/kibana_system.password |cut -d':' -f 2-  | tr -d ' '`
if [[ "$KIBANA_SYS_PASS" == "" ]]; then
    echo FAIL TO SET KIBANA SYSTEM PASSWORD
else
    echo "elasticsearch.username: kibana_system" >> /etc/kibana/kibana.yml
    echo "elasticsearch.password: $KIBANA_SYS_PASS" >> /etc/kibana/kibana.yml
    echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml
    echo "elasticsearch.hosts: [\"https://localhost:9200\"]" >> /etc/kibana/kibana.yml
    echo "elasticsearch.ssl.verificationMode: none" >> /etc/kibana/kibana.yml
fi
sudo service kibana restart 
