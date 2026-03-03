SELECT
    order_id,
    payment_sequential::int AS payment_sequential,
    payment_type,
    payment_installments::int AS payment_installments,
    payment_value::numeric(12,2) AS payment_value   
    
FROM {{source('raw', 'order_payments')}}