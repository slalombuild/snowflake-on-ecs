create or replace transient table airline (
    cal_date date not null
    ,actual_elapsed_time string not null
    ,airtime string not null
    ,arr_delay string not null
    ,arr_time string not null
    ,crs_arr_time string not null
    ,crs_dep_time string not null
    ,crs_elapsedtime string not null
    ,cancelled string not null
    ,carrier_delay string not null
    ,day_of_week int not null
    ,day_of_month int not null
    ,dep_delay string null
    ,dep_time string not null
    ,dest string not null
    ,distance string not null
    ,diverted string not null
    ,flight_num string not null
    ,late_aircraft_delay string not null
    ,month int not null
    ,nas_delay string not null
    ,origin string not null
    ,security_delay string not null
    ,tail_num string null
    ,taxi_in string not null
    ,taxi_out string not null
    ,unique_carrier string not null
    ,weather_delay string not null
    ,year int not null
    ,create_process string not null
    ,create_ts timestamp_ntz not null
)
as
select
    (src:Year || '-' || src:Month || '-' || src:DayofMonth)::date,
    src:ActualElapsedTime::string,
    src:AirTime::string,
    src:ArrDelay::string,
    src:ArrTime::string,
    src:CRSArrTime::string,
    src:CRSDepTime::string,
    src:CRSElapsedTime::string,
    src:Cancelled::string,
    src:CarrierDelay::string,
    src:DayOfWeek::int,
    src:DayofMonth::int,
    nullif(src:DepDelay, 'NA')::int,
    src:DepTime::string,
    src:Dest::string,
    src:Distance::string,
    src:Diverted::string,
    src:FlightNum::string,
    src:LateAircraftDelay::string,
    src:Month::int,
    src:NASDelay::string,
    src:Origin::string,
    src:SecurityDelay::string,
    src:TailNum::string,
    src:TaxiIn::string,
    src:TaxiOut::string,
    src:UniqueCarrier::string,
    src:WeatherDelay::string,
    src:Year::int,
    'Airflow snowflake_analytics Dag'::string,
    convert_timezone('UTC' , current_timestamp )::timestamp_ntz
from raw.public.airline_raw;