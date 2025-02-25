{{ config(materialized='view') }}

with tripdata as (
    select *
    from {{ source('staging', 'fhv_tripdata') }}
    where dispatching_base_num is not null
)

select 
    {{ dbt.safe_cast("dispatching_base_num", "string") }} as dispatching_base_num,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,
    {{ dbt.safe_cast("PUlocationID", "integer") }} as pickup_locationid,
    {{ dbt.safe_cast("DOlocationID", "integer") }} as dropoff_locationid,
    sr_flag,
    {{ dbt.safe_cast("Affiliated_base_number", "string") }} as affiliated_base_number
from tripdata
