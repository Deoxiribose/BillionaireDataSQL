--Test Run as Always
Select * 
From Project3..BillList

--Note this Project contains 350k+ of rows with data!

--Make an average of all annual income
SELECT ROUND(AVG(annual_income), 2) as AverageAnnual
FROM BillList;


--Lets Specifify it and make it only for 2022
SELECT ROUND(AVG(annual_income), 2)as AverageAnnual
FROM BillList
WHERE time = 2022;

--What about or each billionaire?
SELECT name, ROUND(AVG(annual_income), 2)as AverageAnnual
FROM BillList
WHERE time = 2022
GROUP BY name;

--Lets order it high to low
SELECT name, ROUND(AVG(annual_income), 2) as AverageAnnual
FROM BillList
WHERE time = 2022
GROUP BY name
ORDER BY AverageAnnual DESC;

--Lets do something a little more complex, we will look at the 2022 and 2021 values and take the diff while listing from low to high
SELECT name, 
       ROUND(AVG(CASE WHEN time = 2022 THEN annual_income END), 2) as avg_income_2022, 
       ROUND(AVG(CASE WHEN time = 2022 THEN annual_income END), 2) - 
       ROUND(AVG(CASE WHEN time = 2021 THEN annual_income END), 2) as gain_or_loss
FROM BillList
WHERE time in (2021, 2022)
GROUP BY name
ORDER BY gain_or_loss DESC;

--With function is used in combination of join fuction to make columns for avg income 
--Also the Percentage difference of industry vs overall avg income is calculated as pct difference
--Also I make everyhting round to two decimal places to make the data easier to read

WITH avg_income AS (
    SELECT AVG(annual_income) as overall_avg_income
    FROM BillList
), industry_income AS (
    SELECT main_industry, ROUND(AVG(annual_income), 2) as avg_income
    FROM BillList
    GROUP BY main_industry
)
SELECT industry_income.main_industry, industry_income.avg_income, 
       ROUND((industry_income.avg_income / avg_income.overall_avg_income - 1) * 100, 2) as pct_difference
FROM industry_income
JOIN avg_income ON 1 = 1
ORDER BY pct_difference DESC;

--Comparing Billionaires' Industry Income with Pct Change.
WITH avg_income AS (
    SELECT AVG(annual_income) as overall_avg_income
    FROM BillList
), industry_income AS (
    SELECT main_industry, ROUND(AVG(annual_income), 2) as avg_income
    FROM BillList
    WHERE time = 2022
    GROUP BY main_industry
), pct_change AS (
    SELECT main_industry, 
           ROUND((avg_income - overall_avg_income) / overall_avg_income * 100, 2) as pct_difference
    FROM industry_income
    JOIN avg_income ON 1 = 1
)
SELECT DISTINCT b.name, b.last_name, b.main_industry, pct_change.pct_difference
FROM BillList b
JOIN pct_change ON b.main_industry = pct_change.main_industry
WHERE b.time = 2022
ORDER BY pct_difference DESC;













