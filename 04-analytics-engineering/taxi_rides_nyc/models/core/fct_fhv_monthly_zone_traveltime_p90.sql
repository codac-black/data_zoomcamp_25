{{ config(materialized='view') }}

with fhv_trips as (
    select * from {{ ref('dim_fhv_trips') }}
),
trip_durations as (
    select 
        year,
        month,
        pickup_zone,
        dropoff_zone,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration
    from fhv_trips
    where dropoff_datetime is not null 
),
p90_trip_durations as (
    select 
        year,
        month,
        pickup_zone,
        dropoff_zone,
        APPROX_QUANTILES(trip_duration, 100)[OFFSET(90)] as p90_trip_duration
    from trip_durations
    group by year, month, pickup_zone, dropoff_zone
),
filtered_trips as (
    select 
        pickup_zone, 
        dropoff_zone, 
        p90_trip_duration
    from p90_trip_durations
    where year = 2019 and month = 11
    and pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
),
ranked_trips as (
    select * ,
        dense_rank() over (partition by pickup_zone order by p90_trip_duration desc) as rank
    from filtered_trips
)
select pickup_zone, dropoff_zone 
from ranked_trips
where rank = 2 -- 2nd longest p90 trip duration
