
-- Create yellowcab, greencab, fhv, and zone tables
-- First 2 rows removed from files bc they were causing errors on import
-- Yellowcab columns in csv order:
-- VendorID,tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,RatecodeID,store_and_fwd_flag,PULocationID,DOLocationID,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,improvement_surcharge,total_amount
--
-- greencab columns in csv order:
-- VendorID,lpep_pickup_datetime,lpep_dropoff_datetime,store_and_fwd_flag,RatecodeID,PULocationID,DOLocationID,passenger_count,trip_distance,fare_amount,extra,mta_tax,tip_amount,tolls_amount,ehail_fee,improvement_surcharge,total_amount,payment_type,trip_type
--
-- FHV columns in csv order:
-- "Dispatching_base_num","Pickup_DateTime","DropOff_datetime","PUlocationID","DOlocationID","SR_Flag"
--
-- LocationID columns in csv order:
-- "LocationID","Borough","Zone","service_zone"
--
-- Note THAT FHV2018 DATA IS ENCAPSULATED IN QUATIONS "", doesnt appear to be an issue on import.

CREATE TABLE yellowcabs (VendorID INT,	pickup_datetime TEXT,	dropoff_datetime TEXT,	passenger_count INT,	trip_distance FLOAT,	RatecodeID INT,	store_and_fwd_flag TEXT,	PULocationID INT,	DOLocationID INT,	payment_type INT,	fare_amount FLOAT,	extra FLOAT,	mta_tax FLOAT,	tip_amount FLOAT,	tolls_amount FLOAT,	improvement_surcharge FLOAT,	total_amount FLOAT);

CREATE TABLE greencabs (VendorID INT,pickup_datetime TEXT,dropoff_datetime TEXT, store_and_fwd_flag TEXT, RatecodeID INT, PULocationID INT, DOLocationID INT, passenger_count INT,trip_distance FLOAT, fare_amount FLOAT, extra FLOAT, mta_tax FLOAT, tip_amount FLOAT, tolls_amount FLOAT, ehail_fee FLOAT, improvement_surcharge FLOAT, total_amount FLOAT, payment_type INT, trip_type INT);

CREATE TABLE fhvs (Dispatching_base_num TEXT, pickup_datetime TEXT, dropoff_datetime TEXT, PULocationID INT, DOLocationID INT, SR_Flag INT);

CREATE TABLE locations (LocationID INT, Borough TEXT, Zone TEXT, service_zone TEXT);


.mode csv
.separator ,
.import yellow_tripdata_2017-01.csv yellowcabs
.import yellow_tripdata_2018-01.csv yellowcabs

.import green_tripdata_2017-01.csv greencabs
.import green_tripdata_2018-01.csv greencabs

.import fhv_tripdata_2017-01.csv fhvs
.import fhv_tripdata_2018-01.csv fhvs

.import taxi+_zone_lookup.csv locations


.save taxi_final.db
