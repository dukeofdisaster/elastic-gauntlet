# ELASTIC GAUNTLET
This repo was birthed out of $DAYJOB. The driving question I had was this. 

```
"How do I take someone from zero to hero with the elastic stack in an engineering role?" 
```

Two of the most common answers include...

1. ```TRAINING FROM THE VENDOR```
2. ```TRAINING FROM A THIRD PARTY PROVIDER```


While these certainly have their place, they often lack additional in depth operational know-how / savvy or they are slightly out of touch. 

TL;DR there is no perfect solution but this repo was created to give an incoming operator additional practical hands-on skill.

## Operating Systems
LINUX LINUX LINUX LINUX LINUX. 

Elastic loves linux and so should you. If you don't know your way around the command line this repo may be more difficult for you. While the major components of the stack (Logstash, Elasticsearch) are Java applications and thus OS agnostic since they run on the JVM, Linux is the OS of choice since 

1. Elastic's cloud service (elasticsearch at scale) runs on linux. 
2. I've had a brief stint as a 'firefighter' with a small org trying to run the stack that was a 'windows shop'.... and lets just say I think the fire is still burning. 


## /log-samples
Contains various log samples that can be used for practice. Where possible these have been gathered from online sources. Other samples include edge-cases that can really only be addressed in one component of the stack or with some custom external transformation process pre-ingest. 

Problem logs have naming convention ```problem-<problem_description>.log```

## /src
Contains various scripts that can be used. 

1. gen-palo-batch.sh

## /auto-deploy
Contains cloud deployment templates that can have variables modified to meet a given need. For example of OPERATOR_SOURCE_IP white listed for inbound traffic.

Special emphasis was placed on making these templates allow shell access over the web in $PICK_YOUR_CLOUD_PROVIDER_HERE because most large orgs should not be allowing arbitrary SSH traffic outbound. On some providers this is easier to achieve than others (for example, GCP's shell access to a linux box is straight forward and requires no boilerplate config / othe services)

1. GCP
    1. GCP deployments are excluded because the marketplace has a good pre-canned image which requires minimal setup to get to a state that's ready for BAU practice on v 7.17. 
    1. GCP deployment was also a bit weirder than other providers in that it wasn't readily clear if you could just upload a template (like cloudformation or azure) or if you were dependent

## /dev-tools
Contains various dev tools commands that should be straightforward to execute via copy/paste.

## TASKS
**GUIDING PRINCIPLES**
1. Parse as close to the client as possible. 
2. If ECS mappings exist for log fields, map them as closely to ECS as possible. 
    1. If you use pre-canned integrations this is generally more straightforward, but is not a guarantee.
    1. ESTC pre-canned integrations and ECS work best on api-sourced type events
    1. Syslog-type sourced events fare less well with elastic integrations in our testing and may be only partially parsed 
3. Use text fields only on ```event.original```. 
4. Don't use ```event.original``` for log messages that are already well-structured (ndjson) or log messages which must be split (records arrays).
5. If a log message contains an authoritative ```Globally Unique IDentifier (GUID)``` map it appropriattely; you may optionally choose to set this field as the internal/reserved value of ```_id``` on the document at ingest; why or why not?
6. If a log message isn't well structured at the source (json) but is well structured in it's content; i.e ```TIME_HERE LEVEL_HERE SUB_FIELD_HERE OTHER_MESSAGE_DATA_WITH_SPACES_OR_OTHER``` use a ```DISSECT``` filter over grok; your impending carpel tunnel will thank you.
7. If you have to use grok; ```ANCHOR YOUR GROK PATTERNS: ^ and $ are your friends```
8. If you find yourself using lots of grok in a given logstash config, ```MOVE YOUR GROK PATTERNS TO A DEDICATED FILE OUTSIDE OF THE PRIMARY CONFIG``` ; your ophthalmologist won't thank you, but you may thank yourself, and so may any peers that have to view/edit/update your config file.
9. Favor using tagging or other message-specific fields in your logstash filter stanza logic over fields that are tied to the input if you set meta fields on your events; i.e. it's common practice to add field ```logstash.input: 5099tcp``` on a beats input; but operators will often follow the path of least resistence, and if a squeaky wheel needs grease, it may be faster to grease that wheel on ```5099tcp``` and reuse the port, and if you use ```if [logstash][input] == '5099tcp'```, your borderline config just got even muckier.
10. ```DUPLICATES == BAD```: so we're getting a few duplicate messages, so what ? Duplicates don't scale and should be dealt with. This issue mostly arises in in-house API polling patterns where no pre-canned integration exists and a custom one must be developed. To ensure no messages are lost, overlapping poll times end up being used; i.e. ```POLL_BATCH_N(FROM:12:30 TO:12:45), POLL_BATCH_N+1(FROM:12:40 TO:12:55)```. Depending on the log volume different approaches can be used; for example dumping a json dictionary to disk with ```guid:seentime``` entries then purging those entries whenever ```NOW - seentime > SOME_THRESHOLD```. 
11. Use the time reported in your original event as the authoritative ```@timestamp``` ; in the best case this is readily parsed ISO8601 UTC timestamp; 
12. Use time meta as an indicator of issues in your pipeline; taking the diff of the reported log time and different times the event is touched in your pipeline can give useful metrics / indicators of health. For example, syslog messages coming hot off the wire should be relatively low lag (seconds), but if you see a spike in the diff this could indicate issues.

**OBJECTIVES**
1. Deploy a filebeat agent to collect the following logs and ship them directly to elasticsearch. Use ingest pipelines at will. Index name filebeat-test-blahblahblah
    1. Did any problems arise? 
    1. How can you resolve these problems? 
1. Make an elastic agent fleet policy to consume the following logs and ship them directly to elasticsearch. Use ingest pipelines at will. Data stream or index name elastic-agent-test-blahblahblah
    1. Did any problems arise?
    2. How can you resolve these problems?
1. Update your filebeat config to ship to a logstash node w/out tls. It should output to an index named logstash-test-blah-blah-blah
    1. Did any problems arise? 
    2. How can you address these problems?
2. Update your fleet policy to ship to a logstash node. It should output to an index or data stream with name ea-logstash-test-blah-blah-blah
    1. NOTE: Logstash output from fleet is only available on 8.0 so disregard this


## APPENDIX
1. [Palo Alto Syslog Samples](https://github.com/jcustenborder/palo-alto-syslog-parser/blob/master/samples.txt)
- note format varies little from soruce to src
2. [GCP: Elk Ubuntu 2204 powered by Classmethod](https://console.cloud.google.com/marketplace/product/classmethod-can-public/cmca-elk-ubuntu-2204)
- deployes 7.17.X version of the stack, ready made
