-- Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
-- · Пронумеруйте все платежи от 1 до N по дате

select payment_id,
payment_date ,
	row_number () over (order by payment_date)
from payment p

-- · Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате

select customer_id, 
payment_date, 
row_number () over (partition by customer_id order by payment_date)
from payment p 

-- · Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя,
--сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей

select customer_id,
payment_date, 
row_number () over (partition by customer_id order by payment_date),
sum(amount) over (partition by customer_id order by payment_date) as "сумма"
from payment p 

-- · Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так,
-- чтобы платежи с одинаковым значением имели одинаковое значение номера.

select customer_id,
amount,
dense_rank () over (partition by customer_id order by amount desc)
from payment p 

--Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа
--и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select customer_id,
payment_date, 
amount,
lag(amount, 1, 0.0) over (partition by customer_id order by payment_date)
from payment p 

--Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select customer_id,
payment_date, 
amount as "now",
lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) as "next",
lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) - amount as "дельта"
from payment p 

--Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

with a as
(select customer_id,
last_value (amount) over (partition by customer_id) as "last_amount",
last_value (rental_id) over (partition by customer_id) as "last_rent_id",
last_value (payment_date) over (partition by customer_id) as "last_date"
from payment p)
select a.customer_id,
max (last_amount) as amount,
max (last_rent_id) as rent_id,
max (last_date) as date_of_rent
from a
group by a.customer_id

--Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж
-- за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.


select staff_id,
date, 
sum(sum_1) over (partition by staff_id order by date) as sum_all
from(
	select staff_id,
	date,
	max (sum_staff) as sum_1
	from (
		select staff_id,
		date(payment_date), 
		sum(amount) over (partition by staff_id, date(payment_date) order by date(payment_date)) as sum_staff
		from payment p 
		where date_trunc('day',payment_date) between '2005-08-01' and '2005-08-31'
		)
	group by date, staff_id)
	
-- Задание 6. 20 августа 2005 года в магазинах проходила акция:
--покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду.
--С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
	
select *
from (
select max (lv) as cust_100,
max (ld) as date_100
from (
	select
	last_value (customer_id) over (partition by rank_100) as lv,
	last_value (payment_date) over (partition by rank_100) as ld
	from (
		select payment_id,
		customer_id,
		payment_date,
		ntile (162) over (order by payment_id) as rank_100
		from payment p))
group by lv)
where date(date_100) = '2005-08-20'


--Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
--· покупатель, арендовавший наибольшее количество фильмов;
--· покупатель, арендовавший фильмов на самую большую сумму;
--· покупатель, который последним арендовал фильм.

with a as(
select payment_id,
p.customer_id,
p.amount,
p.payment_date, 
c.first_name,
c.last_name,
c3.country,
count (p.customer_id) over (partition by p.customer_id) as film_rent_count,
sum(p.amount) over (partition by p.customer_id) as amount_rent_sum,
row_number () over (partition by p.customer_id order by p.payment_date desc) as number_rent
from payment p 
join customer c on c.customer_id = p.customer_id 
join address a on a.address_id = c.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id),
b as (
select *,
max(a.film_rent_count) over (partition by a.country) as max_film_rent_count,
max(a.amount_rent_sum) over (partition by a.country) as max_amount_rent_sum,
min (a.number_rent) over (partition by a.country) as last_number_rent
from a)
select b.country,
b.customer_id as max_cust_count_sum_number,
b.first_name,
b.last_name
from b
where b.film_rent_count = b.max_film_rent_count
and b.amount_rent_sum = b.max_amount_rent_sum
and b.number_rent = b.last_number_rent

