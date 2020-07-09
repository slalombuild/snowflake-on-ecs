-- Databases 
use role sysadmin;

create or replace database raw
comment = 'Raw database'
data_retention_time_in_days = 1;

create or replace database analytics
comment = 'Analytics database'
data_retention_time_in_days = 1;

create or replace database sandbox
comment = 'Sandbox database'
data_retention_time_in_days = 1;

create or replace schema sandbox.reporting 
with managed access;

-- Roles
use role securityadmin;

create or replace role etl
comment = 'Etl role';
grant role etl to role sysadmin;

grant usage on database raw to role etl;
grant usage on database analytics to role etl;
grant ownership on schema raw.public to role etl;
grant ownership on schema analytics.public to role etl;


create or replace role reporting
comment = 'Reporting role';
grant role reporting to role sysadmin;

grant usage on database raw to role reporting;
grant usage on database analytics to role reporting;
grant usage on database sandbox to role reporting;
grant usage on schema raw.public to role reporting;
grant usage on schema analytics.public to role reporting;
grant usage, create table, create view 
on schema sandbox.reporting to role reporting;


-- Permissions on future tables 
use role accountadmin;

grant select on future tables in schema raw.public 
to role reporting;
grant select on future tables in schema analytics.public to 
role reporting;


-- Warehouses
use role sysadmin;

create or replace warehouse load_wh with
warehouse_size = 'MEDIUM'
warehouse_type = 'STANDARD'
initially_suspended = true
auto_suspend = 60
auto_resume = true
min_cluster_count = 1
max_cluster_count = 1
comment = 'Load warehouse';
grant usage on warehouse load_wh to etl;

create or replace warehouse analyze_wh with
warehouse_size = 'X-SMALL'
warehouse_type = 'STANDARD'
initially_suspended = true
auto_suspend = 60
auto_resume = true
min_cluster_count = 1
max_cluster_count = 1
comment = 'Analyze warehouse';
grant usage on warehouse analyze_wh to reporting;


-- Users
use role securityadmin;

create or replace user snowflake_user
password = '__CHANGE__'
must_change_password = true
default_role = etl
default_warehouse = load_wh
default_namespace = raw.public;
grant role etl to user snowflake_user;
grant role reporting to user snowflake_user;
