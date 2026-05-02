-- ============================================================
-- DMS580S Mini Project 2026
-- OLTP Layer: MySQL Full Schema & Seed Data
-- Domain: Grocery & Supermarket Retail (FreshMart)
-- Author: Christinah Mmabotse Mosima
-- ============================================================

USE bank;

-- ============================================================
-- DROP ORDER (respect foreign key dependencies)
-- ============================================================
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS store_branches;

-- ============================================================
-- TABLE 1: store_branches
-- Physical store locations of FreshMart
-- ============================================================
CREATE TABLE store_branches (
    branch_id   INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city        VARCHAR(80)  NOT NULL,
    province    VARCHAR(80)  NOT NULL,
    address     VARCHAR(200)
);

-- ============================================================
-- TABLE 2: customers
-- Customer demographic and account data
-- ============================================================
CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(80),
    loyalty_tier  ENUM('Bronze','Silver','Gold','Platinum') DEFAULT 'Bronze',
    registered_at DATE         NOT NULL
);

-- ============================================================
-- TABLE 3: categories
-- Product category classification
-- ============================================================
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(60)  NOT NULL,
    description   VARCHAR(200)
);

-- ============================================================
-- TABLE 4: suppliers
-- Wholesale suppliers that stock FreshMart
-- ============================================================
CREATE TABLE suppliers (
    supplier_id   INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(120) NOT NULL,
    contact_email VARCHAR(150),
    city          VARCHAR(80),
    country       VARCHAR(60)  DEFAULT 'South Africa'
);

-- ============================================================
-- TABLE 5: products
-- Grocery product catalogue linked to category and supplier
-- ============================================================
CREATE TABLE products (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_name  VARCHAR(120) NOT NULL,
    category_id   INT          NOT NULL,
    supplier_id   INT          NOT NULL,
    unit_price    DECIMAL(8,2) NOT NULL,
    unit          VARCHAR(20)  NOT NULL,
    stock_qty     INT          NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- ============================================================
-- TABLE 6: orders
-- Header record per customer visit / online session
-- ============================================================
CREATE TABLE orders (
    order_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT          NOT NULL,
    branch_id      INT          NOT NULL,
    order_date     DATE         NOT NULL,
    payment_method ENUM('Cash','Card','EFT','Mobile') NOT NULL,
    order_status   ENUM('Completed','Refunded','Pending') DEFAULT 'Completed',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id)   REFERENCES store_branches(branch_id)
);

-- ============================================================
-- TABLE 7: order_items
-- Line items: one row per product within an order
-- (This is more realistic than a flat orders table)
-- ============================================================
CREATE TABLE order_items (
    item_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT            NOT NULL,
    product_id  INT            NOT NULL,
    quantity    INT            NOT NULL DEFAULT 1,
    unit_price  DECIMAL(8,2)  NOT NULL,   -- price at time of purchase
    line_total  DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- ============================================================
-- SEED: store_branches (8 branches)
-- ============================================================
INSERT INTO store_branches (branch_name, city, province, address) VALUES
('FreshMart Johannesburg CBD',    'Johannesburg',      'Gauteng',       '12 Commissioner St, Johannesburg'),
('FreshMart Cape Town Waterfront','Cape Town',         'Western Cape',  'V&A Waterfront, Cape Town'),
('FreshMart Pretoria Arcadia',    'Pretoria',          'Gauteng',       '45 Park St, Arcadia, Pretoria'),
('FreshMart Durban Berea',        'Durban',            'KwaZulu-Natal', '78 Berea Rd, Durban'),
('FreshMart Polokwane Central',   'Polokwane',         'Limpopo',       '23 Landdros Mare St, Polokwane'),
('FreshMart Soweto Maponya Mall', 'Soweto',            'Gauteng',       'Maponya Mall, Kleiton Rd, Soweto'),
('FreshMart Sandton City',        'Sandton',           'Gauteng',       'Sandton City Mall, Sandton'),
('FreshMart Stellenbosch',        'Stellenbosch',      'Western Cape',  '19 Bird St, Stellenbosch');


-- ============================================================
-- SEED: customers (15 customers)
-- ============================================================
INSERT INTO customers (customer_name, email, phone, city, loyalty_tier, registered_at) VALUES
('Amahle Dlamini',      'amahle.dlamini@gmail.com',      '0821234567', 'Johannesburg',      'Gold',     '2024-01-15'),
('Sipho Nkosi',         'sipho.nkosi@outlook.com',       '0837654321', 'Cape Town',         'Silver',   '2024-02-03'),
('Lerato Mokoena',      'lerato.mokoena@yahoo.com',      '0849876543', 'Pretoria',          'Bronze',   '2024-02-20'),
('Thabo Sithole',       'thabo.sithole@gmail.com',       '0851112233', 'Durban',            'Platinum', '2024-03-05'),
('Nomsa Zulu',          'nomsa.zulu@webmail.co.za',      '0762223344', 'Polokwane',         'Bronze',   '2024-03-18'),
('Kagiso Molefe',       'kagiso.molefe@gmail.com',       '0713334455', 'Soweto',            'Silver',   '2024-04-01'),
('Zanele Khumalo',      'zanele.khumalo@icloud.com',     '0824445566', 'Bloemfontein',      'Gold',     '2024-04-22'),
('Bongani Ndlovu',      'bongani.ndlovu@gmail.com',      '0835556677', 'East London',       'Bronze',   '2024-05-07'),
('Fatima Cassim',       'fatima.cassim@outlook.com',     '0846667788', 'Port Elizabeth',    'Silver',   '2024-05-19'),
('Hendrik van Wyk',     'hendrik.vanwyk@gmail.com',      '0857778899', 'Stellenbosch',      'Gold',     '2024-06-02'),
('Precious Mahlangu',   'precious.mahlangu@yahoo.com',   '0768889900', 'Nelspruit',         'Bronze',   '2024-06-15'),
('David Osei',          'david.osei@gmail.com',          '0719990011', 'Sandton',           'Platinum', '2024-07-01'),
('Thandeka Ntanzi',     'thandeka.ntanzi@webmail.co.za', '0820011223', 'Pietermaritzburg',  'Silver',   '2024-07-20'),
('Rethabile Sello',     'rethabile.sello@gmail.com',     '0831122334', 'Kimberley',         'Bronze',   '2024-08-05'),
('Yusuf Arendse',       'yusuf.arendse@outlook.com',     '0842233445', 'Cape Town',         'Gold',     '2024-08-22');


-- ============================================================
-- SEED: categories (8 categories)
-- ============================================================
INSERT INTO categories (category_name, description) VALUES
('Dairy',      'Milk, cheese, eggs, yoghurt and other dairy products'),
('Bakery',     'Bread, rolls, pastries and baked goods'),
('Meat',       'Fresh and frozen meats including chicken, beef and pork'),
('Grains',     'Rice, maize meal, flour and pasta'),
('Produce',    'Fresh fruits and vegetables'),
('Beverages',  'Juices, cold drinks, water and hot beverages'),
('Pantry',     'Cooking oils, spreads, condiments and canned goods'),
('Household',  'Cleaning products and household essentials');


-- ============================================================
-- SEED: suppliers (6 suppliers)
-- ============================================================
INSERT INTO suppliers (supplier_name, contact_email, city, country) VALUES
('Rainbow Farms SA',       'orders@rainbowfarms.co.za',  'Johannesburg', 'South Africa'),
('Clover Dairy Group',     'supply@clover.co.za',        'Pretoria',     'South Africa'),
('Tiger Brands Ltd',       'wholesale@tigerbrands.co.za','Johannesburg', 'South Africa'),
('Nature Fresh Produce',   'fresh@naturefresh.co.za',    'Cape Town',    'South Africa'),
('Illovo Foods',           'trade@illovo.co.za',         'Durban',       'South Africa'),
('Shoprite Wholesale',     'bulk@shopritewholesale.co.za','Cape Town',   'South Africa');


-- ============================================================
-- SEED: products (20 products)
-- ============================================================
INSERT INTO products (product_name, category_id, supplier_id, unit_price, unit, stock_qty) VALUES
-- Dairy (cat 1, supplier 2 Clover)
('Full Cream Milk',        1, 2,  22.99, 'litre',      350),
('Free-Range Eggs',        1, 1,  45.99, 'pack of 12', 200),
('Cheddar Cheese',         1, 2,  59.99, '400g pack',  180),
('Plain Yoghurt',          1, 2,  19.99, '500ml',      220),
-- Bakery (cat 2, supplier 3 Tiger)
('White Bread',            2, 3,  16.49, 'loaf',       500),
('Whole Wheat Bread',      2, 3,  18.99, 'loaf',       320),
-- Meat (cat 3, supplier 1 Rainbow)
('Chicken Breast',         3, 1,  89.99, 'kg',         160),
('Beef Mince',             3, 1, 119.99, 'kg',         120),
('Pork Sausages',          3, 1,  64.99, '500g pack',   90),
-- Grains (cat 4, supplier 3 Tiger)
('Basmati Rice',           4, 3,  34.99, 'kg',         400),
('Maize Meal 5kg',         4, 3,  79.99, '5kg bag',    300),
('Spaghetti Pasta',        4, 3,  24.99, '500g pack',  280),
-- Produce (cat 5, supplier 4 Nature Fresh)
('Potatoes',               5, 4,  29.99, '2kg bag',    250),
('Onions',                 5, 4,  17.99, 'kg',         300),
('Apples Granny Smith',    5, 4,  39.99, 'kg',         200),
-- Beverages (cat 6, supplier 5 Illovo)
('Orange Juice',           6, 5,  33.99, 'litre',      280),
('Instant Coffee',         6, 3,  74.99, '250g',       150),
-- Pantry (cat 7, supplier 6 Shoprite Wholesale)
('Sunflower Oil',          7, 6,  62.99, 'litre',      310),
('Peanut Butter',          7, 6,  49.99, '400g',       190),
-- Household (cat 8, supplier 6 Shoprite Wholesale)
('Washing Powder',         8, 6,  99.99, '2kg',        140);


-- ============================================================
-- SEED: orders (35 order headers)
-- ============================================================
INSERT INTO orders (customer_id, branch_id, order_date, payment_method, order_status) VALUES
(1,  1, '2025-01-05', 'Card',   'Completed'),   -- order 1
(2,  2, '2025-01-07', 'EFT',    'Completed'),   -- order 2
(3,  3, '2025-01-10', 'Cash',   'Completed'),   -- order 3
(4,  4, '2025-01-12', 'Card',   'Completed'),   -- order 4
(5,  5, '2025-01-15', 'Mobile', 'Completed'),   -- order 5
(6,  6, '2025-02-02', 'Card',   'Completed'),   -- order 6
(7,  1, '2025-02-06', 'EFT',    'Completed'),   -- order 7
(8,  4, '2025-02-10', 'Cash',   'Completed'),   -- order 8
(9,  3, '2025-02-14', 'Card',   'Completed'),   -- order 9
(10, 8, '2025-02-18', 'Mobile', 'Completed'),   -- order 10
(11, 5, '2025-03-01', 'Cash',   'Completed'),   -- order 11
(12, 7, '2025-03-05', 'Card',   'Completed'),   -- order 12
(13, 4, '2025-03-08', 'EFT',    'Completed'),   -- order 13
(14, 5, '2025-03-12', 'Mobile', 'Completed'),   -- order 14
(15, 2, '2025-03-17', 'Card',   'Completed'),   -- order 15
(1,  1, '2025-04-02', 'Card',   'Completed'),   -- order 16
(2,  2, '2025-04-07', 'EFT',    'Completed'),   -- order 17
(3,  3, '2025-04-11', 'Cash',   'Completed'),   -- order 18
(4,  4, '2025-04-16', 'Card',   'Completed'),   -- order 19
(5,  5, '2025-04-20', 'Mobile', 'Completed'),   -- order 20
(6,  6, '2025-05-03', 'Card',   'Completed'),   -- order 21
(7,  1, '2025-05-08', 'EFT',    'Completed'),   -- order 22
(8,  4, '2025-05-12', 'Cash',   'Completed'),   -- order 23
(9,  3, '2025-05-16', 'Card',   'Refunded'),    -- order 24
(10, 8, '2025-05-20', 'Mobile', 'Completed'),   -- order 25
(11, 5, '2025-06-04', 'Cash',   'Completed'),   -- order 26
(12, 7, '2025-06-09', 'Card',   'Completed'),   -- order 27
(13, 4, '2025-06-13', 'EFT',    'Completed'),   -- order 28
(14, 5, '2025-06-18', 'Mobile', 'Completed'),   -- order 29
(15, 2, '2025-06-23', 'Card',   'Completed'),   -- order 30
(1,  1, '2025-07-01', 'Card',   'Completed'),   -- order 31
(3,  3, '2025-07-07', 'EFT',    'Completed'),   -- order 32
(5,  5, '2025-07-14', 'Mobile', 'Completed'),   -- order 33
(8,  4, '2025-07-20', 'Cash',   'Completed'),   -- order 34
(12, 7, '2025-07-28', 'Card',   'Completed');   -- order 35


-- ============================================================
-- SEED: order_items (multiple items per order, 70+ line items)
-- ============================================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- Order 1
(1, 7,  2, 89.99),
(1, 1,  3, 22.99),
-- Order 2
(2, 1,  3, 22.99),
(2, 5,  2, 16.49),
-- Order 3
(3, 11, 1, 79.99),
(3, 13, 2, 29.99),
-- Order 4
(4, 10, 2, 34.99),
(4, 14, 1, 17.99),
-- Order 5
(5, 2,  1, 45.99),
(5, 4,  2, 19.99),
-- Order 6
(6, 8,  1,119.99),
(6, 12, 1, 24.99),
-- Order 7
(7, 3,  2, 59.99),
(7, 18, 1, 62.99),
-- Order 8
(8, 18, 1, 62.99),
(8, 19, 1, 49.99),
-- Order 9
(9, 17, 1, 74.99),
(9, 16, 2, 33.99),
-- Order 10
(10,15, 2, 39.99),
(10, 6, 1, 18.99),
-- Order 11
(11, 5, 3, 16.49),
(11,14, 2, 17.99),
-- Order 12
(12, 7, 3, 89.99),
(12,20, 1, 99.99),
-- Order 13
(13,20, 1, 99.99),
(13,11, 1, 79.99),
-- Order 14
(14,13, 2, 29.99),
(14,15, 1, 39.99),
-- Order 15
(15,16, 4, 33.99),
(15, 5, 2, 16.49),
-- Order 16
(16,19, 1, 49.99),
(16, 2, 2, 45.99),
-- Order 17
(17, 8, 2,119.99),
(17,12, 2, 24.99),
-- Order 18
(18, 9, 2, 64.99),
(18,13, 1, 29.99),
-- Order 19
(19,15, 3, 39.99),
(19, 2, 2, 45.99),
-- Order 20
(20, 2, 2, 45.99),
(20, 4, 1, 19.99),
-- Order 21
(21, 1, 6, 22.99),
(21, 5, 2, 16.49),
-- Order 22
(22,11, 1, 79.99),
(22, 3, 1, 59.99),
-- Order 23
(23, 4, 2, 19.99),
(23,10, 2, 34.99),
-- Order 24
(24,10, 3, 34.99),
(24,16, 2, 33.99),
-- Order 25
(25,15, 2, 39.99),
(25, 9, 1, 64.99),
-- Order 26
(26,14, 4, 17.99),
(26,13, 2, 29.99),
-- Order 27
(27,18, 2, 62.99),
(27, 7, 1, 89.99),
-- Order 28
(28, 7, 1, 89.99),
(28,17, 2, 74.99),
-- Order 29
(29,17, 2, 74.99),
(29,16, 1, 33.99),
-- Order 30
(30, 5, 4, 16.49),
(30, 6, 2, 18.99),
-- Order 31
(31, 3, 1, 59.99),
(31, 1, 2, 22.99),
-- Order 32
(32,15, 3, 39.99),
(32,18, 1, 62.99),
-- Order 33
(33, 8, 1,119.99),
(33,12, 2, 24.99),
-- Order 34
(34,19, 2, 49.99),
(34,14, 1, 17.99),
-- Order 35
(35,16, 3, 33.99),
(35,20, 1, 99.99);


-- ============================================================
-- VERIFICATION QUERIES
-- Run these after the script to confirm all data loaded
-- ============================================================

-- 1. Record counts per table
SELECT 'store_branches' AS table_name, COUNT(*) AS records FROM store_branches UNION ALL
SELECT 'customers',                    COUNT(*)             FROM customers      UNION ALL
SELECT 'categories',                   COUNT(*)             FROM categories     UNION ALL
SELECT 'suppliers',                    COUNT(*)             FROM suppliers      UNION ALL
SELECT 'products',                     COUNT(*)             FROM products       UNION ALL
SELECT 'orders',                       COUNT(*)             FROM orders         UNION ALL
SELECT 'order_items',                  COUNT(*)             FROM order_items;

-- 2. Full readable order view (join all 7 tables)
SELECT
    o.order_id,
    c.customer_name,
    c.loyalty_tier,
    b.branch_name,
    b.city          AS branch_city,
    p.product_name,
    cat.category_name,
    s.supplier_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    o.order_date,
    o.payment_method,
    o.order_status
FROM order_items oi
JOIN orders        o   ON oi.order_id   = o.order_id
JOIN customers     c   ON o.customer_id = c.customer_id
JOIN store_branches b  ON o.branch_id   = b.branch_id
JOIN products      p   ON oi.product_id = p.product_id
JOIN categories    cat ON p.category_id = cat.category_id
JOIN suppliers     s   ON p.supplier_id = s.supplier_id
ORDER BY o.order_id, oi.item_id
LIMIT 20;

-- 3. Revenue per category
SELECT
    cat.category_name,
    SUM(oi.line_total) AS total_revenue,
    COUNT(oi.item_id)  AS items_sold
FROM order_items oi
JOIN products  p   ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY total_revenue DESC;
