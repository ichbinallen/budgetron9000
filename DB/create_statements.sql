/*
USE psql command below to create user and database
psql -U allen
psql -U <postgres> -- this would work if your database was set up the normal way
*/
CREATE USER budgetron9000_user WITH PASSWORD 'henpeebin';
CREATE DATABASE budgetron9000 WITH OWNER budgetron9000_user;

/*
USE psql command below to connect
psql -U budgetron9000_user -d budgetron9000 -h 127.0.0.1
*/

CREATE SCHEMA IF NOT EXISTS b9000;


CREATE TABLE IF NOT EXISTS b9000.accounts (
  a_id SERIAL PRIMARY KEY,
  name VARCHAR,
  type VARCHAR,
  sign VARCHAR,
  date_field VARCHAR,
  date_format VARCHAR,
  vendor_field VARCHAR,
  desc_field VARCHAR,
  category_field VARCHAR,
  subcategory_field VARCHAR,
  amount_field VARCHAR
);

CREATE TABLE b9000.categories (
  c_id SERIAL PRIMARY KEY,
  c_name VARCHAR,
  c_subcategries VARCHAR,
  c_budget REAL
);


CREATE TABLE b9000.transactions (
  t_id SERIAL PRIMARY KEY,
  a_id INT,
  t_date DATE,
  t_vendor VARCHAR,
  t_desc VARCHAR,
  t_category VARCHAR,
  c_id INT,
  t_subcategory VARCHAR,
  t_amount REAL,
  t_exclude BOOLEAN
);
ALTER TABLE b9000.transactions ADD FOREIGN KEY (a_id) REFERENCES b9000.accounts (a_id);
ALTER TABLE b9000.transactions ADD FOREIGN KEY (c_id) REFERENCES b9000.categories (c_id);
