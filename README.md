# PostgreSQL Project, Pizzalytics


# Pizza Sales Database Management
This repository contains SQL scripts for managing a pizza sales database, including data importing, normalization, querying, and analysis.

Dataset source: https://www.kaggle.com/datasets/shilongzhuang/pizza-sales


# Tableau Dashboard Content

Dashboard in Tableau: https://public.tableau.com/app/profile/olena.rubanenko/viz/PizzaSalesAnalysis_17103186745850/Pizzalytics#1

- Running Total
- Month-over-Month % difference
- Price Frequency
- Size Frequency
- Boxplot of quantity sold
- Pizza Name ranking
- Peak hours

# Introduction
The pizza sales database consists of raw data related to pizza orders, including details such as pizza ID, order ID, quantity, order date, order time, total price, pizza size, category, ingredients, and pizza name.
The scripts in this repository perform the following tasks:

* Importing raw CSV data into a PostgreSQL database.
* Normalizing the database schema by dividing the data into multiple tables.
* Creating views for data analysis, including grouping by order ID, order date, order time, and weekday.
* Querying the data to perform various analyses, such as identifying top-selling pizzas, calculating sales totals by month, and determining peak sales times.
* Dividing the dataset into morning, midday, and evening shifts.
* Calculating running totals and identifying top-selling pizzas in each category.

# Database Structure and Analysis

# DDL (Data Definition Language)
* 		CREATE DATABASE: Used to create a new database named pizza_sales_db.
* 		CREATE TABLE: Used to create tables pizza_data_raw, Sales, PizzaDetails, PizzaCategory, Ingredients, grouped_orders, daily_total, month_total, morning_shift, midday_shift, and evening_shift. These statements define the structure of the database schema, including column names, data types, constraints, and indexes.
* 		ALTER TABLE: Used to modify the structure of existing tables by adding columns (weekday, category_id, filling_id) and constraints (fk_pizza, fk_pizza_category).
* 		CREATE VIEW: Used to create views (grouped_orders, daily_total, month_total) that provide virtual representations of data from one or more tables. These views simplify complex queries and encapsulate logic for data analysis.



# DML (Data Manipulation Language)
* 		COPY: Used to import raw CSV data from the file pizza_sales.csv into the pizza_data_raw table.
* 		INSERT INTO: Used to insert data into tables PizzaDetails, Sales, morning_shift, midday_shift, and evening_shift. These statements add new rows of data to the tables.
* 		UPDATE: Used to update existing rows in the PizzaDetails table to populate the category_id and filling_id columns based on matching values in the PizzaCategory and Ingredients tables.
* 		DELETE: Not used in the provided scripts, but it is commonly used to remove rows from tables.


# DQL (Data Query Language)
* 		SELECT: Used extensively throughout the scripts for querying data from tables and views. These SELECT statements retrieve specific columns or aggregated data based on various criteria.
* 		WITH: Used to define common table expressions (CTEs) for more complex queries. CTEs improve readability and maintainability by breaking down complex queries into smaller, reusable parts.
* 		ORDER BY: Used to sort the results of queries based on specified columns and ascending or descending order.
* 		GROUP BY: Used to group rows of data together based on specified columns. This is commonly used with aggregate functions like COUNT, SUM, AVG to perform calculations on grouped data.
* 		HAVING: Used to filter the results of GROUP BY queries based on specified conditions.
* 		JOIN: Not explicitly used in the provided scripts, but it is commonly used to combine data from multiple tables based on matching columns.
* 		EXTRACT: Used to extract parts of dates (year, month, day) from the order_date column for further analysis.
*                Window Functions: Utilized through the OVER clause, particularly with PARTITION BY and RANK() OVER(): It enables the computation of aggregate values within each partition to produce insights like running totals, category-specific rankings, and other cumulative metrics within specific data segments.

# Descriptive Analysis and Visualization with Python

# * 		Data Importing and Preprocessing:
    * Importing raw CSV data into a pandas DataFrame.
    * Data preprocessing steps, such as formatting dates.
# * 		Exploratory Data Analysis:
    * Descriptive statistics of the dataset, including null values and duplicates.
    * Analysis of quantity and total price distributions.
    * Identification of outliers in quantity and total price.
    * Analysis of sales trends by weekday, month, and hour of the day.
    * Identification of top-selling pizza categories and pizza names.
    * Determination of the maximum quantity of pizzas ordered in one order.

# Author
* O.Rubanenko

 
