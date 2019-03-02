-- #1 Retrieve Rides Per Weekday

SELECT
strftime('%Y', pickup_datetime) as valYear,
sum(passenger_count) as Riders,
count(VendorID) as valRides
FROM yellowcabs
WHERE
strftime('%Y', pickup_datetime) IN ('2017', '2018')
AND
strftime('%H', pickup_datetime) IN('07','08')
AND
strftime('%w', pickup_datetime) > '0' AND strftime('%w', pickup_datetime) < '6'
GROUP BY valYear;

-- Similar Query for FHVs
SELECT
strftime('%Y', pickup_datetime) as valYear,
count(Dispatching_base_num) as valRides
FROM yellowcabs
WHERE
strftime('%H', pickup_datetime) IN('07','08')
AND
strftime('%w', pickup_datetime) > '0' AND strftime('%w', pickup_datetime) < '6'
GROUP BY valYear;


-- #2 query to retrieve top three locations by count of riders using
WITH tempTable as (
  SELECT
  strftime('%H', pickup_datetime) as pickupHour,
  Zone,
  count(*) as rideCount
  FROM yellowcabs
  LEFT JOIN locations
    ON yellowcabs.PULocationID = locations.locationID
  WHERE strftime('%Y', pickup_datetime) = '2017'
  UNION
  SELECT
  strftime('%H', pickup_datetime) as pickupHour,
  Zone,
  count(*) as rideCount
  FROM greencabs
  LEFT JOIN locations
    ON greencabs.PULocationID = locations.locationID
  WHERE strftime('%Y', pickup_datetime) = '2017'
  GROUP BY pickupHour
)

SELECT * FROM tempTable temp_outer
WHERE temp_outer.Zone IN (
  SELECT Zone
  FROM tempTable temp_inner
  WHERE temp_inner.pickupHour = temp_outer.pickupHour
  GROUP BY pickupHour, Zone, rideCount
  ORDER BY temp_inner.rideCount ASC LIMIT 3
)
ORDER BY pickupHour;


-- #2 backup call that is less computationally expensive
SELECT
strftime('%H', pickup_datetime) as pickupHour,
Zone,
count(*) as rideCount
FROM yellowcabs
LEFT JOIN locations
  ON yellowcabs.PULocationID = locations.locationID
WHERE strftime('%Y', pickup_datetime) = '2017'
UNION
SELECT
strftime('%H', pickup_datetime) as pickupHour,
Zone,
count(*) as rideCount
FROM greencabs
LEFT JOIN locations
  ON greencabs.PULocationID = locations.locationID
WHERE strftime('%Y', pickup_datetime) = '2017'
GROUP BY pickupHour, Zone
ORDER BY pickupHour ASC;

-- #3 Query to Retrieve Top 3 Locations for Max Fare in 2017

SELECT
Zone,
max(total_amount) AS maxFare

FROM
  (SELECT
  VendorID, PULocationID, total_amount, Zone
  FROM yellowcabs
  LEFT JOIN locations
    ON yellowcabs.PULocationID = locations.locationID
  WHERE strftime('%Y', pickup_datetime) = '2017'
  UNION
  SELECT
  VendorID, PULocationID, total_amount, Zone
  FROM greencabs
  LEFT JOIN locations
    ON greencabs.PULocationID = locations.locationID
  WHERE strftime('%Y', pickup_datetime) = '2017')

GROUP BY Zone
ORDER BY maxFare DESC
LIMIT 3;

-- #4 Avg Tip Data by Payment Type

SELECT
payment_type,
avg(total_amount) AS avgFare,
avg(tip_amount) AS avgTip,
CASE
    WHEN payment_type = 1 THEN "Credit Card"
    WHEN payment_type = 2 THEN "Cash"
    ELSE "other"
END AS PaymentText

FROM
  (SELECT
  VendorID, total_amount, payment_type, tip_amount
  FROM yellowcabs
  WHERE strftime('%Y', pickup_datetime) = '2017'
  UNION
  SELECT
  VendorID, total_amount, payment_type, tip_amount
  FROM greencabs
  WHERE strftime('%Y', pickup_datetime) = '2017')

WHERE tip_amount > 0
GROUP BY PaymentText;

-- #5 Avg Tip Data by Payment Type

SELECT
strftime('%Y', pickup_datetime) as Year,
passenger_count AS Riders,
avg(fare_amount) AS avgFare,
avg(tip_amount) AS avgTip,
avg(total_amount) AS avgTotal,
avg(trip_distance) AS avgTripDistance,
count(fare_amount) AS itemCount

FROM
  (SELECT
  pickup_datetime, passenger_count, fare_amount, tip_amount, total_amount, trip_distance
  FROM yellowcabs
  UNION
  SELECT
  pickup_datetime, passenger_count, fare_amount, tip_amount, total_amount, trip_distance
  FROM greencabs)
WHERE Year IN ('2017','2018')
GROUP BY Year, Riders;

-- #6 Yellow Cab rides, 2017&18 from 7-10PM
-- Assuming car operation runs $0.1/mi
-- We will to be as efficient as possible, keep rides within the borough and determin max earnings per mile
SELECT
Zone,
Borough,
avg(total_amount / trip_distance) AS FarePerMinute,
count(pickup_datetime) AS SampleSize

FROM yellowcabs
LEFT JOIN locations
  ON yellowcabs.PULocationID = locations.locationID
WHERE strftime('%Y', pickup_datetime) IN ('2016', '2018')
AND  strftime('%H', pickup_datetime) IN ('19', '20', '21')
AND trip_distance > 0
AND PULocationID = DOLocationID
GROUP BY Zone
ORDER BY FarePerMile DESC;

-- Question #6 Assuming that we are looking for top earnings per hour
SELECT
Zone,
Borough,
avg(total_amount / ((strftime('%s', dropoff_datetime) - strftime('%s',pickup_datetime))/360)) AS FarePerHour,
count(pickup_datetime) AS SampleSize

FROM yellowcabs
LEFT JOIN locations
  ON yellowcabs.PULocationID = locations.locationID
WHERE strftime('%Y', pickup_datetime) IN ('2016', '2018')
AND  strftime('%H', pickup_datetime) IN ('19', '20', '21')
AND trip_distance > 0
AND PULocationID = DOLocationID
GROUP BY Zone
ORDER BY FarePerHour DESC;
