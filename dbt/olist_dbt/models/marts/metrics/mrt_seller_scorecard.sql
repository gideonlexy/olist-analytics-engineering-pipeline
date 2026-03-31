SELECT
    seller_id,
    order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(seller_order_items) AS total_items_sold,
    SUM(seller_order_revenue) AS total_revenue,
    COUNT(DISTINCT CASE WHEN is_delivered = TRUE THEN order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN is_on_time = TRUE THEN order_id END) AS on_time_orders,
    COUNT(DISTINCT CASE WHEN is_late = TRUE THEN order_id END) AS late_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN is_on_time = TRUE THEN order_id END)::NUMERIC
        / NULLIF(COUNT(DISTINCT CASE WHEN is_delivered = TRUE THEN order_id END), 0),
        4
    ) AS on_time_rate
FROM {{ ref('int_seller_orders') }}
WHERE order_month IS NOT NULL
GROUP BY 1, 2
ORDER BY 2, 1
