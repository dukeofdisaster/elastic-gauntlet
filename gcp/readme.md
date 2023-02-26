# Google Cloud Platform
Google Marketplace is a good candidate for the majority of this exercise because

1. SSh-in-browser requires no custom config
1. Google cloud marketplace has a ready made stack ELK Ubuntu 2204

## NOTES

- the stack runs fine on an E2 Medium instance 
- the stack exposes kibana on https://<target>:5601
- to work through fleet exercises, some additional setup is required. 

## MODIFYING THE STACK FOR FLEET USE
Fleet depends on security being enabled for elasticsearch which will require some additional setup after the stack is deployed.

Executing the following steps will allow fleet usage to proceed.

1. add the following settings in /etc/elasticsearch/elasticsearch.yml

```
xpack.security.enabled: true
xpack.security.authc.api_key.enabled: true
```

2. Restart elasticsearch and ensure it starts fine (check the application log /var/log/elasticsearch)
- reports about yellow shards are fine

3. After elasticsearch is restarted, execute the ```elasticsearch-setup-passwords``` utility ; example output below

```
 /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto 
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,kibana_system,logstash_system,beats_system,remote_monitoring_user.
The passwords will be randomly generated and printed to the console.
Please confirm that you would like to continue [y/N]Y


Changed password for user apm_system
PASSWORD apm_system = SIYqbCAS3tlZqQucTG0e

Changed password for user kibana_system
PASSWORD kibana_system = UyByTQeC2oiVatdr3FCS

Changed password for user kibana
PASSWORD kibana = UyByTQeC2oiVatdr3FCS

Changed password for user logstash_system
PASSWORD logstash_system = GnVxIcL6F77Byo26szJX

Changed password for user beats_system
PASSWORD beats_system = b88J5Wav08jdUwKks0X4

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = y1glMv8juwBHt7XY7GTB

Changed password for user elastic
PASSWORD elastic = UmagcHfNH1i5Soegi44J
```

4. Save these passwords somewhere because you'll be using the kibana_system and logstash_system and elastic users. 
5. Enter the kibana_system credentials in /etc/kibana/kibana.yml

```
# If your Elasticsearch is protected with basic authentication, these settings provide
# the username and password that the Kibana server uses to perform maintenance on the Kibana
# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
# is proxied through the Kibana server.
elasticsearch.username: "kibana_system"
elasticsearch.password: "UyByTQeC2oiVatdr3FCS"
```

6. Restart kibana and ensure it starts up fine (check /var/log/kibana if issues)
- ```service kibana restart```

7. Re auth to Kibana using the elastic credentials; you should have full admin access to kibana now.
8. Update the logstash elasticsearch output with the logstash_system password
- EXTRA CREDIT: Use the logstash keystore instead of plaintext cred 
```
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    user => "logstash_system"
    password => "GnVxIcL6F77Byo26szJX"
  }
}
```

9. Once Logstash and Kibana are talking to elasticsearch fine, install ```socat```
- Elasticsearch in this stack runs on localhost, and if you try to force it to listen on 0.0.0.0 you'll have to add additional
configuration settings which just add more chaos to the equation. We can use socat as a poor-mans proxy to proxy external traffic to localhost:9200
- ```apt install socat```
- create bash script that will proxy this traffic and execute in the background.
```
#!/bin/bash
socat TCP-LISTEN:9222,fork TCP:127.0.0.1:9200 &
- execute the script and confirm you can hit elastic from an external vm or local with curl http://stack_host:9222

10. Once you have your poor-mans proxy in place, update the fleet settings on top right so the ```elasticsaerch hosts`` setting points to your proxy
- i.e. ```http://10.128.0.4:9222``` or whatever your vm's IP address is.
```

10. Add fleet fleet to the host
    1. Download the elastic agent version matching the stack to the target host from [here](https://www.elastic.co/downloads/past-releases/elastic-agent-7-17-8)
    2. Verify the SHA512 of the download to ensure the tarball wasn't butchered in transit (rare, but I've seen it happen at least once, and it was painful to figure out because install was partially successful... lesson learned). 
        1. EXTRA CREDIT: screnshot of of the checksum being verified
    3. Untar the tarball in /opt ```tar xvf elastic-agent-7.17.8-linux-x86_64.tar.gz```
    4. Navigate to ```FLEET``` in the Kibana UI. There should be a pre-canned guide to ```Add a Fleet Server```. Under section **4** specify your VM private IP as the fleet server host, i.e. ```http://10.128.0.4:8220. 
        - ensure you're not trying to deploy a production config otherwise your command will expect to have a bunch of certificate args
    5. Click ``Generate a service token`` which will auto populate your install command... copy the command and add ```--insecure``` to the end of it, to rule out any cert stuff (which shouldn't be happening) and execute from the elastic agent tar directory

```
/opt/elastic-agent-7.17.8-linux-x86_64$ sudo ./elastic-agent install   \
  --fleet-server-es=http://10.128.0.4:9222 \
  --fleet-server-service-token=AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE2NzczNzA1Mjg5MDk6VDZfUDhndGJSZy1IMnJNbWxTVHRZdw \
  --fleet-server-policy=499b5aa7-d214-5b5d-838b-3cd76469844e \
  --fleet-server-insecure-http --insecure
Elastic Agent will be installed at /opt/Elastic/Agent and will run as a service. Do you want to continue? [Y/n]:Y
2023-02-25T22:56:21.234Z        INFO    cmd/enroll_cmd.go:386   Generating self-signed certificate for Fleet Server
2023-02-25T22:56:22.682Z        INFO    cmd/enroll_cmd.go:743   Waiting for Elastic Agent to start Fleet Server
2023-02-25T22:56:24.685Z        INFO    cmd/enroll_cmd.go:776   Fleet Server - Starting
2023-02-25T22:56:28.687Z        INFO    cmd/enroll_cmd.go:757   Fleet Server - Running on policy with Fleet Server integration: 499b5aa7-d214-5b5d-838b-3cd76469844e; missing config fleet.agent.id (expected during bootstrap process)
2023-02-25T22:56:28.688Z        WARN    [tls]   tlscommon/tls_config.go:101     SSL/TLS verifications disabled.
2023-02-25T22:56:28.884Z        INFO    cmd/enroll_cmd.go:454   Starting enrollment to URL: https://cmca-elk-ubuntu-2204-2-vm:8220/
2023-02-25T22:56:28.987Z        WARN    [tls]   tlscommon/tls_config.go:101     SSL/TLS verifications disabled.
2023-02-25T22:56:30.527Z        INFO    cmd/enroll_cmd.go:254   Successfully triggered restart on running Elastic Agent.
Successfully enrolled the Elastic Agent.
Elastic Agent has been successfully installed.

```
    


## APPENDIX
2. [GCP: Elk Ubuntu 2204 powered by Classmethod](https://console.cloud.google.com/marketplace/product/classmethod-can-public/cmca-elk-ubuntu-2204)
- deployes 7.17.X version of the stack, ready made
