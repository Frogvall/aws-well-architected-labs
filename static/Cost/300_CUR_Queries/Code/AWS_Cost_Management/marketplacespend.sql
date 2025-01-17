-- query_id: marketplace-spend
-- query_description: This query provides AWS Marketplace subscription costs including subscription product name, associated linked account, and monthly total unblended cost. This query includes tax, however this can be filtered out in the WHERE clause. Please refer to the CUR Query Library Helpers section for assistance.
-- query_columns: bill_payer_account_id,line_item_usage_account_id,month_line_item_usage_start_time,bill_billing_entity,product_product_name,sum_line_item_unblended_cost
-- query_link: /cost/300_labs/300_cur_queries/queries/aws_cost_management/

SELECT -- automation_select_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  IF(line_item_usage_start_date IS NULL, 
       DATE_FORMAT(DATE_PARSE(CONCAT(SPLIT_PART('${table_name}','_',5),'01'),'%Y%m%d'),'%Y-%m-01'), -- automation_timerange_dateformat
       DATE_FORMAT((line_item_usage_start_date),'%Y-%m-01') -- automation_timerange_dateformat
      ) AS month_line_item_usage_start_time,
  bill_billing_entity,
  product_product_name,
SUM(CAST(line_item_unblended_cost AS decimal(16,8))) AS sum_line_item_unblended_cost
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
  AND bill_billing_entity = 'AWS Marketplace'
GROUP BY -- automation_groupby_stmt
  1,2,3,4,5
ORDER BY -- automation_order_stmt
  month_line_item_usage_start_time ASC,
  sum_line_item_unblended_cost DESC;
