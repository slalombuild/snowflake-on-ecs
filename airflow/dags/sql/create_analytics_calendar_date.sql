create or replace transient table calendar_date (
  cal_date            date    not null primary key
  ,year               int     not null
  ,month              int     not null
  ,month_name         string  not null
  ,quarter            int     not null
  ,quarter_name       string  not null
  ,quarter_name_full  string  not null
  ,day_of_mon         int     not null
  ,day_of_week        string  not null
  ,week_of_year       int     not null
  ,day_of_year        int     not null
  ,create_process     string  not null
  ,create_ts          timestamp_ntz not null
)
as
with cte_cal_date as (
select dateadd(day, seq4(), '1987-01-01') as cal_date
    from table(generator(rowcount=>14000)) -- Number of days after reference date in previous line 
)
select 
    cal_date::date
    ,year(cal_date)::int
    ,month(cal_date)::int
    ,monthname(cal_date)::string
    ,quarter(cal_date)::int
    ,('Q' || quarter(cal_date))::string
    ,('Q' || quarter(cal_date) || '-' || year(cal_date))::string
    ,day(cal_date)::int
    ,dayofweek(cal_date)::string
    ,weekofyear(cal_date)::int
    ,dayofyear(cal_date)::int
    ,'Airflow snowflake_analytics Dag'::string
    ,convert_timezone('UTC' , current_timestamp )::timestamp_ntz
from cte_cal_date;