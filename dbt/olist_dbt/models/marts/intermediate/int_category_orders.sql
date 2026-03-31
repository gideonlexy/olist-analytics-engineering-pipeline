WITH category_order_items AS (

    SELECT
        dp.product_category_name_english,
        oi.order_id,
        DATE_TRUNC('month', oi.order_purchase_timestamp)::DATE AS order_month,
        SUM(oi.gross_item_value) AS category_order_revenue,
        SUM(oi.item_quantity) AS category_order_items
    FROM {{ ref('fct_order_items') }} AS oi
    LEFT JOIN {{ ref('dim_products') }} AS dp
        ON oi.product_id = dp.product_id
    GROUP BY 1, 2, 3

)

SELECT
    coi.product_category_name_english,
    coi.order_id,
    coi.order_month,
    coi.category_order_revenue,
    coi.category_order_items,
    ioe.is_delivered,
    ioe.is_on_time,
    ioe.is_late,
    ioe.delivery_duration_days,
    ioe.delivery_delay_days,
    ioe.avg_review_score
FROM category_order_items AS coi
LEFT JOIN {{ ref('int_orders_enriched') }} AS ioe
    ON coi.order_id = ioe.order_id
