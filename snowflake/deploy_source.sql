
-- Pipeline objects
use role etl;
use database source;


-- Source Stages
create or replace stage public.datasets
url = 's3://snowflake-lab/public/datasets'
comment = 'Snowflake lab datasets';

create or replace stage public.quickstart
url='s3://tableau-snowflake-quickstart'
comment = 'Tableau quickstart datasets';


-- Source File formats
create or replace file format public.csv
type=csv
compression = 'auto' field_delimiter = ',' 
record_delimiter = '\n' 
skip_header = 2 
field_optionally_enclosed_by = 'none' 
trim_space = false 
error_on_column_count_mismatch = true 
escape = 'none' 
escape_unenclosed_field = '\134' 
date_format = 'auto' 
timestamp_format = 'auto' 
null_if = ('\\n');


-- Source Tables
create or replace table public.airline_raw
(
    src variant not null,
    src_filename string not null,
    src_file_row_num int not null,
    create_process string not null,
    create_ts timestamp_ntz not null
);

create or replace table public.nyc_taxi_raw 
(
    vendorid string not null, 
    tpep_pickup_datetime datetime not null, 
    tpep_dropoff_datetime datetime not null, 
    passenger_count integer, 
    trip_distance number (15, 2),
    pickup_longitude number (15, 2),
    pickup_latitude number (15, 2),
    ratecodeid integer, 
    store_and_fwd_flag string, 
    pulocationid integer,
    dolocationid integer,
    payment_type integer,
    fare_amount number (38, 2),
    extra number (15, 1), 
    mta_tax number (15, 1),
    tip_amount number (15, 2),
    tolls_amount number (15, 2), 
    improvement_surcharge number (15, 1),
    total_amount number (15, 2),
    src_filename string not null,
    src_file_row_num int not null,
    create_process string not null,
    create_ts timestamp_ntz not null
);