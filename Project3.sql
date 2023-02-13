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

--Here are a couple examples if R is needed to plot the data

# visualize the inequality gap between the wealthiest and poorest individuals (bash)

# Load the required libraries
library(tidyverse)

# Read the data into R
data <- read.csv("BillList.csv")

# Calculate the minimum and maximum annual income values
min_income <- min(data$annual_income)
max_income <- max(data$annual_income)

# Calculate the inequality gap
gap <- (max_income - min_income) / min_income

# Create the graph
ggplot(data, aes(x = 1, y = annual_income)) +
  geom_bar(stat = "identity", width = 0.5, fill = "blue") +
  geom_hline(yintercept = min_income + gap * min_income, 
             color = "red", linetype = "dotted") +
  labs(x = "", y = "Annual Income") +
  ggtitle(paste("Inequality Gap: ", round(gap * 100, 2), "%"))


#2022 Wealth Gap Visualization by Source of Income (scss)

library(ggplot2)
library(dplyr)

# Load the data into R
data <- read.csv("BillList.csv")

# Filter data to only include 2022 data
data_2022 <- filter(data, time == 2022)

# Group data by source of wealth and calculate mean annual income for each group
grouped_data <- data_2022 %>%
  group_by(source_of_wealth) %>%
  summarize(mean_annual_income = mean(annual_income, na.rm = TRUE))

# Plot the data using ggplot2
ggplot(grouped_data, aes(x = source_of_wealth, y = mean_annual_income)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(x = "Source of Wealth", y = "Mean Annual Income") +
  ggtitle("Income Gap between Wealthiest and Poorest Individuals in 2022")










