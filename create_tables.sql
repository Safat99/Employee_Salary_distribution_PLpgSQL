
create type sex as enum ('male', 'female', 'other');

drop table if exists designation cascade;
drop table if exists employee cascade;
drop table if exists attendance cascade;
drop table if exists weekend; 


create table Designation (
	id serial,
	designation_name varchar(255) unique not null,
	salary int not null,
	primary key (id)
);



create table Employee (
	id  serial,
	pin int unique not null,
	username varchar(50) unique not null,
	email varchar(255) unique not null,
	designation_id int not null,
	address varchar (255) not null,
	gender sex,
	contact_no_self varchar(255) not null,
	guardian_name varchar(255) not null,
	contact_no_guardian varchar(255) not null,
	nid varchar(25) unique not null,
	joining_date date not null default current_date,
	primary key (id),
	foreign key (designation_id)
		references Designation (id)
	);

create table Attendance (
	id serial,
	emp_id int not null,
	date date not null,
	is_present boolean,
	primary key (id),
	foreign key (emp_id)
		references Employee (id)
);

create table Salary_record (
	id serial,
	emp_id int not null,
	salary_date date not null,
	amount int not null,
	primary key (id),
	foreign key (emp_id)
		references Employee (id)
);

create table Holiday (
	id serial,
	title varchar(255) not null,
	date date not null,
	primary key (id)
);

create table Weekend (
	id serial,
	first_weekend int not null,
	second_weekend int,
	primary key (id)
);


create table Salary_Report (
	id serial,
	emp_id int not null,
	month int not null,
	total_working_days int not null,
	total_attendance int not null,
	attendance_percentage real not null,
	allocated_salary int not null,
	salary_given_date date not null default current_date,
	primary key (id),
	foreign key (emp_id)
		references Employee (id)
);
