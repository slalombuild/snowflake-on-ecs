# snowflake-on-ecs

A compact framework for automating a Snowflake analytics pipeline on Amazon ECS.

![alt text](https://snowflake-lab.s3-us-west-2.amazonaws.com/public/images/snowflake_ecs_arch.png "Snowflake on ECS Architecture")

## Getting Started

Clone repository and change to project directory

```bash
pwd
/path/to/repo
git clone https://github.com/SlalomBuild/snowflake-on-ecs.git
cd snowflake-on-ecs
```

## Setting up Snowflake

Setup the Snowflake framework and deploy the `source` database objects.

- Create Snowflake trial account.
- Log in as your Snowflake account user.
- Run `setup_framework.sql` script in the Snowflake Web UI.
- This creates the Snowflake databases, warehouses, roles, and grants
- Log in as `snowflake_user` and change your password.
- Log back in as `snowflake_user`.
- Run `deploy_source.sql` script in Snowflake Web UI.
- This creates the source tables, stages, and file formats.


## Deploying to AWS

### Build Docker image

Start Docker host and run the following command.

``` bash
docker build -t slalombuild/airflow-ecs .
```

### Deploy Docker image to Amazon ECR

Create the ECR repository in your AWS account using the AWS CLI tool

```bash
aws ecr create-repository --repository-name slalombuild/airflow-ecs --region us-west-2
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-west-2:999999999999:repository/slalombuild/airflow-ecs",
        "registryId": "999999999999",
        "repositoryName": "slalombuild/airflow-ecs",
        "repositoryUri": "999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs",
        "createdAt": 1560650383.0
    }
}
```

Tag your image with the repositoryUri value from the previous step

```bash
docker tag slalombuild/airflow-ecs \
999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.3
```

Get the docker login authentication command string for your registry.

```bash
aws ecr get-login --no-include-email --region us-west-2
```

Run the `docker login` command that was returned in the previous step. This command provides an authorization token that is valid for 12 hours.

```bash
docker login -u AWS -p
abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
...
abcdef1234567890abcdef123 = https://999999999999.dkr.ecr.us-west-2.amazonaws.com
```

Push the image to your ECR repository with the repositoryUri value from the earlier step.

```bash
docker push 999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.3
```

### Set SSM Parameters

#### String Parameters

Set Airflow backend Postgres database name and username

```bash
aws ssm put-parameter --name /airflow-ecs/AirflowDbName --type String \
--value "airflowdb"

aws ssm put-parameter --name /airflow-ecs/AirflowDbUser --type String \
--value "airflow"
```

Set Snowflake username

```bash
aws ssm put-parameter --name /airflow-ecs/SnowflakeUser --type String  \
--value "snowflake_user"
```

Set ECR image url

```bash
aws ssm put-parameter --name /airflow-ecs/ImageUrl \
--type String --value "999999999999.dkr.ecr.us-west-2.amazonaws.com/slalombuild/airflow-ecs:1.10.3"
```

#### Secure String Parameters

Set passwords for Airflow backend Postgres db and Snowflake

```bash
aws ssm put-parameter --name /airflow-ecs/AirflowDbCntl --type SecureString \
--value "xxxxxxxxxxx"

aws ssm put-parameter --name /airflow-ecs/SnowflakeCntl --type SecureString  \
--value "xxxxxxxxxxx"
```

Generate and set Fernet key for Airflow cryptography

```bash
python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)"
abcdef1234567890abcdef1234567890abcdef12345=

aws ssm put-parameter --name /airflow-ecs/FernetKey --type SecureString \
--value "abcdef1234567890abcdef1234567890abcdef12345="
```

### Deploy CloudFormation Stacks

See CloudFormation template file for full list of parameters and defaults.

#### Network Stack

Create VPC, Subnets, and ECS cluster

```bash
aws cloudformation deploy --template-file ./cloudformation/private-vpc.yml \
    --stack-name ecs-fargate-network \
    --capabilities CAPABILITY_IAM
```

#### ECS Service Stack

Create ECS Service and Task Definition
```bash
aws cloudformation deploy --template-file ./cloudformation/private-subnet-pubilc-service.yml \
    --stack-name ecs-fargate-service \
    --parameter-overrides \
        StackName=ecs-fargate-network \
        AllowWebCidrIp=185.245.87.200/32 \   # google "my ip"
        SnowflakeAccount=ub61792
```

## Running in AWS

### Run Snowflake DAGs
- Navigate to ECS in AWS Console
- Browse to the Service you created
- Get the public IP of the running task
- Browse to the http://yourpublicip:8080 to reach the Airflow web UI
- Enable the schedule for the `snowflake_source` DAG and manually trigger a launch
- Once DAG runs are complete, do the same for the `snowflake_analytics` DAG
- Once complete, query the `analytics` tables you just built in Snowflake

## Running Locally with Docker

- Coming soon!
