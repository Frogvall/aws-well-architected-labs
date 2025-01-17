-- query_id: ecs-eks
-- query_description: This query will output the daily cost and usage per resource, by operation and service, for Elastic Consainer Services, ECS and EKS, both unblended and amortized costs are shown.
-- query_columns: bill_payer_account_id,line_item_usage_account_id,split_line_item_resource_id,day_line_item_usage_start_date,line_item_operation,line_item_product_code,sum_line_item_usage_amount,sum_line_item_unblended_cost, amortized_cost
-- query_link: /cost/300_labs/300_cur_queries/queries/container/

SELECT -- automation_select_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  SPLIT_PART(line_item_resource_id,':',6) as split_line_item_resource_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d') AS day_line_item_usage_start_date, -- automation_timerange_dateformat
  line_item_operation,
  line_item_product_code,
  SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
  SUM(line_item_unblended_cost) "sum_line_item_unblended_cost"
, sum(CASE
    WHEN ("line_item_line_item_type" = 'SavingsPlanCoveredUsage') THEN "savings_plan_savings_plan_effective_cost"
    WHEN ("line_item_line_item_type" = 'SavingsPlanRecurringFee') THEN ("savings_plan_total_commitment_to_date" - "savings_plan_used_commitment")
    WHEN ("line_item_line_item_type" = 'SavingsPlanNegation') THEN 0
    WHEN ("line_item_line_item_type" = 'SavingsPlanUpfrontFee') THEN 0
    WHEN ("line_item_line_item_type" = 'DiscountedUsage') THEN "reservation_effective_cost"
      ELSE "line_item_unblended_cost" END) "amortized_cost"
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
  and line_item_product_code in ('AmazonECS','AmazonEKS')
  AND line_item_line_item_type  in ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  3,
  4,
  line_item_operation,
  line_item_product_code
ORDER BY -- automation_order_stmt
  day_line_item_usage_start_date,
  sum_line_item_unblended_cost,
  sum_line_item_usage_amount,
  line_item_operation;
