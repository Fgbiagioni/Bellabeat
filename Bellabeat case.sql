-- ===================================================================
-- Case Study 2: How Can a Wellness Technology Company Play It Smart?
-- User: Fabrizio Biagioni
-- ===================================================================

-- Erasing the Database in case it already exists
IF EXISTS(SELECT name FROM sys.databases WHERE name = 'Bellabeat')
	DROP DATABASE Bellabeat
GO
-- Creating the Database
CREATE DATABASE Bellabeat
GO
-- Activating the DB
USE Bellabeat
GO

-- The tables were imported using the Wizard (Flat File Source) and ensuring that the date columns
-- have the same "date" format in each table

-- ================================
-- PROCESS - Organization of data
-- ================================
-- It is important to highlight that the data types have been changed respectively (Date, Float and INT)
-- This can be done in SQL Server by right clicking a Table in the Object Explorer tab and selecting "Design"

Select * from dailyCalories_merged -- 940 obs
Select * from dailyIntensities_merged -- 940 obs, it is important to note that there are no negative values in distance or minutes
Select * from dailySteps_merged -- 940 obs
Select * from weightLogInfo_merged -- 67 obs, the "Date" column was renamed to Activity_Date in excel before import
Select * from sleepDay_merged -- 413 obs

Select count(distinct(Id)) from dailyCalories_merged -- In total, the data has 33 Users
Select count(distinct(Id)) from weightLogInfo_merged -- Only 8 users registered their weight
Select count(distinct(Id)) from sleepDay_merged -- Only 24 users registered their sleeping minutes

-- Identifying negative values in some rows:
SELECT Calories
FROM dailyCalories_merged
WHERE Calories < 0
ORDER BY Calories -- No negative values, this is correct

SELECT StepTotal
FROM dailySteps_merged
WHERE StepTotal < 0
ORDER BY StepTotal -- No negative values, this is correct

SELECT WeightKg
FROM weightLogInfo_merged
WHERE WeightKg < 0
ORDER BY WeightKg -- No negative values, this is correct

SELECT TotalMinutesAsleep
FROM sleepDay_merged
WHERE TotalMinutesAsleep < 0
ORDER BY TotalMinutesAsleep -- No negative values, this is correct

-- Creating a main table of Users and Date (with distinct values, it will serve to relate in Power BI)
if object_id('Usuarios') is not null
  drop table Usuarios;

SELECT DISTINCT Id
INTO Usuarios
FROM dailyCalories_merged;
Select * from Usuarios

if object_id('Activitydates') is not null
  drop table Activitydates;
SELECT DISTINCT ActivityDay
INTO Activitydates
FROM dailyCalories_merged;
Select * from Activitydates
-- Adding a new column to know the weekday of the date
ALTER TABLE Activitydates
ADD Weekday_name VARCHAR(20);
UPDATE Activitydates
SET Weekday_name = DATENAME(WEEKDAY, ActivityDay);
Select * from Activitydates


-- ================================
-- Analyzing the Data
-- ================================

-- Analyzing the hours slept:
-- Creating a new column to see the hours slept (TotalMinutesAsleep has to be Float for it to work)

ALTER TABLE sleepDay_merged 
ADD TotalHoursAsleep AS ROUND(TotalMinutesAsleep/60,2)

Select * from sleepDay_merged
ORDER BY TotalHoursAsleep DESC
-- It can be seen that the person who has slept the most has done so for more than 13 hours.
-- The WHO recommends sleeping at least 6 hours a day, so it is interesting to see
-- which users have not achieved this

Select * from sleepDay_merged
WHERE TotalHoursAsleep < 6
ORDER BY TotalHoursAsleep DESC
-- In total, users have slept less than 6 hours 100 times.

Select Id, Count(Id) as Few_Sleep_Times from sleepDay_merged
WHERE TotalHoursAsleep < 6
GROUP BY Id
ORDER BY Few_Sleep_Times DESC
-- User 3977333714 is the user who has slept less than 6 hours the most (24 times).

-- Adding a description of sleep hours
ALTER TABLE sleepDay_merged 
ADD Sleep_Description AS
       CASE 
            WHEN (TotalMinutesAsleep  < 360) THEN 'Few Sleep'
            WHEN (TotalMinutesAsleep >= 360 and TotalMinutesAsleep <= 540) THEN 'Normal'
			WHEN (TotalMinutesAsleep > 540) THEN 'Long Sleep'
			ELSE 'No Data'
       END
Select * from sleepDay_merged -- It is now observable the description of the hours of sleep

Select Id, TotalHoursAsleep, Sleep_Description
FROM sleepDay_merged
WHERE Sleep_Description = 'Few Sleep'
ORDER BY TotalHoursAsleep ASC
-- This is another way to observe that, in total, the users have had few sleep 100 times.
-- It is important to note that we are asumming no "naps" were taken, and this are all regular sleeps.


-- Another interesting thing to analyze might be the time in bed that the user doesn't sleep
Select Id, TotalTimeInBed, TotalMinutesAsleep,TotalTimeInBed-TotalMinutesAsleep as TimeNotAsleep
FROM sleepDay_merged
ORDER BY TimeNotAsleep DESC
-- We can see that almost all observations, except for one, indicate that the users spent some time in bed
-- before they actually sleep

-- Adding this in the Table (in hours):
ALTER TABLE sleepDay_merged 
ADD HoursNotAsleep AS ROUND((TotalTimeInBed-TotalMinutesAsleep)/60,2)

ALTER TABLE sleepDay_merged 
ADD HoursInBed AS ROUND(TotalTimeInBed/60,2)

Select Id, HoursInBed, TotalHoursAsleep as HoursAsleep,HoursNotAsleep
FROM sleepDay_merged
WHERE HoursNotAsleep > 1
ORDER BY HoursNotAsleep DESC
-- It is possible to see that the users have spent more than 1 hour in bed before sleeping 52 times (in total)

Select Id, Count(Id) as Records, ROUND(AVG(HoursNotAsleep),2) as Hours_In_Bed_Not_Asleep
FROM sleepDay_merged
WHERE HoursNotAsleep > 1
GROUP BY Id
ORDER BY Hours_In_Bed_Not_Asleep DESC
-- User 1844505072 spents, in average, 5.15 hours in Bed without sleep.
-- 11 users have spent more than 1 hour in Bed before sleeping

-- Analyzing the intensity of the activities:
SELECT d.Weekday_name,
ROUND(AVG(i.VeryActiveMinutes),2) as avg_very_act_min,
ROUND(AVG(i.FairlyActiveMinutes),2) as avg_fairly_act_min,
ROUND(AVG(i.LightlyActiveMinutes),2) as avg_lightly_act_min,
ROUND(AVG(i.SedentaryMinutes),2) as sedentary_min
FROM Activitydates as d
JOIN dailyIntensities_merged as i
ON d.ActivityDay = i.ActivityDay
GROUP BY d.Weekday_name
-- We can see that, in average, Monday is the day with more sedentary minutes of activity
-- and it is also the day with more Very Active minutes of activity


-- Now, if we want to analyze the Weight, we can start by having a better look at the User's weight data:
Select Id, MAX(Round(WeightKg,2)) as Max_Weight, MIN(Round(WeightKg,2)) as Min_Weight, Round(AVG(Round(WeightKg,2)),2) as AVG_Weight 
From weightLogInfo_merged
GROUP BY Id
ORDER BY AVG_Weight DESC

-- As an interesting finding we have that there is only one user who exceeds 100kg
-- With this finding, it is also interesting to see how many users are overweight:
Select Id, BMI as BMI
From weightLogInfo_merged
Where BMI < 25

Select ID, COUNT(Id) as times_overweight
From weightLogInfo_merged
Where BMI >= 25 and BMI < 30
GROUP BY Id

Select ID, COUNT(Id) as times_overweight
From weightLogInfo_merged
Where BMI >= 30
GROUP BY Id
-- It can be seen that there is a user with obesity and 4 users with overweight

-- ======================================
-- Using JOINS to deeply analize the data
-- ======================================

-- It is important to note that the date columns are under the same Date format to be able to do the JOINS
-- In addition, the variables have been modified to have them in FLOAT, INT or VARCHAR correspondingly

Select c.Id, c.ActivityDay, c.Calories, Round(w.WeightKg,2) as Weight, ROUND(w.BMI,2) as BMI
  from dailyCalories_merged as c
  join weightLogInfo_merged as w
  on c.Id = w.Id and
  c.ActivityDay = w.Activity_Day
  ORDER BY Weight DESC

-- To observe, in average, a relationship between weight and calories burned:
Select c.Id, Round(AVG(c.Calories),2) as AVG_Calories, Round(AVG(w.WeightKg),2) as AVG_Weight
  from dailyCalories_merged as c
  full join weightLogInfo_merged as w
  on c.Id= w.Id and
  c.ActivityDay = w.Activity_Day
  WHERE w.WeightKg IS NOT NULL  -- to eliminate the null values
  GROUP BY c.Id
  ORDER BY AVG_Weight
  -- It is not easy to see a correlation between Calories and Weight, but there is
  -- actually a small positive relationship between the variables

  Select c.Id, Round(AVG(Round(c.Calories,2)),2) as AVG_Calories, Round(AVG(Round(s.StepTotal,2)),2) as AVG_Step
  from dailyCalories_merged as c
  full join dailySteps_merged as s
  on c.Id= s.Id and
  c.ActivityDay = s.ActivityDay
  GROUP BY c.Id
  ORDER BY AVG_Calories
-- It is seen that there is no exact relationship between the amount of calories and the steps taken
-- Perhaps this may depend on the intensity of the steps taken

  
-- Here some Conditionals (If) will be used to analyze the contexture (BMI) of the users together with their hours of sleep 
-- and see if there is any relationship

SELECT s.Id, ROUND(w.WeightKg,2) as Weight, ROUND(w.BMI,2) as BMI, s.TotalHoursAsleep,
       CASE 
            WHEN (BMI < 18.5) THEN 'Underweight'
            WHEN (BMI >= 18.5 and BMI < 25) THEN 'Normal'
            WHEN (BMI >= 25 and BMI < 30) THEN 'Overweight'
			WHEN (BMI >= 30 and BMI < 35) THEN 'Obese'
			WHEN (BMI > 35) THEN 'Extremely obese'
			ELSE 'No Data'
       END AS Weight_Description
FROM sleepDay_merged as s
RIGHT JOIN weightLogInfo_merged as w 
ON s.Id= w.Id and
  s.SleepDay = w.Activity_Day

-- Adding the description to the Weight table:
ALTER TABLE weightLogInfo_merged 
ADD Weight_Description AS
       CASE 
            WHEN (BMI < 18.5) THEN 'Underweight'
            WHEN (BMI >= 18.5 and BMI < 25) THEN 'Normal'
            WHEN (BMI >= 25 and BMI < 30) THEN 'Overweight'
			WHEN (BMI >= 30 and BMI < 35) THEN 'Obese'
			WHEN (BMI > 35) THEN 'Extremely obese'
			ELSE 'No Data'
       END
Select * from weightLogInfo_merged 

Select COUNT(DISTINCT(Id)) as User_count, Weight_Description
from weightLogInfo_merged 
GROUP BY Weight_Description
-- There is one user with extreme obsesity, 3 users with normal weight, and 4 users with overweight

-- Analyzing the weight and the Intensity of the activities:
SELECT i.Id, ROUND(w.WeightKg,2) as Weight, ROUND(w.BMI,2) as BMI, Weight_Description,
	   (FairlyActiveMinutes+VeryActiveMinutes) as Very_and_Fair_Active_Mins
FROM dailyIntensities_merged as i
JOIN weightLogInfo_merged as w 
ON i.Id= w.Id and
  i.ActivityDay = w.Activity_Day
ORDER BY Very_and_Fair_Active_Mins
-- It is interesting to see that there are a lot of users that didn't have a lot of active minutes of activity
-- Moreover, the only user with extreme obesity is one of them

-- Analyzing again the weight against the intensity of the activities, this time grouped and with averages:
SELECT i.Id, ROUND(AVG(w.WeightKg),2) as AVG_Weight, ROUND(AVG(w.BMI),2) as AVG_BMI,
	   AVG(LightlyActiveMinutes+FairlyActiveMinutes+VeryActiveMinutes) as AVG_Active_Mins
FROM dailyIntensities_merged as i
JOIN weightLogInfo_merged as w 
ON i.Id= w.Id and
  i.ActivityDay = w.Activity_Day
GROUP BY i.Id
ORDER BY AVG_Active_Mins
-- This shows us that user 1927972279 is the one with the less active minutes and with the higher weight.

-- Adding this to the table:
ALTER TABLE dailyIntensities_merged
ADD Active_Minutes AS LightlyActiveMinutes+FairlyActiveMinutes+VeryActiveMinutes
SELECT * FROM dailyIntensities_merged

ALTER TABLE dailyIntensities_merged
ADD WeightKg FLOAT
UPDATE dailyIntensities_merged
SET WeightKg = w.WeightKg
FROM dailyIntensities_merged as i
JOIN weightLogInfo_merged as w  
ON i.Id= w.Id and i.ActivityDay = w.Activity_Day

-- In order to see the same as above, but now in just one table and with more information:
SELECT Id, ROUND(AVG(WeightKg),2) as AVG_Weight, ROUND(AVG(Active_Minutes),2) as AVG_Active_Mins
FROM dailyIntensities_merged
WHERE WeightKg IS NOT NULL
GROUP BY Id
ORDER BY AVG_Active_Mins

-- =================================================
-- Using Functions and Stored Procedures (Just as an additional)
-- =================================================
-- The objective will be to analyze the BMI with respect to a specific range of the weight of the users

-- FUNCTION WITH INLINE TABLE VALUES
IF OBJECT_ID('f_weight') IS NOT NULL
	DROP FUNCTION f_weight;
	
CREATE FUNCTION f_weight (@number1 INT = 1 , @number2 INT = 1)
RETURNS TABLE
AS
RETURN (
	SELECT [Id],[Activity_Day], ROUND([WeightKg],2) AS Weight ,ROUND([BMI],2) as BMI FROM [Bellabeat].[dbo].[weightLogInfo_merged]
	WHERE [WeightKg] > @number1 and [WeightKg] < @number2
);

-- Using the above function
SELECT * FROM f_weight(60,80);
-- With this function you can evaluate the range of weight (kg) of users by comparing it with their BMI

-- STORED PROCEDURE
EXEC sp_tables @table_owner = 'dbo'

IF OBJECT_ID('procedure1') IS NOT NULL
	DROP PROCEDURE procedure1;

CREATE PROCEDURE procedure1(@q INT,@r INT)
AS
	SELECT [Id],[Activity_Day],ROUND([WeightKg],2) as Weight, ROUND([BMI],2) as BMI FROM [Bellabeat].[dbo].[weightLogInfo_merged]
	WHERE [WeightKg] > @q and [WeightKg] < @r

-- Executing 'procedure1'
EXEC procedure1 60,80
-- This confirms that you get the same result as the function, but now with a stored proc.


-- =================================================
-- Exporting the Data to Power BI
-- =================================================

-- We enter Power BI Desktop and click Get data -> SQL Server
-- We deactivate and activate in SQL to obtain the server. In this case:
-- Server: LAPTOP-ELSN9JER\SQLEXPRESS, DB: Bellabeat
-- We use DirectQuery in a simple way and add all the tables.
-- Once the tables are loaded, we proceed to create the Id and ActivityDay relationships between tables to design the graphs.

-- Some conclusions observed with the Dashboard and SQL:
-- Almost all the users evaluated maintain a "normal (50.75%)" or "overweight (47.76%)" weight.
-- The day that more calories have been burned has been Tuesday, and Sunday the least..
-- There is a positive relationship between the calories burned and the total steps.
-- Most user activities has been "sedentary."
-- The most sedentary user is also the one with the the least Active Minutes and the biggest weight.
-- Most users have slept normally throughout the evaluation.
-- The day that with more hours Asleep has been Wednesday, and Monday the least.
-- Interestingly, there is a negative correlation between the average Steps of the activity and average hours asleep.