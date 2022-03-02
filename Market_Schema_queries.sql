use market_star_schema;

select * from
cust_dimen;

select customer_Name, city, state
from
cust_dimen
group by city
;

select distinct
customer_name from
cust_dimen;

select count(*) as Bengal_customers
from cust_dimen
where State = 'west Bengal' and city = 'kolkata';

select * from
cust_dimen;

select count(*) from
cust_dimen
where state = 'Maharashtra' and customer_segment = 'corporate';

select * from
cust_dimen
where 
state in ('Tamil Nadu', 'Bihar', 'Karnatka');

\q

select *
from cust_dimen
where customer_segment = 'consumer';

select ord_id, Profit
from market_fact_full
where profit < 0 ;

### List the order ids of all those orders which caused losses ###
select Ord_id, Shipping_Cost
from market_fact_full
where Ord_id like '%\_5%' and Shipping_Cost between 10 and 15;

select city
from cust_dimen
where city like '%\k%';

select city 
from cust_dimen;

select * from
cust_dimen;

select ord_id
from
market_fact_full;

select * from employee where first_name like "%ee%";

select * from
cust_dimen
where Customer_Name > 'Joshi' and Customer_Name 'Sharma';

select count(sales) as No_of_sales
from market_fact_full;

-- How to calculate total no of cust city wise?--
select count(Customer_Name) as City_wise_customers, city
from cust_dimen
group by City;

-- This is also called drill down of data to lower value --
select count(Customer_Name) as City_wise_customers, city, customer_segment
from cust_dimen
group by City, customer_segment;

select count(ord_id) as loss_count
from market_fact_full
where Profit < 0
;

select count(Customer_Name) as Segment_wise_customers, customer_segment
from cust_dimen
where state = 'Bihar'
group by customer_segment;

-- Order by (sorting data)-- 

select Customer_Name
from cust_dimen
order by Customer_Name;

-- distinct name -- 
select distinct customer_name
from cust_dimen
order by Customer_Name desc
;

select distinct customer_name
from cust_dimen
order by Customer_Name desc
;

select customer_name

from cust_dimen

where state in ('Bihar', 'Tamil Nadu')

order by state, customer_name ;
--  To see top 3 product --
select Prod_id, sum(Order_Quantity)
from market_fact_full
group by Prod_id
order by sum(Order_Quantity) desc
limit 3;

-- Having --

select Prod_id, sum(Order_Quantity)
from market_fact_full
group by Prod_id
having sum(order_Quantity) > 50
order by sum(Order_Quantity) desc
limit 3;

-- Concatinate or add string --

select Customer_Name, concat(upper(substring(substring_index (lower(Customer_name), ' ', 1), 1, 1)),
upper(substring(substring_index (lower(Customer_name), ' ', 1), 1, 1)), substring(substring_index (lower(Customer_name),' ', 1), 1, 1)),
from Cust_dimen;




Select Product_Category, Product_Sub_Category,
concat(Product_Category, '_', Product_Sub_Category as Product_name)
from prod_dimen ;

-- Date - Time Functions --
select count(Ship_Id) as ship_count, month(Ship_date) as Ship_Month
from Shipping_dimen 
group by Ship_month
order by Ship_count desc;


-- which month and year combination saw the most number of critical orders?

select count(ord_Id) as order_count, month(order_date) as order_Month,
year(order_date) as order_year
from orders_dimen
where order_priority = 'Critical'
group by order_year, order_month
order by order_count desc;

select ship_mode, count(Ship_mode) as ship_mode_count
from Shipping_dimen
where year(ship_date) = 2011
group by Ship_mode
order by Ship_mode_count desc;


select customer_Name
-- from
-- cust_dimen 
-- order by customer_Name asc;

select concat (reverse(firstName) , '  ', upper(lastName))
from employees
where employeeNumber=1002;

-- Regular expression (regexp)
select customer_name
from cust_dimen
where customer_name regexp 'car';

-- Customer who names start with A,B,C,D and ending with 'er'.

select Customer_Name
from cust_dimen
where Customer_Name regexp '^[abcd].*er$';

select Customer_Name
from cust_dimen
where Customer_Name regexp '^[pr].*er$';

-- Regexp question To find out the first name of the employee with 'on' in between and group by emp_no --

-- select employeeNumber, firstName
-- from employees
-- where firstName regexp '^[firstName].+on?'
-- group by employeeNumber;

select cust_id, customer_name
from cust_dimen
where customer_name regexp '^[customer_name].+on?'
group by cust_id 
;

-- Nested Queries -- Generic form
select ord_id, sales, round(sales) as Rounded_Sales
from market_fact_full
where sales = (
select max(sales)
from market_fact_full);

select max(sales)
from market_fact_full;

-- Hardcoded form to write code 
select ord_id, sales, round(sales) as Rounded_Sales
from market_fact_full
where sales = 4701.69;

-- Product Categories and sub categories of all products that has no details or Null Value --
select *
from prod_dimen 
where prod_id in (
select prod_id
from market_fact_full
where product_base_margin is null
);

-- print the most frequent customer --
SELECT 
    customer_name, cust_id
FROM
    cust_dimen
WHERE
    cust_id = (SELECT 
            cust_id
        FROM
            market_fact_full
        GROUP BY cust_id
        ORDER BY COUNT(cust_id) DESC);

-- CTE (Common Table Expression) --
select prod_id, profit, product_base_margin
from market_fact_full
where profit < 0
order by profit desc
limit 5;

with least_losses as (
select prod_id, profit, product_base_margin
from market_fact_full
where profit < 0
order by profit desc
limit 5
) select * 
from least_losses
where product_base_margin = (
select max(product_base_margin)
from least_losses
);

-- low priority orders --
select ord_id, order_date, order_priority
from orders_dimen
where order_priority = 'low' and month(order_date) = 4;

with low_priority_orders as (
select ord_id, order_date, order_priority
from orders_dimen
where order_priority = 'low' and month(order_date) = 4
) select count(ord_id) as order_count, order_date
from low_priority_orders 
where day(order_date) between 1 and 15;

-- Views --
create view order_info
as select ord_id, Sales, Order_Quantity, Profit, Shipping_cost
from market_fact_full;

select ord_id, profit
from order_info
where profit > 1000;

-- which year generated the highest profit?
create view market_facts_and_orders
as select *
from market_fact_full
inner Join orders_dimen
using (ord_id);

select sum(profit) as year_wise_profit, year (order_date) as order_year
from market_facts_and_orders
group by order_year
order by year_wise_profit desc
limit 1;

-- Inner Join --
select ord_id, product_category, product_sub_category, profit
from orders_dimen o inner join market_fact_full m inner join shipping_dimen s
on o.ord_id = m.ord_id = s.order_id;

-- 3 way join --
select m.prod_id, m.profit, p.product_category, s.ship_mode
from market_fact_full m inner join prod_dimen p on m.prod_id = p.prod_id
inner join shipping_dimen s on m.ship_id = s.ship_id;

-- customer ordered the most product --
select customer_name -- sum(order_quantity) as total_orders
from cust_dimen c
inner join market_fact_full m
on c.cust_id = m.cust_id
group by customer_name
order by order_quantity desc;

Alternate way --
select customer_name, sum(order_quantity) as total_orders
from cust_dimen 
inner join market_fact_full 
using (cust_id)
group by customer_name
order by total_orders desc;

-- Q? Selling office supplies was more profitable in Delhi as compared to Patna. True or False?
select p.prod_id, profit, product_category, city, sum(profit) as city_wise_profit
from prod_dimen p
inner join market_fact_full m
on p.prod_id = m.prod_id
inner Join cust_dimen c
on m.cust_id = c.cust_id
where product_category = 'office supplies' and (city = 'Delhi' or city = 'Patna')
group by city;

select Customer_Name, sum(Order_Quantity) as No_Of_Orders
from cust_dimen c
inner join market_fact_full m
on c.cust_id = m.cust_id
group by Customer_Name
order by No_Of_Orders desc
limit 1;

select m.manu_name, p.prod_id
from manu m right join prod_dimen p on m.manu_id;

select m.manu_name, count(prod_id)
from manu m left join prod_dimen p on m.manu_id = p.manu_id
group by m.manu_name;

-- Views with joins --

-- Union and Union all--
-- 2 most profitable and 2 least profitable products
(select prod_id, sum(profit)
from market_fact_full
group by prod_id
order by sum(profit) desc
limit 2)
union
(select prod_id, sum(Profit)
from market_fact_full
group by prod_id
order by sum(profit)
limit 2);











-- select Cust_id
-- from cust_dimen;
