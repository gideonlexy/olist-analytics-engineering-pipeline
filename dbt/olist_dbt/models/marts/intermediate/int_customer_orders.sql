WITH valid_orders AS (

    SELECT
        order_id,
        customer_id,
        customer_unique_id,
        CAST(order_purchase_timestamp AS DATE) AS order_date,
        CAST(DATE_TRUNC('month', order_purchase_timestamp) AS DATE) AS order_month
    FROM {{ ref('int_orders_enriched') }}
    WHERE
        is_delivered = TRUE
        AND order_purchase_timestamp IS NOT NULL

),

sequenced AS (

    SELECT
        order_id,
        customer_id,
        customer_unique_id,
        order_date,
        order_month,

        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_date, order_id
        ) AS customer_order_number,

        MIN(order_date) OVER (
            PARTITION BY customer_unique_id
        ) AS first_order_date,

        MIN(order_month) OVER (
            PARTITION BY customer_unique_id
        ) AS cohort_month,

        LEAD(order_date) OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_date, order_id
        ) AS next_order_date

    FROM valid_orders

)

SELECT
    order_id,
    customer_id,
    customer_unique_id,
    order_date,
    order_month,
    customer_order_number,
    first_order_date,
    cohort_month,
    next_order_date,

    COALESCE(customer_order_number = 1, FALSE) AS is_first_order,

    COALESCE(customer_order_number > 1, FALSE) AS is_repeat_order,

    CAST((
        (
            EXTRACT(YEAR FROM AGE(order_month, cohort_month)) * 12
        )
        + EXTRACT(MONTH FROM AGE(order_month, cohort_month))
    ) AS INT) AS months_since_first_order,

    CASE
        WHEN
            customer_order_number = 1
            AND next_order_date IS NOT NULL
            THEN (next_order_date - order_date)
    END AS days_to_second_order

FROM sequenced
