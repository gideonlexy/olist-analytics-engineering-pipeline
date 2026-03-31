WITH seller_order_items AS (

    SELECT
        seller_id,
        order_id,
        DATE_TRUNC('month', order_purchase_timestamp)::DATE AS order_month,
        SUM(gross_item_value) AS seller_order_revenue,
        SUM(item_quantity) AS seller_order_items
    FROM {{ ref('fct_order_items') }}
    GROUP BY 1, 2, 3

)

SELECT
    soi.seller_id,
    soi.order_id,
    soi.order_month,
    soi.seller_order_revenue,
    soi.seller_order_items,
    d.is_delivered,
    d.is_on_time,
    d.is_late
FROM seller_order_items AS soi
LEFT JOIN {{ ref('fct_delivery') }} AS d
    ON soi.order_id = d.order_id
