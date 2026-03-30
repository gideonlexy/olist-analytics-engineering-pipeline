WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM {{ ref('stg_orders') }}
),

order_items_agg AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue,
        SUM(freight_value) AS freight_value,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(*) AS item_count
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS paid_amount,
        MAX(payment_installments) AS max_installments
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
),

reviews_agg AS (
    SELECT
        order_id,
        AVG(review_score)::NUMERIC(10, 2) AS avg_review_score,
        COUNT(*) AS review_count
    FROM {{ ref('stg_order_reviews') }}
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.item_revenue,
    oi.freight_value,
    oi.gross_order_value,
    oi.item_count,

    p.paid_amount,
    p.max_installments,

    r.avg_review_score,
    r.review_count
FROM orders AS o
LEFT JOIN order_items_agg AS oi ON o.order_id = oi.order_id
LEFT JOIN payment_agg AS p ON o.order_id = p.order_id
LEFT JOIN reviews_agg AS r ON o.order_id = r.order_id
