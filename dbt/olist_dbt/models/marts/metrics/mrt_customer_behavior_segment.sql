WITH customer_orders AS (
    SELECT
        customer_unique_id,
        order_id,
        cohort_month,
        customer_order_number,
        days_to_second_order,
        gross_order_revenue

    FROM {{ ref('int_customer_orders') }}
),

customer_summary AS (
    SELECT
        customer_unique_id,
        MIN(cohort_month) AS cohort_month,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(gross_order_revenue) AS total_revenue,
        MAX(days_to_second_order) AS days_to_second_order,
        MAX(
            CASE WHEN customer_order_number > 1 THEN 1 ELSE 0 END
        ) AS has_repeat_order

    FROM customer_orders
    GROUP BY 1
)

SELECT
    cohort_month,
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
        WHEN total_orders = 2 THEN 'Low Repeat'
        WHEN total_orders BETWEEN 3 AND 5 THEN 'Medium Repeat'
        ELSE 'High Repeat'
    END AS customer_segment,
    COUNT(DISTINCT customer_unique_id) AS customers,
    SUM(total_revenue) AS total_revenue,
    AVG(total_revenue)::NUMERIC(10, 2) AS avg_revenue_per_customer
FROM customer_summary
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
