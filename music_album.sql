SELECT TOP (1000) [employee_id]
      ,[last_name]
      ,[first_name]
      ,[title]
      ,[reports_to]
      ,[levels]
      ,[birthdate]
      ,[hire_date]
      ,[address]
      ,[city]
      ,[state]
      ,[country]
      ,[postal_code]
      ,[phone]
      ,[fax]
      ,[email]
  FROM [MUSIC].[dbo].[employee]
select * from employee
order by levels desc

--Q.1 - WHO IS THE SEMIUOR MOST EMPLOYEE BASED ON JOB TITLE?

SELECT TOP 1 *
FROM employee
ORDER BY levels DESC;

--Q.2 - WHICH COUNTRIES HAVE THE MOST INVOICE?

SELECT * FROM invoice
SELECT COUNT(*) AS C , billing_country from invoice
GROUP BY billing_country
ORDER BY C desc

--Q.3 - WHAT ARE TOP 3 VALUES OF TOTAL INVOICE?

SELECT top 3 total FROM invoice
ORDER BY total desc

--Q.4 - WHICH CITY HAS THE BEST CUSTOMERS?WE WOULD LIKE T OTHROW A PROMOTIONAL MUSIC FESTIVAL IN CITY WE MADE THE MOST MONEY.
--      WRITE A QUERY THAT RETURNS ONE CITY THAT HAS THE HIGHEST SUM OF INVOICE TOTALS.
--      RETURN BOTH THE CITY NAME AND SUM OF ALL INVOICE TOTALS

SELECT * FROM invoice

SELECT SUM(total) as invoice_table, billing_city from invoice
GROUP BY billing_city
ORDER BY invoice_table desc

--Q.5 - WHO IS THE BEST CUSTOMER? THE CUSTOMER WHO SPENT THE MOST MONEY WILL BE DECLARED AS THE BEST CUSTOMER.

SELECT * FROM customer

select top 1 customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total 
from customer

join invoice on customer.customer_id = invoice.customer_id

group by customer.customer_id,customer.first_name,customer.last_name
order by total desc

--MODERATE QUESTIONS--

--Q.1 - WRITE QUERY TO RETURN THE EMAIL, FIRST NAME, LAST NAME AND GENRE OF ALL ROCK MUSIC LISTENERS.
--      RETURN YOUR LIST ORDERED ALPHABETICALLY BY EMAIL STARTING WITH A

select distinct email, first_name, last_name from customer 

join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id

where track_id in(
SELECT track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
)

order by email;

--Q.2 - LET'S INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASET.
--      WRITE A QUERY THAT RETURN THE ARTISTNAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS

SELECT TOP 10 artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track

join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id

where genre.name like 'Rock'

group by artist.artist_id, artist.name
order by number_of_songs desc

--Q.3 - RETURN ALL TRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN THE AVERAGE SONG LENGTH.
--      RETURN THE NAME AN MILLISECONDS FOR EACH TRACK ORDER BY THE SONG LENGTH WITH THE LONGEST SONGS LISTED FIRST

SELECT name, milliseconds from track

where milliseconds > (
               select avg(milliseconds) as avg_track_length
			   from track)

order by milliseconds desc

--ADVANCE--

--Q.1 - FIND HOW MUCH AMOUNT SPENT EACH CUSTOMER ON ARTISTS?
--      WRITE A QUERY T ORETURN CUTOMER NAME, ARTIST NAME AND TOTAL SPENT

WITH best_selling_artist as
     (select top 1 artist.artist_id as artist_id, artist.name as artist_name, 
	        sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	 from invoice_line

     join track on track.track_id = invoice_line.track_id
     join album on album.album_id = track.album_id
     join artist on artist.artist_id = album.artist_id

     group by artist.artist_id, artist.name
     order by 3 desc
)

select c.customer_id, c.first_name, c.last_name,bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i

join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id

group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by 5 desc
  
--Q.2 - we want to find out the most popular music genre for each country. we ddetermine the most popular genre as the genre with the highest amount
--      of purchases along with the top genre for countires where the max no of purchases in hsared return all genres.

with popular_genre as(
     select top 1000 count(invoice_line.quantity)as purchases, customer.country,genre.name , genre.genre_id, 
	 row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	 from invoice_line

	 join invoice on invoice.invoice_id = invoice_line.invoice_id
	 join customer on customer.customer_id = invoice.customer_id
	 join track on track.track_id = invoice_line.track_id
	 join genre on genre.genre_id = track.genre_id

	 group by customer.country,genre.name,genre.genre_id
	 order by 2 asc , 1 desc
)

select * from popular_genre where RowNo <=1

--Q.3 - WRITE QUERY THAT DETERMINES THE CUSTOMER THAT HAS SPENT THE MOST ON MUSIC FOR EACH COUNTRY.
--      WRITE A QUERY THAT RETURNS THE COUNTRY ALONG WITH THE TOP CUSTOMER AND HOW MUCH THEY SPENT FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED,
--      PROVIDE ALL CUSTOMERS WHO SPENT THIS AMOUNT.

with customer_with_country as(
      select top 1000 customer.customer_id,first_name,last_name,billing_country, sum(total) as total_spending,
	  row_number() over(partition by billing_country order by sum(total) desc) as RowNo
	  from invoice

	  join customer on customer.customer_id = invoice.customer_id

	  group by customer.customer_id,first_name,last_name,billing_country
	  order by 4 asc, 5 desc
)

select * from customer_with_country where RowNo <= 1