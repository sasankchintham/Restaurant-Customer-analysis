
CREATE TABLE sales (
    customerid VARCHAR(2),
    order_date DATE,
    product_id INTEGER
);


INSERT INTO sales (customerid, order_date, product_id)
VALUES 
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);


CREATE TABLE menu (
    product_id INTEGER,
    product_name VARCHAR(5),
    price INTEGER
);


INSERT INTO menu (product_id, product_name, price)
VALUES 
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);


CREATE TABLE members (
    customer_id VARCHAR(1),
    join_date DATE
);

INSERT INTO members (customer_id, join_date)
VALUES 
('A', '2021-01-07'),
('B', '2021-01-09');

select * from sales;
select * from menu;
select * from members;
-- what is the total amount each customer spent at the restaurant
select s.customerid,sum(m.price) as total_price from sales s left join menu m on s.product_id=m.product_id
group by s.customerid;
-- how many das has each customer visited the restaurant
select customerid,count(order_date) as No_of_visits from sales group by customerid;
-- what is the first item purchased by each customer
select s.customerid,product_name,order_date from menu m join sales s on m.product_id=s.product_id
where s.order_date=(select min(order_date) from sales where customerid=s.customerid)
order by order_date;
-- what is the most purchased item on the menu and how many times it is purchased by all customers
select m.product_name,count(s.product_id) as purchased_count
 from sales s join menu m on s.product_id=m.product_id
 group by m.product_name
 order by purchased_count desc
 limit 1;
 -- which item was most popular for each customer
SELECT s.customerid, m.product_name, COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customerid, m.product_name
HAVING COUNT(s.product_id) = (
    SELECT MAX(item_count)
    FROM (
        SELECT COUNT(s2.product_id) AS item_count
        FROM sales s2
        WHERE s2.customerid = s.customerid
        GROUP BY s2.product_id
    ) AS subquery
)
ORDER BY s.customerid;

-- which item was purchased by customer first after they became a member
SELECT s.customerid, m.product_name, s.order_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customerid = mem.customer_id
WHERE s.order_date >= mem.join_date
AND s.order_date = (
    SELECT MIN(order_date)
    FROM sales s2
    WHERE s2.customerid = s.customerid
    AND s2.order_date >= mem.join_date
)
ORDER BY s.customerid;
-- which item was purchased just before they became customer
SELECT s.customerid, m.product_name, s.order_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customerid = mem.customer_id
WHERE s.order_date < mem.join_date
AND s.order_date = (
    SELECT MAX(order_date)
    FROM sales s2
    WHERE s2.customerid = s.customerid
    AND s2.order_date < mem.join_date
)
ORDER BY s.customerid;
-- what are the total items and total amount each customer spend before they became member
SELECT s.customerid, 
       COUNT(s.product_id) AS total_items, 
       SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customerid = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customerid;

 