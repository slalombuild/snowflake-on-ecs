copy into nyc_taxi_raw(vendorid, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, 
    pickup_longitude, pickup_latitude, ratecodeid, store_and_fwd_flag, pulocationid, dolocationid, payment_type, 
    fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, src_filename, 
    src_file_row_num, create_process, create_ts    
)
from (
  select t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,t.$12,t.$13,t.$14,t.$15,t.$16,t.$17,t.$18,t.$19,
  metadata$filename,
  metadata$file_row_number,
  'Airflow snowflake_raw Dag',
  convert_timezone('UTC' , current_timestamp )::timestamp_ntz
  from @quickstart/nyc-taxi-data/ t
)
file_format= (format_name = csv);