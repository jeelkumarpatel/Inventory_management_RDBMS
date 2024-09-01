 

if not exists(select * from sys.databases where name= 'project') 

    create database project 

GO  

  

use project 
GO 


-- Down meta data 



if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 

    where CONSTRAINT_NAME='fk_deliveries_order_id') 

ALTER TABLE deliveries 

DROP CONSTRAINT fk_deliveries_order_id 
GO 

  

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 

    where CONSTRAINT_NAME='fk_payments_order_id') 

ALTER TABLE payments 

DROP CONSTRAINT fk_payments_order_id 
GO 

  

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 

    where CONSTRAINT_NAME='fk_orders_seller_id') 

ALTER TABLE orders 

DROP CONSTRAINT fk_orders_seller_id 
GO 

  

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 

    where CONSTRAINT_NAME='fk_orders_customer_id') 

ALTER TABLE orders 

DROP CONSTRAINT fk_orders_customer_id 
GO 

  

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 

    where CONSTRAINT_NAME='fk_orders_product_id') 

ALTER TABLE orders 

DROP CONSTRAINT fk_orders_order_product_id 
GO 

  

DROP TABLE IF EXISTS deliveries 

  

DROP TABLE IF EXISTS transaction_reports 

  

DROP TABLE IF EXISTS payments 

  

DROP TABLE IF EXISTS orders 

  

DROP TABLE IF EXISTS sellers 

  

DROP TABLE IF EXISTS products 

  

DROP TABLE IF EXISTS customers 

  

DROP TABLE IF EXISTS categories 

GO 

  

DROP VIEW If EXISTS my_order_status 

GO 

DROP PROCEDURE IF EXISTS get_inactive_customers 

GO 

  

drop procedure if exists p_upsert_products  

GO  

 
 

-- Up meta data 

  

CREATE TABLE customers ( 

customer_id INT identity NOT NULL, 

customer_name VARCHAR(50) NOT NULL, 

customer_email VARCHAR(100) UNIQUE, 

customer_phone VARCHAR(20), 

address VARCHAR(100), 

CONSTRAINT pk_customers_customer_id PRIMARY KEY (customer_id), 

CONSTRAINT uk_customers_customer_email UNIQUE(customer_email), 

) 

GO 

  

CREATE TABLE products ( 

product_id INT identity NOT NULL, 

product_name VARCHAR(100) NOT NULL, 

product_type VARCHAR(500), 

product_category DECIMAL(10,2), 

CONSTRAINT pk_products_product_id PRIMARY KEY(product_id) 

) 

GO 

  

CREATE TABLE sellers ( 

seller_id INT identity NOT NULL, 

seller_name VARCHAR(100) NOT NULL, 

seller_email VARCHAR(100) NOT NULL, 

seller_phone VARCHAR(20), 

address VARCHAR(100) 

CONSTRAINT pk_sellers_seller_id PRIMARY KEY(seller_id), 

CONSTRAINT uk_sellers_seller_email UNIQUE(seller_email) 

) 

GO 

  

CREATE TABLE orders ( 

order_id INT identity NOT NULL, 

order_date DATE NOT NULL , 

order_delivery_date DATE NOT NULL, 

order_status VARCHAR(50), 

order_customer_id INT NOT NULL, 

order_seller_id INT NOT NULL,  

order_product_id INT NOT null, 

CONSTRAINT pk_orders_order_id PRIMARY KEY(order_id) 

) 

GO 

  

CREATE TABLE payments ( 

payment_id INT identity NOT NULL, 

payment_order_id INT, 

payment_date DATE, 

payment_amount DECIMAL(10,2), 

payment_method VARCHAR(50), 

CONSTRAINT pk_payments_payment_id PRIMARY KEY(payment_id) 

) 

GO 

  

  

CREATE TABLE categories ( 

category_id INT identity NOT NULL, 

category_name VARCHAR(100) NOT NULL, 

CONSTRAINT pk_categories_category_id PRIMARY KEY(category_id) 

) 

GO 

  

CREATE TABLE deliveries ( 

delivery_id INT identity NOT NULL, 

delivery_order_id INT, 

delivery_date DATE, 

delivery_status VARCHAR(50), 

CONSTRAINT pk_deliveries_delivery_id PRIMARY KEY(delivery_id) 

) 

GO 

  

ALTER TABLE orders 

ADD CONSTRAINT fk_orders_customer_id 

FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id) 

GO 

  

ALTER TABLE orders 

ADD CONSTRAINT fk_orders_seller_id 

FOREIGN KEY (order_seller_id) REFERENCES sellers(seller_id) 

GO 

  

ALTER TABLE orders 

ADD CONSTRAINT fk_orders_order_product_id 

FOREIGN KEY (order_product_id) REFERENCES products(product_id) 

GO 

  

ALTER TABLE payments 

ADD CONSTRAINT fk_payments_order_id 

FOREIGN KEY (payment_order_id) REFERENCES orders(order_id) 

GO 

  

ALTER TABLE deliveries 

ADD CONSTRAINT fk_deliveries_order_id 

FOREIGN KEY (delivery_order_id) REFERENCES orders(order_id) 

GO 

  

  

--VIEW 

CREATE VIEW my_order_status AS 

SELECT o.order_id, o.order_date, o.order_delivery_date, o.order_status, 

       c.customer_name, c.customer_email, c.customer_phone, c.address AS customer_address, 

        op.payment_method, od.delivery_status 

FROM orders o 

INNER JOIN customers c ON o.order_customer_id = c.customer_id 

INNER JOIN payments op ON o.order_id = op.payment_order_id 

INNER JOIN deliveries od ON o.order_id = od.delivery_order_id 

WHERE c.customer_id = 20; 

GO 

  

  

--TRIGGER 

CREATE TRIGGER order_delivered_trigger 

ON deliveries 

AFTER UPDATE 

AS 

BEGIN 

  IF UPDATE(delivery_status) AND EXISTS (SELECT * FROM inserted WHERE delivery_status = 'delivered') 

  BEGIN 

    UPDATE orders 

    SET order_status = 'delivered' 

    FROM orders 

    INNER JOIN inserted 

    ON orders.order_id = inserted.delivery_order_id  

  END 

END 

GO 

  

 create procedure p_upsert_products (  

@product_name VARCHAR(100),   

@product_type VARCHAR(500),   

@product_category DECIMAL(10,2)   

) as begin  

if exists(select * from products where product_name = @product_name) begin   

update products set product_type = @product_type  

where product_name = @product_name  

end  

else begin  

insert into products (product_name, product_type, product_category)   

values (@product_name, @product_type, @product_category)  

end  

end   

GO 

 
 

  

  

--UP DATA 

INSERT INTO customers (customer_name, customer_email, customer_phone, address) 

VALUES  

('Aarav Singh', 'aarav.singh@example.com', '+91-9876543210', '123 Main St, Mumbai'), 

('Diya Patel', 'diya.patel@example.com', '+91-9876543211', '456 Second Ave, New Delhi'), 

('Kunal Mehta', 'kunal.mehta@example.com', '+91-9876543212', '789 Third St, Bengaluru'), 

('Nisha Gupta', 'nisha.gupta@example.com', '+91-9876543213', '321 Fourth Ave, Kolkata'), 

('Raj Chakraborty', 'raj.chakraborty@example.com', '+91-9876543214', '654 Fifth St, Chennai'), 

('Smita Sharma', 'smita.sharma@example.com', '+91-9876543215', '987 Sixth Ave, Hyderabad'), 

('Varun Khanna', 'varun.khanna@example.com', '+91-9876543216', '246 Seventh St, Pune'), 

('Yash Chopra', 'yash.chopra@example.com', '+91-9876543217', '369 Eighth Ave, Ahmedabad'), 

('Zara Khan', 'zara.khan@example.com', '+91-9876543218', '951 Ninth St, Jaipur'), 

('Avi Patel', 'avi.patel@example.com', '+91-9876543219', '753 Tenth Ave, Surat'), 

('Akshay Kumar', 'akshay.kumar@gmail.com', '9988776655', '123 Main Street, Mumbai'), 

('Priyanka Chopra', 'priyanka.chopra@gmail.com', '9876543210', '456 Oak Lane, Delhi'), 

('Shah Rukh Khan', 'srk@gmail.com', '8765432109', '789 Maple Road, Kolkata'), 

('Deepika Padukone', 'deepika.padukone@gmail.com', '7654321098', '321 Pine Street, Bangalore'), 

('Aamir Khan', 'aamir.khan@gmail.com', '6543210987', '654 Elm Street, Chennai'), 

('Kareena Kapoor', 'kareena.kapoor@gmail.com', '5432109876', '987 Cedar Avenue, Hyderabad'), 

('Salman Khan', 'salman.khan@gmail.com', '4321098765', '234 Oak Street, Pune'), 

('Katrina Kaif', 'katrina.kaif@gmail.com', '3210987654', '567 Pine Lane, Jaipur'), 

('Ranbir Kapoor', 'ranbir.kapoor@gmail.com', '2109876543', '890 Maple Road, Ahmedabad'), 

('Alia Bhatt', 'alia.bhatt@gmail.com', '1098765432', '123 Cedar Street, Surat'); 

  

INSERT INTO products (product_name, product_type, product_category) 

VALUES  

('Blue Denim Jacket', 'Jacket', 45.99), 

('Black Leather Boots', 'Shoes', 89.99), 

('White Button-Up Shirt', 'Shirt', 29.99), 

('Dark Wash Skinny Jeans', 'Jeans', 39.99), 

('Red Plaid Skirt', 'Skirt', 24.99), 

('Olive Green Cargo Pants', 'Pants', 34.99), 

('Grey Hoodie', 'Sweatshirt', 39.99), 

('Brown Suede Jacket', 'Jacket', 99.99), 

('Black Turtleneck Sweater', 'Sweater', 49.99), 

('Navy Blue Blazer', 'Blazer', 74.99), 

('Beige Chino Shorts', 'Shorts', 19.99), 

('Green V-Neck T-Shirt', 'T-Shirt', 12.99), 

('Pink Floral Dress', 'Dress', 54.99), 

('Grey Wool Peacoat', 'Coat', 119.99), 

('Black Skinny Trousers', 'Pants', 29.99), 

('Blue and White Striped Shirt', 'Shirt', 27.99), 

('Tan Ankle Boots', 'Shoes', 59.99), 

('Red and Black Plaid Jacket', 'Jacket', 69.99), 

('Purple Cable Knit Sweater', 'Sweater', 44.99), 

('Yellow Raincoat', 'Coat', 64.99) 

GO 

  

  

INSERT INTO sellers (seller_name, seller_email, seller_phone, address) 

VALUES  

('Adidas India', 'contact@adidas.com', '+91-22-66717800', 'Bandra Kurla Complex, Mumbai'), 

('Puma India', 'customerserviceindia@puma.com', '+91-20-67313600', 'Bavdhan, Pune'), 

('Nike India', 'consumercare.india@nike.com', '+91-80-40405050', 'HSR Layout, Bengaluru'), 

('Zara India', 'customer.service@in.inditex.com', '+91-120-4046400', 'Logix City Centre, Noida'), 

('Levi Strauss & Co', 'customerservice@levi.in', '+91-22-61798600', 'Santacruz East, Mumbai'), 

('Van Heusen', 'vhusen_care@abfrl.adityabirla.com', '+91-80-26771000', 'Bannerghatta Road, Bengaluru'), 

('Calvin Klein', 'customerservicein@ck.com', '+91-22-61366767', 'Andheri East, Mumbai'), 

('United Colors of Benetton', 'india-cs@benetton.com', '+91-80-25327600', 'Koramangala, Bengaluru'), 

('Arrow', 'customercare.arrow@adityabirla.com', '+91-80-46486000', 'Wilson Garden, Bengaluru'), 

('Louis Philippe', 'care.lpu@adityabirla.com', '+91-22-66626100', 'Lower Parel, Mumbai'), 

('Tommy Hilfiger', 'in.tommy@tommy.com', '+91-22-62305100', 'Khar West, Mumbai'), 

('Reebok India', 'adidasgroupindia@adidas.com', '+91-22-40174600', 'Kurla West, Mumbai'), 

('Gucci India', 'indiacustomercare@gucci.com', '+91-22-61191000', 'Nariman Point, Mumbai'), 

('Versace', 'customerservice.india@versace.com', '+91-22-23679111', 'Fort, Mumbai'), 

('Armani India', 'customerservice.in@giorgioarmani.com', '+91-22-61122000', 'Cuffe Parade, Mumbai'), 

('H&M India', 'customerservice.in@hm.com', '+91-80-46485199', 'Garuda Mall, Bengaluru'), 

('Diesel', 'care.diesel@bestseller.com', '+91-22-29209999', 'Lower Parel, Mumbai'), 

('Forever 21', 'support.india@forever21.com', '+91-11-41118120', 'DLF Mall of India, Noida'), 

('GAP India', 'customerservice.in@gap.com', '+91-22-61392222', 'Lower Parel, Mumbai'), 

('Burberry India', 'burberry.care@in.burberry.com', '+91-22-66145151', 'Khar West, Mumbai') 

GO 

  

INSERT INTO orders (order_date, order_delivery_date, order_status, order_customer_id, order_seller_id, order_product_id) 

VALUES 

    ('2023-04-01', '2023-04-10', 'Pending', 1, 1, 1), 

    ('2023-04-02', '2023-04-11', 'Shipped', 2, 2, 2), 

    ('2023-04-03', '2023-04-12', 'Delivered', 3, 3, 3), 

    ('2023-04-04', '2023-04-13', 'Pending', 4, 4, 4), 

    ('2023-04-05', '2023-04-14', 'Shipped', 5, 5, 5), 

    ('2023-04-06', '2023-04-15', 'Delivered', 6, 6, 6), 

    ('2023-04-07', '2023-04-16', 'Pending', 7, 7, 7), 

    ('2023-04-08', '2023-04-17', 'Shipped', 8, 8, 8), 

    ('2023-04-09', '2023-04-18', 'Delivered', 9, 9, 9), 

    ('2023-04-10', '2023-04-19', 'Pending', 10, 10, 10), 

    ('2023-04-11', '2023-04-20', 'Shipped', 11, 11, 11), 

    ('2023-04-12', '2023-04-21', 'Delivered', 12, 12, 12), 

    ('2023-04-13', '2023-04-22', 'Pending', 13, 13, 13), 

    ('2023-04-14', '2023-04-23', 'Shipped', 14, 14, 14), 

    ('2023-04-15', '2023-04-24', 'Delivered', 15, 15, 15), 

    ('2023-04-16', '2023-04-25', 'Pending', 16, 16, 16), 

    ('2023-04-17', '2023-04-26', 'Shipped', 17, 17, 17), 

    ('2023-04-18', '2023-04-27', 'Delivered', 18, 18, 18), 

    ('2023-04-19', '2023-04-28', 'Pending', 19, 19, 19), 

    ('2023-04-20', '2023-04-29', 'Shipped', 20, 20, 20) 

GO 

  

INSERT INTO payments (payment_order_id, payment_date, payment_amount, payment_method) 

VALUES 

(1, '2022-03-12', 124.99, 'Credit Card'), 

(2, '2022-03-15', 89.99, 'PayPal'), 

(3, '2022-03-16', 174.99, 'Debit Card'), 

(4, '2022-03-18', 399.99, 'Bank Transfer'), 

(5, '2022-03-20', 99.99, 'Credit Card'), 

(6, '2022-03-22', 59.99, 'PayPal'), 

(7, '2022-03-24', 124.99, 'Debit Card'), 

(8, '2022-03-26', 49.99, 'Bank Transfer'), 

(9, '2022-03-28', 89.99, 'Credit Card'), 

(10, '2022-03-30', 149.99, 'PayPal'), 

(11, '2022-04-02', 199.99, 'Debit Card'), 

(12, '2022-04-04', 299.99, 'Bank Transfer'), 

(13, '2022-04-06', 79.99, 'Credit Card'), 

(14, '2022-04-08', 39.99, 'PayPal'), 

(15, '2022-04-10', 124.99, 'Debit Card'), 

(16, '2022-04-12', 199.99, 'Bank Transfer'), 

(17, '2022-04-14', 149.99, 'Credit Card'), 

(18, '2022-04-16', 59.99, 'PayPal'), 

(19, '2022-04-18', 99.99, 'Debit Card'), 

(20, '2022-04-20', 174.99, 'Bank Transfer') 

GO 

  

INSERT INTO deliveries (delivery_order_id, delivery_date, delivery_status) 

VALUES 

(1, '2023-05-01', 'shipped'), 

(2, '2023-05-02', 'delivered'), 

(3, '2023-05-02', 'delivered'), 

(4, '2023-05-03', 'in transit'), 

(5, '2023-05-04', 'shipped'), 

(6, '2023-05-05', 'delivered'), 

(7, '2023-05-06', 'in transit'), 

(8, '2023-05-06', 'shipped'), 

(9, '2023-05-07', 'delivered'), 

(10, '2023-05-08', 'in transit'), 

(11, '2023-05-08', 'shipped'), 

(12, '2023-05-09', 'delivered'), 

(13, '2023-05-10', 'in transit'), 

(14, '2023-05-11', 'shipped'), 

(15, '2023-05-11', 'delivered'), 

(16, '2023-05-12', 'in transit'), 

(17, '2023-05-13', 'shipped'), 

(18, '2023-05-13', 'delivered'), 

(19, '2023-05-14', 'in transit'), 

(20, '2023-05-15', 'shipped') 

GO 

  

INSERT INTO categories (category_name) VALUES  

('Tops'), 

('Dresses'), 

('Bottoms'), 

('Outerwear'), 

('Athletic Wear'), 

('Accessories'), 

('Intimates'), 

('Swimwear'), 

('Suits'), 

('Ethnic Wear') 

GO 

  

  

--Verify 

--SELECT * from my_order_status 

--GO 

  

SELECT  

    order_id,  

    order_date,  

    order_delivery_date,  

    order_status,  

    customer_name,  

    customer_email,  

    customer_phone,  

    address,  

    payment_method,  

    SUM(payment_amount) OVER (PARTITION BY order_id) AS total_payment_amount 

FROM  

    orders  

    INNER JOIN customers ON orders.order_customer_id = customers.customer_id  

    INNER JOIN payments ON orders.order_id = payments.payment_order_id  

    INNER JOIN deliveries ON orders.order_id = deliveries.delivery_order_id 

WHERE  

    customer_id = 20; 

GO 

 

SELECT seller_name, seller_email, seller_phone, address from sellers   

where  seller_name = 'Van Heusen'  

 
 