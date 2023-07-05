/*QUERY 1.Create a query that lists each movie, the film category it is classified in,
and the number of times it has been rented out.*/
SELECT DISTINCT(film_title), category_name,
               COUNT(rentals) OVER (PARTITION BY (film_title)) AS rental_count
FROM(SELECT f.title film_title,c.name category_name,r.rental_id rentals
     FROM film f
     JOIN film_category fc
     ON f.film_id = fc.film_id
     JOIN category c
     ON fc.category_id = c.category_id
     AND c.name IN('Animation','Children','Classics','Comedy','Family','Music')
     JOIN inventory i
     ON f.film_id = i.film_id
     JOIN rental r
     ON i.inventory_id = r.inventory_id)sub
ORDER BY 2,1;
/*QUERY 2.Can you provide a table with the movie titles and divide them into 4 levels
(first_quarter, second_quarter, third_quarter, and final_quarter) based on the
quartiles (25%, 50%, 75%) of the rental duration for movies across all
categories?*/
WITH table_1 AS (SELECT f.title film_title,c.name category_name,f.rental_duration rental_duration
                 FROM film f
                 JOIN film_category fc
                 ON f.film_id = fc.film_id
                 JOIN category c
                 ON fc.category_id = c.category_id
                 AND c.name IN('Animation','Children','Classics','Comedy','Family','Music'))
SELECT film_title,category_name,rental_duration,
       NTILE(4)OVER (ORDER BY rental_duration) standard_quartile
FROM table_1
ORDER BY 3;
/*QUERY 3.provide a table with the family-friendly film category, each of the
quartiles, and the corresponding count of movies within each combination of
film category for each corresponding rental duration category. The resulting
table should have three columns:
Category
Rental length category
Count*/
WITH table_1 AS (SELECT f.title film_title,c.name category_name,f.rental_duration rental_duration
                 FROM film f
                 JOIN film_category fc
                 ON f.film_id = fc.film_id
                 JOIN category c
                 ON fc.category_id = c.category_id
                 AND c.name IN('Animation','Children','Classics','Comedy','Family','Music')),
     table_2 AS (SELECT film_title,category_name,rental_duration,
                        NTILE(4)OVER (ORDER BY rental_duration) standard_quartile
                FROM table_1
                ORDER BY 3)
SELECT category_name,standard_quartile,
       COUNT(*) movie_count
FROM table_2
GROUP BY 1,2
ORDER BY 1,2;
/*QUERY 4.Write a query that returns the store ID for the store, the year and month
and the number of rental orders each store has fulfilled for that month. Your
table should include a column for each of the following: year, month, store ID
and count of rental orders fulfilled during that month.*/
WITH table_3 AS (SELECT DATE_PART('month',r.rental_date) rental_month,
                        DATE_PART('year',r.rental_date)rental_year,
                        i.store_id store_id,COUNT(*) count_rentals
                 FROM rental r
                 JOIN inventory i
                 ON r.inventory_id = i.inventory_id
                 GROUP BY 1,2,3
                 ORDER BY 4 DESC)
SELECT (rental_month||'-'||rental_year) AS rental_date,store_id,count_rentals
FROM table_3;
