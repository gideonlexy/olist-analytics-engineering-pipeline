WITH monthly_orders AS (

    SELECT
        cohort_month,
        order_month,
        months_since_first_order,
        customer_id,
        customer_unique_id,
        customer_order_number,
        days_to_second_order
    FROM {{ ref('int_customer_orders') }}

),

cohort_sizes AS (

    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM monthly_orders
    WHERE customer_order_number = 1
    GROUP BY 1

),

activity AS (

    SELECT
        cohort_month,
        order_month,
        months_since_first_order,
        COUNT(DISTINCT customer_unique_id) AS active_customers,
        COUNT(
            DISTINCT CASE WHEN customer_order_number = 1 THEN customer_unique_id END
        ) AS new_customers,
        COUNT(
            DISTINCT CASE WHEN customer_order_number > 1 THEN customer_unique_id END
        ) AS returning_customers

    FROM monthly_orders
    GROUP BY 1, 2, 3

)

SELECT
    a.cohort_month,
    a.order_month,
    a.months_since_first_order,
    c.cohort_size,
    a.active_customers,
    a.new_customers,
    a.returning_customers,

    ROUND(a.active_customers::NUMERIC / NULLIF(c.cohort_size, 0), 4) AS retention_rate,
    ROUND(
        a.returning_customers::NUMERIC / NULLIF(a.active_customers, 0), 4
    ) AS repeat_purchase_rate

FROM activity AS a
LEFT JOIN cohort_sizes AS c
    ON a.cohort_month = c.cohort_month
ORDER BY 1, 2
