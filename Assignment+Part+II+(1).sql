use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/	
-- Solution:	
use supply_db ;

SELECT DATE_FORMAT(Order_Date,'%Y-%m') AS Month,
SUM(Quantity) AS Quantities_Sold,
SUM(Sales) AS Sales
FROM
orders AS ord
LEFT JOIN
ordered_items AS ord_itm
ON ord.Order_Id = ord_itm.Order_Id
LEFT JOIN
product_info AS prod_info
ON ord_itm.Item_Id=prod_info.Product_Id
WHERE LOWER(Product_Name) LIKE '%nike%'
GROUP BY 1
ORDER BY 1;




-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/
-- Solution:
use supply_db ;

SELECT
prod_info.Product_Id,
prod_info.Product_Name,
cat.Name AS Category_Name,
dept.Name AS Department_Name,
prod_info.Product_Price
FROM
product_info AS prod_info
LEFT JOIN
category AS cat
ON prod_info.Category_Id =cat.Id
LEFT JOIN
department AS dept
ON prod_info.Department_Id=dept.Id
ORDER BY prod_info.Product_Price DESC
LIMIT 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
-- Solution:
use supply_db;

with order_info as
(
select count(o.order_id) as ordered_count,type,sum(sales)as sales_info,order_item_id,item_id
from orders as o
inner join ordered_items as oi
on o.order_id=oi.order_id
where type="cash"
group by oi.item_id
)
select distinct(ordered_count) as disctinct_order_count,sales_info,product_name
from order_info as fo
inner join product_info as pi
on fo.item_id=pi.product_id
order by disctinct_order_count desc
limit 10;
-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
-- Solution
use supply_db;

select * from orders as o
join customer_info as c
on o.Customer_Id=c.id
where state='TX' and street like '%Plaza%' and street not like '%mountain%'
order by Order_Id
;

-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
-- Solution:
use supply_db;

with order_info as
(
select order_id
from customer_info as ci
inner join orders as o
on ci.id=o.customer_id
where segment="home office"
),
product_information as
(
select *
from product_info as pi
inner join department as d
on pi.department_id=d.id
where name="Apparel" or name="Outdoors"
),

product_order as
(
select
product_id, item_id , order_id from product_information as pi
inner join ordered_items as oi
on pi.product_id=oi.item_id
)
select count(oi.order_id) as order_count from order_info as oi
inner join product_order as po
on oi.order_id=po.order_id
group by item_id;

-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
-- Solution:
use supply_db;

select count(o.order_id) as Order_count,o.order_state, o.order_city, dense_rank() over( partition by o.order_state order by count(o.order_id) desc) city_rank
from orders o 
inner join customer_info c 
on o.customer_id = c.id
inner join ordered_items oi
on o.order_id = oi.order_id
inner join product_info p 
on oi.item_id = p.product_id
inner join department d 
on p.department_id = d.id
where c.segment= 'Home Office' and d.name in ('Apparel','Outdoors')
group by o.order_city
order by o.order_state,o.order_city;

-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
-- Solution:
use supply_db;

select o.shipping_mode,count(o.order_id) as Shipping_Underestimated_Order_Count,row_number() over(order by count(order_id) desc) Shipping_Mode_Rank 
from orders o
inner join customer_info c
on o.customer_id = c.id
where lower(o.order_status) in ('complete','closed') and lower(c.segment) ='consumer' and o.Scheduled_Shipping_Days < o.Real_Shipping_Days
group by o.shipping_mode;
-- **********************************************************************************************************************************





