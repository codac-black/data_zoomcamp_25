{{
    config(
        materialized='table'
    )
}}

with green_quarterly as (
    select
        extract(year from pickup_datetime) as year,
        extract(quarter from pickup_datetime) as quarter,
        'Green' as service_type,
        sum(total_amount) as quarterly_revenue
    from {{ ref('stg_green_tripdata') }}
    group by 1, 2, 3
),

yellow_quarterly as (
    select
        extract(year from pickup_datetime) as year,
        extract(quarter from pickup_datetime) as quarter,
        'Yellow' as service_type,
        sum(total_amount) as quarterly_revenue
    from {{ ref('stg_yellow_tripdata') }}
    group by 1, 2, 3
),

combined_quarterly as (
    select * from green_quarterly
    union all
    select * from yellow_quarterly
),

revenue_with_prev_year as (
    select
        current_year.year,
        current_year.quarter,
        current_year.service_type,
        current_year.quarterly_revenue,
        prev_year.quarterly_revenue as prev_year_revenue
    from combined_quarterly current_year
    left join combined_quarterly prev_year
        on current_year.service_type = prev_year.service_type
        and current_year.quarter = prev_year.quarter
        and current_year.year = prev_year.year + 1
)

select
    year,
    quarter,
    service_type,
    quarterly_revenue,
    prev_year_revenue,
    case
        when prev_year_revenue is null or prev_year_revenue = 0 then null
        else (quarterly_revenue - prev_year_revenue) / prev_year_revenue * 100
    end as yoy_growth_pct
from revenue_with_prev_year
order by service_type, year, quarter