#!/bin/bash

#sudo yum update -y
sudo yum install jq -y

#aws -h > /dev/null
aws --version
if [ $? -eq 0 ]; then
  SECURITY_GROUP=$(curl http://169.254.169.254/latest/meta-data/security-groups/)
  echo "This security group is assigned to this EC2 instance [$SECURITY_GROUP]"

  if [ "$SECURITY_GROUP" != "" ]; then
    aws ec2 describe-security-groups --group-names "launch-wizard-1"
    if [ $? -ne 0 ]; then
      echo "aws is not configured correctly.  Are you running as sudo?  Then the aws config should be done for root"
    fi

    aws ec2 describe-security-groups --group-names "launch-wizard-1" | jq '.SecurityGroups[] | .IpPermissions[] | [.FromPort,.ToPort,.IpProtocol,.IpRanges[0].CidrIp] | @csv' | grep '3000,3000,\\"tcp\\",\\"0.0.0.0/0\\"'
    if [ $? -ne 0 ]; then
      echo "Cannot find a rule for this EC2 isntance with the port 3000 inbound"
      echo "double the rules, maybe my check is too restrictive"
    else
      echo "found port 80 in the rules for this security group"
    fi
  else
    echo "Unable to get security group.  Probably NOT running on AWS EC2 instance"
  fi
else
  echo "Did not detect AWS linux, skipping validation in AWSCLI..."
fi

docker pull node:latest
docker build -t mm_serveronly .

docker network ls | grep nginxbridge > /dev/null
if [ $? -ne 0 ]; then
  docker network create --driver=bridge nginxbridge
fi
echo image created, with a [network broadcast domain]/subnet named nginxbridge

# below starts the container on port 3000, in detached mode, connected to nginxbridge
# containers can resolve DNS names of other containers in same docker network (it may also be able to resolve in other networks, I dont know, but routing to thoer networks is disabled by default)
if [ "$1" != "pushonly" ]; then
  docker run -dit --name mm_serveronly_demo -p 3000:3000 --network=nginxbridge --restart unless-stopped mm_serveronly:latest
  if [ $? -eq 0 ]; then
    echo "docker container [mm_serveronly_demo] running"
  fi
fi

# if you would prefer this build an image, and it upload to AWS ECR, comment above, uncomment below
# the below commands will only work, if you have aws-cli installed, and execute the command "aws configure" first, to setup the secret key which is set up in AWS Security Credentials
# AND create a AWS ECR public repository named "mm-serveronly-defaults" AND give yourself upload permission to ECR-public

# aws ecr get-login-password --region <aws region> | docker login --username AWS --password-stdin <aws account id>.dkr.ecr.region.amazonaws.com
# docker tag mm-serveronly <aws account id>.dkr.ecr.<same region above>.amazonaws.com/mm-serveronly-defaults:latest
# docker push <aws account id>.dkr.ecr.<same region above>.amazonaws.com/mm-serveronly-defaults:latest
if [ "$1" == "pushonly" ]; then
  aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/y8w3p2i4
  docker tag mm_serveronly:latest public.ecr.aws/y8w3p2i4/mm-serveronly-defaults:latest
  docker push public.ecr.aws/y8w3p2i4/mm-serveronly-defaults:latest
  if [ $? -eq 0 ]; then
    echo "pushed to public ECR repository"
  fi
fi
