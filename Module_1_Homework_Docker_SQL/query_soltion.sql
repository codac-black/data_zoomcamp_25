SELECT
    COUNT(CASE WHEN trip_distance <= 1 THEN 1 END) AS "Up to 1 mile",
    COUNT(CASE WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1 END) AS "Between 1 and 3 miles",
    COUNT(CASE WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1 END) AS "Between 3 and 7 miles",
    COUNT(CASE WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1 END) AS "Between 7 and 10 miles",
    COUNT(CASE WHEN trip_distance > 10 THEN 1 END) AS "Over 10 miles"
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2019-10-01'
  AND lpep_pickup_datetime < '2019-11-01';

SELECT
    DATE(lpep_pickup_datetime) AS pickup_date,
    MAX(trip_distance) AS longest_trip
FROM green_taxi_trips
GROUP BY pickup_date
ORDER BY longest_trip DESC
LIMIT 1;


SELECT
    zones."Zone" AS pickup_zone,
    SUM(total_amount) AS total_amount
FROM green_taxi_trips
JOIN taxi_zones  AS zones
    ON green_taxi_trips."PULocationID" = zones."LocationID"
WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
GROUP BY zones."Zone"
HAVING SUM(total_amount) > 13000
ORDER BY total_amount DESC;

SELECT
    zones."Zone" AS dropoff_zone,
    MAX(tip_amount) AS largest_tip
FROM green_taxi_trips
JOIN taxi_zones AS zones
    ON green_taxi_trips."DOLocationID" = zones."LocationID"
WHERE DATE(lpep_pickup_datetime) >= '2019-10-01'
  AND DATE(lpep_pickup_datetime) < '2019-11-01'
  AND green_taxi_trips."PULocationID" = (
      SELECT "LocationID" FROM taxi_zones WHERE "Zone" = 'East Harlem North'
  )
GROUP BY zones."Zone"
ORDER BY largest_tip DESC
LIMIT 1;
