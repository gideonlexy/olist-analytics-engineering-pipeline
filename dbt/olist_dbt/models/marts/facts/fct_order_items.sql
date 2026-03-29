SELECT
    oi.order_id,
    oi.order_item_id,

    o.customer_id,
    oi.product_id,
    oi.seller_id,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.shipping_limit_date,

    oi.price AS item_price ,
    oi.freight_value AS freight_value,
    (oi.price + oi.freight_value)::NUMERIC(12,2) AS gross_item_value,

    1 AS item_quantity
    
FROM {{ ref('stg_order_items') }} oi
JOIN {{ ref('stg_orders') }} o
    ON oi.order_id = o.order_id