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
left join  `bigquery-public-data.austin_bikeshare.bikeshare_stations` as stations
on trip.start_station_id = stations.station_id
where extract(year from trip.start_time) = 2017;

