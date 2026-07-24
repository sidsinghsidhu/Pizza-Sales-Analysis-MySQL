# Pizza Sales SQL Analysis
## Project Overview
This project involves analyzing the sales data of a pizza restaurant using MySQL. The objective was to extract actionable insights regarding customer ordering patterns, revenue generation, and popular pizza categories to help optimize inventory and boost sales.

## Database Structure
The database consists of four main tables. The raw data for these tables can be found in the uploaded .csv files:

pizzas: Contains pizza IDs, types, sizes, and prices.

pizza_types: Contains pizza categories and names.

orders: Contains order IDs, dates, and times.

order_details: Contains specific quantities of pizzas ordered per order ID.

(Note: The SQL commands used to create the tables that were not imported directly via wizard can be found in the schema.sql file).

## Key Insights & Complex Queries
I solved 13 specific business questions using SQL. Below are a few highlights showcasing advanced SQL techniques:

### 1. Cumulative Revenue Over Time (Window Function)
Used to track how revenue grew sequentially day by day.

SQL
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;
### 2. Top 3 Pizzas by Revenue Per Category (CTEs & Ranking)  
Calculated the highest-grossing pizzas within each specific category 

SQL
WITH RankedSales AS (
    SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue,
    RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) as ranking
    FROM pizza_types AS pt
    JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
)
SELECT category, name, revenue
FROM RankedSales
WHERE ranking <= 3;
## Skills Demonstrated
Joins: INNER JOIN to connect multiple tables.

Aggregations: SUM(), COUNT(), AVG(), ROUND().

Window Functions: RANK(), SUM() OVER().

Subqueries & CTEs: Breaking down complex problems into temporary result sets.

Date/Time Functions: HOUR() to analyze peak order times.

## Full Code
All 13 queries and their solutions can be found in the solutions.sql file.
