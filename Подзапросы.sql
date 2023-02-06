-- 1. Используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей нашего сервиса.
-- Для этого сначала в подзапросе посчитайте, сколько заказов сделал каждый пользователь, а затем обратитесь к
-- результату подзапроса в блоке FROM и уже в основном запросе усредните количество заказов по всем пользователям.
-- Полученное среднее число заказов всех пользователей округлите до двух знаков после запятой. Колонку с этим
-- значением назовите orders_avg.

-- Поле в результирующей таблице: orders_avg

-- Пояснение:
-- К колонкам из подзапроса можно применять агрегирующие функции — так же, как если бы мы обращались к колонкам
-- исходных таблиц.

SELECT round(AVG(Orders_count), 2) AS orders_avg
FROM (
    select user_id, count(order_id) AS Orders_count
    FROM user_actions
    WHERE action = 'create_order'
    group by user_id
) As t1

-- 2. Повторите запрос из предыдущего задания, но теперь вместо подзапроса используйте оператор WITH и табличное выражение. Условия задачи те же.
-- Поле в результирующей таблице: orders_avg

WITH subquery1 AS (
    select user_id, count(order_id) AS Orders_count
    FROM user_actions
    WHERE action = 'create_order'
    group by user_id
)

SELECT round(AVG(Orders_count), 2) AS orders_avg
FROM  subquery1

-- 3. Выведите из таблицы products информацию о всех товарах кроме самого дешёвого. Результат отсортируйте по убыванию id товара.
-- Поля в результирующей таблице: product_id, name, price


SELECT product_id, name, price
FROM products
where price <> (SELECT min(price) FROM products)
order by product_id desc

-- 4. Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров на 20 рублей и более.
-- Результат отсортируйте по убыванию id товара.
-- Поля в результирующей таблице: product_id, name, price

SELECT product_id, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products) + 20
order by product_id desc

-- 5. Посчитайте количество уникальных клиентов в таблице user_actions, сделавших за последнюю неделю хотя бы один заказ.
-- Полученную колонку со значением назовите users_count. В качестве текущей даты, от которой откладывать неделю, используйте
-- последнюю дату в той же таблице user_actions.
-- Поле в результирующей таблице: users_count

SELECT count(distinct user_id) as users_count
FROM user_actions
WHERE action = 'create_order' and time > (SELECT MAX(time) FROM user_actions) - INTERVAL '1 week'

SELECT count(distinct user_id) as users_count
FROM user_actions
WHERE action = 'create_order' and time::date > (SELECT MAX(time::DATE) FROM user_actions) - INTERVAL '1 week'

-- 6. С помощью функции AGE() и агрегирующей функции снова рассчитайте возраст самого молодого курьера мужского пола в таблице couriers,
-- но в этот раз в качестве первой даты используйте последнюю дату из таблицы courier_actions. Чтобы получилась именно дата, перед
-- применением функции AGE() переведите посчитанную последнюю дату в формат DATE, как мы делали в этом задании. Возраст курьера измерьте
-- количеством лет, месяцев и дней и переведите его в тип VARCHAR. Полученную колонку со значением возраста назовите min_age.
-- Поле в результирующей таблице: min_age

-- Пояснение:
-- В этой задаче результат подзапроса выступает в качестве аргумента функции. Чтобы весь запрос выглядел компактнее, для приведения
-- данных к другому типу можно использовать формат записи с двумя двоеточиями — ::.
-- Также обратите внимание, что для получения необходимого результата мы обращаемся к разным таблицам в рамках одного общего запроса
-- — так делать тоже можно. 

-- Расчёт возраста для всех курьеров, а потом выбрать минимальный

SELECT min(age((SELECT max(time)::date
                FROM   courier_actions), birth_date))::varchar as min_age
FROM   couriers
WHERE  sex = 'male'

-- Работает, но медленно
-- Выбрать макс дату и потом расчитать возраст

SELECT age(max(time)::date,
           max(birth_date) - interval '1 day')::varchar as min_age
FROM   couriers, user_actions
WHERE  sex = 'male'

-- 7. Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы, которые не были отменены пользователями.
-- Выведите колонку с id этих заказов. Результат запроса отсортируйте по возрастанию id заказа. Добавьте в запрос оператор LIMIT и выведите
-- только первые 1000 строк результирующей таблицы.

-- Поле в результирующей таблице: order_id

SELECT order_id
FROM   user_actions
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
ORDER BY order_id limit 1000

-- 8. Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.
-- В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков
-- после запятой. Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. Отклонение считайте так: число
-- заказов «минус» округлённое среднее значение. Колонку с отклонением назовите orders_diff. Результат отсортируйте по возрастанию id пользователя.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff

-- Пояснение:
-- В этой задаче можно использовать подзапрос, написанный в первых заданиях этого урока. Чтобы не пришлось дважды писать один и тот же подзапрос,
-- можно использовать оператор WITH.

WITH subquery1 AS (
    SELECT user_id, count(*) AS orders_count
    FROM user_actions
    WHERE  action = 'create_order'
    group by user_id
    ORDER BY user_id
)

SELECT user_id, orders_count, (SELECT round(AVG(orders_count), 2) FROM subquery1) AS orders_avg,
orders_count - (SELECT round(AVG(orders_count), 2) FROM subquery1) AS orders_diff
FROM subquery1
limit 1000

-- 9. Выведите id и содержимое 100 последних доставленных заказов из таблицы orders. Содержимым заказов считаются списки с id входящих
-- в заказ товаров. Результат отсортируйте по возрастанию id заказа.
-- Поля в результирующей таблице: order_id, product_ids

SELECT order_id, product_ids
FROM orders
WHERE order_id IN(
                SELECT order_id
                FROM courier_actions
                WHERE action = 'deliver_order'
                ORDER BY time desc
                limit 100)
ORDER BY order_id

-- 10. Из таблицы couriers выведите всю информацию о курьерах, которые в сентябре 2022 года доставили 30 и более заказов.
-- Результат отсортируйте по возрастанию id курьера.
-- Поля в результирующей таблице: courier_id, birth_date, sex
-- Пояснение:
-- Обратите внимание, что информация о курьерах находится в таблице couriers, а информация о действиях с заказами — в таблице courier_actions.

WITH subquery1 AS (
    SELECT courier_id, count(action)
    FROM courier_actions
    WHERE action = 'deliver_order' and time BETWEEN '2022-09-01' AND '2022-09-30'
    GROUP BY courier_id
)

SELECT courier_id, birth_date, sex
FROM couriers
WHERE courier_id in (SELECT courier_id FROM subquery1 WHERE count >= 30)
ORDER BY courier_id
-- =============================================================================================
SELECT courier_id, birth_date, sex
FROM   couriers
WHERE  courier_id in (SELECT courier_id
                      FROM   courier_actions
                      WHERE  date_part('month', time) = 9
                         and action = 'deliver_order'
                      GROUP BY courier_id having count(distinct order_id) >= 30)
ORDER BY courier_id

-- 11. Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей,
-- а также скидку 10% на товары, цена которых ниже средней на 50 и более рублей. Цену остальных товаров внутри
-- диапазона (среднее - 50; среднее + 50) оставьте без изменений. При расчёте средней цены, округлите её до двух знаков после запятой.

-- Выведите информацию о всех товарах с указанием старой и новой цены. Колонку с новой ценой назовите new_price.
-- Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.

-- Поля в результирующей таблице: product_id, name, price, new_price
-- avg(price) OVER () as avg_price,
WITH subquery1 AS (
    select avg(price) as avg_price
    FROM products
)

SELECT product_id, name, price,
CASE
    WHEN (price >= 50 + (SELECT avg_price FROM subquery1)) THEN price * 0.85
    WHEN (50 + price <= (SELECT avg_price FROM subquery1)) THEN price * 0.9
    ELSE price
END new_price
FROM products
ORDER BY price desc, product_id

-- 12. Выберите все колонки из таблицы orders, но в качестве последней колонки укажите функцию unnest, применённую к колонке product_ids.
-- Новую колонку назовите product_id. Выведите только первые 100 записей результирующей таблицы. Посмотрите на результат работы функции
-- unnest и постарайтесь разобраться, что произошло с исходной таблицей.

-- Поля в результирующей таблице: creation_time, order_id, product_ids, product_id
-- product_ids	содержит [65, 28]

SELECT creation_time, order_id, product_ids, unnest(product_ids) as product_id
FROM orders
limit 100

-- 13. Используя функцию unnest, определите 10 самых популярных товаров в таблице orders. Самыми популярными будем считать те,
-- которые встречались в заказах чаще всего. Если товар встречается в одном заказе несколько раз (т.е. было куплено несколько единиц товара),
-- то это тоже учитывается при подсчёте. 
-- Выведите id товаров и сколько раз они встречались в заказах. Новую колонку с количеством покупок товара назовите times_purchased.

-- Поля в результирующей таблице: product_id, times_purchased

SELECT unnest(product_ids) as product_id, count(*) as times_purchased
FROM orders
GROUP BY unnest(product_ids)
ORDER BY times_purchased desc
limit 10

-- 14*. Из таблицы orders выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров, доступных в нашем сервисе. Результат отсортируйте по возрастанию id заказа.
-- Поля в результирующей таблице: order_id, product_ids

-- Пояснение:
-- В этой задаче вам снова пригодится функция unnest. Также для упрощения кода можно использовать табличные выражения.

SELECT DISTINCT order_id, product_ids
FROM (SELECT order_id, product_ids, unnest(product_ids) as product_id
FROM orders) t1
WHERE product_id in (SELECT product_id FROM products ORDER BY price DESC LIMIT 5)
ORDER BY order_id
--------------------------------------------------------
with top_products as
    (SELECT product_id
    FROM   products
    ORDER BY price desc
    limit 5),

    unnest as (SELECT order_id, product_ids, unnest(product_ids) as product_id
               FROM   orders)

SELECT DISTINCT order_id, product_ids
FROM   unnest
WHERE  product_id in (SELECT * FROM   top_products)
ORDER BY order_id

-- 15*. Посчитайте возраст каждого пользователя в таблице users. Возраст измерьте числом полных лет, как мы делали в прошлых уроках.
-- Возраст считайте относительно последней даты в таблице user_actions. В результат включите колонки с id пользователя и возрастом.
-- Для тех пользователей, у которых в таблице users не указана дата рождения, укажите среднее значение возраста всех остальных пользователей,
-- округлённое до целого числа. Колонку с возрастом назовите age. Результат отсортируйте по возрастанию id пользователя.

-- Поля в результирующей таблице: user_id, age

-- Пояснение:
-- В этой задаче вам придётся написать несколько подзапросов и, возможно, использовать табличные выражения. Пригодятся функции
-- DATE_PART, AGE и COALESCE. Основная сложность заключается в заполнении пропусков средним значением — подумайте, как это можно сделать,
-- и постройте запрос вокруг своего подхода. 


WITH age_sub AS (
    SELECT user_id, extract(year from age((SELECT max(time)::date FROM   courier_actions), birth_date)) as age1
    FROM   users
),
 avg_age_sub AS (
     SELECT AVG(age1)::int AS age_avg
     FROM  age_sub
)

SELECT user_id, 
CASE 
 WHEN age1 IS NULL THEN (SELECT age_avg FROM avg_age_sub)
 ELSE age1
END age
FROM (SELECT user_id, age1 FROM age_sub) t1
ORDER BY user_id

-- 2 способ ============================================================
with users_age as(
    SELECT user_id, date_part('year', age((SELECT max(time) FROM   user_actions), birth_date)) as age
    FROM   users
)

SELECT user_id, coalesce(age, (SELECT round(avg(age)) FROM   users_age)) as age
FROM   users_age
ORDER BY user_id