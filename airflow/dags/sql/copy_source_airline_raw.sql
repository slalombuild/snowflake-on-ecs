copy into airline_raw(src, src_filename, src_file_row_num,
    create_process, create_ts)
from (
  select t.$1,
  metadata$filename,
  metadata$file_row_number,
  'Airflow snowflake_source Dag',
  convert_timezone('UTC' , current_timestamp )::timestamp_ntz
  from @datasets/airline/ t
)
file_format = (type = 'JSON');