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
),

review AS (
    SELECT
        order_id,
        AVG(review_score)::NUMERIC(10, 2) AS avg_review_score,
        COUNT(*) AS review_count
    FROM {{ ref('stg_order_reviews') }}
    GROUP BY 1
),

seller_rollup AS (
    SELECT
        order_id,
        COUNT(DISTINCT seller_id) AS seller_count,
        MIN(seller_id) AS primary_seller_id
    FROM {{ ref('fct_order_items') }}
    GROUP BY 1
)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_state,
    s.primary_seller_id AS seller_id,
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
    d.is_late,

    r.avg_review_score,
    r.review_count

FROM orders AS o
LEFT JOIN rollup_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN rollup_payments AS p
    ON o.order_id = p.order_id
LEFT JOIN delivery AS d
    ON o.order_id = d.order_id
LEFT JOIN review AS r
    ON o.order_id = r.order_id
LEFT JOIN {{ ref('dim_customers') }} AS c
    ON o.customer_id = c.customer_id
LEFT JOIN seller_rollup AS s
    ON o.order_id = s.order_id
