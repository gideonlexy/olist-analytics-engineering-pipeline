SELECT
    product_category_name_english,
    order_month,

    COUNT(DISTINCT order_id) AS total_orders,
    SUM(category_order_items) AS total_items_sold,
    SUM(category_order_revenue) AS total_revenue,

    COUNT(DISTINCT CASE WHEN is_delivered = TRUE THEN order_id END) AS delivered_orders,
    COUNT(
        DISTINCT CASE WHEN is_on_time = TRUE AND is_delivered = TRUE THEN order_id END
    ) AS on_time_orders,
    ROUND(
        COUNT(
            DISTINCT CASE WHEN is_on_time = TRUE AND is_delivered = TRUE THEN order_id END
        )::NUMERIC
        / NULLIF(COUNT(DISTINCT CASE WHEN is_delivered = TRUE THEN order_id END), 0),
        4
    ) AS on_time_rate,

    AVG(delivery_duration_days) AS avg_delivery_duration_days,
    AVG(delivery_delay_days) AS avg_delivery_delay_days,
    AVG(avg_review_score) AS avg_review_score



FROM {{ ref('int_category_orders') }}
WHERE order_month IS NOT NULL
GROUP BY 1, 2
ORDER BY 2, 1
