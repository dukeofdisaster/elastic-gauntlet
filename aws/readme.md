# Amazon Web Services 
Deploying ELK stack on AWS for practice / upskill. 

## NOTE ABOUT Marketplace Solutions
If you're using sandbox environment like A Cloud Guru, marketplace options may be a nogo for you but the marketplace options listed in the appendix are a good starting point.

## NOTE ABOUT A Cloud Guru Solutions
If you're using A Cloud Guru's AWS Sandbox you should edit the default security group to allow all inbound traffic on TCP 22. This will allow AWS Instance connect to work out of the box without the added overhead of whitelisting the relevant AWS IP range. 

EXTRA CREDIT: setup your little security group such that it only allows SSH from the IP ranges used by EC2 Instance Connect in the relevant region. 

## Note About the 2 cloudformation templates for 7.17 and 8.6
These templates have been tested  in A Cloud Guru sandbox and they should not exceed any limits of the platform (I think the ec2 limit is like 5 or 6 instances?). 

The templates were re-used from a different project which included some labbing  with logstash output => s3 and consuming from that bucket via the S3+SQS input.

The consumers in this stack should all have read access to  the s3 bucket logstash-logs/ and the producer (ELK stack)  should have write to logstash-logs/

## First Challenge

## APPENDIX 
1. [ELK packaged by Bitnami v8.6.2](https://aws.amazon.com/marketplace/pp/prodview-tlbc33skxwrm6?ref_=unifiedsearch#pdp-pricing)
    - also has other versions
2. [ELK powered by Classmethod](https://aws.amazon.com/marketplace/pp/prodview-b4smwvohrq6t6?ref_=unifiedsearch)
    - has more granular control of cost estimation
