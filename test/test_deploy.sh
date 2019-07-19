#!/bin/bash
for i in {1..100}
do
    aws --profile mfa cloudformation deploy \
        --template-file ./cloudformation/private-subnet-pubilc-service.yml \
        --stack-name ecs-fargate-service-${i} \
        --parameter-overrides \
            StackName=ecs-fargate-network \
            AllowWebCidrIp=185.245.87.200/32 \
            SnowflakeAccount=ub61792 &
    sleep 2
done
