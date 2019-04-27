-- SQL homework week 9
USE sakila;

#drop the backup table, if it exists
drop table if exists actor_orig;

# make a backup, because I will alter the original table in a later step
create table actor_orig as select * from actor;

/* 
1a. Display the first and last names of all actors from the table actor. 
*/

select * from actor;
select first_name, last_name from actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column Actor Name.

drop the actorname column in order to re-run sql script.  NOTE:   cannot check for 'if exists' in mySql.
if 'if exists' are needed, create a stored procedure.   References:
 https://stackoverflow.com/questions/39738594/how-to-drop-a-column-if-exists-in-mysql
 https://chase-seibert.github.io/blog/2010/01/15/mysql-drop-column-if-exists.html#
*/
alter table actor 
drop column actorname;

ALTER TABLE actor
ADD COLUMN actorName VARCHAR(75) AFTER last_name;

update actor set actorName = upper(concat(first_name, ' ', last_name));

/* 2a. You need to find the ID number, first name, and last name of an actor, 
 of whom you know only the first name, "Joe." 
*/

select actor_id, actorName from actor where first_name like '%joe%';

/*
2b. Find all actors whose last name contain the letters GEN:
*/
select actor_id, actorName from actor where last_name like '%gen%';

/*2c. Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order:
*/

select first_name, last_name 
from actor 
where last_name like '%li%' 
order by last_name asc, first_name asc;

/*2d. Using IN, display the country_id and country columns of the following countries: 
Afghanistan, Bangladesh, and China
*/

select country_id, country 
from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
ADD COLUMN description blob AFTER actorName;

#visual confirmation
#select * from actor;

/*
3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;
select * from actor;
*/

alter table actor 
drop column description;

/*
4a. List the last names of actors, as well as how many actors have that last name.
*/

select last_name, count(last_name) as total 
from actor 
group by last_name 
order by total desc;

/*
4b. List last names of actors and the number of actors who have that last name, 
 but only for names that are shared by at least two actors
 */
 
select last_name, count(last_name) as total 
from actor 
group by last_name 
HAVING total >= 2
order by total desc, last_name asc;

#manual check
#select * from actor;

/* 
4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
 Write a query to fix the record.
 */

update actor
set first_name = 'Harpo'
where actorName ="Groucho Williams";

-- ??   should I add a trigger to automatically update the actorName??

update actor 
set actorName = upper(concat(first_name, ' ', last_name))
where actorName ="Groucho Williams";

select * from actor where last_name like 'williams';

/*
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
*/

update actor
set first_name = 'Groucho'
where actorName ="Harpo Williams";

-- ??   should I add a trigger to automatically update the actorName??

update actor 
set actorName = upper(concat(first_name, ' ', last_name))
where actorName ="Harpo Williams";

select * from actor where last_name like 'williams';

/*
5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
*/
#reference:  https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show create table address;
/* 
CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
*/

# to locate (not re-create) a table
select table_schema as database_name
from information_schema.tables 
where table_type = 'BASE TABLE'
    and table_name = 'address'
order by table_schema;

/*
6a.  Use JOIN to display the first and last names, 
as well as the address, of each staff member. Use the tables staff and address:
*/

select * from staff;
select * from address;

select s.staff_id, s.first_name, s.last_name, s.address_id, 
a.address, a.address2, a.district, a.city_id, a.postal_code
from staff as s
inner join address as a 
on s.address_id=a.address_id;

/*
6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment.
*/


#first, get all payments by staff_id
select staff_id, sum(amount) 
from payment 
group by staff_id;  

#second, revise to only get the August 2005 payments
select * 
from payment 
where month(payment_date) = 08 and year(payment_date) = 2005;
#manual check to confirm the data is correct

#sum the August values by staff_id
select staff_id, sum(amount) 
from payment 
where month(payment_date) = 08 and year(payment_date) = 2005
group by staff_id; 
#manual check to confirm the data is correct

#now the final query to answer the question
select s.first_name, s.last_name, sum(p.amount) 
		from staff as s
        join payment as p
        on s.staff_id = p.staff_id
		where month(p.payment_date) = 08 and year(p.payment_date) = 2005
        group by s.staff_id;
		

/*
6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join.
*/

#manual check. , determine how many actors have been in each film.  Use on film_actor
select fa.film_id, count(fa.actor_id) as actorCount
from film_actor as fa
group by fa.film_id
order by actorCount desc;

#query to answer the question
select f.title, count(fa.actor_id) as actorCount
from film as f
inner join film_actor as fa
on f.film_id = fa.film_id
group by f.title
order by actorCount desc, f.title asc ;

/*
6d. How many copies of the film Hunchback Impossible exist in the inventory system?
*/

#manual check.  find the film_Id of hunchback impossible
select film_id from film where title = 'Hunchback Impossible'; #439

#manual check. count the occurrences of 439 in inventory
select * from inventory where film_id = 439; #returns 6 rows
select count(inventory_id) from inventory where film_id = 439;   #also returns 6

#query to answer the question
select count(i.inventory_id) as InventoryCount
from inventory as i
where i.film_id in
	(
    select f.film_id 
    from film as f
    where f.title = 'Hunchback Impossible'
    );
    #returns 6
    
/*
6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:
*/

#first, manual check the amounts paid by customer id
select p.customer_id, sum(p.amount) as ttlCustomerPaid
from payment as p
group by p.customer_id
order by ttlCustomerPaid desc;

#query to answer the question
select c.first_name, c.last_name as lastName, sum(p.amount) 
from customer as c
inner join payment as p
on c.customer_id = p.customer_id
group by p.customer_id
order by lastName asc;

/*
7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
*/

select distinct(language_id) from film;
#this additional query was not needed since all films are in english

#manual check table for count of films
select count(f.title) 
from film as f
where f.language_id = 1 and (f.title like 'k%' or f.title like 'q%');

#manual check table for films with k and q as the first letter of the title
select f.title 
from film as f
where f.language_id = 1 and (f.title like 'k%' or f.title like 'q%');

#query to answer question
select f.title 
from film as f
where f.language_id in
	(select l.language_id 
    from language as l
    where l.name = 'English')
and (f.title like 'k%' or f.title like 'q%')
;

/*
7b. Use subqueries to display all actors who appear in the film Alone Trip.
*/

#step1 find the film id of Alone Trip
select f.film_id from film as f where title = 'Alone Trip';  #17

#step 2 find the actor_ids who appear in Alone Trip
select fa.actor_id 
from film_actor as fa
where fa.film_id in
	(select f.film_id from film as f where title = 'Alone Trip')
;

#step 3, query to answer the question
select a.first_name, a.last_name
from actor as a
where a.actor_id in
	(select fa.actor_id 
		from film_actor as fa
		where fa.film_id in
			(
            select f.film_id 
            from film as f 
            where title = 'Alone Trip'
            )
	);
    
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information.
*/

select cu.first_name, cu.last_name, cu.email
from customer as cu
inner join address as a
on cu.address_id = a.address_id
	inner join city as ci
    on a.city_id = ci.city_id
		inner join country as co
        on ci.country_id = co.country_id
where co.country = 'Canada';

#  BONUS also find the postal address for a mailing campaign
# data set 'eyeball check' shows incorrect postal codes
#option 1 of 2 - Answer the question only for Canada.
select cu.first_name, cu.last_name, a.address, a.address2, ci.city,  a.district, a.postal_code, co.country
from customer as cu
inner join address as a
on cu.address_id = a.address_id
	inner join city as ci
    on a.city_id = ci.city_id
		inner join country as co
        on ci.country_id = co.country_id
where co.country = 'Canada';

#option 2 of 2 - create a VIEW of the logical user-friencly customer addresses.  Use this view for future queries.

drop view if exists customerAddress;   #add this line in order to run entire sqlscript over and over

create view customerAddress as
select cu.first_name, cu.last_name, a.address, a.address2, ci.city,  a.district, a.postal_code, co.country
from customer as cu
inner join address as a
on cu.address_id = a.address_id
	inner join city as ci
    on a.city_id = ci.city_id
		inner join country as co
        on ci.country_id = co.country_id;

select * from customerAddress where country = 'Canada';

/* 
7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.
*/

select f.title 
from film as f
where f.film_id in
	(
    select fc.film_id 
	from film_category as fc
	where fc.category_id in
		(
		select ca.category_id 
		from category as ca
		where name = 'family'  #8
		)
	)
		;
        
/*
7e. Display the most frequently rented movies in descending order.
*/

/* MANUAL CHECKS 
select * from film; #contains film_id
select * from rental; #contains inventory_id
select * from inventory; #contains inventory_id an film_id
*/

select count(i.inventory_id) as rentalCount, f.title
from film as f
inner join inventory as i
	on f.film_id = i.film_id
		inner join rental as r
        on r.inventory_id = i.inventory_id
group by f.title
order by rentalCount desc;

/*
7f. Write a query to display how much business, in dollars, each store brought in.
Need to converse with someone who knows the data.
*/

/* MANUAL CHECKS 
select * from payment;  #amount, rental_id, staff_id
select * from rental; #rental_id, staff_id
select * from staff; #staff_id, store_id
select * from store; #store_id, address_id
select * from customer
select * from payment
select * from address, address _id, district. city_id;
*/
 
 #manual check.   Determine total received in payments
select sum(amount) from payment;   # 67,416.51
 
#option 1
#there is a view for sales_by_store and I think this question simply wants to ensure I reviewed the views.
#however, the total in this view does not equal the total in the payment table
select * from sales_by_store;

#option 2
#thought process - CUSTOMER visits a STORE and makes a PAYMENT to the STAFF member

select s.store_id as "Store ID"
      ,sum(p.amount) "Cash Brought In"
from store s
join customer c
	on s.store_id = c.store_id
		join payment p
		on c.customer_id = p.customer_id
group by s.store_id;



/*
7g. Write a query to display for each store its store ID, city, and country.
*/
/*  MANUAL CHECKS
select * from store; #store_id, address_id
select * from address;  #address_id, city_id
select * from city;  #city_id, country_id
select * from country;  #country_id
*/

select s.store_id, ci.city, co.country
from store as s
inner join address as a
	on s.address_id = a.address_id
		inner join city as ci
        on a.city_id = ci.city_id
			inner join country as co
            on ci.country_id = co.country_id;
            
/*
7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/

/* MANUAL CHECKS 
select * from category;  #category_id, name
select * from film_category; #film_id, category_id
select * from inventory; #inventory_id, #film_id
select * from rental; # rental_id, inventory_id
select * from payment; # rental_id, amount
*/

#   note:  Each rental is for ONLY ONE inventory ID.   There are no rentals for 2+ films.
select count(distinct rental_id) from rental; #16044
select count(inventory_id) from rental;   #16044

select c.name, sum(p.amount) as sumPayment
from category as c
	inner join film_category as fc
    on c.category_id = fc.category_id
		inner join inventory as i
        on fc.film_id = i.film_id
			inner join rental as r
            on i.inventory_id = r.inventory_id
				inner join payment as p
                on r.rental_id = p.rental_id
group by c.name
order by sumPayment desc limit 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five 
genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.
*/

create view top_Gross_By_Genre as
select c.name, sum(p.amount) as sumPayment
from category as c
	inner join film_category as fc
    on c.category_id = fc.category_id
		inner join inventory as i
        on fc.film_id = i.film_id
			inner join rental as r
            on i.inventory_id = r.inventory_id
				inner join payment as p
                on r.rental_id = p.rental_id
group by c.name
order by sumPayment desc limit 5;

/*
8b. How would you display the view that you created in 8a?
*/

select * from top_Gross_By_Genre;

/*
8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
*/

drop view if exists top_Gross_By_Genre;
