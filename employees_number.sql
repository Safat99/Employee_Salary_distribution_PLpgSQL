select
	username, designation, contact_no_self
from employee
order by designation desc;


-- ans no. ques of g --
select
	designation_name, gender, count(gender)
from employee e
join designation d
on d.id = e.designation_id
group by designation_name, gender;
