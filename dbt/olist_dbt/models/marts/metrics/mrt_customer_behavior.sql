WITH customer_orders AS (
    SELECT
        customer_unique_id,
        cohort_month,
        order_id,
        order_date,
        customer_order_number,
        days_to_second_order
    FROM {{ ref('int_customer_orders') }}
),

customer_summary AS (
    SELECT
        customer_unique_id,
        MIN(cohort_month) AS cohort_month,
        COUNT(DISTINCT order_id) AS total_orders,
        MAX(
            CASE WHEN customer_order_number > 1 THEN 1 ELSE 0 END
        ) AS has_repeat_order,
        MAX(days_to_second_order) AS days_to_second_order
    FROM customer_orders
    GROUP BY 1
),

customer_segmented AS (
    SELECT
        customer_unique_id,
        cohort_month,
        total_orders,
        has_repeat_order,
        days_to_second_order,

        CASE
            WHEN days_to_second_order IS NULL THEN 'No Repeat'
            WHEN days_to_second_order <= 7 THEN '0-7 Days'
            WHEN days_to_second_order <= 30 THEN '8-30 Days'
            WHEN days_to_second_order <= 90 THEN '31-90 Days'
            WHEN days_to_second_order <= 180 THEN '90-180 Days'
            ELSE '180+ Days'
        END AS reorder_bucket,

        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Low Repeat'
            WHEN total_orders BETWEEN 4 AND 6 THEN 'Medium Repeat'
            ELSE 'High Repeat'
        END AS customer_segment

    FROM customer_summary
),

cohort_behavior_base AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_customers,
        COUNT(
            DISTINCT CASE WHEN has_repeat_order = 1 THEN customer_unique_id END
        ) AS repeat_customers,
        AVG(days_to_second_order) AS avg_days_to_second_order,
        AVG(total_orders) AS avg_orders_per_customer_raw,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY days_to_second_order
        ) AS median_days_to_second_order
    FROM customer_segmented
    GROUP BY 1
),

cohort_behavior AS (
    SELECT
        cohort_month,
        total_customers,
        repeat_customers,
        avg_days_to_second_order,
        avg_orders_per_customer_raw::NUMERIC(10, 2) AS avg_orders_per_customer,
        median_days_to_second_order,
        ROUND(repeat_customers::NUMERIC / NULLIF(total_customers, 0), 4) AS repeat_rate
    FROM cohort_behavior_base
)

SELECT
    cohort_month,
    total_customers,
    repeat_customers,
    repeat_rate,
    avg_orders_per_customer,
    avg_days_to_second_order,
    median_days_to_second_order
FROM cohort_behavior
ORDER BY 1
