SELECT
    review_id,
    order_id,
    review_score::int AS review_score,
    review_comment_title,
    review_comment_message,
    NULLIF(review_creation_date, '')::date AS review_creation_date,
    NULLIF(review_answer_timestamp, '')::timestamp AS review_answer_timestamp
FROM {{source('raw', 'order_reviews')}}