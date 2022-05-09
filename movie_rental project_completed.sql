# Project [movie_rental_store]

-- 1. Before doing any exercise, you should explore the data first. For Exercise 1, we will focus on the 
-- product, which is the film (DVD) in this project. Please explore the product-related tables (actor, 
-- film_actor, film, language, film_category, category) by using ‘SELECT *’ – do not forget to limit the 
-- number of records

select * from film limit 10;
select * from actor limit 10;
select * from film_actor limit 10;
select * from language limit 10;
select * from film_category limit 10;
select * from category limit 10;

-- Use table FILM to solve questions as below:
-- 2. What is the largest rental_rate for each rating?
-- 3. How many films in each rating category?
-- 4. Create a new column film_length to segment different films by length:
-- length < 60 then ‘short’; 60 <= length < 120 then ‘starndard’; lengh >=120 then ‘long’
-- , then count the number of files in each segment.

select max(rental_rate) as max_rental_rate, rating
from film group by rating;

select count(distinct film_id) as num_film, rating
from film group by rating;

select case when length < 60 then "short"
when length >= 60 and length < 120 then "standard"
when length >= 120 then "long"
else "others" end as film_length, count(film_id) as num_files from film
group by 1;
-- remember it is wrong if using "when 60 <= length < 120", it must be changed by using "and" query

-- Use table ACTOR to solve questions as below:
-- 5. Which actors have the last name ‘Johansson’
-- 6. How many distinct actors’ last names are there?
-- 7. Which last names are not repeated? Hint: use COUNT() and GROUP BY and HAVING
-- 8. Which last names appear more than once?

select concat(first_name, " ", last_name) as actor_name from actor
where last_name = "Johansson";
-- using concat to append two string type variables, use it as a new variables

select count(distinct last_name) from actor; 

select count(*) as num_repeated, last_name 
from actor group by 2 having count(*) = 1;
-- you can't write "having 1 = 1, it is meaningless

select count(*) as num_repeated, last_name 
from actor group by 2 having num_repeated > 1;

-- Use table FILM_ACTOR to solve questions as below:
-- 9. Count the number of actors in each film, order the result by the number of actors with descending 
-- order
-- 10. How many films each actor played in?

select count(distinct actor_id) as num_actors, film_id 
from film_actor
group by 2
order by 1 DESC;

select count(distinct film_id) as num_film, actor_id 
from film_actor
group by 2 order by 1 DESC;

-- 11. Find language name for each film by using table Film and Language;
-- 12. In table Film_actor, there are actor_id and film_id columns. I want to know the actor 
-- name for each actor_id, and film tile for each film_id. Hint: Use multiple table Inner Join
-- 13. In table Film, there are no category information. I want to know which category each 
-- film belongs to. Hint: use table film_category to find the category id for each film and 
-- then use table category to get category name
-- 14. Select films with rental_rate > 2 and then combine the results with films with rating G, 
-- PG-13 or PG

select a.name as language_name,
b.* from language as a left join film as b
on a.language_id = b.language_id;

select a.title as film_title, b.actor_id as actor_ID,
concat(c.first_name, " ", c.last_name) as actor_name, a.film_id from film as a
join film_actor as b on a.film_id = b.film_id join actor as c on b.actor_id = c.actor_id;

select a.*, c.name from film as a left join film_category as b on a.film_id = b.film_id
left join category as c on b.category_id = c.category_id;
-- remember to use left join instead of using inner join

select * from film where rental_rate > 2
union
select * from film where rating in ("G", "PG-13", "PG");  #union function

-- The rental table contains one row for each rental of each inventory item with 
-- information about who rented what item, when it was rented, and when it was returned
-- • The rental table refers to the inventory, customer, and staff tables and is referred 
-- to by the payment table
-- • Rental_id: A surrogate primary key that uniquely identifies the rental
-- 15. How many rentals (basically, the sales volume) happened from 2005-05 to 2005-08? 
-- Hint: use date between '2005-05-01' and '2005-08-31';
-- 16. I want to see the rental volume by month. Hint: you need to use substring function to 
-- create a month column, e.g.
-- 17. Rank the staff by total rental volumes for all time period. I need the staff’s names, so 
-- you have to join with staff table

select * from rental limit 10;

select count(rental_id) as rentals_num from rental
where rental_date between "2005-05-01" and "2005-08-31";  # time variables can be used like this

select substring(rental_date, 6,2) as month, count(rental_id) from rental
where rental_date between '2005-05-01' and '2005-08-31' 
group by 1;

select count(a.rental_id) as total_volumes, concat(b.first_name, " ", b.last_name) as staff_name
from rental as a join staff as b
on a.staff_id = b.staff_id
group by 2;

-- 18. Create the current inventory level report for each film in each store?
-- • The inventory table has the inventory information for each film at each store
-- o inventory_id - A surrogate primary key used to uniquely identify each item 
-- in inventory, so each inventory id means each available film.

select film_id, store_id, count(inventory_id) from inventory
group by 1,2;

-- 19. When you show the inventory level to your manager, you manager definitely wants to 
-- know the film name. Please add film name for the inventory report.
-- • Tile column in film table is the film name
-- • Should you use left join or inner join? – this depends on how you want to present 
-- your result to your manager, so there is no right or wrong answer
-- • Which table should be your base table if you want to use left join?

select f.title as film_name, i.film_id, i.store_id, count(*)
from
inventory as i
left join
film as f on i.film_id=f.film_id
group by 1,2,3;       #realize that we need to let inventory as the base table for left join

-- 20. After you show the inventory level again to your manager, you manager still wants to 
-- know the category for each film. Please add the category for the inventory report.
-- • Name column in category table is the category name
-- • You need to join film, category, inventory, and film_category

select f.title as film_name, 
f.film_id,  -- be careful about which film_id you are using. if you select film_id from inventory table, you will get NULL value
c.name as category, 
i.store_id, 
count(i.film_id) as num_of_stock -- be careful which column you want to count to get the inventory number. if you count(*), NULL will be counted as 1
from
film as f 
left join inventory as i
on i.film_id=f.film_id
left join
film_category as fc on f.film_id=fc.film_id
left join
category as c on fc.category_id=c.category_id
group by 1,2,3,4; -- !!!!!!!!!! very important mistake that many data analysts will make

-- 21. Your manager is happy now, but you need to save the query result to a table, just in 
-- case your manager wants to check again, and you may need the table to do some 
-- analysis in the future

create table inventory_rep as
select f.title as film_name, 
f.film_id, 
c.name as category, 
i.store_id, 
count(i.film_id) as num_of_stock 
from
film as f 
left join inventory as i
on i.film_id=f.film_id
left join
film_category as fc on f.film_id=fc.film_id
left join
category as c on fc.category_id=c.category_id
group by 1,2,3,4;

-- 22. Use your report to identify the film which is not available in any store, and the next 
-- step will be to notice the supply chain team to add the film into the store

select * from film where film_id in
(
select film_id from inventory_rep 
where num_of_stock = 0);  # num of stock is zero represents the film is not avaliable in any store

-- Let’s look at Revenue:
-- • The payment table records each payment made by a customer, with information 
-- such as the amount and the rental being paid for. Let us consider the payment 
-- amount as revenue and ignore the receivable revenue part
-- • rental_id: The rental that the payment is being applied to. This is optional because 
-- some payments are for outstanding fees and may not be directly related to a rental 
-- – which means it can be null;
-- 23. How many revenues made from 2005-05 to 2005-08 by month? 
-- 24. How many revenues made from 2005-05 to 2005-08 by each store? 
-- 25. Say the movie rental store wants to offer unpopular movies for sale to free up shelf 
-- space for newer ones. Help the store to identify unpopular movies by counting the 
-- number of rental times for each film. Provide the film id, film name, category name so 
-- the store can also know which categories are not popular. Hint: count how many times 
-- each film was checked out and rank the result by ascending order

select * from payment limit 10;

select sum(amount) as total_revenue, substring(payment_date, 6, 2) as Month
from payment
where payment_date between "2005-05-01" and "2005-08-31"
group by 2;

select store_id, sum(amount) as revenue from 
payment as p
join
staff as s
on p.staff_id=s.staff_id
where payment_date 
between '2005-05-01' and '2005-08-31' group by 1;

select 
f.film_id, 
f.title, 
c.name as category, 
count(distinct rental_id) as times_rented 
from 
rental as r
left join inventory as i
on i.inventory_id=r.inventory_id
left join film f
on i.film_id=f.film_id
left join film_category fc
on f.film_id=fc.film_id
left join category c
on fc.category_id=c.category_id
group by 1,2,3
order by 4 desc;