create procedure calculate_salary()
language 'plpgsql'
as $$
declare
	prev_month_total_days integer;
--	prev_month_total_weekend integer;
--	prev_month_total_holiday integer;
	prev_month_total_offday integer;
	prev_month_start_day date;
	prev_month_end_day date;
begin
	
	select date_trunc('month', current_date - interval '1 month')::date
	into prev_month_start_day;

	select prev_month_start_day + interval '1 month - 1 day' into prev_month_end_day;
	
	select date_part(
		'days',
		date_trunc('month', current_date - interval '1 month') 
		+ interval '1 month - 1 day'
	) into prev_month_total_days;

	select count(*)
	into prev_month_total_offday
	from 
	(
		select to_char(weekend_dates, 'yyyy-mm-dd') 
		from generate_series(
			date_trunc('month', current_date - interval '1 month'),
			date_trunc('month', current_date - interval '1 month') + interval '1 month - 1 day',
			interval '1 day'
		) as weekend_dates
		where extract ('isodow' from weekend_dates) in (5,6)
		union
		(
			select to_char(date, 'yyyy-mm-dd')
			from holiday
			where date between prev_month_start_day and prev_month_end_day
			order by date)
		) as subquery;

	raise notice 'total days of the prev_month is %', prev_month_total_days;
	raise notice 'total off-day of prev month is %', prev_month_total_offday;
	raise notice 'total working days are %' , (prev_month_total_days - prev_month_total_offday);

end;
$$

call calculate_salary();

------------------------  create function ---------------------------------------
create function find_total_working_days ()
	returns int
	language plpgsql
as
$$
declare
	prev_month_total_days integer;
	prev_month_total_offday integer;
	prev_month_start_day date;
	prev_month_end_day date;

begin
	select date_trunc('month', current_date - interval '1 month')::date
	into prev_month_start_day;

	select prev_month_start_day + interval '1 month - 1 day' into prev_month_end_day;
	
	select date_part(
		'days',
		date_trunc('month', current_date - interval '1 month') 
		+ interval '1 month - 1 day'
	) into prev_month_total_days;

	select count(*)
	into prev_month_total_offday
	from 
	(
		select to_char(weekend_dates, 'yyyy-mm-dd') 
		from generate_series(
			date_trunc('month', current_date - interval '1 month'),
			date_trunc('month', current_date - interval '1 month') + interval '1 month - 1 day',
			interval '1 day'
		) as weekend_dates
		where extract ('isodow' from weekend_dates) in (5,6)
		union
		(
			select to_char(date, 'yyyy-mm-dd')
			from holiday
			where date between prev_month_start_day and prev_month_end_day
			order by date)
		) as subquery;
	
	return (prev_month_total_days - prev_month_total_offday);
	
end;
$$



select find_total_working_days ();

--------------------------------------------------------------------
create or replace procedure insert_salary_report()
language 'plpgsql'
as $$
declare
	prev_month_total_working_days integer;
	rec record;
	len integer;
	prev_month integer;

begin
	--finding all people prev month allocated salary
	prev_month_total_working_days := find_total_working_days();
	len := (select count(*) from employee);
	prev_month := (select date_part('month', current_date)-1);
	
	raise notice 'total % employees are there', len;
	raise notice 'total working days are %', prev_month_total_working_days;

	for rec in 
--	1..len loop
		select 	emp_id,count(*) as total_present, salary as monthly_salary,
				count(*) * salary / prev_month_total_working_days as allocated_salary
		from attendance a
		join employee e on a.emp_id = e.id 
		join designation d on d.id = e.designation_id
		where is_present = true
		group by emp_id, salary
	loop
		insert into salary_report (
			emp_id, month, 
			total_working_days, total_attendance,
			attendance_percentage, 
			allocated_salary
			)
		values (
			rec.emp_id, prev_month,
			prev_month_total_working_days, rec.total_present,
			(cast(rec.total_present as real)/cast(prev_month_total_working_days as real)),
			rec.allocated_salary
			);
	end loop;
end;
$$


call insert_salary_report();

--
----------------------------the final report query ------------------------------------------------------

create or replace function show_the_final_report() 
returns table (
	Employee_PIN int,
	Employee_Name varchar,
	gender sex,
	Salary_Month int,
	designation varchar,
	total_working_days int,
	total_attendance int,
	attendance_percentage real,
	monthly_salary int,
	allocated_salary int	
)
language plpgsql
as $$
begin
	return query
		select 
			pin, username,
			e.gender, sr.month,  designation_name as designation,
			sr.total_working_days, sr.total_attendance, sr.attendance_percentage,
			d.salary as monthly_salary, sr.allocated_salary
		from attendance a
		join employee e on a.emp_id = e.id 
		join designation d on d.id = e.designation_id
		join salary_report sr on sr.emp_id = e.id
		where is_present = true
		group by 
			pin, username, e.gender, month, 
			designation_name, sr.total_working_days, 
			sr.total_attendance, sr.attendance_percentage,
			d.salary, sr.allocated_salary;
end;
$$

--------find total off days------------------
create or replace function find_offdays(year int, month int)
returns int
language plpgsql
as
$$
declare
	offdays_count integer;
	result_date date;
begin
	select make_date(year, month, 1) into result_date;
	
	select count(*)
	into offdays_count 
	from 
		(
			select to_char(weekend_dates, 'yyyy-mm-dd') 
			from generate_series(
				date_trunc('month', result_date),
				date_trunc('month', result_date) + interval '1 month - 1 day',
				interval '1 day'
			) as weekend_dates
			where extract ('isodow' from weekend_dates) in (5,6)
			union
			(
			select to_char(date, 'yyyy-mm-dd')
			from holiday 
			where date between 
			date_trunc('month', result_date) and date_trunc('month', result_date) + interval '1 month - 1 day' 
			order by date
			)
		) as subquery;
	
	return offdays_count;
end;
$$;

select find_offdays(2023,02);

-------------------
create or replace function find_total_days(year int, month int)
returns int
language plpgsql
as
$$
declare
	total_days integer;
	result_date date;
begin
	select make_date(year, month, 1) into result_date;
	
	select date_part(
		'days',
		date_trunc('month', result_date) 
		+ interval '1 month - 1 day'
	) into total_days;

	return total_days;
end;
$$;

select find_total_days(2023,06);


