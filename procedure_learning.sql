select * from holiday h; 

create procedure proc_insert_holiday(title varchar(255), date date)
language 'plpgsql'
as $$
begin
	insert into holiday (title, date) values (title, date);
	commit;
end;
$$;


call proc_insert_holiday('shob e barat' , '2023-03-08');

\set numbers SELECT COUNT(*) FROM holiday;


------------------------- function writing -------------
CREATE OR REPLACE FUNCTION test_return_query()
RETURNS TABLE(name varchar, amount integer)
language 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
	    select employee.username,  count(*)::integer
	    from attendance
	    join employee
	    on employee.id = attendance.emp_id
	    where is_present = true 
	    group by employee.username;
end;
$$;	


-------------------- another way to assigning variables -----------------------
do $$
declare
--	prev_month_total_attendance integer;
--	current_emp_id integer;
	rec record;
begin
	
	select emp_id, count(*) as total
--	into current_emp_id, prev_month_total_attendance
	into rec
	from attendance
	where is_present = true and emp_id = 3
	group by emp_id;

	
--	raise notice '1st emp total attendance %', prev_month_total_attendance;
	raise notice '1st emp total attendance %', rec.total;	

end;
$$


---------------- practicing for loop --------------------
do $$
declare
	len int;
begin
	len := (select count(*) from employee e);
	
	raise notice 'total len: %', len;
	for counter in 1..len loop
		raise notice 'counter: %', counter;
	end loop;
end;
$$
