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

-- 9. Давайте проведём небольшую аналитику нашего сервиса и посчитаем, сколько в среднем товаров заказывает каждый пользователь.
-- Для начала объедините таблицы user_actions и orders — это вы уже умеете делать. В качестве ключа используйте поле order_id.
-- Выведите id пользователей и заказов, а также список товаров в заказе. Отсортируйте таблицу по id пользователя по возрастанию,
-- затем по id заказа — тоже по возрастанию.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, order_id, product_ids

-- Пояснение:
-- Перед тем как объединять таблицы, подумайте, какой тип соединения можно использовать. Попробуйте разные способы и сравните результаты.


