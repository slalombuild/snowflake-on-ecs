# snowflake-on-ecs

A compact framework for automating a Snowflake analytics pipeline on Amazon ECS.

![alt text](https://snowflake-lab.s3-us-west-2.amazonaws.com/public/images/snowflake_ecs_arch.png "Snowflake on ECS Architecture")

## Getting Started

Clone repository and change to project directory

```bash
cd /path/to/repo
git clone https://github.com/SlalomBuild/snowflake-on-ecs.git
cd snowflake-on-ecs
```

## Installing Requirements

Install requirements for running tests and deploying to AWS

```bash
pip install -r requirements-dev.txt
```

## Setting up Snowflake

Setup the Snowflake framework and deploy the `raw` database objects.

- Create Snowflake trial account.
- Log in as your Snowflake account user.
- Run `setup_framework.sql` script in the Snowflake Web UI.
- This creates the Snowflake databases, warehouses, roles, and grants
- Log in as `snowflake_user` and change your password.
- Log back in as `snowflake_user`.
- Run `deploy_objects.sql` script in Snowflake Web UI.
- This creates the raw tables, stages, and file formats.

## Deploying to AWS

### Build Docker image

Start Docker host and run the following command.

``` bash
$ docker build -t slalombuild/airflow-ecs .
...
Step 16/17 : ENTRYPOINT ["/entrypoint.sh"]
 ---> Using cache
 ---> f1e75339c73a
Step 17/17 : CMD ["webserver"]
 ---> Using cache
 ---> 4d746387437b
Successfully built 4d746387437b
Successfully tagged slalombuild/airflow-ecs:latest
```

### Deploy Docker image to Amazon ECR

Create the ECR repository in your AWS account using the AWS CLI tool

```bash
$ aws ecr create-repository --repository-name slalombuild/airflow-ecs --region us-west-2
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-west-2:999999999999:repository/slalombuild/airflow-ecs",
        "registryId": "999999999999",
        "repositoryName": "slalombuild/airflow-ecs",
        "repositoryUri": "999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs",
        "createdAt": 1584829898.0,
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}
```

Tag your image with the repositoryUri value from the previous step

```bash
docker tag slalombuild/airflow-ecs \
999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.9
```

Get the docker login authentication command string for your registry.

```bash
$ aws ecr get-login --no-include-email --region us-west-2
docker login -u AWS -p abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
...
abcdef1234567890abcdef123 = https://999999999999.dkr.ecr.us-west-2.amazonaws.com
```

Run the `docker login` command that was returned in the previous step. This command provides an authorization token that is valid for 12 hours. You can safely ignore the warning message.

```bash
$ docker login -u AWS -p abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
...
abcdef1234567890abcdef123 = https://999999999999.dkr.ecr.us-west-2.amazonaws.com
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```

Push the image to your ECR repository with the repositoryUri value from the earlier step.

```bash
$ docker push 999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.9
The push refers to repository [999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs]
1491e4384c9e: Pushed
309c14d6a58f: Pushed
ad3a7ed741d6: Pushed
5ed16ea2a772: Pushed
fd12edf2a904: Pushed
fdf6c4a26006: Pushed
1.10.9: digest: sha256:b854fa72f5f01e0a8ce3a8c4267ce2d6e849533de299d6f9763751fce069119e size: 1574
```

### Set SSM Parameters

#### String Parameters

Set Airflow backend Postgres database name and username

```bash
$ aws ssm put-parameter --name /airflow-ecs/AirflowDbName --type String \
--value "airflowdb" --region us-west-2
{
    "Version": 1,
    "Tier": "Standard"
}

$ aws ssm put-parameter --name /airflow-ecs/AirflowDbUser --type String \
--value "airflow" --region us-west-2
{
    "Version": 1,
    "Tier": "Standard"
}
```

Set Snowflake username

```bash
$ aws ssm put-parameter --name /airflow-ecs/SnowflakeUser --type String  \
--value "snowflake_user" --region us-west-2
{
    "Version": 1,
    "Tier": "Standard"
}
```

Set ECR image url

```bash
$ aws ssm put-parameter --name /airflow-ecs/ImageUrl \
--region us-west-2 \
--type String --value "999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.9"
{
    "Version": 1,
    "Tier": "Standard"
}
```

#### Secure String Parameters

Set passwords for Airflow backend Postgres db and Snowflake

```bash
$ aws ssm put-parameter --name /airflow-ecs/AirflowDbCntl --type SecureString \
--value "xxxxxxxxxxx" --region us-west-2

$ aws ssm put-parameter --name /airflow-ecs/SnowflakeCntl --type SecureString  \
--value "xxxxxxxxxxx" --region us-west-2
```

Generate and set Fernet key for Airflow cryptography

```bash
$ python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)"
abcdef1234567890abcdef1234567890abcdef12345=

$ aws ssm put-parameter --name /airflow-ecs/FernetKey --type SecureString \
--value "abcdef1234567890abcdef1234567890abcdef12345=" --region us-west-2
{
    "Version": 1,
    "Tier": "Standard"
}
```

### Deploy CloudFormation Stacks

See CloudFormation template file for full list of parameters and defaults.

#### Network Stack

Create VPC, Subnets, and ECS cluster

```bash
$ aws cloudformation deploy --template-file ./cloudformation/private-vpc.yml \
    --stack-name ecs-fargate-network \
    --region us-west-2 \
    --capabilities CAPABILITY_IAM

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - ecs-fargate-network
```

#### ECS Service Stack

Create ECS Service and Task Definition

```bash
# Hit https://www.whatsmyip.org for AllowWebCidrIp value
$ aws cloudformation deploy --template-file ./cloudformation/private-subnet-pubilc-service.yml \
    --stack-name ecs-fargate-service \
    --region us-west-2 \
    --parameter-overrides \
        StackName=ecs-fargate-network \
        AllowWebCidrIp=xxx.xxx.xxx.xxx/32 \
        SnowflakeAccount=ab12345

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - ecs-fargate-service
```

## Running in AWS

- Navigate to ECS in AWS Console
- Browse to the Service you created
- Get the public IP of the running task
- Browse to the `http://\<yourtaskpublicip\>:8080` to reach the Airflow web UI
- Enable the schedule for the `snowflake_raw` DAG and manually trigger a launch
- Once DAG runs are complete, do the same for the `snowflake_analytics` DAG
- Once complete, query the `analytics` tables you just built in Snowflake

## Running Locally in Docker

- Edit the `docker-compose-local.yml` file, replacing the values from your Snowflake account
- Make sure docker host is started,
- Run docker compose command to start up Airflow and Postgres DB containers.

```bash
docker-compose -f docker-compose-local.yml up -d
```

- Browse to the `http://localhost:8080` to reach the Airflow web UI
- Enable the schedule for the `snowflake_raw` DAG and manually trigger a launch
- Once DAG runs are complete, do the same for the `snowflake_analytics` DAG
- Once complete, query the `analytics` tables you just built in Snowflake

## Automated Testing

### Run Tox

Run the following tests using Python `tox`. The tests are configured in the `tox.ini` file

- Cloudformation lint
- flake8 Python lint
- Airflow tests

```bash
$ tox
...
cfn-lint run-test: commands[0] | cfn-lint 'cloudformation/*.*'
...
flake8 run-test: commands[0] | flake8 airflow/dags/ airflow/test/ test/
...
tests run-test: commands[0] | pytest test/
================================================= 1 passed in 13.32s ================================================
______________________________________________________ summary_______________________________________________________
  cfn-lint: commands succeeded
  flake8: commands succeeded
  tests: commands succeeded
  congratulations :)
```

## Upcoming Features

- An ECSOperator for executing tasks in Fargate
- Integration with [dbt](http://getdbt.com) for building data models
- Serverless version using AWS Lambda and Step Functions
