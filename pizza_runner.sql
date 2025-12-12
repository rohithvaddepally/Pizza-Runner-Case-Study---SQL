/************************************************************************A-Pizza Metrics************************************************************************/

#1 How many pizzas were ordered?

SELECT count(pizza_id) as pizzas_ordered
FROM customer_orders;

###A total of 14 pizzas were ordered.###


#2 How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) AS orders
FROM customer_orders;

###10 orders were made.###



#3 How many successful orders were delivered by each runner?

#3.1
SELECT runner_id,
COUNT(
      CASE
         WHEN cancellation =  '' 
              THEN 'NULL'
         WHEN TRIM(LOWER(cancellation))  = '' 
              THEN 'NULL'
         WHEN TRIM(LOWER(cancellation))  = 'null' 
              THEN 'NULL'
      END) AS  orders_delivered
FROM runner_orders
GROUP BY runner_id;

#3.2 correct one with pickup_time column
SELECT runner_id,
       COUNT(runner_id) AS orders_delivered
FROM runner_orders
     WHERE pickup_time != 'null'
GROUP BY runner_id;


#3.3 correct one with cancellation column 
SELECT runner_id,
       COUNT(runner_id) AS orders_delivered
FROM runner_orders
     WHERE cancellation IS NULL OR cancellation = 'null' OR cancellation = 'nan' OR cancellation = ''
GROUP BY runner_id;

###runner-1 made 4, runner-2 made 3, runner-3 made 1.###



#4 How many of each type of pizza was delivered?
SELECT pn.pizza_name,
       COUNT(co.pizza_id) as number_of_pizzas
FROM customer_orders co
LEFT JOIN runner_orders ro
	 ON co.order_id = ro.order_id
LEFT JOIN pizza_names pn
     ON co.pizza_id = pn.pizza_id
WHERE ro.pickup_time IS NOT NULL
      AND (ro.cancellation IS NULL OR ro.cancellation = 'null' OR ro.cancellation = 'nan' OR ro.cancellation = '')
GROUP BY pn.pizza_name;

###9 meatlovers & 3 vegetarian pizzas were delivered.###




#5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,
       SUM( CASE 
                WHEN pizza_name = 'Meatlovers' THEN 1 
                ELSE 0 
                END) AS Meatlovers,
	   SUM( CASE 
                WHEN pizza_name = 'Vegetarian' THEN 1
                ELSE 0
                END) AS Vegetarians
FROM (
      SELECT co.customer_id,
             pn.pizza_name
      FROM customer_orders co
      LEFT JOIN pizza_names pn
           ON co.pizza_id = pn.pizza_id
	) AS x
GROUP BY customer_id
ORDER BY customer_id;

/*customer_id   Meatlovers    Vegetarians
   101	             2	           1
   102	             2	           1
   103	             3	           1 
   104	             3	           0
   105	             0	           1*/





#6 What was the maximum number of pizzas delivered in a single order?     

#without CTE
SELECT co.order_id,
       COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
LEFT JOIN runner_orders ro
	 ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
      AND (ro.cancellation IS NULL OR ro.cancellation = 'null' OR ro.cancellation = 'nan' OR ro.cancellation = '')
GROUP BY co.order_id
ORDER BY total_pizzas DESC
LIMIT 1;


# using CTE
WITH cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR cancellation = 'null' 
                 OR cancellation = 'nan' 
                 OR cancellation = ''
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),
delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
)

SELECT co.order_id,
       COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN delivered_orders do
	 ON co.order_id = do.order_id
GROUP BY co.order_id
ORDER BY total_pizzas DESC
LIMIT 1;

### order number 4 has 3 pizzas delivered which is the highest.###





#7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

#solution 1: CASE statement without TRIM and LOWER
#table cleaned_runner_orders where it cleans the cancellation column and replaces null,nan,'' with NULL
WITH cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR cancellation = 'null' 
                 OR cancellation = 'nan' 
                 OR cancellation = ''
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),
delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
),

#table for changes made or not
change_table AS (
SELECT co.order_id,
       co.customer_id,
       (CASE 
            WHEN (co.exclusions OR co.extras) IS NULL 
				 OR (co.exclusions OR co.extras) = ''
                 OR (co.exclusions OR co.extras) = 'null'
		    THEN 'nochangesmade'
		    ELSE 'changesmade'
		END) AS changed_or_not
FROM customer_orders co
JOIN delivered_orders d
     ON co.order_id = d.order_id
)

SELECT customer_id,
       SUM(
            CASE 
                WHEN changed_or_not = 'nochangesmade' 
                THEN 1 ELSE 0 
			END) AS pizzas_with_no_change,
		SUM(
            CASE 
                WHEN changed_or_not = 'changesmade' 
                THEN 1 ELSE 0
			END) AS pizzas_with_change
FROM change_table 
GROUP BY customer_id
ORDER BY customer_id;


# solution 2 : CASE statement WITH TRIM & LOWER
#table cleaned_runner_orders where it cleans the cancellation column and replaces null,nan,'' with NULL
WITH cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR TRIM(LOWER(cancellation)) IN ('', 'null', 'nan')
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),
delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
),

#table for changes made or not
change_table AS (
SELECT co.order_id,
       co.customer_id,
       (CASE 
            WHEN (co.exclusions IS NULL OR TRIM(LOWER(co.exclusions)) IN ('', 'null'))
             AND (co.extras IS NULL OR TRIM(LOWER(co.extras)) IN ('', 'null'))
		    THEN 'nochangesmade'
		    ELSE 'changesmade'
		END) AS changed_or_not
FROM customer_orders co
JOIN delivered_orders d
     ON co.order_id = d.order_id
)

SELECT customer_id,
       SUM(
            CASE 
                WHEN changed_or_not = 'nochangesmade' 
                THEN 1 ELSE 0 
			END) AS pizzas_with_no_change,
		SUM(
            CASE 
                WHEN changed_or_not = 'changesmade' 
                THEN 1 ELSE 0
			END) AS pizzas_with_change
FROM change_table 
GROUP BY customer_id
ORDER BY customer_id;
            
/*customer_id  pizzas_with_change  pizzas_with_no_change       
101	0	2
102	0	3
103	3	0
104	2	1
105	1	0*/





#8. How many pizzas were delivered that had both exclusions and extras?
WITH cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR TRIM(LOWER(cancellation)) IN ('', 'null', 'nan')
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),
delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
),

both_change_table AS(
SELECT co.order_id,
       co.customer_id,
       co.pizza_id,
       co.exclusions,
       co.extras,
       (CASE 
            WHEN (co.exclusions AND co.extras) IS NULL 
				 OR (co.exclusions AND co.extras) = ''
                 OR (co.exclusions AND co.extras) = 'null'
		    THEN 'nobothchangesmade'
		    ELSE 'bothchangesmade'
		END) AS both_changed_or_not
FROM customer_orders co
JOIN delivered_orders d
     ON co.order_id = d.order_id
)

SELECT COUNT(pizza_id) AS pizzacount,
       both_changed_or_not
FROM both_change_table
GROUP BY both_changed_or_not;

 ###only 1 pizza had both changes made and 11 has no changes made.###
 
 
 
 

#9.What was the total volume of pizzas ordered for each hour of the day?
#extarcting minute
SELECT TIME(order_time) AS order_time_only,
       EXTRACT(MINUTE FROM order_time) AS order_minute
FROM customer_orders;


#extarcting second
SELECT TIME(order_time) AS order_time_only,
       EXTRACT(SECOND FROM order_time) AS order_second
FROM customer_orders;


#extacing hour and grouping by order_hour
SELECT #TIME(order_time) AS order_time_only,
       EXTRACT(HOUR FROM order_time) AS order_hour,
       COUNT(pizza_id) AS pizzas
FROM customer_orders
GROUP BY order_hour
ORDER BY order_hour;

/* order_hour   pizzas
11	1
13	3
18	3
19	1
21	3
23	3*/






#10.What was the volume of orders for each day of the week?
#orders for each day(date)
SELECT #DATE(order_time) AS order_date_only,
       DAY(order_time) AS order_day,
       COUNT(order_id) AS orders
FROM customer_orders
GROUP BY order_day
ORDER BY order_day;


#orders for ach weekday
SELECT DAYNAME(order_time) AS weekday_name,
       COUNT(order_id) AS orders
FROM customer_orders
GROUP BY weekday_name
ORDER BY FIELD(weekday_name,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

/*weekday_name   orders
Wednesday	5
Thursday	3
Friday	    1
Saturday	5*/







/**************************************************************************B. Runner and customer Experience****************************************************/

#1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
WITH week_window AS (
	SELECT runner_id,
            registration_date,
            FLOOR(DATEDIFF(registration_date, '2021-01-01')/7) + 1 AS week_number
	FROM runners
    )
    SELECT COUNT(runner_id) AS runners,
           week_number
	FROM week_window
    GROUP BY week_number;

/* runners   week_number   
   2	1
   1	2
   1	3 */
    
    
    
    

                
#2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT ro.runner_id,
       ROUND(AVG(timestampdiff(MINUTE, co.order_time, ro.pickup_time))) AS average_diff_minutes
FROM customer_orders co
JOIN runner_orders ro
     ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL AND (ro.cancellation IS NULL 
                                      OR TRIM(LOWER(ro.cancellation)) IN ('', 'null', 'nan'))
GROUP BY ro.runner_id;

/*runner_id    average_diff_minutes
1	15
2	23
3	10*/





#3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH order_avg_prep_time AS(
SELECT co.order_id,
       COUNT(co.pizza_id) as pizzas,
	   ROUND(AVG(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time))) AS Avg_order_preparation_time
FROM customer_orders co
JOIN runner_orders ro
	 ON co.order_id = ro.order_id
WHERE ro.pickup_time!='null'
GROUP BY co.order_id
)
SELECT (pizzas) AS number_of_pizzas_per_order,
       ROUND(AVG(Avg_order_preparation_time)) AS avg_prep_time_minutes
FROM order_avg_prep_time
GROUP BY pizzas;

### yes, there is a correlation between number of pizzas and time taken to prepare them. If there are more number of pizzas per order increases, average prep time also increases.###








#4. What was the average distance travelled for each customer?
WITH cleaned_distance AS 
(SELECT order_id,
       (CASE 
           WHEN distance IS NULL
                OR TRIM(LOWER(distance)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(distance, '[^0-9\.]','') AS DECIMAL(5,2))
	   END ) AS distance_km
FROM runner_orders
)

SELECT co.customer_id,
       ROUND(AVG(cd.distance_km),1) AS average_distance_travelled_in_km
FROM customer_orders co
LEFT JOIN cleaned_distance cd
          ON co.order_id = cd.order_id
GROUP BY co.customer_id;

/*customer_id    average_distance_travelled_in_km
101	20.0
102	16.3
103	23.0
104	10.0
105	25.0*/






#5. What was the difference between the longest and shortest delivery times for all orders?
WITH cleaned_duration AS 
(SELECT order_id,
       (CASE 
           WHEN duration IS NULL
                OR TRIM(LOWER(duration)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(duration, '[^0-9]','') AS UNSIGNED)
	   END ) AS duration_minutes
FROM runner_orders
)

SELECT (MAX(duration_minutes))-(MIN(duration_minutes)) AS diff
FROM cleaned_duration;

### 30mins difference.###







#6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH cleaned_runner_orders AS 
(SELECT runner_id,
        order_id,
       (CASE 
           WHEN distance IS NULL
                OR TRIM(LOWER(distance)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(distance, '[^0-9\.]','') AS DECIMAL(5,0))
	   END ) AS distance_km,
       (CASE 
           WHEN duration IS NULL
                OR TRIM(LOWER(duration)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(duration, '[^0-9]','') AS UNSIGNED)
	   END ) AS duration_minutes,
       (CASE 
            WHEN cancellation IS NULL 
                 OR TRIM(LOWER(cancellation)) IN ('', 'null', 'nan')
                THEN NULL
            ELSE cancellation
        END) AS cancellation_clean
FROM runner_orders
)
 
SELECT runner_id,
       order_id,
       distance_km,
       duration_minutes,
       ROUND((distance_km)/(duration_minutes/60),2) AS speed_kmm
FROM cleaned_runner_orders
 WHERE cancellation_clean IS NULL
      AND duration_minutes IS NOT NULL
      AND distance_km IS NOT NULL
ORDER BY runner_id, order_id ASC;

/*runner_id   order_id   distance_km   duration_minutes    speed_kmm
1	1	20	32	37.50
1	2	20	27	44.44
1	3	13	20	39.00
1	10	10	10	60.00
2	4	23	40	34.50
2	7	25	25	60.00
2	8	23	15	92.00
3	5	10	15	40.00*/






#7. What is the successful delivery percentage for each runner?
WITH cleaned_delivered_orders AS (
        SELECT runner_id,
        order_id,
        pickup_time,
       (CASE 
            WHEN cancellation IS NULL 
                 OR TRIM(LOWER(cancellation)) IN ('', 'null', 'nan')
                THEN NULL
            ELSE cancellation
        END) AS cancellation_clean
        FROM runner_orders
),

attempts AS (
		  SELECT runner_id,
          COUNT(*) AS total_attempts
          FROM cleaned_delivered_orders
          GROUP BY runner_id
          ),
          
successful AS (
          SELECT runner_id,
                 COUNT(*) AS successful_deliveries
		  FROM cleaned_delivered_orders
          WHERE pickup_time IS NOT NULL
                AND cancellation_clean IS NULL
		  GROUP BY runner_id
)

SELECT 
    a.runner_id,
    a.total_attempts,
    s.successful_deliveries,
    ROUND((s.successful_deliveries / a.total_attempts) * 100, 0) AS success_percentage
FROM attempts a
JOIN successful s
     ON a.runner_id = s.runner_id 
ORDER BY a.runner_id;

/*runner_id    total_attempts     successful_deliveries     success_percentage
1	4	4	100
2	4	3	75
3	2	1	50*/






/*****************************************************************************************C. Ingredient Optimisation*******************************************************************************/

#1. What are the standard ingredients for each pizza?
WITH RECURSIVE split_toppings AS ( 
 SELECT pizza_id,
	   TRIM(SUBSTRING_INDEX(toppings,',',1)) AS topping_id,
       SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings,',',1)) + 2) AS remaining
	FROM pizza_recipes
    
    UNION ALL

    -- Recursive: keep splitting until empty
    SELECT
        pizza_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS topping_id,
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_toppings
    WHERE remaining <> ''
),

topping_names AS (
SELECT st.pizza_id, 
       pt.topping_id,
       pt.topping_name,
       ROW_NUMBER() OVER (PARTITION BY st.pizza_id ORDER BY st.topping_id) AS rn
FROM split_toppings st
LEFT JOIN pizza_toppings pt 
          ON st.topping_id = pt.topping_id
)

SELECT 
     MAX(CASE WHEN pizza_id = 1 THEN topping_name END) AS Meatlovers,
     MAX(CASE WHEN pizza_id = 2 THEN topping_name END) AS Vegetarian
FROM topping_names
GROUP BY rn;

/*Meatlovers    Vegetarian
Bacon	   Tomatoes
Salami	   Tomato Sauce
BBQ Sauce  Cheese
Beef	   Mushrooms
Cheese	   Onions
Chicken	   Peppers
Mushrooms  NULL
Pepperoni  NULL*/







#2.What was the most commonly added extra?
WITH RECURSIVE split_extras AS (
     
	SELECT order_id,
            TRIM(SUBSTRING_INDEX(extras,',',1)) AS topping_id,
            SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras,',',1)) + 2) AS remaining
	FROM customer_orders
    WHERE  extras IS NOT NULL 
                  AND TRIM(LOWER(extras)) NOT IN ('', 'null')
                  
                  
    UNION ALL
    
	SELECT order_id,
           TRIM(SUBSTRING_INDEX(remaining,',',1)) AS topping_id,
           SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining,',',1)) + 2)
	FROM split_extras
    WHERE remaining <> ''
)

SELECT pt.topping_name,
       COUNT(se.topping_id) AS mostly_added
FROM split_extras se
LEFT JOIN pizza_toppings pt
          ON se.topping_id = pt.topping_id
GROUP BY pt.topping_name;

###Bacon is the most commonly added extra on a pizza.###







#3. What was the most common exclusion?
WITH RECURSIVE split_exclusions AS (

	   SELECT order_id,
              TRIM(SUBSTRING_INDEX(exclusions,',',1)) AS topping_id,
              SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions,',',1)) + 2) AS remaining
	   FROM customer_orders
       WHERE exclusions IS NOT NULL 
                  AND TRIM(LOWER(exclusions)) NOT IN ('', 'null')
                  
	  UNION ALL
       
	  SELECT order_id,
             TRIM(SUBSTRING_INDEX(remaining,',',1)) AS topping_id,
              SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining,',',1)) + 2)
	  FROM split_exclusions
      WHERE remaining <> ''
)

SELECT pt.topping_name,
       COUNT(se.topping_id) AS mostly_excluded
FROM split_exclusions se
LEFT JOIN pizza_toppings pt
          ON se.topping_id = pt.topping_id
GROUP BY pt.topping_name;

###cheese is mostly excluded.###
          





/*************************************************************************************D. Pricings and Ratings**************************************************************************/

#1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR cancellation = 'null' 
                 OR cancellation = 'nan' 
                 OR cancellation = ''
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),

delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
)

SELECT 
       CONCAT('$',SUM( CASE 
             WHEN pizza_id = 1
             THEN 12
             WHEN pizza_id = 2
             THEN 10
		 END )) AS total_sales
FROM delivered_orders do
JOIN customer_orders co
     ON do.order_id = co.order_id;

### total_sales = $138.###     
     
     
     





#2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra (along with If a Meat Lovers pizza costs $12 and Vegetarian costs $10)- only successfully delivered
WITH RECURSIVE split_extras AS (
	SELECT order_id,
           pizza_id,
           ROW_NUMBER() OVER (PARTITION BY order_id, pizza_id ORDER BY (SELECT 1)) AS pizza_instance,
		   TRIM(SUBSTRING_INDEX(extras,',',1)) AS topping_id,
		   SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras,',',1)) + 2) AS remaining
	FROM customer_orders
                  
                  
    UNION ALL
    
	SELECT order_id,
           pizza_id,
           pizza_instance,
           TRIM(SUBSTRING_INDEX(remaining,',',1)) AS topping_id,
           SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining,',',1)) + 2)
	FROM split_extras
    WHERE remaining <> ''
),

pizzatoppingcharges AS (
SELECT order_id,
       pizza_id,
       pizza_instance,
       SUM( CASE WHEN topping_id IS NULL 
                 OR topping_id = 'null' 
                 OR topping_id = 'nan' 
                 OR topping_id = ''
			  THEN 0
		      ELSE 1
		 END) AS topping_charges_per_order,
         ( CASE 
             WHEN pizza_id = 1
             THEN 12
             WHEN pizza_id = 2
             THEN 10
		 END ) AS pizza_charges_per_order
FROM split_extras
GROUP BY order_id, pizza_id, pizza_instance
ORDER BY order_id, pizza_id, pizza_instance
),

cleaned_runner_orders AS (
SELECT  order_id,
        runner_id,
        pickup_time,
        (CASE 
            WHEN cancellation IS NULL 
                 OR cancellation = 'null' 
                 OR cancellation = 'nan' 
                 OR cancellation = ''
            THEN NULL
            ELSE cancellation
        END )AS cancellation_clean
    FROM runner_orders
),

delivered_orders AS (
SELECT order_id
FROM cleaned_runner_orders
WHERE pickup_time is NOT NULL
      AND cancellation_clean IS NULL
)

SELECT CONCAT('$',SUM(topping_charges_per_order + pizza_charges_per_order)) AS total_sales
FROM delivered_orders deo
JOIN pizzatoppingcharges ptc
     ON deo.order_id = ptc.order_id;
     
###total_sales = $142###     






#3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
     #how would you design an additional table for this new dataset - 
     #generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
     
###refer runner_ratings_table.###     






/*#4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/

WITH cleaned_runner_orders AS 
(SELECT runner_id,
        order_id,
        pickup_time,
       (CASE 
           WHEN distance IS NULL
                OR TRIM(LOWER(distance)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(distance, '[^0-9\.]','') AS DECIMAL(5,0))
	   END ) AS distance_km,
       (CASE 
           WHEN duration IS NULL
                OR TRIM(LOWER(duration)) IN ('','null','nan')     
                THEN NULL
		   ELSE CAST(REGEXP_REPLACE(duration, '[^0-9]','') AS UNSIGNED)
	   END ) AS duration_minutes,
       (CASE 
            WHEN cancellation IS NULL 
                 OR TRIM(LOWER(cancellation)) IN ('', 'null', 'nan')
                THEN NULL
            ELSE cancellation
        END) AS cancellation_clean
FROM runner_orders
),

successful_deliveries AS(
          SELECT *
		  FROM cleaned_runner_orders
          WHERE pickup_time IS NOT NULL
                AND cancellation_clean IS NULL
),

pizza_count AS(
SELECT order_id,
       COUNT(*) AS total_pizzas 
FROM customer_orders
GROUP BY order_id
),

order_summary AS (
      SELECT order_id,
      MIN(customer_id) AS customer_id,
      MIN(order_time) AS order_time
      FROM customer_orders
      GROUP BY order_id
)

SELECT co.customer_id,
       co.order_id,
       sd.runner_id,
	   co.order_time,
       sd.pickup_time,
       CONCAT(TIMESTAMPDIFF(MINUTE, co.order_time, sd.pickup_time),' minutes') AS time_taken_to_pickup,
       sd.duration_minutes,
       ROUND((sd.distance_km/sd.duration_minutes),2) AS avg_del_speed,
       rr.rating ,
       pc.total_pizzas
FROM successful_deliveries sd
JOIN order_summary co
	  ON sd.order_id = co.order_id
JOIN pizza_count pc
      ON pc.order_id = co.order_id
JOIN runner_ratings rr
      ON rr.order_id = co.order_id

/*
customer_id   order_id    runner_id    order_time     pickup_time     time_taken_to_pickup     duration_minutes   avg_del_speed    rating    total_pizzas
101	1	1	2020-01-01 18:05:02	2020-01-01 18:15:34	10 minutes	32	0.63	5	1
101	2	1	2020-01-01 19:00:52	2020-01-01 19:10:54	10 minutes	27	0.74	4	1
102	3	1	2020-01-02 23:51:23	2020-01-03 00:12:37	21 minutes	20	0.65	5	2
103	4	2	2020-01-04 13:23:46	2020-01-04 13:53:03	29 minutes	40	0.58	3	3
104	5	3	2020-01-08 21:00:29	2020-01-08 21:10:57	10 minutes	15	0.67	5	1
105	7	2	2020-01-08 21:20:29	2020-01-08 21:30:45	10 minutes	25	1.00	4	1
102	8	2	2020-01-09 23:54:33	2020-01-10 00:15:02	20 minutes	15	1.53	5	1
104	10	1	2020-01-11 18:34:49	2020-01-11 18:50:20	15 minutes	10	1.00	4	2 */






       

























