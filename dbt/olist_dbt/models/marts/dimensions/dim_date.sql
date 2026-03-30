WITH date_spine AS (

    {{ dbt_utils.date_spine(
        datepart = "day",
        start_date = "cast('2016-01-01' AS date)",
        end_date = "cast('2020-12-31' AS date)",
    )}}
)

SELECT
    CAST(date_day AS DATE) AS date_day,
    EXTRACT(YEAR FROM date_day) AS date_year,
    EXTRACT(QUARTER FROM date_day) AS date_quarter,
    EXTRACT(MONTH FROM date_day) AS month_of_year,
    TRIM(TO_CHAR(date_day, 'Month')) AS month_name,
    TO_CHAR(date_day, 'YYYY-MM') AS calendar_year_month,
    EXTRACT(WEEK FROM date_day) AS week_of_year,
    EXTRACT(ISODOW FROM date_day) AS iso_day_of_week,
    TRIM(TO_CHAR(date_day, 'Day')) AS day_name,
    COALESCE(EXTRACT(ISODOW FROM date_day) IN (6, 7), FALSE) AS is_weekend,
    CAST(DATE_TRUNC('month', date_day) AS DATE) AS month_start_date,
    CAST(DATE_TRUNC('quarter', date_day) AS DATE) AS quarter_start_date,
    CAST(DATE_TRUNC('year', date_day) AS DATE) AS year_start_date,
    CAST(DATE_TRUNC('week', date_day) AS DATE) AS week_start_date

FROM date_spine
