SELECT
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    SUM(gross_order_revenue) AS daily_revenue,
    COUNT(DISTINCT order_id) AS delivered_orders,
    SUM(total_items) AS daily_items_sold,
    AVG(gross_order_revenue) AS average_order_value

FROM {{ ref('int_orders_enriched') }}
WHERE
    is_delivered = TRUE
    AND order_purchase_timestamp IS NOT NULL
    AND gross_order_revenue IS NOT NULL
GROUP BY 1
