--Check ID Length
SELECT Id, LEN(Id) AS ID_Length
  FROM Bellabeat.dbo.dailyActivity
 WHERE LEN(Id) > 10




SELECT Id, LEN(Id) AS ID_Length
  FROM Bellabeat.dbo.sleepDay
 WHERE LEN(Id) > 10


 -- Identify duplicate rows

SELECT Id, ActivityDate, COUNT(*) AS Count
FROM Bellabeat.dbo.dailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(*)>1



SELECT Id, SleepDay, COUNT(*) AS Count
FROM Bellabeat.dbo.sleepDay
GROUP BY Id, SleepDay
HAVING COUNT(*)>1

-- Delete duplicate rows in Table SleepDay using the row_number() function with CTE

WITH CTE_SleepDay AS 
(SELECT Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed,           
           ROW_NUMBER() OVER (PARTITION BY Id, SleepDay
           ORDER BY Id, SleepDay) AS DuplicateCount
    FROM Bellabeat.dbo.sleepDay
)
SELECT * 
FROM CTE_SleepDay
WHERE DuplicateCount > 1

WITH CTE_SleepDay AS 
(SELECT Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed,           
           ROW_NUMBER() OVER (PARTITION BY Id, SleepDay
           ORDER BY Id, SleepDay) AS DuplicateCount
    FROM Bellabeat.dbo.sleepDay
)
DELETE FROM CTE_SleepDay
WHERE DuplicateCount > 1


SELECT Id, SleepDay, COUNT(*) AS Count
FROM Bellabeat.dbo.sleepDay
GROUP BY Id, SleepDay
HAVING COUNT(*)>1

-- Converting Data Types

SELECT CAST (ActivityDate AS date) AS ActivityDate
FROM Bellabeat.dbo.dailyActivity

Update Bellabeat.dbo.dailyActivity
SET ActivityDate = CAST (ActivityDate AS date)


SELECT CAST (SleepDay AS smalldatetime) AS SleepDay
FROM Bellabeat.dbo.sleepDay

Update Bellabeat.dbo.sleepDay
SET SleepDay = CAST (SleepDay AS smalldatetime)

ALTER TABLE Bellabeat.dbo.sleepDay
Add SleepDayConverted smalldatetime;

Update Bellabeat.dbo.sleepDay
SET SleepDayConverted = CONVERT(smalldatetime,SleepDay)

Select *
From Bellabeat.dbo.sleepDay

/* 
Data Analysis
*/

-- Calculate Total numbers of users

SELECT COUNT (DISTINCT Id)
  FROM Bellabeat.dbo.dailyActivity

-- Average data from all records


SELECT AVG(TotalSteps) AS Average_Steps, ROUND(AVG(TotalDistance), 2) AS Average_Distance,
		AVG(VeryActiveMinutes) AS Average_VeryActiveMinutes, 
		AVG(FairlyActiveMinutes) AS Average_FairlyActiveMinutes, 
		AVG(LightlyActiveMinutes) AS Average_LightlyActiveMinutes,
		AVG(SedentaryMinutes) AS Average_SedentaryMinutes,
		AVG(Calories) AS Average_Calories
 FROM Bellabeat.dbo.dailyActivity

  /*
Avg_Steps		  7637
Avg_Distance 　　　　　 　5.49
Avg_VeryActiveMinutes　　 　21
Avg_FairlyActiveMinutes　　 13
Avg_LightlyActiveMinutes　 192
Avg_SedentaryMinutes	   991    
Avg_Calories　　　　　　  2303
*/

-- Calculate numbers of users who are active more than average

 -- Steps

 SELECT  COUNT(Average_Steps) AS Count
 FROM 
  (SELECT AVG(TotalSteps) AS Average_Steps
   FROM Bellabeat.dbo.dailyActivity
   GROUP BY Id
   HAVING AVG(TotalSteps) > 7637
   ) sub

 -- TotalDistance

 SELECT  COUNT(Average_TotalDistance) AS Count
 FROM 
  (SELECT AVG(TotalDistance) AS Average_TotalDistance
   FROM Bellabeat.dbo.dailyActivity
   GROUP BY Id
   HAVING AVG(TotalDistance) > 5.49
   ) sub

 -- VeryActiveMinutes

 SELECT  COUNT(Average_VeryActiveMinutes) AS Count
 FROM 
  (SELECT AVG(VeryActiveMinutes) AS Average_VeryActiveMinutes
   FROM Bellabeat.dbo.dailyActivity
   GROUP BY Id
   HAVING AVG(VeryActiveMinutes) > 21
   ) sub

-- SedentaryMinutes

 SELECT  COUNT(Average_SedentaryMinutes) AS Count
 FROM 
  (SELECT AVG(SedentaryMinutes) AS Average_SedentaryMinutes
   FROM Bellabeat.dbo.dailyActivity
   GROUP BY Id
   HAVING AVG(SedentaryMinutes) > 991
   ) sub


 SELECT AVG(TotalSteps) AS Average_Steps, ROUND(AVG(TotalDistance), 2) AS Average_Distance,
		AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) AS Average_Minutes, 
		AVG(Calories) AS Average_Calories
 FROM Bellabeat.dbo.dailyActivity

--  Using subsequery to find the users who have average steps over 9,000

SELECT Id, Average_steps, Average_distance, Average_Calories
 FROM ( 
SELECT Id, AVG(TotalSteps) AS Average_steps, AVG(TotalDistance) AS Average_distance, AVG(VeryActiveDistance) AS Average_VeryActiveDistance,
       AVG(ModeratelyActiveDistance) AS Average_ModeratelyActiveDistance, AVG(LightActiveDistance) AS Average_LightActiveDistance, 
	   AVG(SedentaryActiveDistance) AS Average_SedentaryActiveDistance, AVG(VeryActiveMinutes) AS Average_VeryActiveMinutes, 
	   AVG(FairlyActiveMinutes) AS Average_FairlyActiveMinutes, AVG(LightlyActiveMinutes) AS Average_LightlyActiveMinutes,　
	   AVG(SedentaryMinutes) AS Average_SedentaryMinutes, AVG(Calories) AS Average_Calories
  FROM Bellabeat.dbo.dailyActivity
 GROUP BY Id
  ) sub

 WHERE Average_steps > 9000 
 ORDER BY Average_steps desc

  

 
 -- Top 10 users in total steps

SELECT TOP 10 Id,  SUM(TotalSteps) AS TotalStep, SUM(TotalDistance) AS Total_Distance
FROM Bellabeat.dbo.dailyActivity
GROUP BY Id
ORDER BY 2 DESC 

-- Combine two tables to understand the relationship

 SELECT Activity.Id, AVG(Activity.TotalSteps) AS Average_Steps, AVG(Activity.TotalDistance) AS Average_Distance, 
		AVG((Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes + Activity.LightlyActiveMinutes + Activity.SedentaryMinutes)/4) AS Average_Minutes, 
		AVG(Activity.Calories) AS Average_Calories, AVG(sleepDay.TotalMinutesAsleep) AS Average_Asleep　　
  FROM Bellabeat.dbo.dailyActivity Activity
  JOIN Bellabeat.dbo.sleepDay sleepDay
    ON Activity.Id = sleepDay.Id
 GROUP BY Activity.Id
 ORDER BY 2　DESC

  -- Combine two tables to understand the relationship between active minutes and sleep time

 SELECT Activity.Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		AVG(sleepDay.TotalMinutesAsleep) AS Average_TotalMinutesAsleep
  FROM Bellabeat.dbo.dailyActivity Activity
  JOIN Bellabeat.dbo.sleepDay sleepDay
    ON Activity.Id = sleepDay.Id
 GROUP BY Activity.Id
 ORDER BY 2　DESC

 

 -- Using CASE statement to determine activity type

 SELECT Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		CASE WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 60 THEN 'High Activity'
			 WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 30 THEN 'Median Activity'
			 ELSE 'Low activity' END AS Type

  FROM Bellabeat.dbo.dailyActivity Activity
  
 GROUP BY Id
 ORDER BY 2 DESC　

 -- Count the number of users for each activity type

 WITH CTE_Activiy AS (
  SELECT Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		CASE WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 60 THEN 'High Activity'
			 WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 30 THEN 'Median Activity'
			 ELSE 'Low activity' END AS Type

		
  FROM Bellabeat.dbo.dailyActivity Activity
  
 GROUP BY Id
)

 SELECT Type, COUNT(*) AS Count
 FROM CTE_Activiy
 GROUP BY Type
 ORDER BY 2