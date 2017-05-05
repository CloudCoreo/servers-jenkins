server-jenkins
============================



## Description
This composite creates a simple Jenkins server instance via an Autoscaling Group


## Hierarchy
![composite inheritance hierarchy](https://raw.githubusercontent.com/CloudCoreo/servers-jenkins/master/images/hierarchy.png "composite inheritance hierarchy")



## Required variables with no default

### `BACKUP_BUCKET`:
  * description: 

### `YUM_REPO_BUCKET`:
  * description: 

### `BACKUP_BUCKET_REGION`:
  * description: 

### `JENKINS_INGRESS_CIDRS`:
  * description: 

### `JENKINS_KEYPAIR`:
  * description: the name of the keypair to launch jenkins with

### `PRIVATE_SUBNET_NAME`:
  * description: 

### `REGION`:
  * description: 

### `VPC_NAME`:
  * description: 


## Required variables with default

### `JENKINS_BACKUP_CRON`:
  * description: default to backing up every hour on the hour
  * default: 0 * * * *


### `ENV`:
  * description: just a way to namespace the backups
  * default: dev


### `JENKINS_AMI`:
  * description: Amazon Linux AMI 2014.03.2 (HVM)
  * default: ami-76817c1e


### `JENKINS_INGRESS_PORTS`:
  * description: Ports to open up in the jenkins security group
  * default: 50, 16

### `JENKINS_NAME`:
  * description: the name of the jenkins server
  * default: jenkins


### `JENKINS_SIZE`:
  * description: the size of the server to launch
  * default: t2.small



## Optional variables with default

**None**


## Optional variables with no default

**None**

## Tags
1. Servers
1. Jenkins


## Categories
1. Servers



## Diagram
![diagram](https://raw.githubusercontent.com/CloudCoreo/servers-jenkins/master/images/diagram.png "diagram")


## Icon
![icon](https://raw.githubusercontent.com/CloudCoreo/servers-jenkins/master/images/icon.png "icon")

