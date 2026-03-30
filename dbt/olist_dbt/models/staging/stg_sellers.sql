SELECT
    seller_id,
    NULLIF(seller_zip_code_prefix::TEXT, '')::TEXT AS seller_zip_code_prefix,
    seller_city,
    seller_state
FROM {{source('raw', 'sellers')}}
