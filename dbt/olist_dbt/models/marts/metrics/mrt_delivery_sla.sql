SELECT
    DATE_TRUNC('month', order_delivered_customer_date)::DATE AS delivery_month,
    customer_state,

    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN is_on_time = TRUE THEN order_id END) AS on_time_orders,
    COUNT(DISTINCT CASE WHEN is_late = TRUE THEN order_id END) AS late_orders,

    ROUND(
        COUNT(DISTINCT CASE WHEN is_on_time = TRUE THEN order_id END)::NUMERIC
        / NULLIF(COUNT(DISTINCT order_id), 0),
        4
    ) AS on_time_rate,
    COUNT(DISTINCT CASE WHEN is_late = TRUE THEN order_id END)::NUMERIC
    /
    NULLIF(COUNT(DISTINCT order_id), 0) AS late_rate,

    AVG(delivery_duration_days) AS avg_delivery_duration_days,
    AVG(delivery_delay_days) AS avg_delivery_delay_days

FROM {{ ref('fct_delivery') }}
WHERE
    is_delivered = TRUE
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
