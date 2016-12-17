## This file was automatically generated using the CloudCoreo CLI
##
## This config.rb file exists to create and maintain services not related to compute.
## for example, a VPC might be maintained using:
##
coreo_aws_vpc_vpc "${VPC_NAME}" do
  action :sustain
  cidr "12.0.0.0/16"
  internet_gateway true
end

coreo_aws_ec2_securityGroups "${JENKINS_NAME}" do
  action :sustain
  description "Jenkins security group"
  vpc "${VPC_NAME}"
  allows [ 
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => ${JENKINS_INGRESS_PORTS},
            :cidrs => ${JENKINS_INGRESS_CIDRS}
          },{ 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ["0..65535"],
            :cidrs => ["0.0.0.0/0"]
          }
    ]
end

coreo_aws_iam_policy "${JENKINS_NAME}-route53" do
  action :sustain
  policy_name "AllowJenkinsRoute53Entries"
  policy_document <<-EOH
{
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
          "route53:*"
      ]
    }
  ]
}
EOH
end

coreo_aws_iam_policy "${JENKINS_NAME}-s3" do
  action :sustain
  policy_name "AllowJenkinsS3Backup"
  policy_document <<-EOH
{
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${BACKUP_BUCKET}/${BACKUP_BUCKET_REGION}/jenkins/${ENV}/${JENKINS_NAME}",
          "arn:aws:s3:::${BACKUP_BUCKET}/${BACKUP_BUCKET_REGION}/jenkins/${ENV}/${JENKINS_NAME}/*"
      ],
      "Action": [ 
          "s3:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*",
      "Action": [
          "s3:ListAllMyBuckets"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${BACKUP_BUCKET}",
          "arn:aws:s3:::${BACKUP_BUCKET}/*"
      ],
      "Action": [
          "s3:GetBucket*", 
          "s3:List*" 
      ]
    }
  ]
}
EOH
end

coreo_aws_vpc_routetable "${JENKINS_NAME}-routetable" do
  action :sustain
  vpc "${VPC_NAME}"
  number_of_tables 3
end

coreo_aws_vpc_subnet "${PRIVATE_SUBNET_NAME}" do
  action :sustain
  vpc "${VPC_NAME}"
  percent_of_vpc_allocated 25
  route_table "${JENKINS_NAME}-routetable"
end

coreo_aws_iam_policy "${JENKINS_NAME}-yum" do
  action :sustain
  policy_document <<-EOH
{
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${YUM_REPO_BUCKET}",
          "arn:aws:s3:::${YUM_REPO_BUCKET}/*"
      ],
      "Action": [ 
          "s3:*"
      ]
    }
  ]
}
EOH
end

coreo_aws_iam_instance_profile "${JENKINS_NAME}" do
  action :sustain
  policies ["${JENKINS_NAME}-s3", "${JENKINS_NAME}-route53", "${JENKINS_NAME}-yum"]
end

coreo_aws_ec2_instance "${JENKINS_NAME}" do
  action :define
  image_id "${AWS_LINUX_AMI}"
  size "${JENKINS_SIZE}"
  security_groups ["${JENKINS_NAME}"]
  role "${JENKINS_NAME}"
  ssh_key "${JENKINS_KEYPAIR}"
  disks [
         {
           :device_name => "/dev/xvda",
           :volume_size => 50
         }
        ]
end

coreo_aws_ec2_autoscaling "${JENKINS_NAME}" do
  action :sustain 
  minimum 1
  maximum 1
  server_definition "${JENKINS_NAME}"
  subnet "${PRIVATE_SUBNET_NAME}"
end
