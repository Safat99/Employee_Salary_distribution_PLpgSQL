select * from product_groups;
select * from products;

-- finding the 2nd largest price (or nth)

select product_name, price from products
where price = (
	select distinct price from products
	order by price desc
	limit 1 offset 1
);

-- finding the max largest price

select
	product_name ,
	price
from
	products
where
	price = (
	select
		max(price)
	from
		products
	);
	
------------------------ window function in psql -----------------------------
select product_name,price,group_name, avg(price) over (partition by group_name)
from products
inner join product_groups using(group_id)
--group by group_name;


------alter table constraint -----------



