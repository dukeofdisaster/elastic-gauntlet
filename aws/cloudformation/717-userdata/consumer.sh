#!/bin/bash
#   USAGE:
#       - Setups a filebeat consumer on ec2 with Elastic 7.X repo 
#       - This userdata is used in a cloudformation template that has roles granting the instance read access to s3
#         to consume logs generated the the logstash producer. 
#
#### UPDATE YUM AND SETUP THE ELASTIC REPO
sudo yum -y update && sudo yum -y upgrade
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[elastic-7.x]" > /tmp/elastic.repo
echo 'name=Elastic repository for 7.x packages' >> /tmp/elastic.repo
echo 'baseurl=https://artifacts.elastic.co/packages/7.x/yum' >> /tmp/elastic.repo
echo 'gpgcheck=1' >> /tmp/elastic.repo
echo 'gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch' >> /tmp/elastic.repo
echo 'enabled=1' >> /tmp/elastic.repo
echo 'autorefresh=1' >> /tmp/elastic.repo
echo 'type=rpm-md' >> /tmp/elastic.repo
sudo cp /tmp/elastic.repo /etc/yum.repos.d/

#### yum update again now that we added elastic repo
sudo yum -y update 
sudo yum -y install filebeat jq
echo 'ZmlsZWJlYXQuaW5wdXRzOgotIHR5cGU6IGF3cy1zMwogIGVuYWJsZWQ6IHRydWUKICBxdWV1ZV91cmw6IGh0dHBzOi8vc3FzLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tLzxzb21lYWNjb3VudGlkPi9sb2dzdGFzaC1sb2dzCiAgZXhwYW5kX2V2ZW50bGlzdF9mcm9tX2ZpZWxkOiBSZWNvcmRzCgpsb2dnaW5nLmxldmVsOiBpbmZvCmxvZ2dpbmcudG9fZmlsZXM6IHRydWUKbG9nZ2luZy5maWxlczoKICBwYXRoOiAvdmFyL2xvZy9maWxlYmVhdAogIG5hbWU6IGZpbGViZWF0CiAga2VlcGZpbGVzOiA3CiAgcGVybWlzc2lvbnM6IDA2NDQKb3V0cHV0LmZpbGU6CiAgcGF0aDogIi90bXAvZmlsZWJlYXQiCiAgZmlsZW5hbWU6ICJmaWxlYmVhdC1vdXRwdXQubG9nIgogICMgcm90YXRlIGV2ZXJ5IDEwRwogIHJvdGF0ZV9ldmVyeV9rYjogMTAwMDAwMDAKICBudW1iZXJfb2ZfZmlsZXM6IDMKICBwZXJtaXNzaW9uczogMDY0NAo=' > /tmp/filebeat.yml.b64
base64 -d < /tmp/filebeat.yml.b64 > /tmp/filebeat.yml
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId | xargs -i sed -i "s/<someaccountid>/{}/g" /tmp/filebeat.yml


#### OPTIONAL: add an ssh key if the net you're on allows arbitrary ssh outbound; skips setup in aws
#echo 'ssh-rsa SOMEPUBKEYHERE elliot@evilcorp.lan' >> /home/ec2-user/.ssh/authorized_keys
#echo 'ssh-rsa SOMEPUBKEYHERE elliot@evilcorp.lan' >> /root/.ssh/authorized_keys


#### watchcount.sh script for grepping files
echo 'IyEvYmluL2Jhc2gKIyBVU0FHRTogZ2l2ZW4gYSBrZXl3b3JkLCBncmVwIHRhcmdldCBwYXR0ZXJuIGZvciBrZXl3b3JkCktFWVdPUkQ9JDEKd2hpbGUgdHJ1ZSA7IGRvIGdyZXAgJEtFWVdPUkQgL3RtcC9maWxlYmVhdC8qIHwgd2MgLWwgJiYgc2xlZXAgMSA7IGRvbmUK' > /tmp/watchcount.sh.b64
base64 -d < /tmp/watchcount.sh.b64 > /tmp/watchcount.sh
sudo cp /tmp/filebeat.yml /etc/filebeat/filebeat.yml
sudo mkdir /tmp/filebeat && sudo chown root:ec2-user /tmp/filebeat && sudo chmod o+rx /tmp/filebeat
