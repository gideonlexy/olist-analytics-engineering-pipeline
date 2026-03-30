SELECT
    order_id,
    payment_sequential::INT AS payment_sequential,
    payment_type,
    payment_installments::INT AS payment_installments,
    payment_value::NUMERIC(12, 2) AS payment_value

FROM {{source('raw', 'order_payments')}}
