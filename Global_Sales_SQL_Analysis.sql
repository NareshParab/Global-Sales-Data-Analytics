CREATE DATABASE sales_analytics;
USE sales_analytics;
SELECT DATABASE();
SHOW DATABASES;
USE sales_analytics;
SHOW TABLES;
SELECT COUNT(*) AS Total_Rows
FROM global_sales_cleaned;
SELECT *
FROM global_sales_cleaned
LIMIT 10;
DESCRIBE global_sales_cleaned;
SELECT ORDERDATE
FROM global_sales_cleaned
LIMIT 10;
ALTER TABLE global_sales_cleaned
MODIFY COLUMN ORDERDATE DATE;
DESCRIBE global_sales_cleaned;
SELECT
    ROUND(SUM(SALES), 2) AS Total_Revenue,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders,
    COUNT(DISTINCT CUSTOMERNAME) AS Total_Customers,
    COUNT(DISTINCT PRODUCTCODE) AS Total_Products,
    ROUND(AVG(SALES), 2) AS Average_Order_Value
FROM global_sales_cleaned;
SELECT
    ROUND(SUM(SALES), 2) AS Total_Revenue,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders,
    COUNT(DISTINCT CUSTOMERNAME) AS Total_Customers,
    COUNT(DISTINCT PRODUCTCODE) AS Total_Products,
    ROUND(AVG(SALES), 2) AS Average_Order_Value
FROM global_sales_cleaned;
SELECT
    ROUND(SUM(SALES) / COUNT(DISTINCT ORDERNUMBER), 2) AS Average_Order_Value
FROM global_sales_cleaned;
-- =====================================================
-- Business Question 1
-- What is the overall business performance?
-- =====================================================

SELECT
    ROUND(SUM(SALES), 2) AS Total_Revenue,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders,
    COUNT(DISTINCT CUSTOMERNAME) AS Total_Customers,
    COUNT(DISTINCT PRODUCTCODE) AS Total_Products
FROM global_sales_cleaned;

-- =====================================================
-- Business Question 2
-- What is the Average Order Value?
-- =====================================================

SELECT
    ROUND(SUM(SALES) / COUNT(DISTINCT ORDERNUMBER), 2) AS Average_Order_Value
FROM global_sales_cleaned;

-- Business Question 3
-- How did total revenue change year by year?
SELECT
    YEAR,
    ROUND(SUM(SALES), 2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY YEAR
ORDER BY YEAR;

-- 
SELECT
    YEAR,
    MONTH_NUMBER,
    MONTH_NAME,
    ROUND(SUM(SALES), 2) AS Monthly_Revenue
FROM global_sales_cleaned
GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME
ORDER BY YEAR, MONTH_NUMBER;
-- Which Quarter Generates the Highest Revenue?
SELECT
    YEAR,
    QUARTER,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY YEAR, QUARTER
ORDER BY YEAR, QUARTER;
-- Which Month Performs Best Across All Years?
SELECT
    MONTH_NUMBER,
    MONTH_NAME,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY MONTH_NUMBER, MONTH_NAME
ORDER BY Total_Revenue DESC;
-- Which Day of the Week Generates the Most Revenue?
SELECT
    DAY_NAME,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY DAY_NAME
ORDER BY Total_Revenue DESC;
-- Which months had the highest number of orders?
SELECT
    MONTH_NUMBER,
    MONTH_NAME,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY MONTH_NUMBER, MONTH_NAME
ORDER BY Total_Orders DESC;
-- Which quarter received the most orders?
SELECT
    YEAR,
    QUARTER,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY YEAR, QUARTER
ORDER BY YEAR, QUARTER;
-- Product Line Performance
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY PRODUCTLINE
ORDER BY Total_Revenue DESC;
-- Top 10 Products
SELECT
    PRODUCTCODE,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY PRODUCTCODE
ORDER BY Total_Revenue DESC
LIMIT 10;
-- Bottom 10 Products
SELECT
    PRODUCTCODE,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY PRODUCTCODE
ORDER BY Total_Revenue ASC
LIMIT 10;
-- Which Product Line generates the highest revenue?
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY PRODUCTLINE
ORDER BY Total_Revenue DESC;
-- What percentage of total revenue does each Product Line contribute?
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS Total_Revenue,
    ROUND(
        (SUM(SALES) /
        (SELECT SUM(SALES) FROM global_sales_cleaned))*100,
        2
    ) AS Revenue_Percentage
FROM global_sales_cleaned
GROUP BY PRODUCTLINE
ORDER BY Total_Revenue DESC;
-- Which Product Line receives the highest number of orders?
SELECT
    PRODUCTLINE,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY PRODUCTLINE
ORDER BY Total_Orders DESC;
-- Who are the Top 10 Customers by Revenue?
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES), 2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY CUSTOMERNAME
ORDER BY Total_Revenue DESC
LIMIT 10;
-- Which customers place the most orders?
SELECT
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY CUSTOMERNAME
ORDER BY Total_Orders DESC
LIMIT 10;
-- Which countries generate the highest revenue?
SELECT
    COUNTRY,
    ROUND(SUM(SALES), 2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY COUNTRY
ORDER BY Total_Revenue DESC;
-- Who are the Top 10 Customers by Revenue? (using a CTE)
WITH CustomerRevenue AS
(
    SELECT
        CUSTOMERNAME,
        ROUND(SUM(SALES),2) AS Total_Revenue
    FROM global_sales_cleaned
    GROUP BY CUSTOMERNAME
)

SELECT *
FROM CustomerRevenue
ORDER BY Total_Revenue DESC
LIMIT 10;
-- Rank Product Lines by revenue
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS Total_Revenue,
    DENSE_RANK() OVER(
        ORDER BY SUM(SALES) DESC
    ) AS Product_Rank
FROM global_sales_cleaned
GROUP BY PRODUCTLINE;
-- Find the Top 3 Products within each Product Line
WITH ProductSales AS (
    SELECT
        PRODUCTLINE,
        PRODUCTCODE,
        ROUND(SUM(SALES),2) AS Total_Revenue,
        ROW_NUMBER() OVER(
            PARTITION BY PRODUCTLINE
            ORDER BY SUM(SALES) DESC
        ) AS Row_Num
    FROM global_sales_cleaned
    GROUP BY PRODUCTLINE, PRODUCTCODE
)

SELECT *
FROM ProductSales
WHERE Row_Num <= 3
ORDER BY PRODUCTLINE, Row_Num;
-- How does revenue accumulate month by month?
SELECT
    YEAR,
    MONTH_NUMBER,
    MONTH_NAME,
    ROUND(SUM(SALES),2) AS Monthly_Revenue,
    ROUND(
        SUM(SUM(SALES)) OVER(
            ORDER BY YEAR, MONTH_NUMBER
        ),
        2
    ) AS Running_Total
FROM global_sales_cleaned
GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME
ORDER BY YEAR, MONTH_NUMBER;
-- Geographic Analysis
-- Top 10 Cities by Revenue
SELECT
    CITY,
    COUNTRY,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY CITY, COUNTRY
ORDER BY Total_Revenue DESC
LIMIT 10;
-- Revenue by Territory
SELECT
    TERRITORY,
    ROUND(SUM(SALES),2) AS Total_Revenue
FROM global_sales_cleaned
GROUP BY TERRITORY
ORDER BY Total_Revenue DESC;
-- Average Order Value by Country
SELECT
    COUNTRY,
    ROUND(SUM(SALES)/COUNT(DISTINCT ORDERNUMBER),2) AS Avg_Order_Value
FROM global_sales_cleaned
GROUP BY COUNTRY
ORDER BY Avg_Order_Value DESC;
-- Top Countries by Customer Count
SELECT
    COUNTRY,
    COUNT(DISTINCT CUSTOMERNAME) AS Total_Customers
FROM global_sales_cleaned
GROUP BY COUNTRY
ORDER BY Total_Customers DESC
LIMIT 5;
-- Customer Segmentation
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),2) AS Lifetime_Revenue,

    CASE
        WHEN SUM(SALES) >= 100000 THEN 'Gold'
        WHEN SUM(SALES) >= 50000 THEN 'Silver'
        ELSE 'Bronze'
    END AS Customer_Category

FROM global_sales_cleaned
GROUP BY CUSTOMERNAME
ORDER BY Lifetime_Revenue DESC;
-- Repeat Customers
SELECT
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY CUSTOMERNAME
HAVING COUNT(DISTINCT ORDERNUMBER) > 1
ORDER BY Total_Orders DESC;
-- One-Time Customers
SELECT
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS Total_Orders
FROM global_sales_cleaned
GROUP BY CUSTOMERNAME
HAVING COUNT(DISTINCT ORDERNUMBER) = 1;

-- Monthly Revenue with Previous Month Revenue
SELECT
    YEAR,
    MONTH_NUMBER,
    MONTH_NAME,
    ROUND(SUM(SALES),2) AS Monthly_Revenue,

    LAG(ROUND(SUM(SALES),2))
    OVER(
        ORDER BY YEAR, MONTH_NUMBER
    ) AS Previous_Month_Revenue

FROM global_sales_cleaned
GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME
ORDER BY YEAR, MONTH_NUMBER; 

-- Month over Month Growth %
WITH MonthlySales AS
(
    SELECT
        YEAR,
        MONTH_NUMBER,
        MONTH_NAME,
        ROUND(SUM(SALES),2) AS Monthly_Revenue
    FROM global_sales_cleaned
    GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME
)

SELECT
    *,
    ROUND(
        (
            Monthly_Revenue -
            LAG(Monthly_Revenue)
            OVER(ORDER BY YEAR, MONTH_NUMBER)
        )
        /
        LAG(Monthly_Revenue)
        OVER(ORDER BY YEAR, MONTH_NUMBER)
        *100,
        2
    ) AS Growth_Percentage

FROM MonthlySales;
WITH MonthlySales AS
(
    SELECT
        YEAR,
        MONTH_NUMBER,
        MONTH_NAME,
        ROUND(SUM(SALES),2) AS Monthly_Revenue
    FROM global_sales_cleaned
    GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME
),

GrowthData AS
(
    SELECT
        *,
        ROUND(
            (
                Monthly_Revenue -
                LAG(Monthly_Revenue)
                OVER(ORDER BY YEAR, MONTH_NUMBER)
            )
            /
            LAG(Monthly_Revenue)
            OVER(ORDER BY YEAR, MONTH_NUMBER)
            *100,
            2
        ) AS Growth_Percentage
    FROM MonthlySales
)

SELECT *
FROM GrowthData
ORDER BY Growth_Percentage DESC;

CREATE VIEW vw_monthly_sales AS
SELECT
    YEAR,
    MONTH_NUMBER,
    MONTH_NAME,
    ROUND(SUM(SALES),2) AS Monthly_Revenue

FROM global_sales_cleaned
GROUP BY YEAR, MONTH_NUMBER, MONTH_NAME;

CREATE VIEW vw_customer_sales AS
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),2) AS Revenue

FROM global_sales_cleaned
GROUP BY CUSTOMERNAME;

CREATE VIEW vw_country_sales AS
SELECT
    COUNTRY,
    ROUND(SUM(SALES),2) AS Revenue
FROM global_sales_cleaned
GROUP BY COUNTRY;

ALTER TABLE global_sales_cleaned
MODIFY COUNTRY VARCHAR(100);