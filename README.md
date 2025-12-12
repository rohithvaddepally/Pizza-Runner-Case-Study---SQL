# Pizza Runner Case Study - SQL

## ER Diagram
<img width="1155" height="573" alt="pizza_runner_ER_diagram" src="https://github.com/user-attachments/assets/af0fd734-8e4d-49a4-88ab-d9f730d083d4" />


## Tables:
1. customer_orders
   <img width="1068" height="847" alt="customer_orders table" src="https://github.com/user-attachments/assets/bb6ce037-effa-4b39-9ac6-6a42e7a76879" />
   
2. pizza_names
   <img width="288" height="188" alt="pizza_names table" src="https://github.com/user-attachments/assets/65099c7f-1d0b-4817-8ce5-6f8a179b2cc7" />
   
3. pizza_recipes
   <img width="352" height="177" alt="pizza_recipes table" src="https://github.com/user-attachments/assets/d751f883-f08e-4e20-b7c9-de78d0a1ede5" />
   
4. pizza_toppings
   <img width="351" height="725" alt="pizza_toppings table" src="https://github.com/user-attachments/assets/0395dcc8-485b-4f28-a0e6-54b6ea0f2676" />
   
5. runners
   <img width="357" height="282" alt="runners table" src="https://github.com/user-attachments/assets/37d61371-4f48-4008-ace5-139a9d03615a" />
   
6. runner_orders
   <img width="912" height="602" alt="runner_orders table" src="https://github.com/user-attachments/assets/736910a3-8d5a-4066-831f-269d512afbc8" />



## Table created:
1. runner_ratings

## This case study is broken down into 4 different sections:
1. Pizza Metrics (10 questions)
2. Runner and Customer Experience (7 questions)
3. Ingredient Optimisation (3 Questions)
4. Pricing and Ratings (4 questions)


## Important SQL functions and Clauses in this case study
1. Functions: CASE, TRIM, SUBSTRING_INDEX, REGXP_REPLACE, DATEDIFF, TIMESTAMPDIFF, Window functions-ROW_NUMBER
2. Clauses: GROUP BY, ORDER BY, WITH (CTE), WITH RECURSIVE, JOIN/LEFT JOIN, LIMIT, UNION ALL


## Here are some of the questions answered in this case study
1. How many of each type of pizza were delivered?
<img width="265" height="82" alt="image" src="https://github.com/user-attachments/assets/d71edec9-4494-4998-9924-151edff50d50" />


2. What was the total volume of pizzas ordered for each hour of the day?
<img width="187" height="162" alt="image" src="https://github.com/user-attachments/assets/48abe9e6-8a87-485f-83fe-8abb53ed5b7b" />


3. What was the volume of orders for each day of the week?
<img width="223" height="123" alt="image" src="https://github.com/user-attachments/assets/00234412-4673-4ad3-95f5-8dcbd401d221" />


4. What was the difference between the longest and shortest delivery times for all orders?

   30 minutes difference.
   

6. What was the most common exclusion?
<img width="271" height="117" alt="image" src="https://github.com/user-attachments/assets/9678dff0-a11f-499c-99d5-f7e70802a13e" />


7. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra (along with If a Meat Lovers pizza costs $12 and Vegetarian costs $10)- only successfully delivered.

   Total Sales - $142
   


9. can you join all of the information together to form a table that has the following information for successful deliveries?
   customer_id
   order_id
   runner_id
   rating
   order_time
   pickup_time
   Time between order and pickup
   Delivery duration
   Average speed
   Total number of pizzas
<img width="1136" height="226" alt="image" src="https://github.com/user-attachments/assets/a457bed4-20fc-46cc-bfe0-c340bfbb3046" />


# CHEERS!
