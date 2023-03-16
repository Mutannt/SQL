-- Задача 1.
-- Для каждого дня в таблице orders рассчитайте следующие показатели:
-- •	Выручку, полученную в этот день.
-- •	Суммарную выручку на текущий день.
-- •	Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.
-- Колонки с показателями назовите соответственно revenue, total_revenue, revenue_change. Колонку с датами назовите date.
-- Прирост выручки рассчитайте в процентах и округлите значения до двух знаков после запятой.
-- Результат должен быть отсортирован по возрастанию даты.
-- Поля в результирующей таблице: date, revenue, total_revenue, revenue_change
-- Пояснение: 
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день,
-- а оплата получена на следующий, возникнуть не могут.
-- Суммарная выручка на текущий день — это результат сложения выручки, полученной в текущий день, со значениями аналогичного
-- показателя всех предыдущих дней.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Не забывайте при делении заранее приводить значения к нужному типу данных. Пропущенные значения прироста для самой первой
-- даты не заполняйте — просто оставьте поля в этой строке пустыми.

WITH subquery1 AS (
SELECT creation_time::DATE as date, SUM(price) as revenue
FROM 
    (SELECT creation_time, order_id, product_ids, unnest(product_ids) as product_id
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY creation_time::DATE)

SELECT date, revenue, 
sum(revenue) over (order by date) as total_revenue,
ROUND(revenue * 100::decimal / lag(revenue) over (order by date) -100, 2) as revenue_change
FROM subquery1
ORDER BY date




-- Задача 2.
-- Теперь на основе данных о выручке рассчитаем несколько относительных показателей, которые покажут, сколько в среднем потребители
-- готовы платить за услуги нашего сервиса доставки. Остановимся на следующих метриках:
-- 1. ARPU (Average Revenue Per User) — средняя выручка на одного пользователя за определённый период.
-- 2. ARPPU (Average Revenue Per Paying User) — средняя выручка на одного платящего пользователя за определённый период.
-- 3. AOV (Average Order Value) — средний чек, или отношение выручки за определённый период к общему количеству заказов за это же время.
-- Если за рассматриваемый период сервис заработал 100 000 рублей и при этом им пользовались 500 уникальных пользователей, из которых
-- 400 сделали в общей сложности 650 заказов, тогда метрики будут иметь следующие значения:
-- ARPU =100000/500=200
-- ARPPU =100000/400=250
-- AOV=100000/650≈153,85
-- Задание:
-- Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:
-- •	Выручку на пользователя (ARPU) за текущий день.
-- •	Выручку на платящего пользователя (ARPPU) за текущий день.
-- •	Выручку с заказа, или средний чек (AOV) за текущий день.
-- Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с датами назовите date. 
-- При расчёте всех показателей округляйте значения до двух знаков после запятой.
-- Результат должен быть отсортирован по возрастанию даты. 
-- Поля в результирующей таблице: date, arpu, arppu, aov
-- Пояснение: 
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день,
-- а оплата получена на следующий, возникнуть не могут.
-- Платящими будем считать тех пользователей, которые в данный день оформили хотя бы один заказ, который в дальнейшем не был отменен.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Не забывайте при делении заранее приводить значения к нужному типу данных.

WITH subquery1 AS (
SELECT date, SUM(price) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as revenue,
count(distinct user_id) as count_users,
count(distinct user_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as count_paying_users,
count(distinct order_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order'))  as count_orders
FROM
    (SELECT time::date as date, order_id, product_ids, unnest(product_ids) as product_id, user_id
    FROM orders JOIN user_actions using(order_id)
    ) t1
    LEFT JOIN products using(product_id)
GROUP BY date)

SELECT date,
ROUND(revenue::decimal / count_users, 2) as arpu,
ROUND(revenue::decimal / count_paying_users, 2) as arppu,
ROUND(revenue::decimal / count_orders, 2) as aov
FROM subquery1
ORDER BY date

-- Задача 3.
-- Дополним наш анализ ещё более интересными расчётами — вычислим все те же метрики, но для каждого дня будем учитывать накопленную
-- выручку и все имеющиеся на текущий момент данные о числе пользователей и заказов. Таким образом, получим динамический ARPU,
-- ARPPU и AOV и сможем проследить, как он менялся на протяжении времени с учётом поступающих нам данных.
-- По таблицам orders и user_actions для каждого дня рассчитайте следующие показатели:
-- •	Накопленную выручку на пользователя (Running ARPU).
-- •	Накопленную выручку на платящего пользователя (Running ARPPU).
-- •	Накопленную выручку с заказа, или средний чек (Running AOV).
-- Колонки с показателями назовите соответственно running_arpu, running_arppu, running_aov. Колонку с датами назовите date. 
-- При расчёте всех показателей округляйте значения до двух знаков после запятой.
-- Результат должен быть отсортирован по возрастанию даты. 
-- Поля в результирующей таблице: date, running_arpu, running_arppu, running_aov
-- Пояснение: 
-- При расчёте числа пользователей и платящих пользователей на текущую дату учитывайте соответствующих пользователей за все предыдущие дни,
-- включая текущий.
-- Платящими будем считать тех пользователей, которые на текущий день оформили хотя бы один заказ, который в дальнейшем не был отменен.
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день,
-- а оплата получена на следующий, возникнуть не могут.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Не забывайте при делении заранее приводить значения к нужному типу данных.

WITH subquery1 AS (
SELECT date, SUM(price) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as revenue,
count(distinct user_id) as count_users,
count(distinct user_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as count_paying_users,
count(distinct order_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order'))  as count_orders
FROM
    (SELECT time::DATE as date, order_id, product_ids, unnest(product_ids) as product_id, user_id
    FROM orders JOIN user_actions using(order_id)
    ) t1
    LEFT JOIN products using(product_id)
GROUP BY date)

SELECT date, 
ROUND(revenue2::decimal / count_users2, 2) as running_arpu,
ROUND(revenue2::decimal / count_paying_users2, 2) as running_arppu,
ROUND(revenue2::decimal / count_orders2, 2) as running_aov
FROM
    (SELECT date,
    sum(revenue) over (order by date) as revenue2,
    sum(count_users) over (order by date) as count_users2,
    sum(count_paying_users) over (order by date) as count_paying_users2,
    sum(count_orders) over (order by date) as count_orders2
    FROM subquery1) t2
ORDER BY date

-- Задача 4.
-- Давайте посчитаем те же показатели, но в другом разрезе — не просто по дням, а по дням недели.
-- Задание:
-- Для каждого дня недели в таблицах orders и user_actions рассчитайте следующие показатели:
-- •	Выручку на пользователя (ARPU).
-- •	Выручку на платящего пользователя (ARPPU).
-- •	Выручку на заказ (AOV).
-- При расчётах учитывайте данные только за период с 26 августа 2022 года по 8 сентября 2022 года включительно — так,
-- чтобы в анализ попало одинаковое количество всех дней недели (ровно по два дня).
-- В результирующую таблицу включите как наименования дней недели (например, Monday), так и порядковый номер дня недели
-- (от 1 до 7, где 1 — это Monday, 7 — это Sunday).
-- Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с наименованием дня недели назовите weekday,
-- а колонку с порядковым номером дня недели weekday_number.
-- При расчёте всех показателей округляйте значения до двух знаков после запятой.
-- Результат должен быть отсортирован по возрастанию порядкового номера дня недели.
-- Поля в результирующей таблице: 
-- weekday, weekday_number, arpu, arppu, aov
-- Пояснение: 
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день,
-- а оплата получена на следующий, возникнуть не могут.
-- Платящими будем считать тех пользователей, которые в данный день оформили хотя бы один заказ, который в дальнейшем не был отменен.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Не забывайте при делении заранее приводить значения к нужному типу данных.
-- В этой задаче порядковый номер дня недели необходим для того, чтобы дни недели были расположены на графике слева направо в
-- правильном порядке — не по возрастанию наименования, а по возрастанию порядкового номера. Для получения корректной визуализации
-- в настройках оси X необходимо отключить сортировку, установленную по умолчанию.

WITH subquery1 as (
SELECT to_char(date, 'Day') as weekday, date_part('isodow', date) as weekday_number,
SUM(price) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as revenue,
count(distinct user_id) as count_users,
count(distinct user_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as count_paying_users,
count(distinct order_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order'))  as count_orders
FROM
    (SELECT time::DATE as date, order_id, product_ids, unnest(product_ids) as product_id, user_id
    FROM orders join user_actions using(order_id)
    WHERE time BETWEEN '2022-08-26' AND '2022-09-09') t1
    LEFT JOIN products using(product_id)
GROUP BY weekday, weekday_number)

SELECT weekday, weekday_number,
ROUND(revenue::decimal / count_users, 2) as arpu,
ROUND(revenue::decimal / count_paying_users, 2) as arppu,
ROUND(revenue::decimal / count_orders, 2) as aov
FROM subquery1
ORDER BY weekday_number

-- Задача 5
-- Немного усложним наш первоначальный запрос и отдельно посчитаем ежедневную выручку с заказов новых пользователей
-- нашего сервиса. Посмотрим, какую долю она составляет в общей выручке с заказов всех пользователей — и новых, и старых.
-- Задание:
-- Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:
-- Выручку, полученную в этот день.
-- Выручку с заказов новых пользователей, полученную в этот день.
-- Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
-- Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.
-- Колонки с показателями назовите соответственно revenue, new_users_revenue, new_users_revenue_share,
-- old_users_revenue_share. Колонку с датами назовите date. 
-- Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.
-- Результат должен быть отсортирован по возрастанию даты.
-- Поля в результирующей таблице:
-- date, revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share
-- Пояснение: 
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен
-- в один день, а оплата получена на следующий, возникнуть не могут.
-- Новыми будем считать тех пользователей, которые в данный день совершили своё первое действие в нашем сервисе.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Не забывайте при делении заранее приводить значения к нужному типу данных.

WITH date_first_action as (
    -- Дата первого действия пользователя
    SELECT user_id, MIN(time::date) AS min_date
    FROM user_actions
    GROUP BY user_id
),
order_cost as (
    -- Стоимость заказов
    SELECT order_id, sum(price)as order_cost
    FROM
        (SELECT order_id, unnest(product_ids) as product_id
        FROM orders) t1
        LEFT JOIN products using(product_id)
    GROUP BY order_id
),
total_cost_on_date as (
    -- Суммарная стоимость заказов на каждую дату для пользователя
    SELECT user_id, time::date as date, sum(order_cost)
    FROM user_actions LEFT JOIN order_cost using(order_id)
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY user_id, date
)

SELECT date, revenue, new_users_revenue,
ROUND(new_users_revenue * 100::decimal / revenue, 2) as new_users_revenue_share,
100 - ROUND(new_users_revenue * 100::decimal / revenue, 2) as old_users_revenue_share
FROM
-- Выручка, полученная с каждого пользователя в его первый день(user_id, date, sum),
-- GROUP BY - суммарная выручка с новых пользователей за каждый день
    (SELECT date, sum(sum) as new_users_revenue
    FROM date_first_action LEFT JOIN total_cost_on_date using(user_id)
    WHERE min_date = date
    GROUP BY date) t2
    
    LEFT JOIN 
-- Выручка, полученная в этот день
    (SELECT time::date as date, sum(order_cost) as revenue
    FROM user_actions LEFT JOIN order_cost using(order_id)
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY date) t3
    
    USING(date)
ORDER BY date


-- Задача 6
-- Также было бы интересно посмотреть, какие товары пользуются наибольшим спросом и приносят нам основной доход.
-- Задание:
-- Для каждого товара, представленного в таблице products, за весь период времени в таблице orders рассчитайте следующие показатели:
-- 1.	Суммарную выручку, полученную от продажи этого товара за весь период.
-- 2.	Долю выручки от продажи этого товара в общей выручке, полученной за весь период.
-- Колонки с показателями назовите соответственно revenue и share_in_revenue. Колонку с наименованиями товаров назовите product_name.
-- Долю выручки с каждого товара необходимо выразить в процентах. При её расчёте округляйте значения до двух знаков после запятой.
-- Товары, округлённая доля которых в выручке составляет менее 0.5%, объедините в общую группу с названием «ДРУГОЕ» (без кавычек),
-- просуммировав округлённые доли этих товаров.
-- Результат должен быть отсортирован по убыванию выручки от продажи товара.
-- Поля в результирующей таблице: product_name, revenue, share_in_revenue
-- Пояснение: 
-- Будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день,
-- а оплата получена на следующий, возникнуть не могут.
-- При расчёте выручки помните, что не все заказы были оплачены — некоторые были отменены пользователями.
-- Товары с небольшой долей в выручке необходимо объединить в одну группу, чтобы не выводить на графике абсолютно все товары из
-- таблицы products.

WITH subquery1 AS (
SELECT name as product_name,
SUM(price) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) as revenue
FROM
    (SELECT order_id, product_ids, unnest(product_ids) as product_id, user_id
    FROM orders JOIN user_actions using(order_id)
    ) t1
    LEFT JOIN products using(product_id)
GROUP BY product_name),
subquery2 as (
    SELECT product_name, revenue,
    ROUND(revenue * 100 / SUM(revenue) OVER(), 2) as share_in_revenue
    FROM subquery1
),
subquery3 as (
    SELECT sum(revenue) as revenue, sum(share_in_revenue) as share_in_revenue
    FROM subquery2
    WHERE share_in_revenue <= 0.5
)

SELECT *
FROM subquery2
WHERE share_in_revenue > 0.5
UNION
SELECT 'ДРУГОЕ' AS product_name, revenue, share_in_revenue FROM subquery3
ORDER BY revenue DESC

-- 2 Способ
SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT case when round(100 * revenue / sum(revenue) OVER (), 2) >= 0.5 then name
                    else 'ДРУГОЕ' end as product_name,
               revenue,
               round(100 * revenue / sum(revenue) OVER (), 2) as share_in_revenue
        FROM   (SELECT name,
                       sum(price) as revenue
                FROM   (SELECT order_id,
                               unnest(product_ids) as product_id
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')) t1
                    LEFT JOIN products using(product_id)
                GROUP BY name) t2) t3
GROUP BY product_name
ORDER BY revenue desc


