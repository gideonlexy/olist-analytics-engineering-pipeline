SELECT
    order_item_id,
    order_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM {{source('raw', 'order_items')}}