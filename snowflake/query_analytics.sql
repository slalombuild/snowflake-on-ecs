use role reporting;
use warehouse analyze_wh;
use database analytics;
 
-- Average and max tip by quarter
-- What else can you discover?
select 
d.quarter_name_full
,avg(tip_amount) as avg_tip
,max(tip_amount) as max_tip
,max(d.cal_date) as cal_date_sort
from nyc_taxi t
inner join calendar_date d on t.tpep_pickup_date = d.cal_date
group by quarter_name_full
order by cal_date_sort asc;
