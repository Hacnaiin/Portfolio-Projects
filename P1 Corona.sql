
-- Corona Virus Analysis. Dataset Credit goes to Mentorness

-- Create a Database
create database corona

-- Check out the contents of our dataset
select * 
from details

-- Rename 2nd column [Country/Region] to Country
exec sp_rename 'details.[Country/Region]' , 'Country' , 'COLUMN'

-- Rename Taiwan* to Taiwan
update 
	details
set 
	Country = 'Taiwan'
where 
	Country = 'Taiwan*'

-- Q1: Write a code to check NULL values
select 
	* 
from 
	details
where
	Province is null or
	Country is null or
	Latitude is null or 
	Longitude is null or
	Date is null or
	Confirmed is null or
	Deaths is null or
	Recovered is null

-- Q2: If NULL values are present, update them with zeros for all columns.
update 
	details
set
	Province = coalesce(Province, 0),
	Country = coalesce(Country,0),
	Latitude = coalesce(Latitude,0),
	Longitude = coalesce(Longitude,0),
	Date = coalesce(Date,0),
	Confirmed = coalesce(Confirmed,0),
	Deaths = coalesce(Deaths,0),
	Recovered = coalesce(Recovered,0)
where
	Province is null or
	Country is null or
	Latitude is null or 
	Longitude is null or
	Date is null or
	Confirmed is null or
	Deaths is null or
	Recovered is null

-- Q3: check total number of rows
select 
	count(*) as Total_Rows
from 
	details

-- Q4: Check what is start_date and end_date
select 
	MIN(Date) as Start_Date, 
	MAX(Date) as End_Date
from 
	details

-- Q5: Number of month present in dataset
select
	COUNT(distinct convert(varchar(7), date, 120)) as Total_Months
from
	details

-- Q6: Find monthly average for confirmed, deaths, recovered
select 
	YEAR(TRY_CONVERT(date, Date, 103)) as Year,
	MONTH(TRY_CONVERT(date, Date, 103)) as Month,
	AVG(Confirmed) as Avg_Confirmed,
	AVG(Deaths) as Avg_Deaths,
	AVG(Recovered) as Avg_Recovered
from
	details
group by 
	YEAR(TRY_CONVERT(date, Date, 103)) , MONTH(TRY_CONVERT(date, Date, 103))
order by 
	Year, Month

-- Q7: Find most frequent value for confirmed, deaths, recovered each month
with 
	MonthlyStats as(
select
	YEAR(TRY_CONVERT(date, Date, 103)) as Year,
	MONTH(TRY_CONVERT(date, Date, 103)) as Month,
	Confirmed, Deaths, Recovered,
	ROW_NUMBER() over(partition by YEAR(TRY_CONVERT(date, Date, 103)), 
	MONTH(TRY_CONVERT(date, Date, 103)) order by count(*) desc) as Row_Num
from 
	details
group by 
	YEAR(TRY_CONVERT(date, Date, 103)), 
	MONTH(TRY_CONVERT(date, Date, 103)),
	Confirmed, Deaths, Recovered
)
select
	Year, Month, 
	Confirmed as Most_Frequent_Confirmed,
	Deaths as Most_Frequent_Deaths,
	Recovered as Most_Frequent_Recovered
from
	MonthlyStats
where 
	Row_Num=1

-- Q8: Find minimum values for confirmed, deaths, recovered per year
select
	YEAR(TRY_CONVERT(date, Date, 103)) as Year,
	MIN(Confirmed) as Min_Confirmed,
	MIN(Deaths) as Min_Deaths,
	MIN(Recovered) as Min_Recovered
from 
	details
where 
	Confirmed<>0 and Deaths<>0 and Recovered<>0
group by
	YEAR(TRY_CONVERT(date, Date, 103))
order by
	Year

-- Q9: Find maximum values of confirmed, deaths, recovered per year
select
	YEAR(TRY_CONVERT(date, Date, 103)) as Year,
	max(Confirmed) as Max_Confirmed,
	max(Deaths) as Max_Deaths,
	max(Recovered) as Max_Recovered
from 
	details
group by 
	YEAR(TRY_CONVERT(date, Date, 103))
order by 
	Year

-- Q10: The total number of case of confirmed, deaths, recovered each month
select
	YEAR(TRY_CONVERT(date, Date, 103)) as Year,
	MONTH(TRY_CONVERT(date, Date, 103)) as Month,
	SUM(Confirmed) as Total_Confirmed,
	SUM(Deaths) as Total_Deaths,
	SUM(Recovered) as Total_Recovered
from
	details
group by 
	YEAR(TRY_CONVERT(date, Date, 103)) , MONTH(TRY_CONVERT(date, Date, 103))
order by 
	1, 2

-- Q11:  Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV)
select 
	Country,
	YEAR(TRY_CONVERT(date, Date, 103)) Year,
	SUM(Confirmed) as Total_Confirmed_Cases,
	AVG(Confirmed) as Average_Confirmed_Cases,
	STDEV(Confirmed) as STD_Confirmed_Cases
from 
	details
group by 
	Country, YEAR(TRY_CONVERT(date, Date, 103))
order by 
	1, 2

-- Q12: Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
select
	Country,
	MONTH(TRY_CONVERT(date, Date, 103)) Month,
	SUM(Deaths) as Total_Deaths_Cases,
	AVG(Deaths) as Average_Deaths_Cases,
	STDEV(Deaths) as STD_Deaths_Cases
from
	details
group by 
	Country, MONTH(TRY_CONVERT(date, Date, 103))
order by 
	1, 2

-- Q13: Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
select
	Country,
	YEAR(TRY_CONVERT(date, Date, 103)) Year,
	SUM(Recovered) as Total_Recovered_Cases,
	AVG(Recovered) as Average_Recovered_Cases,
	STDEV(Recovered) as STD_Recovered_Cases
from 
	details
group by 
	Country, YEAR(TRY_CONVERT(date, Date, 103))
order by 
	1, 2

-- Q14: Find Country having highest number of the Confirmed case
select 
top 1
	Country,
	MAX(Confirmed) as Highest_Confirmed_Cases
from 
	details
group by 
	Country
order by 
	Highest_Confirmed_Cases desc

-- Q15: Find Country having lowest number of the death case
select 
top 1
	Country,
	MIN(Confirmed) as Lowest_Confirmed_Cases
from
	details
where 
	Confirmed<>0
group by 
	Country
order by 
	Country , Lowest_Confirmed_Cases

-- Q16: Find top 5 countries having highest recovered case
select 
top 5
	Country,
	MAX(Recovered) as Highest_Recovered_Cases
from
	details
group by 
	Country
order by 
	Highest_Recovered_Cases desc

-- Finally, let's combine the Latitude & Longitude column to make a spatial measure
alter table 
	details
add 
	Coordinates geography

update 
	details
set 
	Coordinates = geography::Point(Latitude, Longitude, 4326)

---------------- THE END ----------------