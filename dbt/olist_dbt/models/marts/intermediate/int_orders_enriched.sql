
WITH orders AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM {{ ref('stg_orders') }}

),

rollup_items AS (
    SELECT
        order_id,
        SUM(gross_item_value) AS gross_order_revenue,
        SUM(item_quantity) AS total_items
    FROM {{ ref('fct_order_items') }}
    GROUP BY 1
),

rollup_payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_record_count
    FROM {{ ref('fct_payments') }}
    GROUP BY 1
),

delivery AS (
    SELECT
        order_id,
        delivery_duration_days,
        delivery_delay_days,
        is_delivered,
        is_on_time,
        is_late
    FROM {{ ref('fct_delivery') }}
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.gross_order_revenue,
    oi.total_items,

    p.total_payment_value,
    p.payment_record_count,

    d.delivery_duration_days,
    d.delivery_delay_days,
    d.is_delivered,
    d.is_on_time,
    d.is_late

FROM orders o
LEFT JOIN rollup_items oi
    on o.order_id = oi.order_id
LEFT JOIN rollup_payments p
    on o.order_id = p.order_id
LEFT JOIN delivery d
    on o.order_id = d.order_id