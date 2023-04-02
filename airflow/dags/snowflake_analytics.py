from datetime import timedelta

import airflow
from airflow import DAG
from airflow.contrib.operators.snowflake_operator import SnowflakeOperator

# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': airflow.utils.dates.days_ago(1),
    'email': ['admin@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'snowflake_analytics',
    default_args=default_args,
    description='Snowflake analytics pipeline',
    schedule_interval='@daily',
)


t1 = SnowflakeOperator(
    task_id='create_analytics_calendar_date',
    sql='sql/create_analytics_calendar_date.sql',
    snowflake_conn_id='snowflake_default',
    warehouse='load_wh',
    database='analytics',
    autocommit=True,
    dag=dag)

# t2 = SnowflakeOperator(
#     task_id='create_analytics_airline',
#     sql='sql/create_analytics_airline.sql',
#     snowflake_conn_id='snowflake_default',
#     warehouse='load_wh',
#     database='analytics',
#     autocommit=True,
#     dag=dag)

t2 = SnowflakeOperator(
    task_id='create_analytics_nyc_taxi',
    sql='sql/create_analytics_nyc_taxi.sql',
    snowflake_conn_id='snowflake_default',
    warehouse='load_wh',
    database='analytics',
    autocommit=True,
    dag=dag)

# t1 >> t2 >> t3
t1 >> t2
