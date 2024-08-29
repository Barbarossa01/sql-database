<h1>E-commerce PostgreSQL Database</h1>
This repository contains the SQL dump for an E-commerce database built using PostgreSQL. The database includes several advanced features such as custom functions, triggers, 
and views to manage products, stores, and sales data.

<h1>File Overview</h1>
ecommerce_db.sql: This file contains the SQL script to create the database schema, including tables, functions, triggers, and views.

<h1>Database Schema</h1>

<h3>Tables</h3>
produkty: Stores information about products, including name, price, stock quantity, and category.
produkty_log: Logs price changes for products.
sklepy: Stores information about the stores, including name, address, phone number, and email.
sklepy_produktow: Represents the relationship between stores and products, including the quantity of each product in each store

<h3>Functions</h3>
calculate_discount(product_id INT, discount_percentage NUMERIC(5,2)): Calculates the discounted price of a product.
get_total_sales(store_id INT): Calculates the total sales value for a specific store.
oblicz_wartosc_sklepu(id_sklepu INT): Calculates the total value of all products in a specific store.

<h3>Triggers</h3>
aktualizuj_stan_magazynowy: Updates the stock quantity in the produkty table after a new entry is made in sklepy_produktow.
after_update_produkty: Logs price changes to the produkty_log table after any update to the produkty table.
before_insert_produkty: Ensures that the price of a product cannot be negative before inserting a new record into the produkty table.

<h3>Views</h3>
view_product_discount: Displays products with their original and discounted prices.
view_store_inventory: Displays the inventory of products in each store.
view_total_sales_by_store: Displays the total sales amount for each store.

<h1>How to Use</h1>
Setup PostgreSQL: Ensure you have PostgreSQL installed on your machine.
</br>
Create Database: Create a new database in your PostgreSQL instance.

````sql
CREATE DATABASE ecommerce_db;
````
Import the SQL file: Use the following command to import the ecommerce_db.sql file into your newly created database.
````sql
psql -U your_username -d ecommerce_db -f ecommerce_db.sql
````

Explore the Database: You can now explore the tables, functions, triggers, and views by querying the ecommerce_db database.

<h1>Contact</h1>
For any questions or suggestions, feel free to open an issue or reach out via email muhzaindin03@gmail.com
