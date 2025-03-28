{{ config(materialized='table') }}

with fhv_trips as (
    select * from {{ ref('stg_fhv_tripdata') }}
),

dim_zones as (
    select * from {{ ref('dim_zones') }}
),

fhv_trips_enriched as (
    select 
        {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
        fhv_trips.dispatching_base_num,
        fhv_trips.pickup_datetime,
        fhv_trips.dropoff_datetime,
        fhv_trips.pickup_locationid,
        pickup_zone.borough as pickup_borough, 
        pickup_zone.zone as pickup_zone, 
        fhv_trips.dropoff_locationid,
        dropoff_zone.borough as dropoff_borough, 
        dropoff_zone.zone as dropoff_zone,
        fhv_trips.sr_flag,
        fhv_trips.affiliated_base_number,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month
    from fhv_trips
    left join dim_zones as pickup_zone
    on fhv_trips.pickup_locationid = pickup_zone.locationid
    left join dim_zones as dropoff_zone
    on fhv_trips.dropoff_locationid = dropoff_zone.locationid
)

select * from fhv_trips_enriched
