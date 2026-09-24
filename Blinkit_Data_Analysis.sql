select * from blinkit_data

-- Change column data types
alter table blinkit_data 
alter column item_fat_content type varchar(20) ; 
alter table blinkit_data 
alter column item_identifier type varchar(20) ; 
alter table blinkit_data 
alter column item_type type char(200) ; 
alter table blinkit_data 
alter column outlet_identifier type varchar(20) ; 
alter table blinkit_data 
alter column outlet_location_type type varchar(20) ;
alter table blinkit_data 
alter column outlet_size type char(20) ;
alter table blinkit_data 
alter column outlet_type type char(200) ;
alter table blinkit_data 
alter column item_visibility type float ;
alter table blinkit_data 
alter column item_weight type float ;
alter table blinkit_data 
alter column sales type float ;
alter table blinkit_data 
alter column rating type int ;

select max(item_visibility) from blinkit_data

-- Clean and standardize item_fat_content values
UPDATE blinkit_data
SET item_fat_content = CASE
  WHEN LOWER(item_fat_content) IN ('lf', 'low fat') THEN 'Low Fat'
  WHEN LOWER(item_fat_content) = 'reg' THEN 'Regular'
  ELSE item_fat_content
END;

-- Average sales by item type
select item_type , avg(sales) as "avg_sales" from blinkit_data
group by item_type

-- Average rating grouped by outlet_type
select outlet_type , round(avg(rating),2) as "avg_rating" from blinkit_data
group by outlet_type 

-- Categorize sales using CASE statement
select item_type , sales , 
case 
when sales >=250 then 'High Sales'
when sales >=120 then 'Avg Sales'
else 'Low sales'
end as "Sales Type "
from blinkit_data

-- Average item weight partitioned by item_type
select item_fat_content , item_type ,
avg(item_weight) over(partition by item_type ) as "Avg_Item_weight" from blinkit_data

-- Total sales
select sum(sales) as "total_sales" from blinkit_data

-- Average sales
select avg(sales) as "avg_sales" from blinkit_data

-- Which outlet type has the highest sales?
select outlet_type , sum(sales) as "high_sales_by_outlet_type" from blinkit_data
group by outlet_type
order by sum_sales_by_outlet_type desc ;

-- Which outlet location has the highest/lowest sales?
select outlet_location_type , sum(sales) as "high_sales_by_outlet_type" from blinkit_data
group by outlet_location_type
order by high_sales_by_outlet_type desc ;

-- Which item_type has the highest sales?
select item_type , sum(sales) as hign_sales from blinkit_data
group by item_type
order by hign_sales desc ;

-- Which fat content (Low Fat vs Regular) sells more?
select item_fat_content , sum(sales) as high_sales_fat_content from blinkit_data
group by item_fat_content
order by high_sales_fat_content desc ;

-- Is there any relation between item_weight and sales?
SELECT weight_category, AVG(sales) AS avg_sales
FROM (
  SELECT sales,
    CASE 
      WHEN item_weight >= 20 THEN 'High'
      WHEN item_weight >= 10 THEN 'Avg'
      ELSE 'Low'
    END AS weight_category
  FROM blinkit_data
) AS temp
GROUP BY weight_category;

-- Does higher item_visibility lead to higher sales?
SELECT 
  CASE 
    WHEN item_visibility >= 0.15 THEN 'High Visibility'
    WHEN item_visibility >= 0.05 THEN 'Avg Visibility'
    ELSE 'Low Visibility'
  END AS visibility_category,
  AVG(sales) AS avg_sales,
  SUM(sales) AS total_sales
FROM blinkit_data
GROUP BY visibility_category
ORDER BY avg_sales DESC;

-- Is there any relation between rating and sales?
select rating , sum(sales) as "total_sales" from blinkit_data
group by rating 
order by total_sales desc ;

-- Product with low visibility but high sales
select item_type , sales  from blinkit_data
where item_visibility = (select min(item_visibility) from blinkit_data )
order by sales desc 
limit 1 ;

-- Total sales for each outlet_identifier
select distinct outlet_identifier ,
sum(sales) over (partition by outlet_identifier) as "total_sales" from blinkit_data 
order by total_sales desc ;

-- Top 5 outlets by sales
select max(sales) , outlet_type as max_sales from blinkit_data
group by outlet_type
order by max_sales desc ;

-- Sales trend by outlet establishment year
SELECT outlet_establishment_year, SUM(sales) as total_sales
FROM blinkit_data
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;

-- Best-selling item_type for each outlet_type (Using RANK)
with my_cte as (
select item_type , outlet_type , sum(sales) as "best_sales" from blinkit_data
group by item_type , outlet_type 
)
select item_type , outlet_type , rank() over (partition by outlet_type order by best_sales desc  ) as rnk from my_cte

-- Highest rated product within each item_type
select item_type , sales , rating , 
rank() over (partition by item_type order by rating desc  ) as "high_rated_product" from blinkit_data

-- Total sales after applying 10% discount
SELECT 
  SUM(sales) as total_sales,
  SUM(sales * 0.9) as total_discounted_sales,
  SUM(sales * 0.10) as total_discount_amount
FROM blinkit_data; 

-- Which outlet_size has the highest average sales?
with my_cte as 
(select outlet_size ,  sales from blinkit_data
where sales > (select avg(sales) as sales from blinkit_data) )
select outlet_size , sales , rank() over(partition by outlet_size order by sales desc  ) as "rank"  from my_cte

-- Sales comparison: Outlets opened before 2015 vs after 2015
select  sum(sales)  from blinkit_data
where outlet_establishment_year >=2015
select  sum(sales)  from blinkit_data
where outlet_establishment_year >=2015

-- Best outlet_type + location combination
SELECT outlet_type, outlet_location_type, SUM(sales) as total
FROM blinkit_data GROUP BY 1,2 ORDER BY total DESC LIMIT 3;

-- Sales trend by rating (3-5 star)
SELECT rating, AVG(sales), COUNT(*) 
FROM blinkit_data GROUP BY rating ORDER BY rating;