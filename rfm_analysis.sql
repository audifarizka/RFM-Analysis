# First create the database

create database online_retail_ii;

use online_retail_ii;

# Create empty table for the csv files 

drop table if exists retail_2;

CREATE TABLE retail_2 (
	Invoice VARCHAR(20),
	StockCode VARCHAR(20),
	Description TEXT,
	Quantity INT,
	InvoiceDate DATETIME,
	Price FLOAT,
	Customer_ID VARCHAR(20),
	Country VARCHAR(50)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/retail_1.csv' into table retail_2
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines
;

-- (
--	Invoice, StockCode,	Description, Quantity, InvoiceDate,	Price, Customer_ID,	Country
-- )

select count(*) as data_length_retail_1
from retail_2
;

# data_length_retail_1
# 1044848
# same with when reading using pandas

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/retail_2.csv' into table retail_2
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines
;

select count(*) as data_length_combined
from retail_2
;

# data_length_combined
# 1586758
# same with when reading using pandas

# check for any null columns
select column_name
from information_schema.columns
where table_name = 'retail_2'
;

select *
from retail_2
where Invoice = "" or
	StockCode = ""or
    Description = "" or
    Quantity = "" or
    Price = "" or
    Customer_ID = "" or
    Country = ""
;

select count(*) description_null
from retail_2
where Description = ""
;

# description_null
# 5729
# same with using pandas

select count(*) cust_id_null
from retail_2
where Customer_ID = ""
;

# cust_id_null
# 370367
# same with using python

# check the rows where Quantity is negative

select count(*) negative_quantity
from retail_2
where Quantity < 0
;

# negative_quantity
# 33181
# same with using python

# filter out rows without Customer_ID and with negative Quantity
select *
from retail_2
where Customer_ID != '' and Quantity > 0
;

select count(*) cust_id_and_quantity_filter
from retail_2
where Customer_ID != '' and Quantity > 0
;

# cust_id_and_quantity_filter
# 1189040
# same with using python

# clean the Description
# exclude those containing "test", "adjustment", "discount", and "charges"

select Description
from retail_2
where trim(lower(Description)) like '%test%'
	or trim(lower(Description)) like '%adjustment%'
    or trim(lower(Description)) like '%discount%'
    or trim(lower(Description)) like '%charges%'
;

# get the rows where Description's match the patterns

with filter1 as(
	select *
	from retail_2
	where Customer_ID != '' and Quantity > 0
)

# select count(*) desc_pattern_remove
select *
from filter1
where trim(lower(Description)) like '%test%'
	or trim(lower(Description)) like '%adjustment%'
    or trim(lower(Description)) like '%discount%'
    or trim(lower(Description)) like '%charges%'
;

# desc_pattern_remove
# 95
# same with using python

# now filter them out

with filter1 as(
	select *
	from retail_2
	where Customer_ID != '' and Quantity > 0
)

select count(*)
from filter1
where trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
;

# count(*)
# 1188945
# same with using python

# remove rows where StockCode contains 'POST', 'DOT', 'PADS', 'C2', or 'S'

with filter1 as(
	select *
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
)

select count(*) stockcode_filtered
from filter1
where StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
;

# stockcode_filtered
# 1185607
# same with using python

# remove rows having prices 0 and lower
with filter1 as(
	select Invoice, StockCode, trim(Description) Description, Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
)

select *
from filter1
where Price <= 0
;

# filtering 
with filter1 as(
	select Invoice, StockCode, trim(Description) Description, Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
)

select count(*) final_filter
from filter1
;

# final_filter
# 1185501
# same as using python

# final data filter
# save into a table

#create table retail_filter as
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
)

select *
from retail_filter
;


# RFM analysis

# Recency
# get the last purchase ever
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
)
select max(InvoiceDate)
from retail_filter
;

# get the recency
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),
last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase
    from retail_filter
    group by Customer_ID
)

select Customer_ID, ultimate_purchase, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency
from last_purchase
group by Customer_ID
order by Customer_ID
;

# get the frequency
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
)
select Customer_ID, count(distinct(Invoice))
from retail_filter
group by Customer_ID
;

# combine with recency
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),
last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency
    from retail_filter
    group by Customer_ID
)

select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency
from last_purchase
group by Customer_ID
order by Customer_ID
;

# get the Monetary
# create column Total_Purchase
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, sum(Purchase) Monetary
    from retail_filter
    group by Customer_ID
)

select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
from last_purchase
group by Customer_ID
order by Customer_ID
;

# values in Recency, Frequency, and Monetary are all the same with using pandas

# assign ranks for Recency, Frequency, and Monetary
# first calculate the quantiles

with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
from last_purchase
group by Customer_ID
order by Customer_ID
)

select Customer_ID, Recency, Frequency, Monetary,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
order by Customer_ID
;

# due to differences in ranking methods and formulas,
# the percentage ranks are slightly different than with python

# score the ranks
with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
	from last_purchase
	group by Customer_ID
	order by Customer_ID
),

ranks as (select *,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
)

select *,
	ntile(4) over (order by rece_rank desc) rece_score,
    ntile(4) over (order by freq_rank desc) freq_score,
    ntile(4) over (order by mone_rank desc) mone_score
from ranks
order by Customer_ID
;

# some of frequency rank results are different than using python pandas
# due to differences in calculations (pandas using average rank, pct=True,
# mysql using percent_rank), resulting in lower frequency scores in some values.
# recency and monetary scores are the same

# get the rfm scores

with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
	from last_purchase
	group by Customer_ID
	order by Customer_ID
),

ranks as (select *,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
),

scores as (select *,
	ntile(4) over (order by rece_rank desc) rece_score,
    ntile(4) over (order by freq_rank desc) freq_score,
    ntile(4) over (order by mone_rank desc) mone_score
from ranks)

select *,
	concat(rece_score, freq_score, mone_score) rfm_score
from scores
order by Customer_ID
;

#  apply customer segmentations

with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
	from last_purchase
	group by Customer_ID
	order by Customer_ID
),

ranks as (select *,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
),

scores as (select *,
	ntile(4) over (order by rece_rank desc) rece_score,
    ntile(4) over (order by freq_rank desc) freq_score,
    ntile(4) over (order by mone_rank desc) mone_score
from ranks),

final_score as (select *,
	concat(rece_score, freq_score, mone_score) rfm_score
from scores)

select *, 
	#Customer_ID, rece_score R_Score, freq_score F_Score, mone_score M_Score, rfm_score,
	case 
		when rfm_score = 444 then "Champion"
		when freq_score >= 3 and mone_score >= 3 then "Loyal Customer"
        when rece_score <= 2 and freq_score >= 3 then "Potential Loyalist"
        when rece_score = 1 and freq_score = 1 and mone_score >= 3 then "New Customer"
        when rece_score >= 3 and freq_score >= 2 then "At Risk"
        when rece_score = 1 and freq_score = 1 and mone_score = 1 then "Lost Customer"
        else "Others"
	end as cust_segmentation
from final_score
order by Customer_ID
;

# count the segments

with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
	from last_purchase
	group by Customer_ID
	order by Customer_ID
),

ranks as (select *,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
),

scores as (select *,
	ntile(4) over (order by rece_rank desc) rece_score,
    ntile(4) over (order by freq_rank desc) freq_score,
    ntile(4) over (order by mone_rank desc) mone_score
from ranks),

final_score as (select *,
	concat(rece_score, freq_score, mone_score) rfm_score
from scores),

segmentation as (select Customer_ID, rece_score R_Score, freq_score F_Score, mone_score M_Score, rfm_score,
		case 
			when rfm_score = 444 then "Champion"
            # rece_score = 4 and freq_score = 4 and mone_score = 4 then "Champion" 
			when freq_score >= 3 and mone_score >= 3 then "Loyal Customer"
			when rece_score <= 2 and freq_score >= 3 then "Potential Loyalist"
			when rece_score = 1 and freq_score = 1 and mone_score >= 3 then "New Customer"
			when rece_score >= 3 and freq_score >= 2 then "At Risk"
			when rece_score = 1 and freq_score = 1 and mone_score = 1 then "Lost Customer"
			else "Others"
		end as cust_segmentation
from final_score)

select cust_segmentation, count(cust_segmentation) count
from segmentation
group by cust_segmentation
;

# there are differences in results against python pandas' due to the differences in ranking
# save the result into a csv file "segment_mysql.csv" to be opened with pandas

# check for the 'New Customer' segment, since this only appeared in calculations using MySQL

with retail_filter as(
	select Invoice, StockCode, trim(Description), Quantity, InvoiceDate, Price, Customer_ID, Country, (Quantity * Price) Purchase
	from retail_2
	where Customer_ID != '' and Quantity > 0
    and trim(lower(Description)) not like '%test%'
	and trim(lower(Description)) not like '%adjustment%'
    and trim(lower(Description)) not like '%discount%'
    and trim(lower(Description)) not like '%charges%'
    and StockCode not in ('POST', 'DOT', 'PADS', 'C2', 'S')
    and Price > 0
),

last_purchase as (
	select Customer_ID, max(InvoiceDate) ultimate_purchase, count(distinct(Invoice)) Frequency, round(sum(Purchase), 2) Monetary
    from retail_filter
    group by Customer_ID
),

rfm as (select Customer_ID, datediff((select max(InvoiceDate) from retail_filter), ultimate_purchase) Recency, Frequency, Monetary
	from last_purchase
	group by Customer_ID
	order by Customer_ID
),

ranks as (select *,
	round(percent_rank() over (order by Recency asc), 6) rece_rank,
    round(percent_rank() over (order by Frequency desc), 6) freq_rank,
    round(percent_rank() over (order by Monetary desc), 6) mone_rank
from rfm
),

scores as (select *,
	ntile(4) over (order by rece_rank desc) rece_score,
    ntile(4) over (order by freq_rank desc) freq_score,
    ntile(4) over (order by mone_rank desc) mone_score
from ranks),

final_score as (select *,
	concat(rece_score, freq_score, mone_score) rfm_score
from scores)

select Customer_ID, rece_score R_Score, freq_score F_Score, mone_score M_Score, rfm_score,
	case 
		when rfm_score = 444 then "Champion"
		when freq_score >= 3 and mone_score >= 3 then "Loyal Customer"
        when rece_score <= 2 and freq_score >= 3 then "Potential Loyalist"
        when rece_score = 1 and freq_score = 1 and mone_score >= 3 then "New Customer"
        when rece_score >= 3 and freq_score >= 2 then "At Risk"
        when rece_score = 1 and freq_score = 1 and mone_score = 1 then "Lost Customer"
        else "Others"
	end as cust_segmentation
from final_score
where rece_score = 1 and freq_score = 1 and mone_score >= 3
order by Customer_ID
;

# the 'New Customer' segment occurred mainly due to F_Score values of 1, which only appeared using MySQL's formulations, completely missing in pandas' analysis
