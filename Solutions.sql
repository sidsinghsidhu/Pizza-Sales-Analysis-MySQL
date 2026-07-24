-- 1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS 'Total Orders' 
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(pizzas.price * order_details.quantity), 2) AS 'Total Sales'
FROM pizzas 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id;

-- 3. Identify the highest priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS 'Number of Orders'
FROM pizzas 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY 'Number of Orders' DESC 
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC 
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS 'Total Quantity Ordered'
FROM pizza_types AS pt 
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY `Total Quantity Ordered` DESC;

-- 7. Determine the distribution of the orders by hours of the day.
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY hour;

-- 8. Join the relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0) AS 'Average Pizza Per Day' 
FROM (
    SELECT orders.order_date, SUM(order_details.quantity) AS quantity
    FROM orders 
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_totals;

-- 10. Determine the top 3 most ordered pizzas based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types AS pt 
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC 
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (
        SELECT SUM(od.quantity * p.price)
        FROM order_details AS od
        JOIN pizzas AS p ON od.pizza_id = p.pizza_id
    ) * 100, 1) AS percentage
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;

-- 12. Analyse the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH RankedSales AS (
    SELECT 
        pt.category, 
        pt.name, 
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) as ranking
    FROM pizza_types AS pt
    JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
)
SELECT 
    category, 
    name, 
    revenue
FROM RankedSales
WHERE ranking <= 3;