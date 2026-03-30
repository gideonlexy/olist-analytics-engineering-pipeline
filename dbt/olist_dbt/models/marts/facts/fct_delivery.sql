SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    c.customer_city,
    c.customer_state,


    -- Delivery performance metrics
    CASE
        WHEN
            o.order_delivered_customer_date IS NOT NULL
            AND o.order_purchase_timestamp IS NOT NULL
            THEN
                (o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE)
    END AS delivery_duration_days,

    CASE
        WHEN
            o.order_delivered_customer_date IS NOT NULL
            AND o.order_estimated_delivery_date IS NOT NULL
            THEN
                (o.order_delivered_customer_date::DATE - o.order_estimated_delivery_date::DATE)
    END AS delivery_delay_days,

    COALESCE(o.order_status = 'delivered', FALSE) AS is_delivered,

    COALESCE(
        o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
        AND (o.order_delivered_customer_date::DATE <= o.order_estimated_delivery_date::DATE),
        FALSE
    ) AS is_on_time,

    COALESCE(
        o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
        AND (o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE),
        FALSE
    ) AS is_late


FROM {{ ref('stg_orders') }} AS o
LEFT JOIN {{ ref('dim_customers') }} AS c
    ON o.customer_id = c.customer_id
