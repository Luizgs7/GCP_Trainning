# Creating the firt experiment model.

#standardSQL
CREATE OR REPLACE MODEL `model.model_01`
OPTIONS(model_type='LINEAR_REG') AS
select
trip.start_station_name,
extract(hour from trip.start_time) as hour,
extract(DAYOFWEEK from trip.start_time) as weakday,
stations.address as location,
trip.duration_minutes as label
from `bigquery-public-data.austin_bikeshare.bikeshare_trips`  as trip
inner join  `bigquery-public-data.austin_bikeshare.bikeshare_stations` as stations
on trip.start_station_id = stations.station_id
where extract(year from trip.start_time) = 2017;


# Validating model on the 2019 data
#standardSQL
SELECT
  *
FROM
  ml.EVALUATE(MODEL `model.model_01`, (
select
trip.start_station_name,
extract(hour from trip.start_time) as hour,
extract(DAYOFWEEK from trip.start_time) as weakday,
stations.address as location,
trip.duration_minutes as label
from `bigquery-public-data.austin_bikeshare.bikeshare_trips`  as trip
inner join  `bigquery-public-data.austin_bikeshare.bikeshare_stations` as stations
on trip.start_station_id = stations.station_id
where extract(year from trip.start_time) = 2019));



# Creating the second model, adding more features:
-- starting station name, 
-- bike share subscriber type 
-- start time for the trip
#standardSQL
CREATE OR REPLACE MODEL `model.model_02`
OPTIONS(model_type='LINEAR_REG') AS
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes as label
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE 
  EXTRACT(YEAR FROM start_time) = 2017
;


#standardSQL
SELECT
  *
FROM
  ml.EVALUATE(MODEL `model.model_02`, (
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes as label
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE 
  EXTRACT(YEAR FROM start_time) = 2019
));



-- When both models have been created and evaulated, use the second model, 
-- that uses subscriber_type as a feature, to predict average trip length for trips 
-- from the busiest bike sharing station in 2019 where the subscriber type is Single Trip.

  #standardSQL
SELECT AVG(predicted_label) AS average_predicted_trip_length
FROM ML.predict(MODEL model.model_02, (
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE 
  EXTRACT(YEAR FROM start_time) = 2019
  AND subscriber_type = 'Single Trip'
  AND start_station_name = '21st & Speedway @PCL'));
