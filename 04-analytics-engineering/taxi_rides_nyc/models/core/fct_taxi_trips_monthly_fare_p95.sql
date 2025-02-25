{{ config(materialized='table') }}

with valid_trips as (
    select 
        service_type,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month,
        fare_amount
    from {{ref("fact_trips")}}
    where fare_amount > 0
      and trip_distance > 0
      and payment_type_description in ('Cash', 'Credit Card')
),

percentile_fares as (
    select 
        distinct service_type,
        year,
        month,
        percentile_cont(fare_amount, 0.97) OVER (PARTITION BY service_type, year, month) as p97_fare,
        percentile_cont(fare_amount, 0.95) OVER (PARTITION BY service_type, year, month) as p95_fare,
        percentile_cont(fare_amount, 0.90) OVER (PARTITION BY service_type, year, month) as p90_fare
    from valid_trips
)

select *
from percentile_fares
where year = 2020 and month = 4
