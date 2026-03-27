SELECT 
    customer_id,
    customer_unique_id,
    NULLIF(customer_zip_code_prefix::text,'')::text AS customer_zip_code_prefix,
    customer_city,
    customer_state
FROM {{source('raw', 'customers')}}
