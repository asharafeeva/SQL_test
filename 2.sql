--Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.

select c.first_name,
c.last_name,
a.address,
c2.city,
c3.country 
from customer c
join address a on c.address_id = a.address_id
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id

--Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select c.store_id,
count(customer_id)
from customer c 
group by store_id 

-- · Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300.
--Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации.

select c.store_id,
count(customer_id)
from customer c 
group by store_id 
having count(customer_id) > 300

---- · Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём.

select c.store_id,
count(customer_id),
c2.city,
s2.first_name,
s2.last_name 
from customer c
join store s on c.store_id = s.store_id
join staff s2 on s2.staff_id = s.manager_staff_id 
join address a on s2.address_id = a.address_id
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id 
group by c.store_id, c2.city, s2.first_name, s2.last_name 
having count(customer_id) > 300

--Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.

select c.customer_id ,
c.first_name,
c.last_name, 
count(r.rental_id) 
from customer c 
join rental r on r.customer_id = c.customer_id 
group by c.customer_id
order by count(r.rental_id) desc 
limit 5 

--Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
-- · количество взятых в аренду фильмов;
-- · общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
-- · минимальное значение платежа за аренду фильма;
-- · максимальное значение платежа за аренду фильма.

select c.customer_id ,
c.first_name,
c.last_name, 
count(r.rental_id),
round(sum(p.amount)) total,
min(p.amount),
max(p.amount)
from customer c 
join rental r on r.customer_id = c.customer_id 
join payment p on r.rental_id = p.rental_id 
group by c.customer_id
--order by count(r.rental_id) desc 

--Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так,
--чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.

with a as
(select city 
from city c),
b as
(select city 
from city c)
select a.*, b.*
from a
cross join b
where a.city != b.city

--Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
-- и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.

select distinct r.customer_id,
round(avg((extract (day from (return_date - rental_date))))) as days
from rental r 
group by r.customer_id
order by r.customer_id

--Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.

select f.title,
count(p.rental_id),
sum(p.amount)
from film f 
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id 
left join payment p on r.rental_id = p.rental_id
group by f.title

--Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.

select f.title
from film f 
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id 
left join payment p on r.rental_id = p.rental_id
group by f.title
having count(p.rental_id) = 0

--Задание 9. Посчитайте количество продаж, выполненных каждым продавцом.
--Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300,
--то значение в колонке будет «Да», иначе должно быть значение «Нет».

select s.first_name,
s.last_name,
sum(p.amount),
	case 
		when sum(p.amount) > 7300 then 'да'
		when sum(p.amount) < 7300 then 'ytn'
	end as "премия"
from staff s 
join payment p on s.staff_id = p.staff_id
group by s.staff_id 
