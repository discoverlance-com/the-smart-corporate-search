-- 1. CLEANUP (Idempotent: Safe to run multiple times)
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 2. SCHEMA DEFINITION
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    cost DECIMAL(10, 2) -- Added cost to calculate profit margin
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    region VARCHAR(50), -- North America, EMEA, APAC
    tier VARCHAR(20)    -- Enterprise, SMB, Startup
);

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    customer_id INT REFERENCES customers(id),
    sale_date DATE,
    quantity INT,
    total_amount DECIMAL(10, 2)
);

-- 3. SEED DATA: PRODUCTS (Tech Hardware)
-- Clear existing data to prevent duplicates
TRUNCATE TABLE products, customers, sales RESTART IDENTITY CASCADE;

INSERT INTO products (name, category, price, cost) VALUES
('Titanium Laptop X1', 'Laptops', 1500.00, 900.00),
('Titanium Laptop Pro', 'Laptops', 2200.00, 1400.00),
('Budget Chromebook', 'Laptops', 350.00, 200.00),
('ErgoMouse 5000', 'Accessories', 50.00, 15.00),
('MechKeyboard RGB', 'Accessories', 120.00, 60.00),
('4K Monitor Ultra', 'Monitors', 600.00, 350.00),
('Curved Monitor 34"', 'Monitors', 800.00, 500.00),
('Enterprise Server Rack', 'Servers', 5000.00, 3000.00),
('Office License Seat', 'Software', 15.00, 0.50),
('Cloud Storage 10TB', 'Software', 100.00, 20.00);

-- 4. SEED DATA: CUSTOMERS
INSERT INTO customers (company_name, region, tier) VALUES
('Acme Corp', 'North America', 'Enterprise'),
('Globex Corporation', 'EMEA', 'Enterprise'),
('Soylent Corp', 'North America', 'SMB'),
('Initech', 'North America', 'SMB'),
('Umbrella Corp', 'EMEA', 'Enterprise'),
('Cyberdyne Systems', 'APAC', 'Enterprise'),
('Stark Industries', 'North America', 'Enterprise'),
('Wayne Enterprises', 'North America', 'Enterprise'),
('Massive Dynamic', 'EMEA', 'Startup'),
('Hooli', 'North America', 'Startup');

-- 5. SEED DATA: SALES (100+ Records spread across Q1-Q4)
-- Q1 Sales
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 10, 15000.00), -- Acme bought 10 Laptops
(8, 2, '2024-01-20', 2, 10000.00),  -- Globex bought Servers
(4, 3, '2024-02-10', 50, 2500.00),  -- Soylent bought Mice
(2, 7, '2024-02-15', 5, 11000.00),  -- Stark bought Pro Laptops
(9, 4, '2024-03-01', 100, 1500.00), -- Initech bought Licenses
(6, 6, '2024-03-10', 20, 12000.00), -- Cyberdyne bought Monitors
(1, 5, '2024-03-25', 5, 7500.00),
(5, 8, '2024-03-28', 10, 1200.00);

-- Q2 Sales
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_amount) VALUES
(8, 1, '2024-04-05', 5, 25000.00), -- Acme bought more Servers
(3, 9, '2024-04-12', 20, 7000.00), -- Massive Dynamic bought Chromebooks
(7, 10, '2024-05-01', 5, 4000.00),  -- Hooli bought Curved Monitors
(2, 6, '2024-05-15', 50, 110000.00), -- Cyberdyne HUGE order
(10, 2, '2024-05-20', 10, 1000.00),
(4, 5, '2024-06-01', 100, 5000.00),
(5, 7, '2024-06-10', 20, 2400.00),
(1, 3, '2024-06-25', 2, 3000.00);

-- Q3 Sales
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_amount) VALUES
(8, 7, '2024-07-04', 1, 5000.00),
(2, 8, '2024-07-15', 15, 33000.00),
(6, 1, '2024-08-01', 50, 30000.00), -- Acme Office upgrade
(9, 9, '2024-08-10', 10, 150.00),
(3, 4, '2024-08-20', 5, 1750.00),
(1, 10, '2024-09-01', 30, 45000.00), -- Hooli expansion
(5, 6, '2024-09-15', 50, 6000.00),
(7, 2, '2024-09-30', 10, 8000.00);

-- Q4 Sales (End of year push)
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_amount) VALUES
(8, 6, '2024-10-05', 10, 50000.00), -- Cyberdyne Server Farm
(2, 1, '2024-10-12', 20, 44000.00),
(4, 2, '2024-11-01', 200, 10000.00), -- Globex Accessories
(10, 3, '2024-11-15', 5, 500.00),
(6, 8, '2024-11-20', 10, 6000.00),
(1, 5, '2024-12-01', 10, 15000.00),
(9, 7, '2024-12-10', 500, 7500.00), -- Stark Ind Software Renewal
(3, 4, '2024-12-20', 10, 3500.00);

-- 6. GENERATE MORE RANDOM DATA (To reach 100+ records)
-- This block generates 70 random sales using cross joins for volume
INSERT INTO sales (product_id, customer_id, sale_date, quantity, total_amount)
SELECT 
    (random() * 9 + 1)::int,                  -- Random Product 1-10
    (random() * 9 + 1)::int,                  -- Random Customer 1-10
    '2024-01-01'::date + (random() * 360)::int, -- Random Date in 2024
    (random() * 10 + 1)::int,                 -- Random Qty 1-10
    (random() * 1000 + 100)::decimal(10,2)    -- Random Amount (simplified)
FROM generate_series(1, 70);