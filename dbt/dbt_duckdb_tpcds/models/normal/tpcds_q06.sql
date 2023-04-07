{{ config(materialized='external', location='s3://datafy-dp-samples-ympfsg/tpcds-dbt-duckdb/q06_100G_result.parquet') }}
WITH store_sales AS (
    select * from {{ source('external_source', 'store_sales') }}
),
date_dim AS (
    select * from {{ source('external_source', 'date_dim') }}
),
customer AS (
    select * from {{ source('external_source', 'customer') }}
),
customer_address AS (
    select * from {{ source('external_source', 'customer_address') }}
),
item AS (
    select * from {{ source('external_source', 'item') }}
)

SELECT a.ca_state state,
       count(*) cnt
FROM customer_address a ,
     customer c ,
     store_sales s ,
     date_dim d ,
     item i
WHERE a.ca_address_sk = c.c_current_addr_sk
  AND c.c_customer_sk = s.ss_customer_sk
  AND s.ss_sold_date_sk = d.d_date_sk
  AND s.ss_item_sk = i.i_item_sk
  AND d.d_month_seq =
      (SELECT DISTINCT (d_month_seq)
       FROM date_dim
       WHERE d_year = 2001
         AND d_moy = 1 )
  AND i.i_current_price > 1.2 *
                          (SELECT avg(j.i_current_price)
                           FROM item j
                           WHERE j.i_category = i.i_category)
GROUP BY a.ca_state
HAVING count(*) >= 10
ORDER BY cnt NULLS FIRST,
         a.ca_state NULLS FIRST
    LIMIT 100