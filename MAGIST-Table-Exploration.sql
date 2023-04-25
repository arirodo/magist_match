USE magist;

/*How many orders are there in the dataset? 99441*/
SELECT 
    COUNT(*)
FROM
    orders;
    
    
 /*Are orders actually delivered? 96.4K got delivered*/   
SELECT 
    order_status, COUNT(*)
FROM
    orders
GROUP BY order_status;


 /*Is Magist having user growth? - It seems so, year over year with maybe some seasonality*/   
SELECT 
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp),
    COUNT(DISTINCT (customer_id))
FROM
    orders
GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp);


/*How many products are there on the products table? - 32951*/
SELECT 
    COUNT(DISTINCT (product_id)) AS different_products
FROM
    products;
    
    
/*Which are the categories with the most products? - cama_mesa_banho, esporte_lazer, moveis_decoracao, beleza_saude, utilidades_domesticas*/
SELECT 
    product_category_name AS category,
    COUNT(DISTINCT (product_id)) AS different_products
FROM
    products
GROUP BY category
ORDER BY different_products DESC;



/*How many of those products were present in actual transactions? -32951 */
SELECT 
    COUNT(DISTINCT (product_id))
FROM
    order_items;

/*What’s the price for the most expensive and cheapest products? - 6735 and .85 */
SELECT 
    MAX(price) AS expensive_product,
    MIN(price) AS cheapest_product
FROM
    order_items;
 
    
    
/*What are the highest and lowest payment values? - max = 13664.1 and min =0 */
SELECT 
    MAX(payment_value) AS highest_payment,
    MIN(payment_value) AS lowest_payment
FROM
    order_payments;


/*What categories of tech products does Magist have?*/
SELECT DISTINCT
    (product_category_name_english),
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items AS oi ON products.product_id = oi.product_id
        INNER JOIN
    orders ON oi.order_id = orders.order_id
HAVING category_tech_product != 'other_categories'
ORDER BY product_category_name_english DESC;



/* How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
What’s the average price of the products being sold? */

SELECT 
    MAX(price),
    MIN(price),
    CAST(AVG(price) AS DECIMAL (10 , 2 )) AS avg_price,
    COUNT(DISTINCT (products.product_id)) AS unique_products,
    COUNT(price) AS total_sold,
    CAST(COUNT(price) / (SELECT 
                (COUNT(price))
            FROM
                order_items)
        AS DECIMAL (10 , 2 )) AS 'percentage_of_total',
    COUNT(DISTINCT (orders.customer_id)) AS nr_customers,
    COUNT(oi.product_id) / COUNT(DISTINCT (orders.customer_id)) AS avg_item_sold_customer,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items AS oi ON products.product_id = oi.product_id
        INNER JOIN
    orders ON oi.order_id = orders.order_id
GROUP BY category_tech_product
ORDER BY nr_customers DESC;


/* Are expensive tech products popular? */

SELECT 
    CAST(AVG(price) AS DECIMAL (10 , 2 )) AS avg_price,
    COUNT(DISTINCT (products.product_id)) AS unique_products,
    CAST((COUNT(DISTINCT (products.product_id)) / 32951)
        AS DECIMAL (10 , 2 )) AS percentage_unique,
    COUNT(price) AS total_sold,
    CAST(COUNT(price) /  (SELECT 
                (COUNT(price))
            FROM
                order_items) AS DECIMAL (10 , 2 )) AS percentage_sold_of_total,
    COUNT(DISTINCT (orders.customer_id)) AS nr_customers,
    CAST((COUNT(DISTINCT (orders.customer_id)) /  (SELECT (COUNT(DISTINCT (orders.customer_id)))
            FROM
                orders))
        AS DECIMAL (10 , 2 )) AS percentage_of_unique_customers,
    COUNT(oi.product_id) / COUNT(DISTINCT (orders.customer_id)) AS avg_item_sold_customer,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product,
    CASE
        WHEN price <= 29.99 THEN 'low'
        WHEN price <= 74.9 THEN 'medium'
        WHEN price <= 149.99 THEN 'high'
        ELSE 'highend'
    END AS pricing
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items AS oi ON products.product_id = oi.product_id
        INNER JOIN
    orders ON oi.order_id = orders.order_id
GROUP BY category_tech_product , pricing
ORDER BY category_tech_product , avg_price ASC;

/* How many months of data are included in the magist database? -25 */
SELECT DISTINCT
    (MONTH(order_purchase_timestamp)) AS months,
    YEAR(order_purchase_timestamp) AS years
FROM
    orders
ORDER BY years , months;

/*How many sellers are there?*/

select count(distinct(seller_id)) from sellers;

/* Join Tables with classification category product*/
SELECT 
    product_category_name_english,
    products.product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    order_id,
    order_item_id,
    sellers.seller_id,
    shipping_limit_date,
    price,
    freight_value,
    seller_zip_code_prefix,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id;
   
    
/* How many Tech sellers are there? - 3694 sellers What percentage of overall sellers are Tech sellers? */

SELECT 
    COUNT(DISTINCT (sellers.seller_id)) AS nr_sellers,
    CAST((COUNT(DISTINCT (sellers.seller_id)) / (SELECT 
                (COUNT(DISTINCT (sellers.seller_id)))
            FROM
                sellers))
        AS DECIMAL (10 , 2 )) AS percentage_total_sellers,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id
GROUP BY category_tech_product;



/*What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers? */

SELECT 
    FORMAT(SUM(price), 'C0') AS sales,
    COUNT(order_items.product_id) as products_sold,
    cast((SUM(price)/13591644) as decimal (10,2)) as perc_total_sales,
    cast((COUNT((order_items.product_id))/112650) as decimal (10,2)) as perc_products_sold,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id
GROUP BY category_tech_product WITH ROLLUP 
ORDER BY sales DESC;

/*Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?*/

SELECT 
    FORMAT(SUM(price), 'C0') AS sales,
    COUNT(order_items.product_id) AS products_sold,
    CAST((SUM(price) / 13591644) AS DECIMAL (10 , 2 )) AS perc_total_sales,
    CAST((COUNT((order_items.product_id)) / 112650)
        AS DECIMAL (10 , 2 )) AS perc_products_sold,
    CAST(((SUM(price) / COUNT(DISTINCT (sellers.seller_id))) / 25)
        AS DECIMAL (10 , 2 )) AS avg_monthly_revenue,
    CASE
        WHEN
            product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'fixed_telephony',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_tech_product
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    orders ON order_items.order_id = orders.order_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id
GROUP BY category_tech_product WITH ROLLUP
ORDER BY sales DESC;

/*What’s the average time between the order being placed and the product being delivered?*/

SELECT 
    AVG(DATEDIFF(o.order_delivered_customer_date,
            o.order_purchase_timestamp)) AS avg_days_delivery,
    CASE
        WHEN
            pt.product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_type
FROM
    product_category_name_translation pt
        INNER JOIN
    products p1 ON pt.product_category_name = p1.product_category_name
        INNER JOIN
    order_items oi ON p1.product_id = oi.product_id
        INNER JOIN
    orders o ON oi.order_id = o.order_id
        INNER JOIN
    order_payments op ON o.order_id = op.order_id
GROUP BY category_type WITH ROLLUP;


/*How many orders are delivered on time vs orders delivered with a delay?*/

SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
                order_estimated_delivery_date)) AS avg_DD_delivery_before_est,
    AVG(DATEDIFF(order_delivered_customer_date,
                order_purchase_timestamp)) AS avg_DD_delivery_after_purch,
    COUNT(order_id) AS orders,
    CAST((COUNT(order_id) / (select COUNT(orders.order_id) from orders)) AS DECIMAL (10 , 2 )) AS percentage_deliveries,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'ontime'
        ELSE 'late'
    END AS delivery
FROM
    orders
GROUP BY delivery WITH ROLLUP;


/*Is there any pattern for delayed orders, e.g. big products being delayed more often?*/
/*Delivery by time and weight - Nothing significant. Light orders have a slight better deliverability than the other ones (.04% points)*/
SELECT 
    ROUND(AVG(product_weight_g), 0) AS avg_weight_gr,
    ROUND(COUNT(orders.order_id) / (select COUNT(orders.order_id) from orders), 2) AS perc_orders,
    CASE
        WHEN product_weight_g <= 300 THEN 'light'
        WHEN product_weight_g <= 700 THEN 'normal'
        WHEN product_weight_g <= 1800 THEN 'heavy'
        ELSE 'superheavy'
    END AS weight_scale,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'ontime'
        ELSE 'late'
    END AS delivery
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    orders ON order_items.order_id = orders.order_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id
GROUP BY delivery , weight_scale;


SELECT 
    ROUND(AVG(product_weight_g), 0) AS avg_weight_gr,
    COUNT(DISTINCT (orders.order_id)) AS orders,
    ROUND((COUNT(DISTINCT (orders.order_id)) / (select (COUNT(DISTINCT (orders.order_id))) from orders)),
            2) AS perc_deliveries,
    CASE
        WHEN
            pcnt.product_category_name_english IN ('audio' , 'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_type,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'ontime'
        ELSE 'late'
    END AS delivery
FROM
    product_category_name_translation AS pcnt
        INNER JOIN
    products ON pcnt.product_category_name = products.product_category_name
        INNER JOIN
    order_items ON products.product_id = order_items.product_id
        INNER JOIN
    orders ON order_items.order_id = orders.order_id
        INNER JOIN
    sellers ON order_items.seller_id = sellers.seller_id
GROUP BY category_type , delivery WITH ROLLUP;

/*Create View from TABLE PRODUCTS + translation save as products.csv */
CREATE VIEW product_tech_category AS
SELECT 
    product_id, product_category_name_english as product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, round(((product_width_cm*product_height_cm*product_length_cm)/5000),2) as volumetric,
    CASE
        WHEN
            pcnt.product_category_name_english IN ('audio' , 
				'auto',
                'cine_photo',
                'consoles_games',
                'home_appliances',
                'home_appliances_2',
                'electronics',
                'small_appliances',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'watches_gifts',
                'security_and_services',
                'signaling_and_security',
                'tablets_printing_image',
                'telephony',
                'air_conditioning',
                'musical_instruments',
                'fixed_telephony')
        THEN
            'tech_product'
        ELSE 'other_categories'
    END AS category_type,
      CASE
        WHEN product_weight_g <= 300 THEN 'light'
        WHEN product_weight_g <= 700 THEN 'normal'
        WHEN product_weight_g <= 1800 THEN 'heavy'
        ELSE 'superheavy'
    END AS weight_scale,

     CASE
        WHEN ((product_width_cm*product_height_cm*product_length_cm)/5000) <= 0.57 THEN 'small'
        WHEN ((product_width_cm*product_height_cm*product_length_cm)/5000) <= 1.37 THEN 'normal'
        WHEN ((product_width_cm*product_height_cm*product_length_cm)/5000) <= 3.69 THEN 'big'
        ELSE 'superbig'
    END AS volumetric_scale
    
FROM
    products
        INNER JOIN
    product_category_name_translation AS pcnt ON products.product_category_name = pcnt.product_category_name limit 40000;

/*Creation of a new TABLE from ORDERS with delivery categorization save as orders.csv*/
CREATE TABLE delivery_orders( 
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(order_delivered_carrier_date, order_purchase_timestamp) AS dispatch_days,
    DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date) AS delivery_carrier_days,
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp ) AS delivery_days,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'ontime'
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
        ELSE 'unavailable'
    END AS delivery,
    
    CASE
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 7 THEN 'fast'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 10 THEN 'normal'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 16 THEN 'slow'
		WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 220 THEN 'superslow'
        ELSE 'unavailable'
    END AS benchmark_magist
    
FROM
    orders
LIMIT 1000000);

/*Creation of a new TABLE from ORDERS_ITEMS with price categorization save as order_items.csv*/
CREATE TABLE price_categorization(

SELECT 
    *,
    CASE
        WHEN price <= 39.99 THEN 'low'
        WHEN price <= 74.99 THEN 'medium'
        WHEN price <= 134.99 THEN 'high'
        ELSE 'highend'
    END AS pricing_benchmark,
    CASE
        WHEN price <= 29.99 THEN 'low'
        WHEN price <= 74.9 THEN 'medium'
        WHEN price <= 149.99 THEN 'high'
        ELSE 'highend'
    END AS pricing_benchmark_tech
FROM
    order_items
LIMIT 1000000);

/*score reviews*/
SELECT 
    (COUNT(review_id) / (SELECT 
            COUNT(*)
        FROM
            order_reviews)),
    review_score
FROM
    order_reviews
GROUP BY review_score WITH ROLLUP;


/*avg price category*/
SELECT 
    product_category_name,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(order_id) AS orders,
    COUNT(DISTINCT (seller_id)) AS sellers
FROM
    order_items
        INNER JOIN
    product_tech_category AS ptc ON order_items.product_id = ptc.product_id
GROUP BY product_category_name
ORDER BY orders DESC;
