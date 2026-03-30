SELECT
    order_item_id,
    order_id,
    product_id,
    seller_id,

    NULLIF(shipping_limit_date, '')::TIMESTAMP AS shipping_limit_date,
    price::NUMERIC(12, 2) AS price,
    freight_value::NUMERIC(12, 2) AS freight_value

FROM {{source('raw', 'order_items')}}
