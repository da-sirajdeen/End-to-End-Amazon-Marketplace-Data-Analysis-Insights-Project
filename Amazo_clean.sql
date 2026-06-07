use ecommerce
show tables

-- Load and explore dataset structure
SELECT *
FROM amazon
LIMIT 10000;

SELECT count(*) from amazon

-- Ensure correct table naming.
RENAME TABLE ecommerce_clean TO amazon;

-- Duplicate user+product combinations

SELECT user_id, product_id, COUNT(*) 
FROM amazon 
GROUP BY user_id, product_id 
HAVING COUNT(*) > 1;


-- Check null values in key columns.
SELECT 
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
  SUM(CASE WHEN final_price IS NULL THEN 1 ELSE 0 END) AS null_final_price,
  SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating
FROM amazon;

-- final_price should always be <= price

SELECT COUNT(*) AS price_errors
FROM amazon
WHERE final_price > price;

-- Verify: final_price ≈ price - (price * discount/100)

SELECT COUNT(*) AS discount_mismatch
FROM amazon
WHERE ABS(final_price - (price * (1 - discount/100))) > 1;

-- Evaluate brand performance.
SELECT category, subcategory, COUNT(*) AS product_count,
       ROUND(AVG(rating),2) AS avg_rating,
       ROUND(AVG(discount),2) AS avg_discount
FROM amazon
GROUP BY category, subcategory
ORDER BY product_count DESC;


-- Get statistical overview.
SELECT 
  MIN(price), MAX(price),
  MIN(discount), MAX(discount),      
  MIN(final_price), MAX(final_price),
  MIN(rating), MAX(rating),         
  MIN(seller_rating), MAX(seller_rating),
  MIN(stock), MAX(stock),    
  MIN(review_count), MAX(review_count)
FROM amazon;

SELECT customer_id, product_id, COUNT(*)
FROM amazon
GROUP BY customer_id, product_id
HAVING COUNT(*) > 1;

DESCRIBE amazon;

SELECT COUNT(*) AS total_rows
FROM amazon;

-- Analyze seller performance.
SELECT brand, COUNT(*) AS listings,
       ROUND(AVG(final_price), 0) AS avg_price,
       ROUND(AVG(rating), 0) AS avg_rating,
       SUM(stock) AS total_stock
FROM amazon
GROUP BY brand
ORDER BY avg_rating DESC;


SELECT seller_id, COUNT(*) AS products_sold,
       ROUND(AVG(seller_rating), 0) AS avg_seller_rating,
       ROUND(AVG(discount), 0) AS avg_discount_offered
FROM amazon
GROUP BY seller_id
ORDER BY products_sold DESC
LIMIT 2000;


-- Categorize pricing mismatches.
SELECT 
  CASE 
    WHEN (final_price - (price * (1 - discount/100))) > 0 
    THEN 'final_price HIGHER than expected'
    ELSE 'final_price LOWER than expected'
  END AS direction,
  COUNT(*) AS count
FROM amazon
WHERE ABS(final_price - (price * (1 - discount/100))) > 1
GROUP BY direction;

SELECT 
  CASE 
    WHEN ABS(final_price - (price * (1 - discount/100))) <= 1 THEN 'Tiny (≤1)'
    WHEN ABS(final_price - (price * (1 - discount/100))) <= 10 THEN 'Small (1-10)'
    WHEN ABS(final_price - (price * (1 - discount/100))) <= 100 THEN 'Medium (10-100)'
    ELSE 'Large (100+)'
  END AS error_size,
  COUNT(*) AS count
FROM amazon
WHERE ABS(final_price - (price * (1 - discount/100))) > 1
GROUP BY error_size
ORDER BY count DESC;

SELECT user_id, product_id, COUNT(*) AS total
FROM amazon 
GROUP BY user_id, product_id 
HAVING COUNT(*) > 1
ORDER BY total DESC
LIMIT 10;


SELECT 
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS null_subcategory,
  SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS null_brand,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
  SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
  SUM(CASE WHEN final_price IS NULL THEN 1 ELSE 0 END) AS null_final_price,
  SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
  SUM(CASE WHEN review_count IS NULL THEN 1 ELSE 0 END) AS null_review_count,
  SUM(CASE WHEN stock IS NULL THEN 1 ELSE 0 END) AS null_stock,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
  SUM(CASE WHEN seller_rating IS NULL THEN 1 ELSE 0 END) AS null_seller_rating
FROM amazon;

SELECT *
FROM amazon
INTO OUTFILE 'C:/Users/Public/python3.12/Learn/Projects/Amazon.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


select * 
from amazon
limit 100000;


SELECT DISTINCT *
FROM amazon;

CREATE TABLE amazon_clean AS
SELECT DISTINCT *
FROM amazon;

DESCRIBE amazon_clean;

select *
from amazon_clean;

SELECT COUNT(*) AS total_rows
FROM amazon_clean;

SELECT COUNT(*) AS total
FROM amazon;

select *
from amazon_clean;

SELECT DISTINCT location
FROM amazon_clean;

-- Export dataset for external tools.
SET SQL_SAFE_UPDATES = 0;

UPDATE amazon_clean
SET location = CASE
    WHEN location = 'Hyderabad' THEN 'Dubai'
    WHEN location = 'Chennai' THEN 'Abu Dhabi'
    WHEN location = 'Mumbai' THEN 'Sharjah'
    WHEN location = 'Delhi' THEN 'Fujairah'
    WHEN location = 'Bangalore' THEN 'Jumeirah'
    ELSE location
END;

SET SQL_SAFE_UPDATES = 1;

Select *
From amazon_clean

find ~                          # Search from home directory
  -name "Amazon_Clean.sql"      # Look for this specific filename
  -type f                       # Only search for files (not directories)