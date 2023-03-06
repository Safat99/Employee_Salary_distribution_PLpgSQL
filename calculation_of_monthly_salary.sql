select * from salary;

select
	designation, salary,
	(salary/20) as per_day_salary
from salary;


select
	designation, salary as monthly_salary,
	((salary/20) * 10) as current_month_salary_assuming_present_10_days,
	username
from salary
join employee
using (designation);



--finding total working days

/*
possible solution --> 1. user will give input
					2. we can assume at least any of employee will be present in a working day
				
*/

--number of total holidays 
select * from attendance
limit 100;

select
	date, count(*)
from attendance
where is_present = true
group by date
order by date;

----------------------- main query ------------------------
select 
	emp_id, username, designation_name, count(*) as total_present_days, 
	salary as monthly_salary, count(*) * salary / 19 as allocated_salary
from attendance a
join employee e on a.emp_id = e.id 
join designation d on d.id = e.designation_id
where is_present = true
group by emp_id, username, salary, designation_name;


---finding prev month total days

select date_part(
		'days',
		date_trunc('month', current_date - interval '1 month') 
		+ interval '1 month - 1 day'
);


--- finding weekend

--select count(*) total_weekends_of_prev_month
select count(*) from 
	(
		select to_char(weekend_dates, 'yyyy-mm-dd') 
		from generate_series(
			date_trunc('month', current_date - interval '1 month'),
			date_trunc('month', current_date - interval '1 month') + interval '1 month - 1 day',
			interval '1 day'
		) as weekend_dates
		where extract ('isodow' from weekend_dates) in (5,6)
		union
		(select to_char(date, 'yyyy-mm-dd') from holiday order by date)
	) as subquery;

--holiday table day mapping mon = 1, tues = 2
select extract (isodow from current_date) as holiday_isodow;





