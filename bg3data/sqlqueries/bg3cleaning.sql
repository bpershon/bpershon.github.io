-- Updating the all products price column

-- Convert all CP price values into GP (1 CP == 1/100 GP)
UPDATE [bg3].[dbo].[all_products]
SET price = CAST(REPLACE([price], ' cp', '') AS float) / 100
WHERE price like '%cp'

-- Convert all SP price values into GP (1 SP == 1/10 GP)
UPDATE [bg3].[dbo].[all_products]
SET price = CAST(REPLACE([price], ' sp', '') AS float) / 10
WHERE price like '%sp'

-- Remove all GP characters from price column
UPDATE [bg3].[dbo].[all_products]
SET price = REPLACE([price], ' gp', '')
WHERE price like '%gp'

-- Verify updates
SELECT * 
FROM [bg3].[dbo].[all_products]


-- Removing redundant data from sub tables (price), would like to have to fetch these from different tables.
ALTER TABLE [bg3].[dbo].[details_adventure_gear]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[details_armor]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[details_magic_items]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[details_poisons]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[details_potions]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[details_weapons]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[sales]
DROP COLUMN price

ALTER TABLE [bg3].[dbo].[sales]
DROP COLUMN product_name

-- Clean the date column from the sale table, has a blank time character string
UPDATE [bg3].[dbo].[sales]
SET date = CONVERT(varchar(10), CAST(date AS date), 101)

-- Removing 72 rows that are missing a sales_id, all show a quantity of 9,999
DELETE FROM [bg3].[dbo].[sales]
WHERE sale_id like '';

-- Removing 116 rows that are missing product_id
DELETE FROM [bg3].[dbo].[sales]
WHERE product_id like '';

-- Delete duplicate rows from the sales table, 3,794
WITH cte([sale_id], [date], [customer_id], [product_id], [quantity],
     duplicatecount)
     AS (SELECT [sale_id],
                [date],
                [customer_id],
                [product_id],
                [quantity],
                Row_number()
                  OVER(
                    partition BY [sale_id], [date], [customer_id], [product_id],
                  [quantity]
                    ORDER BY sale_id) AS DuplicateCount
         FROM   [bg3].[dbo].[sales])
DELETE FROM cte
WHERE  duplicatecount > 1;


