## This repo offers a solution for pushing a Splunk Docker container image to ECR and deploying it on an auto-scaling group on ECS.


# Prerequisites 
- An AWS account with access keys

- AWSCLI configured on your command line interface 

- Terraform installed on your machine

- Docker Desktop installed on your machine
 



# How to Deploy
Git clone this repo to a directory of your choosing

Right click on Docker Desktop and run it as administrator

CD into the ecr+docker-compose directory

In the docker-compose.yml file change the password to fit your needs

```
services:
  splunk:
    image: splunk/splunk:latest
    hostname: splunk-standalone
    environment:
      - SPLUNK_START_ARGS=--accept-license
      - SPLUNK_PASSWORD=what_lies_below
      - SPLUNK_GENERAL_TERMS=--accept-sgt-current-at-splunk-com
    ports:
      - "8000:8000" # Splunk Web UI
      - "8089:8089" # HTTP Event Collector (HEC)
    volumes:
      - splunk_data:/opt/splunk/var
volumes:
  splunk_data:
```

Create the Docker container by running the following command:
```docker compose up -d```

Modify the Terraform configuration files to suit your needs for deployment.

Once the container has been created, run the following Terraform commands to create the ECR repository:

``` 
    terraform init
    terraform validate
    terraform plan
    terraform apply
```

After the ECR repository has been created, click on the automated-push.sh file. This is a simple bash script that will push the docker container image to the ECR repository you've just deployed in Terraform.

```#!/bin/bash
Account=$(aws sts get-caller-identity --query "Account" --output text)
UserId=$(aws sts get-caller-identity --query "UserId" --output text)
Arn=$(aws sts get-caller-identity --query "Arn" --output text)
echo "Account: $Account"
echo "UserId: $UserId"
echo "Arn: $Arn"
REGION="eu-west-1"
IMAGE="splunk/splunk"
REPOSITORY="class6"
TAG="splunk"
# Choose any of the tags you want
LATEST="latest"
echo $REGION
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $Account.dkr.ecr.$REGION.amazonaws.com
docker tag $IMAGE:$LATEST $Account.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY/$TAG:latest
docker push $Account.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY/$TAG:latest
echo "CONGRATULATIONS! Your image has been successfully uploaded to ECR."
```




Change REGION, REPOSITORY, and TAG environment variables as needed.

Run the automated-push.sh by running: ```./automated-push.sh```

Let the bash script run (This may take anywhere from 15-20 minutes)

Once it has completed the terminal will echo the following message: CONGRATULATIONS! Your image has been successfully uploaded to ECR.



CD into the infra directory

Edit the Terraform configuration files as needed within the infra directory and run the same Terraform commands to create the Splunk service on ECS:

```
    terraform init
    terraform validate
    terraform plan
    terraform apply
```

Once the resources have finished provisioning, use the output of the load balancer DNS to verify that the deployment worked.

It should look similar to this: ```splunk-lb-dns = "http://splunkapp-lb01-680620791.eu-west-1.elb.amazonaws.com"```




If you have done your deployment correctly, you should a screen similar to the image below when you input your load balancer DNS into your browser.

The username will be admin and the password will be whatever environment variable that you set in your aws_ecs_task_definition on line 46.



![alt text](https://github.com/NichFos/splunk-on-ecr-and-ecs-terraform/blob/main/images/splunk-7.1.0-1.png)






# Troubleshooting

If you get a 504 Bad Gateway Error, there is a misconfiguration with your security groups. 

Possibilities for error:

- Target group security group is not associated with the launch template

- Target group security group is not set to port 8000

- Load Balancer security group is not being used for the Application Load Balancer

- In file 6-task&service.tf starting on line 90 downwards, network configuration was not configured properly.


If you get a 503 Service Temporarily Unavailable error, that means that your service has not yet finished deploying and needs some time to warm up. Be patient and refresh your browser.

If your auto scaling group instances aren't being associated with the ECS cluster, make sure you have the ecs.sh file in the infra folder. 

- If the ecs.sh file is in the infra folder, make sure the EC2 launch template is actually utilizing that ecs.sh file in the user_data argument.

- Ensure that you are also attaching the correct IAM instance profile to the EC2 launch template. Ensure it has the proper IAM policy attached to it.



If your task definition isn't being created due to a lack of CPU, GPU, or Memory, you likely don't have the cpu and memory arguments defined in your container definitions.

- Provide the CPU, GPU, or Memory arguments (depending on what you're lacking) in the container definitions block in file 6-task&service.tf on lines 23-26.

