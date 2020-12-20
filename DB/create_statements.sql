/*
USE psql command below to create user and database
psql -U allen
psql -U <postgres> -- this would work if your database was set up the normal way
*/
CREATE USER b9k_user WITH PASSWORD 'henpeebin';
CREATE DATABASE b9k WITH OWNER b9k_user;

/*
USE psql command below to connect
psql -U b9k_user -d b9k -h 127.0.0.1
*/

CREATE SCHEMA IF NOT EXISTS b9k;


CREATE TABLE IF NOT EXISTS b9k.accounts (
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

CREATE TABLE b9k.categories (
  c_id SERIAL PRIMARY KEY,
  c_name VARCHAR,
  c_subcategries VARCHAR,
  c_budget REAL
);


CREATE TABLE b9k.transactions (
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
ALTER TABLE b9k.transactions ADD FOREIGN KEY (a_id) REFERENCES b9k.accounts (a_id);
ALTER TABLE b9k.transactions ADD FOREIGN KEY (c_id) REFERENCES b9k.categories (c_id);
