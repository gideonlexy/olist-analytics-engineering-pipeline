SELECT
    product_id,
    product_category_name,
    product_name_lenght::int AS product_name_length,
    product_description_lenght::int AS product_description_length,
    product_photos_qty::int AS product_photos_qty,
    product_weight_g::numeric(10,2) AS product_weight_g,
    product_length_cm::numeric(10,2) AS product_length_cm, 
    product_height_cm::numeric(10,2) AS product_height_cm,
    product_width_cm::numeric(10,2) AS product_width_cm
FROM {{source('raw', 'products')}}