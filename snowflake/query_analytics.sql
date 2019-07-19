-- Airport departure delays by quarter
-- ORD selected

use role reporting;
use warehouse analyze_wh;
use database analytics;

select 
d.quarter_name_full
,avg(a.dep_delay) as avg_delay
,max(a.cal_date) as cal_date_sort
from airline a 
inner join calendar_date d on a.cal_date = d.cal_date
where d.year between 2004 and 2008
and origin='ORD'
group by quarter_name_full
order by cal_date_sort asc;
