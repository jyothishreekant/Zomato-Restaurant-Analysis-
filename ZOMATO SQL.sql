CREATE DATABASE ZOMATOANALYSIS;
USE ZOMATOANALYSIS;

DROP TABLE IF EXISTS zomato;

CREATE TABLE zomato (
RestaurantID BIGINT,
RestaurantName TEXT,
CountryCode INT,
City TEXT,
Locality TEXT,
LocalityVerbose TEXT,
Longitude DOUBLE,
Latitude DOUBLE,
Cuisines TEXT,
Currency TEXT,
Has_Table_booking VARCHAR(10),
Has_Online_delivery VARCHAR(10),
Is_delivering_now VARCHAR(10),
Switch_to_order_menu VARCHAR(10),
Price_range INT,
Votes INT,
Average_Cost_for_two INT,
Rating DECIMAL(3,1),
Datekey_Opening VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/ADMIN/Desktop/ZOMATO/Zomata (1).csv'
INTO TABLE zomato
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE country_code (
    CountryCode INT,
    Country VARCHAR(100)
);
LOAD DATA LOCAL INFILE 'C:/Users/ADMIN/Desktop/project/Country-Code.csv'
INTO TABLE country_code
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM country_code;
select count(*) from zomato;

SELECT * FROM ZOMATO;

#JOIN 
SELECT a.RestaurantName,
       b.Country
FROM zomato a
JOIN country_code b
ON a.CountryCode = b.CountryCode;

-- ADD COUNTRY INTO RAW DATA
ALTER TABLE zomato
ADD COLUMN CountryName VARCHAR(50);

UPDATE zomato a
JOIN country_code b
ON a.CountryCode = a.CountryCode
SET a.CountryName = b.Country;

SELECT * FROM zomato;

ALTER TABLE zomato
MODIFY COLUMN `Datekey_Opening` DATE;

-- 2.CALENDER
CREATE TABLE calendar AS
SELECT Datekey_Opening AS FullDate,
       YEAR(Datekey_Opening) AS Year,
	   MONTH(Datekey_Opening) AS MonthNo,
       MONTHNAME(Datekey_Opening) AS MonthFullName,
       CONCAT('Q',QUARTER(Datekey_Opening)) AS Quarter,
       DATE_FORMAT(Datekey_Opening,'%Y-%b') AS YearMonth,
       DAYOFWEEK(Datekey_Opening) AS WeekdayNo,
       DAYNAME(Datekey_Opening) AS WeekdayName,
CASE
WHEN MONTH(Datekey_Opening)=4 THEN 'FM1'
WHEN MONTH(Datekey_Opening)=5 THEN 'FM2'
WHEN MONTH(Datekey_Opening)=6 THEN 'FM3'
WHEN MONTH(Datekey_Opening)=7 THEN 'FM4'
WHEN MONTH(Datekey_Opening)=8 THEN 'FM5'
WHEN MONTH(Datekey_Opening)=9 THEN 'FM6'
WHEN MONTH(Datekey_Opening)=10 THEN 'FM7'
WHEN MONTH(Datekey_Opening)=11 THEN 'FM8'
WHEN MONTH(Datekey_Opening)=12 THEN 'FM9'
WHEN MONTH(Datekey_Opening)=1 THEN 'FM10'
WHEN MONTH(Datekey_Opening)=2 THEN 'FM11'
ELSE 'FM12'
END AS FinancialMonth,

CASE
WHEN MONTH(Datekey_Opening) IN (4,5,6) THEN 'FQ1'
WHEN MONTH(Datekey_Opening) IN (7,8,9) THEN 'FQ2'
WHEN MONTH(Datekey_Opening) IN (10,11,12) THEN 'FQ3'
ELSE 'FQ4'
END AS FinancialQuarter FROM zomato;

SELECT *FROM CALENDAR;

-- KPI
#Total country
SELECT COUNT(DISTINCT CountryCode) AS Total_Countries
FROM zomato;

#Total Cities
SELECT COUNT(DISTINCT City) AS Total_Cities
FROM zomato;

#Total Restaurant
SELECT COUNT(*) AS Total_Restaurants
FROM zomato;

#Avg Rating
select round(avg(rating),2) as average_rating from zomato;

-- 3.Find the Numbers of Resturants based on City and Country.
SELECT CountryName,
       City,
       COUNT(*) AS Restaurant_Count
FROM zomato
GROUP BY CountryName, City
ORDER BY CountryName, Restaurant_Count DESC;

-- 4.Numbers of Resturants opening based on Year , Quarter , Month
SELECT
    b.Year,
    b.Quarter,
    b.MonthFullName,
    COUNT(*) AS Restaurant_Count
FROM zomato a
JOIN calendar b
    ON a.Datekey_Opening = b.FullDate
GROUP BY
    b.Year,
    b.Quarter,
    b.MonthFullName,
    b.MonthNo
ORDER BY
    b.Year,
    b.MonthNo;
    
    -- 5. Count of Resturants based on Average Ratings
    SELECT CASE
        WHEN Rating = 0 THEN 'Not Rated'
        WHEN Rating <= 2 THEN 'Poor'
        WHEN Rating <= 3 THEN 'Average'
        WHEN Rating <= 4 THEN 'Good'
        ELSE 'Excellent'
    END AS Rating_Category,
    COUNT(*) AS Restaurant_Count
FROM zomato
GROUP BY Rating_Category;

-- 6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT CASE
        WHEN Average_Cost_for_two <= 500 THEN '0-500'
        WHEN Average_Cost_for_two <= 1000 THEN '501-1000'
        WHEN Average_Cost_for_two <= 2000 THEN '1001-2000'
        WHEN Average_Cost_for_two <= 3000 THEN '2001-3000'
        ELSE '3000+'
    END AS Price_Bucket,
    COUNT(*) AS Restaurant_Count
FROM zomato
GROUP BY Price_Bucket
ORDER BY Restaurant_Count DESC;

-- 7.Percentage of Resturants based on "Has_Table_booking"
SELECT Has_Table_booking,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato), 2) AS Percentage
FROM zomato
GROUP BY Has_Table_booking;

-- 8.Percentage of Resturants based on "Has_Online_delivery"
SELECT
    Has_Online_delivery,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato), 2) AS Percentage
FROM zomato
GROUP BY Has_Online_delivery;

-- 9. Develop querry based on Cusines, City, Ratings
SELECT Cuisines,
    COUNT(*) AS Restaurant_Count
FROM zomato
WHERE Cuisines IS NOT NULL
GROUP BY Cuisines
ORDER BY Restaurant_Count DESC
LIMIT 10;





