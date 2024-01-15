-- While answering the Stakeholders questions I found some issues with the data, I moved the discovery to thr top of this file. I have commented the answers section below the discovery section.

-- Error discovery

-- Who are our most loyal customers? We would like to send them special deals/info
WITH subtotal
     AS (SELECT s.customer_id,
                s.quantity,
                Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id)
SELECT c.NAME,
       c.class,
       Sum(Cast(s.quantity AS INT)) AS units_purchased,
       Round(Sum(total), 0)         AS total_sales
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
GROUP  BY c.NAME,
          c.class
ORDER  BY total_sales DESC; 

-- It seem like Semil Webb has purchased double the amount of our next loyal customer, lets make sure there isn't an issue with his sales data
WITH subtotal
     AS (SELECT s.customer_id,
                p.product_name,
                s.quantity,
                Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id)
SELECT c.NAME,
       s.product_name,
       s.quantity,
       s.total
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
WHERE  c.NAME LIKE 'Semil  Webb'
ORDER  BY s.total DESC;

-- Mr. Webb has 2 purchases of 9,999 Helm Of Teleportation, that's one heck of a hat party or we have an error here, lets check the dates to first make sure it isn't a duplicate
WITH subtotal
     AS (SELECT s.customer_id,
                s.date,
                p.product_name,
                s.quantity
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id)
SELECT c.NAME,
       s.date,
       s.product_name,
       s.quantity
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
WHERE  c.NAME LIKE 'Semil  Webb'
       AND s.quantity > 5000; 

-- Seems we have a duplicate entry here on 10/03/2021 for 9,999 Helm's of Teleportation!
-- Let's check if we have other duplicates in the sales table
SELECT sale_id,
       date,
       Count(*) AS cnt
FROM   [bg3].[dbo].[sales]
GROUP  BY sale_id,
          date
HAVING Count(*) > 1
ORDER  BY cnt DESC; 

-- 3809 duplicated rows
WITH dups AS
(
         SELECT   sale_id,
                  date,
                  Count(*) AS cnt
         FROM     [bg3].[dbo].[sales]
         GROUP BY sale_id,
                  date
         HAVING   Count(*) > 1 )
SELECT   a.*
FROM     [bg3].[dbo].[sales] AS a
JOIN     dups                AS b
ON       a.sale_id = b.sale_id
AND      a.date = b.date
ORDER BY a.date DESC;

-- Lets try using distinct on the sales id to clean it up a bit
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         p.product_name,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id)
SELECT c.NAME,
       s.product_name,
       s.quantity,
       s.total
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
WHERE  c.NAME LIKE 'Semil  Webb'
ORDER  BY s.total DESC; 

-- Worked with Mr. Semil Webb, lets look at those top customers once again, it would probably be worth checking with your stakeholders to verify that purchases of 9,999 of a single item are rare
-- We will make a judgement call and say a customer is unlikely to purchase over 5,000 of a single item at a time.
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000)
SELECT c.NAME,
       c.class,
       Sum(Cast(s.quantity AS INT)) AS units_purchased,
       Round(Sum(total), 0)         AS total_sales
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
GROUP  BY c.NAME,
          c.class
ORDER  BY total_sales DESC; 

-- Answering Stakeholder Questions

-- Total Sales
SELECT SUM(Cast(s.quantity AS INT) * Cast(p.price AS FLOAT)) AS Total_Sales
FROM   [bg3].[dbo].[sales] AS s
       INNER JOIN [bg3].[dbo].[all_products] AS p
				ON s.product_id = p.product_id
WHERE	s.quantity <= 5000 AND
		s.product_id not like '';

-- Total Units Sold
SELECT	SUM(CAST(quantity AS int)) AS Total_Units_Sold
FROM	[bg3].[dbo].[sales]
WHERE	quantity <= 5000 AND
		product_id not like '';


-- Can you show our revenue year by year?
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.date,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000 AND
				s.product_id not like '')
SELECT Year(date)           AS Yr,
       Round(Sum(total), 0) AS Revenue
FROM   subtotal
GROUP  BY Year(date)
ORDER  BY Yr; 


-- Which products are the most profitable?
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         p.product_name,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000 AND
				s.product_id not like '')
SELECT product_name,
       Sum(Cast(quantity AS INT)) AS units_sold,
       Round(Sum(total), 0)       AS revenue
FROM   subtotal
GROUP  BY product_name
ORDER  BY revenue DESC; 


-- What category of products are most profitable?
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         p.type,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000 AND
				s.product_id not like '')
SELECT type,
       Round(Sum(total), 0) AS revenue,
	   SUM(CAST(quantity AS int)) AS units_sold
FROM   subtotal
GROUP  BY type
ORDER  BY revenue DESC; 


-- What do our customer demographics look like?
-- Gender
SELECT sex,
       Count(*)                                                      AS cnt,
       Round(Count(*) * 100.0 / (SELECT Count(*)
                                 FROM   [bg3].[dbo].[customers]), 2) AS pct
FROM   [bg3].[dbo].[customers]
GROUP  BY sex; 

-- Let's see how much each gender spends
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         s.quantity,
                         Cast(s.quantity AS FLOAT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000 AND
				s.product_id not like '')
SELECT c.sex,
       Round(Sum(Cast(s.total AS FLOAT)), 0) AS revenue
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON c.customer_id = s.customer_id
GROUP  BY c.sex
ORDER  BY revenue DESC; 

-- Race
SELECT race,
       Count(*)                                                      AS cnt,
       Round(Count(*) * 100.0 / (SELECT Count(*)
                                 FROM   [bg3].[dbo].[customers]), 2) AS pct
FROM   [bg3].[dbo].[customers]
GROUP  BY race
ORDER  BY pct DESC 

-- Let's see how much each race spends
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000)
SELECT c.race,
       Round(Sum(Cast(s.total AS FLOAT)), 0) AS revenue
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON c.customer_id = s.customer_id
GROUP  BY c.race
ORDER  BY revenue DESC; 

-- Class
SELECT class,
       Count(*)                                                      AS cnt,
       Round(Count(*) * 100.0 / (SELECT Count(*)
                                 FROM   [bg3].[dbo].[customers]), 2) AS pct
FROM   [bg3].[dbo].[customers]
GROUP  BY class
ORDER  BY pct DESC; 

-- Let's see how much each class spends
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000)
SELECT c.class,
       Round(Sum(Cast(s.total AS FLOAT)), 0) AS revenue
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON c.customer_id = s.customer_id
GROUP  BY c.class
ORDER  BY revenue DESC; 

-- Who are our most loyal customers? We would liek to send them special deals/info.
WITH subtotal
     AS (SELECT DISTINCT s.sale_id,
                         s.customer_id,
                         s.quantity,
                         Cast(s.quantity AS INT) * Cast(p.price AS FLOAT) AS
                         total
         FROM   [bg3].[dbo].[sales] AS s
                INNER JOIN [bg3].[dbo].[all_products] AS p
                        ON s.product_id = p.product_id
         WHERE  s.quantity <= 5000)
SELECT c.NAME,
       c.class,
       Sum(Cast(s.quantity AS INT)) AS units_purchased,
       Round(Sum(total), 0)         AS total_sales
FROM   subtotal AS s
       INNER JOIN [bg3].[dbo].[customers] AS c
               ON s.customer_id = c.customer_id
GROUP  BY c.NAME,
          c.class
ORDER  BY total_sales DESC;


-- Last purchase date per customer
SELECT	c.name,  
		MAX(CAST(s.date as date)) as last_purchase_date
FROM	[bg3].[dbo].[sales] s
		INNER JOIN [bg3].[dbo].[customers] c
			ON s.customer_id = c.customer_id
GROUP	BY c.name
ORDER	BY last_purchase_date;

-- Verify: Taran  Willowrush 2022-10-31
SELECT	c.name,  
		CAST(s.date as date) as zdate
FROM	[bg3].[dbo].[sales] s
		INNER JOIN [bg3].[dbo].[customers] c
			ON s.customer_id = c.customer_id
WHERE	c.name like 'Taran  Willowrush'
ORDER	BY zdate DESC;