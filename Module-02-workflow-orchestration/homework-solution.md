## Module 2 Homework

1. Within the execution for Yellow Taxi data for the year 2020 and month 12: what is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

`134.5 MB`

2. What is the rendered value of the variable file when the inputs taxi is set to green, year is set to 2020, and month is set to 04 during execution?

`*green_tripdata_2020-04.csv*`

3. How many rows are there for the Yellow Taxi data for all CSV files in the year 2020?

```sql
SELECT COUNT(*) AS total_rows_2020
FROM `data-engineering.zoomcamp.yellow_tripdata`
WHERE tpep_pickup_datetime BETWEEN '2020-01-01' AND '2020-12-31 23:59:59';
```
`Result 21,640,960 rows `

4. How many rows are there for the Green Taxi data for all CSV files in the year 2020?

```sql
SELECT count(*) AS total_rows_2020
FROM `data-engineering.zoomcamp.green_tripdata`
where extract(YEAR FROM lpep_pickup_datetime) = 2020;
```
`Result: 1,733,999 rows`

5. How many rows are there for the Yellow Taxi data for the March 2021 CSV file?

```sql
SELECT COUNT(*) AS total_rows_march_2021
FROM `data-engineering.zoomcamp.yellow_tripdata`
WHERE tpep_pickup_datetime BETWEEN '2021-03-01' AND '2021-03-31 23:59:59';
```
`Reuslt: 1,925,130 rows `

6. How would you configure the timezone to New York in a Schedule trigger?

`Add a timezone property set to America/New_York in the Schedule trigger configuration`
