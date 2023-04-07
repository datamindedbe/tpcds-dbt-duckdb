{{ config(materialized='external', location='s3://datafy-dp-samples-ympfsg/tpcds-dbt-duckdb/q12_100G_result.parquet') }}
WITH web_sales AS (
    select * from {{ source('external_source', 'web_sales') }}
),
date_dim AS (
    select * from {{ source('external_source', 'date_dim') }}
),
item AS (
    select * from {{ source('external_source', 'item') }}
)

SELECT i_item_id,
       i_item_desc,
       i_category,
       i_class,
       i_current_price,
       sum(ws_ext_sales_price) AS itemrevenue,
       sum(ws_ext_sales_price)*100.0000/sum(sum(ws_ext_sales_price)) OVER (PARTITION BY i_class) AS revenueratio
FROM web_sales,
     item,
     date_dim
WHERE ws_item_sk = i_item_sk
  AND i_category IN ('Sports',
                     'Books',
                     'Home')
  AND ws_sold_date_sk = d_date_sk
  AND d_date BETWEEN cast('1999-02-22' AS date) AND cast('1999-03-24' AS date)
GROUP BY i_item_id,
         i_item_desc,
         i_category,
         i_class,
         i_current_price
ORDER BY i_category,
         i_class,
         i_item_id,
         i_item_desc,
         revenueratio
    LIMIT 100
