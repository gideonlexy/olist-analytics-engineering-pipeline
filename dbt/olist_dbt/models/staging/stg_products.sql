SELECT
    product_id,
    product_category_name,
    product_name_lenght::INT AS product_name_length,
    product_description_lenght::INT AS product_description_length,
    product_photos_qty::INT AS product_photos_qty,
    product_weight_g::NUMERIC(10, 2) AS product_weight_g,
    product_length_cm::NUMERIC(10, 2) AS product_length_cm,
    product_height_cm::NUMERIC(10, 2) AS product_height_cm,
    product_width_cm::NUMERIC(10, 2) AS product_width_cm
FROM {{source('raw', 'products')}}
