-- ==========================================================
-- WEEK 8 PRACTICE LAB 4: COMPLETE REPRODUCIBLE PIPELINE
-- ==========================================================

CREATE TEMP TABLE w8_orders_raw AS 
SELECT * FROM UNNEST([
  STRUCT(1 AS source_row_id, 'O100' AS order_id, 1 AS line_no, 'C01' AS customer_id, '2026-10-01' AS order_date_raw, '2' AS quantity_raw, '25.00' AS unit_price_raw, '0' AS discount_raw, 'Completed' AS status_raw, TIMESTAMP '2026-10-02 08:00:00+00' AS updated_at),
  (2, 'O100', 1, 'C01', '2026-10-01', '2', '25.00', '0', 'Completed', TIMESTAMP '2026-10-02 08:00:00+00'),
  (3, 'O101', 1, ' c02 ', '2026-10-02', '1', '100', '0.10', 'complete', TIMESTAMP '2026-10-03 08:00:00+00'),
  (4, 'O102', 1, 'C03', '2026-10-03', NULL, '40', NULL, 'Completed', TIMESTAMP '2026-10-04 08:00:00+00'),
  (5, 'O103', 1, 'C04', '2026-02-30', '3', '20', '0', 'Completed', TIMESTAMP '2026-10-05 08:00:00+00'),
  (6, 'O104', 1, 'C99', '2026-10-05', '1', '80', '0', 'Completed', TIMESTAMP '2026-10-06 08:00:00+00'),
  (7, 'O105', 1, 'C01', '2026-10-05', '0', '15', '0', 'Completed', TIMESTAMP '2026-10-06 08:00:00+00'),
  (8, 'O106', 1, '', '2026-10-06', '2', 'bad', '0', 'Completed', TIMESTAMP '2026-10-07 08:00:00+00'),
  (9, 'O107', 1, 'C02', '2026-10-07', '1', '2000', '0', 'Completed', TIMESTAMP '2026-10-08 08:00:00+00'),
  (10, 'O108', 1, 'C03', '2026-10-07', '1', '50', '0', 'Cancelled', TIMESTAMP '2026-10-08 08:00:00+00'),
  (11, 'O101', 1, 'C02', '2026-10-02', '1', '100', '0.20', 'Completed', TIMESTAMP '2026-10-09 08:00:00+00'),
  (12, 'O100', 2, 'C01', '2026-10-01', '1', '10', '0', 'Completed', TIMESTAMP '2026-10-02 08:00:00+00')
]);


CREATE TEMP TABLE w8_customers_raw AS 
SELECT * FROM UNNEST([
  STRUCT(101 AS source_row_id, 'C01' AS customer_id, 'North' AS region, TIMESTAMP '2026-10-01 07:00:00+00' AS updated_at),
  (102, ' c02 ', 'South', TIMESTAMP '2026-10-01 07:00:00+00'),
  (103, 'C02', 'South', TIMESTAMP '2026-10-04 07:00:00+00'),
  (104, 'C03', 'West', TIMESTAMP '2026-10-01 07:00:00+00'),
  (105, 'C04', 'East', TIMESTAMP '2026-10-01 07:00:00+00')
]);

-- (Step 2)
CREATE TEMP TABLE w8_orders_typed AS
SELECT *,
  NULLIF(UPPER(TRIM(customer_id)), '') AS customer_key,
  SAFE_CAST(order_date_raw AS DATE) AS order_date,
  SAFE_CAST(quantity_raw AS INT64) AS quantity,
  SAFE_CAST(unit_price_raw AS NUMERIC) AS unit_price,
  CASE WHEN discount_raw IS NULL THEN NUMERIC '0'
       ELSE SAFE_CAST(discount_raw AS NUMERIC) END AS discount,
  CASE LOWER(TRIM(status_raw))
    WHEN 'complete' THEN 'Completed'
    WHEN 'completed' THEN 'Completed'
    WHEN 'cancelled' THEN 'Cancelled'
    ELSE 'Unknown'
  END AS status
FROM w8_orders_raw;

-- (Step 3)
CREATE TEMP TABLE w8_orders_latest AS
SELECT * EXCEPT (row_num)
FROM (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY order_id, line_no 
      ORDER BY updated_at DESC, source_row_id DESC
    ) AS row_num
  FROM w8_orders_typed
)
WHERE row_num = 1;

-- (Step 4)
CREATE TEMP TABLE w8_valid_lines AS
SELECT *, 
  quantity * unit_price * (1 - discount) AS revenue
FROM w8_orders_latest
WHERE order_date IS NOT NULL
  AND quantity > 0
  AND unit_price >= 0
  AND discount BETWEEN 0 AND 1;


CREATE TEMP TABLE w8_completed_lines AS
SELECT * FROM w8_valid_lines WHERE status = 'Completed';


CREATE TEMP TABLE w8_customers_clean AS
SELECT source_row_id, UPPER(TRIM(customer_id)) AS customer_key, region, updated_at
FROM w8_customers_raw
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY UPPER(TRIM(customer_id)) 
  ORDER BY updated_at DESC, source_row_id DESC
) = 1;


CREATE TEMP TABLE w8_sales_analytical AS
SELECT
  CONCAT(o.order_id, '-', o.line_no) AS order_line_key,
  o.order_id,
  o.line_no,
  o.customer_key,
  o.order_date,
  o.quantity,
  o.unit_price,
  o.discount,
  o.status,
  o.revenue,
  COALESCE(c.region, 'Unassigned') AS region,
  c.customer_key IS NOT NULL AS customer_matched,
  o.source_row_id,
  o.updated_at
FROM w8_completed_lines AS o
LEFT JOIN w8_customers_clean AS c
  ON o.customer_key = c.customer_key;


SELECT * FROM w8_sales_analytical ORDER BY order_id, line_no;


SELECT 
    region,
    COUNT(*) AS line_count,
    SUM(revenue) AS regional_revenue
FROM w8_sales_analytical
GROUP BY region
ORDER BY regional_revenue DESC;