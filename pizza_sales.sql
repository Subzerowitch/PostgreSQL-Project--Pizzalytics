/* Import raw csv. */

CREATE DATABASE pizza_sales_db;

\c pizza_sales_db

CREATE TABLE pizza_data_raw (pizza_id DECIMAL,
order_id DECIMAL,
pizza_name_id VARCHAR(50),
quantity DECIMAL,
order_date DATE,
order_time TIME,
unit_price DECIMAL,
total_price DECIMAL,
pizza_size VARCHAR(3),
pizza_category VARCHAR(50),
pizza_ingredients VARCHAR(400),
pizza_name VARCHAR(300)
) ;

SET DateStyle = 'ISO, DMY';

COPY pizza_data_raw FROM  '/Users/imac/Downloads/pizza_sales.csv' DELIMITER ',' CSV HEADER;

/* Check imported data. */
SELECT * FROM pizza_data_raw LIMIT 40;

/* Divide raw data into 2 tables. */
CREATE TABLE Sales (pizza_id DECIMAL,
order_id DECIMAL,
quantity DECIMAL,
order_date DATE,
order_time TIME,
total_price DECIMAL,
PRIMARY KEY (pizza_id, order_id)
);

CREATE TABLE PizzaDetails (pizza_id DECIMAL PRIMARY KEY,
pizza_name_id VARCHAR(90),
pizza_size VARCHAR(3),
pizza_category VARCHAR(60),
pizza_ingredients TEXT,
pizza_name VARCHAR(400)
);

ALTER TABLE Sales
ADD CONSTRAINT fk_pizza
FOREIGN KEY (pizza_id)
REFERENCES PizzaDetails(pizza_id);


INSERT INTO PizzaDetails (pizza_id,
pizza_name_id,
pizza_size,
pizza_category,
pizza_ingredients,
pizza_name)
SELECT pizza_id, pizza_name_id, pizza_size, pizza_category, pizza_ingredients, pizza_name
FROM temp_table;


INSERT INTO Sales (pizza_id,
order_id,
quantity,
order_date,
order_time,
total_price)
SELECT pizza_id, order_id, quantity, order_date, order_time, total_price
FROM temp_table;


/* Normalization. Create PizzaCategory table with category_id as primary key and add foreign key to PizzaDetails. Add column category_id from PizzaCategory to PizzaDetails and drop pizza_category column. */

CREATE TABLE PizzaCategory (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(60) UNIQUE
);

INSERT INTO PizzaCategory (category_name)
SELECT DISTINCT TRIM(LOWER(pizza_category))
FROM PizzaDetails
ON CONFLICT (category_name) DO NOTHING;

ALTER TABLE PizzaDetails ADD COLUMN category_id INT;

UPDATE PizzaDetails
SET category_id = pc.category_id
FROM PizzaCategory pc
WHERE TRIM(LOWER(PizzaDetails.pizza_category)) = pc.category_name;

ALTER TABLE PizzaDetails
ADD CONSTRAINT fk_pizza_category
FOREIGN KEY (category_id)
REFERENCES PizzaCategory(category_id);


 ALTER TABLE PizzaDetails DROP COLUMN pizza_category;

/* Normalization. Create Ingredients table with filling_id as primary key and add foreign key to PizzaDetails table. Add column filling_id from Ingredients to PizzaDetails and drop pizza_ingredients column. */

CREATE TABLE Ingredients (filling_id SERIAL PRIMARY KEY, pizza_ingredients TEXT, pizza_name VARCHAR(300), UNIQUE (pizza_ingredients, pizza_name) );

 INSERT INTO Ingredients (pizza_ingredients, pizza_name) SELECT DISTINCT pizza_ingredients, pizza_name FROM PizzaDetails ON CONFLICT (pizza_ingredients, pizza_name) DO NOTHING;

ALTER TABLE PizzaDetails ADD COLUMN filling_id INT;

 UPDATE PizzaDetails SET filling_id = i.filling_id FROM Ingredients i WHERE PizzaDetails.pizza_ingredients = i.pizza_ingredients AND PizzaDetails.pizza_name = i.pizza_name;

ALTER TABLE PizzaDetails DROP COLUMN pizza_ingredients;

/* Add 'weekday' column to Sales table. */
ALTER TABLE Sales ADD COLUMN weekday VARCHAR (10);

UPDATE Sales
SET weekday = to_char(order_Date, 'Day');


/*Create a view: group records by order_id, order_date, order_time, weekday. Add columns with total_pizzas_ordered (number of pizzas in 1 order) and total_bill for each order. */
CREATE VIEW grouped_orders AS
SELECT order_id,
order_date, order_time,
weekday, COUNT(quantity) AS total_pizzas_ordered,
SUM(total_price) AS total_bill
FROM Sales
GROUP BY order_id, order_date, order_time, weekday
ORDER BY order_id;

/* Create a view: daily_total. */
CREATE VIEW daily_total AS
SELECT EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
EXTRACT(DAY FROM order_date) AS day,
weekday,
SUM(total_bill) AS month_total
FROM grouped_orders GROUP BY 1,2,3,4 ORDER BY 1,2,3 ;

/* Create a view: month_total. */  CREATE VIEW month_total AS
SELECT EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
SUM(total_bill) AS month_total
FROM grouped_orders
GROUP BY 1,2
ORDER BY 1,2 ;



/*QUERYING THE DATA. Month with highest sales. */
SELECT * FROM month_total ORDER BY month_total DESC LIMIT 5;


/* Weekday with highest average sales. */  SELECT weekday,
ROUND(AVG(month_total),2) AS average_by_weekday
FROM daily_total
GROUP BY weekday
ORDER BY average_by_weekday DESC;


/*  Divide dataset into 3 tables: morning, midday, and evening shifts .*/
SELECT MIN(order_time) FROM Sales;
SELECT MAX(order_time) FROM Sales;


CREATE TABLE morning_shift (pizza_id DECIMAL, order_id DECIMAL, quantity DECIMAL, order_date DATE, order_time TIME, unit_price DECIMAL);

INSERT INTO morning_shift (pizza_id, order_id, quantity, order_date, order_time, unit_price)
SELECT pizza_id, order_id, quantity, order_date, order_time, unit_price
FROM pizza_data_raw
WHERE order_time BETWEEN '09:52:21' AND '14:00:00';

CREATE TABLE midday_shift (pizza_id DECIMAL, order_id DECIMAL, quantity DECIMAL, order_date DATE, order_time TIME, unit_price DECIMAL);

INSERT INTO midday_shift (pizza_id, order_id, quantity, order_date, order_time, unit_price)
SELECT pizza_id, order_id, quantity, order_date, order_time, unit_price
FROM pizza_data_raw
WHERE order_time BETWEEN '14:00:00' AND '18:00:00';

CREATE TABLE evening_shift (pizza_id DECIMAL, order_id DECIMAL, quantity DECIMAL, order_date DATE, order_time TIME, unit_price DECIMAL);

INSERT INTO evening_shift (pizza_id, order_id, quantity, order_date, order_time, unit_price)
SELECT pizza_id, order_id, quantity, order_date, order_time, unit_price
FROM pizza_data_raw
WHERE order_time BETWEEN '18:00:00' AND '23:59:59';


/* Running total of count of each pizza_category. */  SELECT
    pizza_id,
    order_id,
    order_date,
    order_time,
    pizza_category,
    COUNT(pizza_category) OVER (PARTITION BY pizza_category ORDER BY order_date, order_time) AS running_total_count
FROM
    pizza_data_raw;


/* Top 3 pizzas sold in each category. */
WITH RankedSales AS (
    SELECT
        pizza_category,
        pizza_name,
        COUNT(*) AS number_of_sales,
        RANK() OVER (PARTITION BY pizza_category ORDER BY COUNT(*) DESC) as sales_rank
    FROM
        pizza_data_raw
    GROUP BY
        pizza_category,
        pizza_name
)
SELECT
    pizza_category,
    pizza_name,
    number_of_sales,
    sales_rank
FROM
    RankedSales
WHERE
    sales_rank <= 3
ORDER BY
    pizza_category,
    sales_rank;

/* Pizzas without onions and garlic. */
SELECT pizza_name
FROM PizzaDetails
WHERE pizza_ingredients NOT IN ('Onions', 'Red Onions', 'Garlic')
GROUP BY pizza_name;

/* Unique Pizza names in assortment of the restaurant. */
SELECT DISTINCT pizza_name FROM PizzaDetails;

/*Pizza names ordered more than 2k times during all period. */
SELECT pizza_name,
COUNT(*) FROM PizzaDetails
GROUP BY pizza_name
HAVING COUNT(*) > 2000;

/* Count pizzas ordered with cheese. */
SELECT pizza_name, pizza_ingredients,  COUNT(*) AS ordered
FROM PizzaDetails
WHERE pizza_ingredients LIKE '%Cheese%'
GROUP BY pizza_name, pizza_ingredients
ORDER BY ordered DESC;
