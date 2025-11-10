#!/bin/bash
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