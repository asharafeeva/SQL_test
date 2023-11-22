--Задание 1. Выведите уникальные названия городов из таблицы городов

select city distinct
from city c
order by city

--Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

select distinct c.city
from city c 
where city like 'L%'
and city like '%a'
and city not like '% %'

--Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам,
--которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно
--и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.

select *
from payment p 
where payment_date between '2005-06-17' and '2005-06-20'
and amount >= 1.00
order by payment_date

--Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.

select *
from payment p 
order by payment_date desc
limit 10

--Задание 5. Выведите следующую информацию по покупателям:
-- ·      Фамилия и имя (в одной колонке через пробел)
-- ·      Электронная почта
-- ·      Длину значения поля email
-- ·      Дату последнего обновления записи о покупателе (без времени)
-- Каждой колонке задайте наименование на русском языке.

select concat (first_name,' ',last_name) as "Фамилия и Имя",
email as "почта",
length (email) as "длина адреса",
date(last_update) as "дата обновл"
from customer c

--Задание 6. Выведите одним запросом только активных покупателей,
--имена которых KELLY или WILLIE. Все буквы в фамилии и имени из
--верхнего регистра должны быть переведены в нижний регистр.

select 
lower(first_name) as first_name,
lower(last_name) as last_name
from customer c
where first_name in ('KELLY','WILLIE')
and active = 1

--Задание 7. Выведите одним запросом информацию о фильмах,
--у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно,
--а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.

select *
from film
where (rating = 'R' and rental_rate between 0.00 and 3.00)
or (rating = 'PG-13' and rental_rate>=4.00)

--Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.

select*
--length (description) as len
from film
order by length (description) desc
limit 3

--Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
-- ·      в первой колонке должно быть значение, указанное до @,
-- ·      во второй колонке должно быть значение, указанное после @.

select --email,
split_part(email,'@',1) as full_name,
split_part(email,'@',2) as domain_name
from customer c

-- Задание 10. Доработайте запрос из предыдущего задания,
--скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.

select --email,
initcap(split_part(email,'@',1)) as full_name,
initcap(split_part(email,'@',2)) as domain_name
from customer c



