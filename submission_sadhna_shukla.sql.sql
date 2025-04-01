/*==============================================================
    Project : SQL Data Analysis - Business Queries
    Author: Sadhna Shukla
    Date: [October 6, 2024]
    Filename: submission_SadhnaShukla.sql
    Description: This SQL file contains queries for answering various 
                 business questions related to customer, product, and order data.

    Queries Included:
    --------------------------------------------------------------
    1. Query to display customer details with title, full name, email, customer creation date, and category.
    2. Query to display unsold products with calculated discount and inventory value.
    3. Query to display product class details with inventory value over 100,000.
    4. Query to display customers who canceled all orders.
    5. Query to display shipper information for DHL.
    6. Query to display customer details for cash payments with last names starting with 'G'.
    7. Query to display the biggest order volume that fits in Carton ID 10.
    8. Query to display product details and inventory status based on sales and product category.
    9. Query to display products sold with product ID 201 but not shipped to Bangalore and New Delhi.
    10. Query to display details for orders shipped to addresses where the PIN code doesn't start with "5".
    
    ==============================================================
*/





## 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

SELECT  
    'Mr' AS Title,  -- Default title for all  
    UPPER(CUSTOMER_FNAME) AS Full_Name_First,  
    UPPER(CUSTOMER_LNAME) AS Full_Name_Last,  
    CUSTOMER_EMAIL AS Customer_Email,  
    CUSTOMER_CREATION_DATE AS Customer_CreationDate,  
    CASE   
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2005 THEN 'CATEGORY A'  
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) >= 2005 AND EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2011 THEN 'CATEGORY B'  
        ELSE 'CATEGORY C'  
    END AS Customer_Category  
FROM   
    online_customer
    LIMIT 1000;


-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    
    
    SELECT   
    p.PRODUCT_ID,  
    p.PRODUCT_DESC,  
    p.PRODUCT_QUANTITY_AVAIL,  
    p.PRODUCT_PRICE,  
    (p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE,  
    CASE   
        WHEN p.PRODUCT_PRICE > 20000 THEN p.PRODUCT_PRICE * 0.80  -- 20% discount  
        WHEN p.PRODUCT_PRICE > 10000 THEN p.PRODUCT_PRICE * 0.85  -- 15% discount  
        ELSE p.PRODUCT_PRICE * 0.90  -- 10% discount  
    END AS NEW_PRICE  
FROM   
    PRODUCT p  
LEFT JOIN   
    ORDER_ITEMS oi ON p.PRODUCT_ID = oi.PRODUCT_ID  -- Joining with ORDER_ITEMS to find unsold products  
WHERE   
    oi.PRODUCT_ID IS NULL  -- Selecting products that have not been sold (not in ORDER_ITEMS)  
ORDER BY   
    INVENTORY_VALUE DESC;  -- Sorting by inventory value, in decreasing order
    
    
    
    -- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    
SELECT   
    pc.PRODUCT_CLASS_CODE,  
    pc.PRODUCT_CLASS_DESC,  -- Corrected column name  
    COUNT(p.PRODUCT_ID) AS COUNT_OF_PRODUCT_TYPE,  
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE  
FROM   
    PRODUCT p  
JOIN   
    PRODUCT_CLASS pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE  -- Joining with PRODUCT_CLASS  
GROUP BY   
    pc.PRODUCT_CLASS_CODE,   
    pc.PRODUCT_CLASS_DESC  -- Using the corrected column name  
HAVING   
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) > 100000  -- Filtering for inventory value greater than 100,000  
ORDER BY   
    INVENTORY_VALUE DESC  -- Sorting by inventory value in decreasing order  
LIMIT 0, 1000;  -- Optional limit for results



-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    
   SELECT   
    oc.CUSTOMER_ID,  
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS FULL_NAME,  -- Updated column names  
    oc.CUSTOMER_EMAIL,  
    oc.CUSTOMER_PHONE,  
    a.COUNTRY  
FROM   
    ONLINE_CUSTOMER oc  
JOIN   
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID  -- Joining to get the country  
WHERE   
    oc.CUSTOMER_ID NOT IN (  
        SELECT   
            oh.CUSTOMER_ID  
        FROM   
            ORDER_HEADER oh  
        WHERE   
            oh.ORDER_STATUS != 'Cancelled'  -- Assuming 'Cancelled' is the status for canceled orders  
    )  
AND   
    oc.CUSTOMER_ID IN (  
        SELECT   
            oh.CUSTOMER_ID  
        FROM   
            ORDER_HEADER oh  
    );  -- Ensuring the customer has placed at least one order



-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    

    
    SELECT   
    s.SHIPPER_NAME,  
    a.CITY,  
    COUNT(DISTINCT oc.CUSTOMER_ID) AS NUMBER_OF_CUSTOMERS,  
    COUNT(oh.ORDER_ID) AS NUMBER_OF_CONSIGNMENTS_DELIVERED  
FROM   
    SHIPPER s  
JOIN   
    ORDER_HEADER oh ON s.SHIPPER_ID = oh.SHIPPER_ID  
JOIN   
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID  
JOIN   
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID  
WHERE   
    s.SHIPPER_NAME = 'DHL'  -- Use SHIPPER_NAME if the SHIPPER_ID is unknown  
GROUP BY   
    s.SHIPPER_NAME,   
    a.CITY  
LIMIT 9;  -- Limiting results to 9 rows



-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]

SELECT   
    oc.CUSTOMER_ID,  
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,   
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,  
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE  -- Changed to use PRODUCT_PRICE  
FROM   
    ONLINE_CUSTOMER oc  
JOIN   
    ORDER_HEADER oh ON oc.CUSTOMER_ID = oh.CUSTOMER_ID  
JOIN   
    ORDER_ITEMS oi ON oh.ORDER_ID = oi.ORDER_ID  
JOIN   
    PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID  
WHERE   
    oh.PAYMENT_MODE = 'CASH'  
    AND oc.CUSTOMER_LNAME LIKE 'G%'  
GROUP BY   
    oc.CUSTOMER_ID,  
    CUSTOMER_FULL_NAME  
ORDER BY   
    oc.CUSTOMER_ID  
LIMIT 0, 1000;


-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
WITH CartonVolume AS (  
    SELECT   
        CARTON_ID,   
        LEN * WIDTH * HEIGHT AS VOLUME  
    FROM   
        CARTON   
    WHERE   
        CARTON_ID = 10  
),  
  
-- Calculate the total volume for each order  
OrderVolumes AS (  
    SELECT   
        oi.ORDER_ID,  
        SUM(p.WIDTH * p.LEN * p.HEIGHT * oi.PRODUCT_QUANTITY) AS TOTAL_VOLUME  -- Corrected to use p.LEN  
    FROM   
        ORDER_ITEMS oi  
    JOIN   
        PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID  
    GROUP BY   
        oi.ORDER_ID  
)  

-- Select the order with the maximum volume that fits in Carton ID 10  
SELECT   
    ov.ORDER_ID,  
    ov.TOTAL_VOLUME,  
    cv.CARTON_ID  -- Adding Carton ID to the output  
FROM   
    OrderVolumes ov  
JOIN   
    CartonVolume cv ON ov.TOTAL_VOLUME <= cv.VOLUME  -- Ensure the order volume fits in the carton  
ORDER BY   
    ov.TOTAL_VOLUME DESC  
LIMIT 1;  -- Only return the biggest order



-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
-- Create the products table if it doesn't exist  

SELECT   
    p.product_id,  
    p.product_desc,  
    p.product_quantity_avail,  
    COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS quantity_sold,  
    CASE   
        WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN   
            'no sales in past, give discount to reduce inventory'  
        ELSE   
            CASE   
                WHEN p.product_quantity_avail < 0.3 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN   
                    'low inventory, need to add inventory'  
                WHEN p.product_quantity_avail < 0.7 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN   
                    'medium inventory, need to add some inventory'  
                ELSE   
                    'sufficient inventory'  
            END  
    END AS inventory_status  
FROM   
    product p  
LEFT JOIN   
    order_items oi ON p.product_id = oi.PRODUCT_ID  
GROUP BY   
    p.product_id, p.product_desc, p.product_quantity_avail  
LIMIT 0, 1000;



-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    
   SELECT   
    oi.PRODUCT_ID,  
    p.PRODUCT_DESC,  
    SUM(oi.PRODUCT_QUANTITY) AS total_qty  
FROM   
    ORDER_ITEMS oi  
JOIN   
    ORDER_HEADER oh ON oi.ORDER_ID = oh.ORDER_ID  
JOIN   
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID -- Join to get ADDRESS_ID  
JOIN   
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID -- Join to filter by ADDRESS  
JOIN   
    PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID  
WHERE   
    oi.ORDER_ID IN (  
        SELECT   
            oi2.ORDER_ID  
        FROM   
            ORDER_ITEMS oi2  
        WHERE   
            oi2.PRODUCT_ID = 201  
    )  
    AND a.ADDRESS_ID NOT IN (  
        SELECT   
            a2.ADDRESS_ID   
        FROM   
            ADDRESS a2   
        WHERE   
            a2.CITY IN ('Bangalore', 'New Delhi')  
    )  
GROUP BY   
    oi.PRODUCT_ID, p.PRODUCT_DESC  
ORDER BY   
    total_qty DESC  
LIMIT 0, 1000;




-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
    



SELECT   
    oh.ORDER_ID,  
    oc.CUSTOMER_ID,  
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,  
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY  
FROM   
    ORDER_HEADER oh  
JOIN   
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID  
JOIN   
    ORDER_ITEMS oi ON oh.ORDER_ID = oi.ORDER_ID  
JOIN   
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID  
WHERE   
    MOD(oh.ORDER_ID, 2) = 0  -- Ensure the ORDER_ID is even  
    AND a.PINCODE NOT LIKE '5%'  -- PINCODE does not start with '5'  
GROUP BY   
    oh.ORDER_ID, oc.CUSTOMER_ID, CUSTOMER_FULLNAME  
ORDER BY   
    oh.ORDER_ID;

