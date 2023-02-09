-- Вы заметите, что в таблице user_actions уникальных пользователей больше. Это значит, что про часть пользователей мы что-то не знаем
-- — у нас попросту нет о них информации в таблице users. Поэтому в результате соединения этих двух таблиц с помощью INNER JOIN эта часть
-- пользователей будет исключена из результата.
SELECT COUNT(DISTINCT user_id)
FROM users
-- 20,331
SELECT COUNT(DISTINCT user_id)
FROM user_actions
-- 21,401

-- 1.INNER JOIN (JOIN) Объедините таблицы user_actions и users по ключу user_id. В результат включите две колонки с user_id из обеих таблиц.
-- Эти две колонки назовите соответственно user_id_left и user_id_right. Также в результат включите колонки order_id, time,
-- action, sex, birth_date. Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).

-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT users.user_id as user_id_left, user_actions.user_id as user_id_right,  order_id, time, action, sex, birth_date
FROM users JOIN user_actions ON users.user_id = user_actions.user_id
ORDER BY user_id_left

----------------------------------------------------------------------------
SELECT a.user_id as user_id_left,
       b.user_id as user_id_right,
       order_id,
       time,
       action,
       sex,
       birth_date
FROM   user_actions a join users b using (user_id)
ORDER BY user_id_left

-- 2. А теперь попробуйте немного переписать запрос из прошлого задания и посчитать количество уникальных id в объединённой таблице.
-- То есть снова объедините таблицы, но в этот раз просто посчитайте уникальные user_id в одной из колонок с id.
-- Выведите это количество в качестве результата. Колонку с посчитанным значением назовите users_count.

-- Поле в результирующей таблице: users_count

-- После того как решите задачу, сравните полученное значение с количеством уникальных пользователей в таблицах users и user_actions,
-- которое мы посчитали на прошлом шаге. С каким значением оно совпадает?
-- 20,331 Со значением из таблицы users

SELECT count(DISTINCT users.user_id) as  users_count
FROM users JOIN user_actions ON users.user_id = user_actions.user_id

-- 3.LEFT JOIN С помощью LEFT JOIN объедините таблицы user_actions и users по ключу user_id. Обратите внимание на порядок таблиц — слева users_actions,
-- справа users. В результат включите две колонки с user_id из обеих таблиц. Эти две колонки назовите соответственно user_id_left и user_id_right.
-- Также в результат включите колонки order_id, time, action, sex, birth_date. Отсортируйте получившуюся таблицу по возрастанию id пользователя
-- (в колонке из левой таблицы).

-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

-- После того как решите задачу, обратите внимание на колонки с user_id. Нет ли в какой-то из них пропущенных значений?

SELECT user_actions.user_id as user_id_left, users.user_id as user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions LEFT JOIN users ON users.user_id = user_actions.user_id
ORDER BY user_id_left

-- 4. Теперь снова попробуйте немного переписать запрос из прошлого задания и посчитайте количество уникальных id в колонке user_id,
-- пришедшей из левой таблицы user_actions. Выведите это количество в качестве результата. Колонку с посчитанным значением назовите users_count.

-- Поле в результирующей таблице: users_count

-- После того как решите задачу, сравните полученное значение с количеством уникальных пользователей в таблицах users и user_actions.
-- С каким значением оно совпало в этот раз?
-- 21401  Со значением из таблицы user_actions

SELECT count(DISTINCT user_actions.user_id) as users_count
FROM user_actions LEFT JOIN users ON users.user_id = user_actions.user_id

-- 5. Возьмите запрос из задания 3, где вы объединяли таблицы user_actions и users с помощью LEFT JOIN, добавьте к запросу оператор WHERE
-- и исключите NULL значения в колонке user_id из правой таблицы. Включите в результат все те же колонки и отсортируйте получившуюся
-- таблицу по возрастанию id пользователя в колонке из левой таблицы.

-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

-- После того как решите задачу, попробуйте сдать это же решение в первом задании — сработает или нет? Подумайте, какой JOIN
-- мы сейчас получили после всех манипуляций с результатом. Заодно можете посчитать число уникальных user_id в запросе из этого задания,
-- чтобы расставить все точки над «i».
-- 20,331 Типо Inner Join	

SELECT user_actions.user_id as user_id_left, users.user_id as user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions LEFT JOIN users ON users.user_id = user_actions.user_id
WHERE users.user_id IS NOT NULL
ORDER BY user_id_left

-- 6. FULL JOIN С помощью FULL JOIN объедините по ключу birth_date таблицы, полученные в результате вышеуказанных запросов
-- (то есть объедините друг с другом два подзапроса). Не нужно изменять их, просто добавьте нужный join. В результат включите
-- две колонки с birth_date из обеих таблиц. Эти две колонки назовите соответственно users_birth_date и couriers_birth_date.
-- Также включите в результат колонки с числом пользователей и курьеров — users_count и couriers_count. Отсортируйте получившуюся
-- таблицу сначала по колонке users_birth_date по возрастанию, затем по колонке couriers_birth_date — тоже по возрастанию.

-- Поля в результирующей таблице: users_birth_date, users_count,  couriers_birth_date, couriers_count

-- После того как решите задачу, изучите полученную таблицу в Redash. Обратите внимание на пропущенные значения в колонках
-- с датами рождения курьеров и пользователей. Подтвердилось ли наше предположение?
-- Да, есть такие даты, в которые родился кто-то из курьеров, но не родился ни один пользователь, и наоборот.

SELECT users_birth_date, users_count,  couriers_birth_date, couriers_count
FROM (SELECT birth_date as users_birth_date, COUNT(user_id) AS users_count
    FROM users
    WHERE birth_date IS NOT NULL
    GROUP BY users_birth_date) AS t1
FULL JOIN 
    (SELECT birth_date as couriers_birth_date, COUNT(courier_id) AS couriers_count
    FROM couriers
    WHERE birth_date IS NOT NULL
    GROUP BY couriers_birth_date) AS t2
ON users_birth_date = couriers_birth_date
ORDER BY users_birth_date, couriers_birth_date

-- 7. Объедините два следующих запроса друг с другом так, чтобы на выходе получился набор уникальных дат из таблиц users и couriers:
-- SELECT birth_date
-- FROM users
-- WHERE birth_date IS NOT NULL

-- SELECT birth_date
-- FROM couriers
-- WHERE birth_date IS NOT NULL


-- Поместите в подзапрос полученный после объединения набор дат и посчитайте их количество. Колонку с числом дат назовите dates_count.

-- Поле в результирующей таблице: dates_count

-- После того как решите задачу, сравните полученное число дат с количеством строк в таблице, которую мы получили в прошлом задании.
-- Совпали ли эти значения?
-- 2672 Строк, в прошлом задании 4476

SELECT count(birth_date) as dates_count
FROM
(SELECT birth_date
FROM users
WHERE birth_date IS NOT NULL
UNION
SELECT birth_date
FROM couriers
WHERE birth_date IS NOT NULL) t1

-- 8. CROSS JOIN Из таблицы users отберите id первых 100 пользователей (LIMIT)и с помощью CROSS JOIN объедините их со всеми наименованиями
-- товаров из таблицы products. Выведите две колонки — id пользователя и наименование товара. Результат отсортируйте сначала по возрастанию
-- id пользователя, затем по имени товара — тоже по возрастанию.
-- Поля в результирующей таблице: user_id, name

-- После того как решите задачу, посмотрите сколько было изначально строк в каждой таблице и сравните с тем, сколько их получилось после объединения.

SELECT user_id, name
FROM 
    (SELECT user_id
    FROM users
    limit 100) t1
CROSS JOIN
    (SELECT name
    FROM products) t2
ORDER BY user_id, name

-- Давайте проведём небольшую аналитику нашего сервиса и посчитаем, сколько в среднем товаров заказывает каждый пользователь.

-- 9. Для начала объедините таблицы user_actions и orders — это вы уже умеете делать. В качестве ключа используйте поле order_id.
-- Выведите id пользователей и заказов, а также список товаров в заказе. Отсортируйте таблицу по id пользователя по возрастанию,
-- затем по id заказа — тоже по возрастанию.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, order_id, product_ids

-- Пояснение:
-- Перед тем как объединять таблицы, подумайте, какой тип соединения можно использовать. Попробуйте разные способы и сравните результаты.

SELECT user_id, order_id, product_ids
FROM user_actions LEFT JOIN orders using(order_id)
ORDER BY user_id, order_id
limit 1000

-- Немного уточним наш запрос, поскольку нас интересуют не все заказы из таблицы user_actions, а только те, которые не были отменены
-- пользователями, причём уникальные.

-- 10!! Снова объедините таблицы user_actions и orders, но теперь оставьте только уникальные неотменённые заказы (мы делали похожий запрос
-- на прошлом уроке). Остальные условия задачи те же: вывести id пользователей и заказов, а также список товаров в заказе. Отсортируйте
-- таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, order_id, product_ids

-- Пояснение:
-- Обратите внимание, что отфильтровать значения вы можете двумя способами. Это можно сделать либо до объединения таблиц, либо после него.
-- Рекомендуется делать фильтрацию до объединения, так как в таком случае вы заранее уменьшаете количество строк в одной из таблиц и тем
-- самым ускоряете процесс объединения. Однако для этого потребуется написать вложенный запрос.

SELECT user_id, order_id, product_ids
FROM 
    (SELECT distinct user_id, order_id
    FROM user_actions
    WHERE order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order') ) t1
JOIN orders using(order_id)
ORDER BY user_id, order_id
limit 1000

-- 11. Используя запрос из предыдущего задания, посчитайте, сколько в среднем товаров заказывает каждый пользователь. Выведите id пользователя
-- и среднее количество товаров в заказе. Среднее значение округлите до двух знаков после запятой. Колонку посчитанными значениями назовите
-- avg_order_size. Результат выполнения запроса отсортируйте по возрастанию id пользователя. 

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

-- Поля в результирующей таблице: user_id, avg_order_size

SELECT user_id, ROUND(AVG(array_length(product_ids, 1)), 2) as avg_order_size
FROM 
    (SELECT distinct user_id, order_id
    FROM user_actions
    WHERE order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order') ) t1
JOIN orders using(order_id)
GROUP BY user_id
ORDER BY user_id
limit 1000

-- 12. Что если бы мы захотели сделать более подробную аналитику и, например, посчитать среднюю стоимость заказа (средний чек) каждого клиента?
-- Для этого нам бы уже потребовалась информация о стоимости каждого отдельного заказа.

-- Для начала к таблице с заказами (orders) примените функцию unnest, как мы делали в прошлом уроке. Колонку с id товаров назовите product_id.
-- Затем к образовавшейся расширенной таблице по ключу product_id добавьте информацию о ценах на товары (из таблицы products).
-- Должна получиться таблица с заказами, товарами внутри каждого заказа и ценами на эти товары. Выведите колонки с id заказа,
-- id товара и ценой товара. Результат отсортируйте сначала по возрастанию id заказа, затем по возрастанию id товара.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

-- Поля в результирующей таблице: order_id, product_id, price

SELECT order_id, t1.product_id, price
FROM (SELECT unnest(product_ids) AS product_id, order_id FROM orders) t1
LEFT JOIN products ON t1.product_id = products.product_id
ORDER BY order_id, t1.product_id
LIMIT 1000

-- 13. Используя запрос из предыдущего задания, рассчитайте суммарную стоимость каждого заказа. Выведите колонки с id заказов и их стоимостью.
-- Колонку со стоимостью заказа назовите order_price. Результат отсортируйте по возрастанию id заказа.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

-- Поля в результирующей таблице: order_id, order_price

SELECT order_id, SUM(price) AS order_price
FROM
(SELECT unnest(product_ids) AS product_id, order_id FROM orders) t1
LEFT JOIN products ON t1.product_id = products.product_id
GROUP BY order_id
ORDER BY order_id
LIMIT 1000


-- 14. Объедините запрос из предыдущего задания с частью запроса, который вы составили в задаче 11, то есть объедините запрос со стоимостью
-- заказов с запросом, в котором вы считали размер каждого заказа из таблицы user_actions.

-- На основе объединённой таблицы для каждого пользователя рассчитайте следующие показатели (метрики):
-- общее число заказов — колонку назовите orders_count
-- среднее количество товаров в заказе — avg_order_size
-- суммарную стоимость всех покупок — sum_order_value
-- среднюю стоимость заказа — avg_order_value
-- минимальную стоимость заказа — min_order_value
-- максимальную стоимость заказа — max_order_value
-- Полученный результат отсортируйте по возрастанию id пользователя.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

-- Помните, что в расчётах мы по-прежнему учитываем только неотменённые заказы. При расчёте средних значений,
-- округляйте их до двух знаков после запятой.

-- Поля в результирующей таблице: 

-- user_id, orders_count, avg_order_size, sum_order_value, avg_order_value, min_order_value, max_order_value

-- Пояснение:
-- Для решения задачи нужно просто объединить запросы, которые вы уже написали на прошлых шагах, и сделать
-- группировку с агрегацией. Подумайте, какой ключ и тип соединения нужно использовать. Если ваш запрос кажется
-- слишком громоздким и сложным для восприятия, воспользуйтесь оператором WITH и табличными выражениями.

WITH subquery1 AS (
    SELECT order_id, SUM(price) AS order_price
    FROM
    (SELECT unnest(product_ids) AS product_id, order_id FROM orders) t1
    LEFT JOIN products ON t1.product_id = products.product_id
    GROUP BY order_id
    ORDER BY order_id
),
subquery2 AS (
    SELECT user_id, order_id, array_length(product_ids, 1) AS order_count_products
    FROM 
        (SELECT distinct user_id, order_id
        FROM user_actions
        WHERE order_id not in (SELECT order_id
                            FROM   user_actions
                            WHERE  action = 'cancel_order') ) t1
    JOIN orders using(order_id)
    ORDER BY user_id
)

SELECT user_id, COUNT(order_id) AS orders_count, ROUND(AVG(order_count_products), 2) AS avg_order_size,
SUM(order_price) AS sum_order_value, ROUND(AVG(order_price), 2) AS avg_order_value, MIN(order_price) AS min_order_value,
MAX(order_price) AS max_order_value
FROM  subquery1 JOIN subquery2 using(order_id)
GROUP BY user_id
ORDER BY user_id
LIMIT 1000

-- 15. По таблицам courier_actions , orders и products определите 10 самых популярных товаров, доставленных в сентябре 2022 года.
-- Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего. Если товар встречается в одном заказе
-- несколько раз (было куплено несколько единиц товара), то при подсчёте учитываем только одну единицу товара. Выведите наименования
-- товаров и сколько раз они встречались в заказах. Новую колонку с количеством покупок товара назовите times_purchased. 
-- Поля в результирующей таблице: name, times_purchased

-- Пояснение:
-- Мы уже решали похожую задачу на прошлом уроке. Попробуйте модифицировать свой запрос таким образом, чтобы он выводил наименования товаров,
-- а не id. Также не забудьте учесть, что теперь несколько вхождений товара в заказ считаем, как одно вхождение.

WITH subquery1 AS (
    SELECT product_id, count(product_id) AS times_purchased
    FROM(
        SELECT distinct order_id, unnest(product_ids) as product_id
        FROM orders LEFT JOIN courier_actions using(order_id)
        WHERE date_part('month', time) = 9 AND date_part('year', time) = 2022 AND action = 'deliver_order'
    ) t1
    GROUP BY product_id
)

SELECT name, times_purchased
FROM subquery1 LEFT JOIN products using(product_id)
ORDER BY times_purchased desc
limit 10

-- 2 Способ
SELECT name, count(product_id) as times_purchased
FROM   (SELECT DISTINCT order_id, unnest(product_ids) as product_id
        FROM   orders) as t
        LEFT JOIN products using (product_id)
        RIGHT JOIN courier_actions using (order_id)
WHERE  action = 'deliver_order'
   and date_part('month', time) = 9
   and date_part('year', time) = 2022
GROUP BY name
ORDER BY times_purchased desc
limit 10

-- 16. Доля отменённых заказов. Возьмите запрос, составленный на одном из прошлых уроков, и подтяните в него из таблицы users данные
-- о поле пользователей таким образом, чтобы все пользователи из таблицы users_actions остались в результате. Затем посчитайте среднее
-- значение cancel_rate для каждого пола, округлив его до трёх знаков после запятой. Колонку с посчитанным средним значением назовите
-- avg_cancel_rate.

-- Помните про отсутствие информации о поле некоторых пользователей после join, так как не все пользователи из таблицы user_action
-- есть в таблице users. Для этой группы тоже посчитайте cancel_rate и в результирующей таблице для пустого значения в колонке с
-- полом укажите ‘unknown’ (без кавычек). Возможно, для этого придётся вспомнить, как работает COALESCE.

-- Результат отсортируйте по колонке с полом пользователя по возрастанию.
-- Поля в результирующей таблице: sex, avg_cancel_rate

-- Пояснение:
-- Метрику cancel_rate в разрезе пола можно посчитать разными способами, в этой задаче предлагаем следующий алгоритм:
-- 1. Сначала посчитайте cancel_rate для каждого пользователя.
-- 2. Затем приджойните к результату информацию о поле пользователей.
-- 3. Потом рассчитайте avg_cancel_rate для каждого пола и округлите значения до трёх знаков после запятой.

WITH subjuery1 AS (
    SELECT user_id,
           round(count(order_id) filter (WHERE action = 'cancel_order') / count(distinct order_id)::decimal, 2) as cancel_rate
    FROM   user_actions
    GROUP BY user_id
    ORDER BY user_id
)

SELECT coalesce(sex, 'unknown') as sex, ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM subjuery1 LEFT JOIN users using(user_id)
GROUP BY sex
ORDER BY sex

-- 17. По таблицам orders и courier_actions определите id десяти заказов, которые доставляли дольше всего.
-- Поле в результирующей таблице: order_id

-- Пояснение:
-- Для расчёта времени, затраченного на доставку заказа, используйте информацию о времени доставки и времени создания заказа
-- — с данными в формате времени можно тоже проводить арифметические операции (например, вычислять разницу между ними).
-- Обратите внимание, что колонки с этими данными находятся в разных таблицах. Для определения самых долгих заказов используйте оператор LIMIT. 

SELECT order_id
FROM   orders RIGHT JOIN (SELECT order_id, time as deliver_time
                          FROM   courier_actions
                          WHERE  action = 'deliver_order') as t using (order_id)
ORDER BY deliver_time - creation_time DESC
LIMIT 10

-- 18*. На днях менеджер снова обратился к вам с задачей: попросил сделать выгрузку из таблицы orders со всеми заказами и их содержимым.
-- Из переписки вы так и не поняли, зачем ему все эти данные, но задачу сделали: нажали SELECT * и отправили ему excel-файл с заказами.
-- На следующее утро выяснилось, что такие данные его не устраивают, так как он не понимает, что это за списки с наборами чисел.
-- Действительно, этот момент вы не учли.

-- Задача: Произведите замену списков с id товаров из таблицы orders на списки с наименованиями товаров. Наименования возьмите из
-- таблицы products. Колонку с новыми списками наименований назовите product_names. 

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: order_id, product_names
-- Пояснение:

-- Для решения задачи вам нужно сделать unnest колонки product_ids, соединить промежуточный результат с таблицей products для получения
-- наименований товаров, а затем сделать обратно группировку с агрегацией в список наименований. 
-- Для того чтобы сделать агрегацию значений в колонке в список, необходимо воспользоваться функцией array_agg.
-- array_agg — это продвинутая агрегирующая функция, которая собирает все значения в указанном столбце в единый список (ARRAY).
-- По сути array_agg — это операция, обратная unnest, её синтаксис ничем не отличается от синтаксиса остальных агрегирующих функций:
-- SELECT column_1, array_agg(column_2) AS new_array
-- FROM table
-- GROUP BY column_1
-- Перед тем как решать задачу, попробуйте сначала выполнить простое упражнение: разверните списки с id товаров, поместите результат
-- в подзапрос, а потом сразу же сверните всё обратно в списки с помощью array_agg. Алгоритм решения этой задачи примерно такой же.

SELECT order_id, array_agg(name) AS product_names
FROM 
    (SELECT order_id, unnest(product_ids) as product_id FROM orders) t1
    LEFT JOIN products using(product_id)
GROUP BY order_id
LIMIT 1000

-- 19**. Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.
-- Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя и возраст курьера.
-- Возраст измерьте числом полных лет, как мы делали в прошлых уроках. Считайте его относительно последней даты в таблице
-- user_actions — как для пользователей, так и для курьеров. Колонки с возрастом назовите user_age и courier_age.
-- Результат отсортируйте по возрастанию id заказа.

-- Поля в результирующей таблице: order_id, user_id, user_age, courier_id, courier_age

WITH subquery1 AS (
    SELECT DISTINCT orders.order_id, user_id, courier_id
    FROM orders
        LEFT JOIN user_actions using(order_id)
        LEFT JOIN courier_actions using(order_id)
    WHERE orders.order_id IN (
        SELECT order_id
        FROM orders
        WHERE array_length(product_ids, 1) = (SELECT MAX(array_length(product_ids, 1))
                                                FROM orders)
    )
)

SELECT order_id,
        user_id,
        date_part('year', age((SELECT MAX(time)::DATE FROM   user_actions), users.birth_date)) AS user_age,
        courier_id,
        date_part('year', age((SELECT MAX(time)::DATE FROM   user_actions), couriers.birth_date)) AS courier_age
FROM subquery1
    LEFT JOIN users using(user_id)
    LEFT JOIN couriers using(courier_id)
ORDER BY order_id
-- 2 Способ ==================================
with order_id_large_size as (SELECT order_id
                             FROM   orders
                             WHERE  array_length(product_ids, 1) = (SELECT max(array_length(product_ids, 1))
                                                                    FROM   orders))
SELECT DISTINCT order_id,
                user_id,
                date_part('year', age((SELECT max(time) FROM   user_actions), users.birth_date)) as user_age,
                courier_id,
                date_part('year', age((SELECT max(time) FROM   user_actions), couriers.birth_date)) as courier_age
FROM   (SELECT order_id,
               user_id
        FROM   user_actions
        WHERE  order_id in (SELECT * FROM   order_id_large_size)) t1
    LEFT JOIN (SELECT order_id,
                      courier_id
               FROM   courier_actions
               WHERE  order_id in (SELECT * FROM   order_id_large_size)) t2 using(order_id)
    LEFT JOIN users using(user_id)
    LEFT JOIN couriers using(courier_id)
ORDER BY order_id

-- 20**. SELF JOIN. Выясните, какие пары товаров покупают вместе чаще всего.
-- Пары товаров сформируйте на основе таблицы с заказами. Отменённые заказы не учитывайте. В качестве результата выведите две колонки
-- — колонку с парами наименований товаров и колонку со значениями, показывающими, сколько раз конкретная пара встретилась в заказах
-- пользователей. Колонки назовите соответственно pair и count_pair.

-- Пары товаров должны быть представлены в виде списков из двух наименований. Пары товаров внутри списков должны быть отсортированы
-- в порядке возрастания наименования. Результат отсортируйте сначала по убыванию частоты встречаемости пары товаров в заказах, затем
-- по колонке pair — по возрастанию.

-- Поля в результирующей таблице: pair, count_pair

-- Пояснение:
-- В этой задаче вам необходимо сделать SELF JOIN. Подумайте, какую таблицу нужно присоединить к самой себе и заранее обработайте данные.
-- Для решения рекомендуем воспользоваться табличными выражениями. Также вам могут пригодиться функции для работы со списками. Ознакомьтесь
-- с примерами из документации и подумайте, что можно использовать в своём решении.
-- Задача творческая и может быть решена разными способами.








