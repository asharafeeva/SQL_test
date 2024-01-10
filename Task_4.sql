--Задание 1.Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features),
-- равным "Behind the Scenes"

select max(array_upper(special_features,1))
from film 

select *
from film f 
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes'

--Задание 2.Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes", используя другие фукции или операторы языка SQL
-- для поиска значений в массиве

select *
from film f 
where 'Behind the Scenes' = ANY (special_features)

select *
from film f
where special_features && ARRAY['Behind the Scenes']

--Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом "Behind the Scenes".
-- Обязательное условие для выполнения задания: используйте запрос из задание 1, помещенный в СТЕ.

with a as (
select *
from film f 
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes')
select r.customer_id,
count(i.film_id) distinct  
from a
join inventory i on a.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by r.customer_id
order by r.customer_id 

-- Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом "Behind the Scenes".
-- Обязательное условие для выполнения задания: используйте запрос из задание 1, помещенный в подзапрос, который необходимо использовать
-- для решения задания.


select r.customer_id,
count(i.film_id) distinct  
from (
select *
from film  
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes') f
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by r.customer_id
order by r.customer_id 

--Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос
--для обновления материализованного представления

create materialized view mymatview as
select r.customer_id,
count(i.film_id) distinct  
from (
select *
from film  
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes') f
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by r.customer_id
order by r.customer_id

refresh materialized view mymatview 

--select *
--from mymatview

--Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
-- с каким опреатором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значений в массиве происходит быстрее;
-- какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.

explain analyze select *
from film f 
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes'

--actual time = 0.06

explain analyze select *
from film f 
where 'Behind the Scenes' = ANY (special_features)

--actual time = 0.029

explain analyze select *
from film f
where special_features && ARRAY['Behind the Scenes']

--actual time = 0.021

-- Вывод: поиск значений в массиве происходит быстрее с использованием оператором &&,
--который проверяет перекрывается ли левый операнд с правым

explain analyze with a as (
select *
from film f 
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes')
select r.customer_id,
count(i.film_id) distinct  
from a
join inventory i on a.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by r.customer_id
order by r.customer_id

--actual time = 17.372

explain analyze select r.customer_id,
count(i.film_id) distinct  
from (
select *
from film  
where special_features[1] like 'Behind the Scenes'
or special_features[2] like 'Behind the Scenes'
or special_features[3] like 'Behind the Scenes'
or special_features[4] like 'Behind the Scenes') f
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
group by r.customer_id
order by r.customer_id 

--actual time = 18.176

-- Вывод: вариант вычислений с использованием CTE происходит быстрее.

--Дополнительное задание. 1. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже
select *
from (
	select staff_id, payment_id, rental_id,payment_date,
	first_value (amount) over (partition by staff_id order by payment_date),
	row_number () over (partition by staff_id order by payment_date)
	from payment) p 
where row_number =1

--Дополнительное задание. 2. Для каждого магазина определите и выведите одним SQL запросом следующие аналитические показатели:
-- - день, в который арендовали больше всего фильмов (в формате год-месяц-день);
-- - количество фильмов, взятых в аренду в этот день;
-- - день, в который продали фильмов на наименьшую сумму;
-- - сумму продажи в этот день.

with 
a as(
	select payment_id,
	payment_date,
	amount,
	r.rental_id,
	rental_date,
	s.store_id
	from payment p 
	join rental r on p.rental_id = r.rental_id 
	join staff s on r.staff_id = s.staff_id),
b as (
	select store_id, rental_date, payment_date,
	count(rental_id) over (partition by rental_date,store_id) as film_rent,
	sum(amount) over (partition by payment_date,store_id) as film_payed
	from a),
c as (
	select *,
	row_number () over (partition by store_id order by film_rent desc) as row_rent,
	row_number () over (partition by store_id order by film_payed) as row_pay
	from b),
d as (
	select store_id, rental_date, film_rent
	from c
	where row_rent = 1),
e as (
	select store_id, payment_date, film_payed
	from c
	where row_pay = 1)
select d.store_id, rental_date, film_rent, payment_date, film_payed
from d
join e on d.store_id = e.store_id
