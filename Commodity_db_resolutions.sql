use commodity_db;

-- Questions 1
/****************************************************************************
These questions are as follows:
 

    Determine the common commodities between the Top 10 costliest commodities of 2019 and 2020.
    What is the maximum difference between the prices of a commodity at one place vs the other for the month of June 2021? 
    Which commodity was it for?
    Arrange the commodities in an order based on the number of variants in which they are available, with the highest one shown 
    at the top, which is the third commodity in the list.
    In a state with the least number of data points available, which commodity has the highest number of data points available?
    What is the price variation of commodities for each city from January 2019 to December 2020? Which commodity has seen 
    the highest price variation and in which city?
    
    With an analysis of the ERD, you will need the following inputs and outputs.

    Input: price_details: Id, Commodity_Id, Date, Retail_Price, commodities_info: Id, Commodity
    Expected output: Commodity; Take distinct to remove duplicates
    
***********************************************************************************/
with year1_summary as
(
    select commodity_id, 
    max(retail_price) as price
    from price_details
    where year(date)=2019
    group by Commodity_Id
    order by price desc
    limit 10
    ),
     year2_summary as
    (
    select commodity_id, 
    max(retail_price) as price
    from price_details
    where year(date)=2020
    group by Commodity_Id
    order by price desc
    limit 10
    ),
    common_commodities as 
    (
    select y1.commodity_id
    from
    year1_summary as y1
    inner join year2_summary as y2
    on y1.commodity_id = y2.commodity_id
    )
    select
    distinct ci.commodity as common_commodities_list
    from
    common_commodities as cc
    join commodities_info as ci
    on cc.commodity_id = ci.id
    ;
    
    /*********************************************************
    Question - 2
	Find the difference between the maximum and minimum prices for June, for a commodity that has this difference as 
    maximum amongst all commodities.
    
    The following are the desired inputs and outputs:

Input: price_details: Id, Region_Id, Commodity_Id, Date and Retail_Price;  commodities_info: Id and Commodity
Expected output: Commodity | price difference;  Retain the info for the highest difference.

****************************************************************/
-- Solution

with june_prices as
(
select commodity_id, date,
Min(retail_price) as min_price,
Max(Retail_Price) as max_price
from
price_details
where year(date)=2020 and month(date)=06
group by Commodity_Id
)
select ci.commodity, date,
max_price - min_price as price_diff
from
june_prices as jp
inner join commodities_info as ci
on jp.commodity_id = ci.id
order by price_diff desc
limit 1
;

/*************************************************************************************************
Question: 3
In this problem, each commodity is available in numerous varieties. We need a table that shows all the commodities sorted 
in decreasing order of the number of varieties available. After finding this, the third commodity in this list is also asked 
for.

The following are the desired inputs and outputs:
Input: commodities_info: Commodity and Variety
Expected output: Commodity | Variety count; Sort in descending order of Variety count
*************************************************************************************************/
-- Solution

with commodity_info as
(
select commodity
from
commodities_info
),
v_info as
(
select count(distinct variety) as dist_variety
from commodities
)
select
commodity, dist_variety
from 
commodity_info as ci
inner join v_info as vi
on ci.commodity = vi.commodity
;

select Commodity, count(distinct variety) as variety_count
from
commodities_info
group by Commodity
order by variety_count desc;

/************************************************************************************************
Find out the state with the least number of entries, that is, where the company has minimum presence amongst all other states. 
Then, within that state, we have to find out the commodity with the highest number of data points available.
This question is one of the most commonly asked questions in business scenarios, as it helps in planning business outlooks.

The following are the inputs and outputs required as per the demand of the problem statement:
Input: price_details: Id, region_id, commodity_id region_info: Id and State commodities_info: Id and Commodity
Expected output: commodity;  Expecting only one value as output

The initial steps to be taken are as follows:
Step 1: Join region information and price details by using the Region_Id from price_details with Id from region_info.
Step 2: From the result of Step 1, perform aggregation – COUNT(Id), group by State.
Step 3: Sort the result based on the record count computed in Step 2 in ascending order; Filter for the top State.
Step 4: Filter for the state identified from Step 3 from the price_details table.
*********************************************************************************************************/
-- solution 
with raw_data as
(
select pd.id, pd.Commodity_Id, ri.state
from 
price_details as pd
left join region_info as ri
on pd.region_id = ri.id
),
state_rec_count as
(
select state, count(id) as state_wise_datapoints
from raw_data
group by state
order by state_wise_datapoints
limit 1
),
commodity_list as
(
select commodity_id, count(id) as record_count
from
raw_data
where state in (select distinct state from state_rec_count)
group by commodity_id
order by record_count desc
)
select commodity, 
sum(record_count) as record_account
from
commodity_list as cl
left join commodities_info as ci
on cl.commodity_id = ci.id
group by Commodity
order by record_count desc
limit 1
;
