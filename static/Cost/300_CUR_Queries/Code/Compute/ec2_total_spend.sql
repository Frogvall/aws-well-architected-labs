-- query_id: ec2_total_spend
-- query_description: This query will display the top costs for all spend with the product code of ‘AmazonEC2’. This will include all pricing categories (i.e. OnDemand, Reserved etc..) as well as charges for storage on EC2 (i.e. gp2). The query will output the product code as well as the product description to provide context. It is ordered by largest to smallest spend.
-- query_columns: line_item_product_code,line_item_line_item_description,sum_line_item_unblended_cost
--query_link: /cost/300_labs/300_cur_queries/queries/compute/

SELECT -- automation_select_stmt
line_item_product_code, 
line_item_line_item_description, 
round(sum(line_item_unblended_cost),2) as sum_line_item_unblended_cost 
FROM -- automation_from_stmt
${table_name} -- automation_tablename
WHERE -- automation_where_stmt
year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
AND line_item_product_code like '%AmazonEC2%'
AND line_item_line_item_type NOT IN ('Tax','Refund')
AND line_item_product_code like '%AmazonEC2%'
GROUP BY -- automation_groupby_stmt
line_item_product_code, 
line_item_line_item_description
ORDER BY -- automation_order_stmt
sum_line_item_unblended_cost desc;

