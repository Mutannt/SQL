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

-- ==========================================================================================================================
-- Рассмотрим метрику CAC (Customer Acquisition Cost), которая отражает совокупные затраты на привлечение одного покупателя.
-- Представим ситуацию: к нам обратились маркетологи с просьбой сравнить две рекламные кампании.
-- В рекламной кампании № 1 о нашем приложении рассказал известный блогер на Youtube-канале о кулинарии. На эту интеграцию суммарно
-- потратили 250 тысяч рублей. В результате этой кампании 1 сентября в приложении зарегистрировались 200 человек.
-- В рамках рекламной кампании № 2 пользователям показывали таргетированную рекламу в социальных сетях. На это тоже суммарно потратили
-- 250 тысяч рублей, и в результате 1 сентября у нас появилось 260 новых пользователей.
-- Как нам оценить, какой из каналов привлечения сработал лучше? На первый взгляд, вторая кампания показала себя лучше, поскольку нам
-- удалось привлечь больше людей за те же деньги. Но не будем торопиться с выводами — давайте сначала проведём более подробный анализ
-- и рассчитаем CAC для двух рекламных кампаний.

-- Задание 1:
-- На основе таблицы user_actions рассчитайте метрику CAC для двух рекламных кампаний.
-- олонку с наименованиями кампаний назовите ads_campaign, а колонку со значением метрики — cac.
-- Наименования кампаний выведите в следующем виде:
-- Кампания № 1
-- Кампания № 2
-- Полученные значения метрики округлите до двух знаков после запятой.
-- Результат должен быть отсортирован по убыванию значения метрики.
-- Поля в результирующей таблице: ads_campaign, cac
-- Пояснение: 
-- Покупателями будем считать тех пользователей, которые сделали хотя бы один заказ, который в дальнейшем не был отменён.
-- Например, если человек сделал только один заказ, а потом отменил его, то покупателем мы его не считаем.
-- Не забывайте при делении заранее приводить значения к нужному типу данных.

-- Покупатели из первой рекламной компании
SELECT 'Кампания № 1' AS ads_campaign, ROUND(250000::decimal / count(distinct user_id),2) as cac
FROM user_actions
WHERE user_id IN (8804, 9828, 9524, 9667, 9165, 10013, 9625, 8879, 9145, 8657, 8706, 9476, 9813, 
                8940, 9971, 10122, 8732, 9689, 9198, 8896, 8815, 9689, 9075, 9071, 9528, 9896, 
                10135, 9478, 9612, 8638, 10057, 9167, 9450, 9999, 9313, 9720, 9599, 9351, 8638, 
                8752, 9998, 9431, 9660, 9004, 8632, 8896, 8750, 9605, 8867, 9535, 9494, 9762, 
                8990, 9526, 9786, 9654, 9144, 9391, 10016, 8988, 9009, 9061, 9004, 9550, 8707, 
                8788, 8988, 8853, 9836, 8810, 9916, 9660, 9677, 9896, 8933, 8828, 9108, 9180, 
                9897, 9960, 9472, 9818, 9695, 9965, 10023, 8972, 9035, 8869, 9662, 9561, 9740, 
                8723, 9146, 10103, 9963, 10103, 8715, 9167, 9313, 9679, 9251, 10001, 8867, 8707, 
                9945, 9562, 10013, 9020, 9317, 9002, 9838, 9144, 8911, 9505, 9313, 10134, 9197, 
                9398, 9652, 9999, 9210, 8741, 9963, 9422, 9778, 8815, 9512, 9794, 9019, 9287, 9561, 
                9321, 9677, 10122, 8752, 9810, 9871, 9162, 8876, 9414, 10030, 9334, 9175, 9182, 
                9451, 9257, 9321, 9531, 9655, 9845, 8883, 9993, 9804, 10105, 8774, 8631, 9081, 8845, 
                9451, 9019, 8750, 8788, 9625, 9414, 10064, 9633, 9891, 8751, 8643, 9559, 8791, 9518, 
                9968, 9726, 9036, 9085, 9603, 8909, 9454, 9739, 9223, 9420, 8830, 9615, 8859, 9887, 
                9491, 8739, 8770, 9069, 9278, 9831, 9291, 9089, 8976, 9611, 10082, 8673, 9113, 10051)
                and order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
UNION                
-- Покупатели из второй рекламной компании
SELECT 'Кампания № 2' AS ads_campaign, ROUND(250000::decimal / count(distinct user_id),2) as cac
FROM user_actions
WHERE user_id IN (9752, 9510, 8893, 9196, 10038, 9839, 9820, 9064, 9930, 9529, 9267, 9161, 9231, 
                    8953, 9863, 8878, 10078, 9370, 8675, 9961, 9007, 9207, 9539, 9335, 8700, 9598, 
                    9068, 9082, 8916, 10131, 9704, 9904, 9421, 9083, 9337, 9041, 8955, 10033, 9137, 
                    9539, 8855, 9117, 8771, 9226, 8733, 8851, 9749, 10027, 9757, 9788, 8646, 9567, 
                    9140, 9719, 10073, 9000, 8971, 9437, 9958, 8683, 9410, 10075, 8923, 9255, 8995, 
                    9343, 10059, 9082, 9267, 9929, 8670, 9570, 9281, 8795, 9082, 8814, 8795, 10067, 
                    9700, 9432, 9783, 10081, 9591, 8733, 9337, 9808, 9392, 9185, 8882, 8681, 8825, 
                    9692, 10048, 8682, 9631, 8942, 9910, 9428, 9500, 9527, 8655, 8890, 9000, 8827, 
                    9485, 9013, 9042, 10047, 8798, 9250, 8929, 9161, 9545, 9333, 9230, 9841, 8659, 
                    9181, 9880, 9983, 9538, 9483, 9557, 9883, 9901, 9103, 10110, 8827, 9530, 9310, 
                    9711, 9383, 9527, 8968, 8973, 9497, 9753, 8980, 8838, 9370, 8682, 8854, 8966, 
                    9658, 9939, 8704, 9281, 10113, 8697, 9149, 8870, 9959, 9127, 9203, 9635, 9273, 
                    9356, 10069, 9855, 8680, 9912, 8900, 9131, 10058, 9479, 9259, 9368, 9908, 9468, 
                    8902, 9292, 8742, 9672, 9564, 8949, 9404, 9183, 8913, 8694, 10092, 8771, 8805, 
                    8794, 9179, 9666, 9095, 9935, 9190, 9183, 9631, 9231, 9109, 9123, 8806, 9229, 
                    9741, 9303, 9303, 10045, 9744, 8665, 9843, 9634, 8812, 9684, 9616, 8660, 9498, 
                    9877, 9727, 9882, 8663, 9755, 8754, 9131, 9273, 9879, 9492, 9920, 9853, 8803, 
                    9711, 9885, 9560, 8886, 8644, 9636, 10073, 10106, 9859, 8943, 8849, 8629, 8729, 
                    9227, 9711, 9282, 9312, 8630, 9735, 9315, 9077, 8999, 8713, 10079, 9596, 8748, 
                    9327, 9790, 8719, 9706, 9289, 9047, 9495, 9558, 8650, 9784, 8935, 9764, 8712)
                and order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')

-- 2 Вариант
SELECT concat('Кампания № ', ads_campaign) as ads_campaign,
       round(250000.0 / count(distinct user_id), 2) as cac
FROM   (SELECT user_id,
               order_id,
               action,
               case when user_id in (8804, 9828, 9524, 9667, 9165, 10013, 9625, 8879, 9145, 8657,
                                     8706, 9476, 9813, 8940, 9971, 10122, 8732, 9689, 9198,
                                     8896, 8815, 9689, 9075, 9071, 9528, 9896, 10135, 9478,
                                     9612, 8638, 10057, 9167, 9450, 9999, 9313, 9720, 9599,
                                     9351, 8638, 8752, 9998, 9431, 9660, 9004, 8632, 8896,
                                     8750, 9605, 8867, 9535, 9494, 9762, 8990, 9526, 9786,
                                     9654, 9144, 9391, 10016, 8988, 9009, 9061, 9004, 9550,
                                     8707, 8788, 8988, 8853, 9836, 8810, 9916, 9660, 9677,
                                     9896, 8933, 8828, 9108, 9180, 9897, 9960, 9472, 9818,
                                     9695, 9965, 10023, 8972, 9035, 8869, 9662, 9561, 9740,
                                     8723, 9146, 10103, 9963, 10103, 8715, 9167, 9313, 9679,
                                     9251, 10001, 8867, 8707, 9945, 9562, 10013, 9020, 9317,
                                     9002, 9838, 9144, 8911, 9505, 9313, 10134, 9197, 9398,
                                     9652, 9999, 9210, 8741, 9963, 9422, 9778, 8815, 9512,
                                     9794, 9019, 9287, 9561, 9321, 9677, 10122, 8752, 9810,
                                     9871, 9162, 8876, 9414, 10030, 9334, 9175, 9182, 9451,
                                     9257, 9321, 9531, 9655, 9845, 8883, 9993, 9804, 10105,
                                     8774, 8631, 9081, 8845, 9451, 9019, 8750, 8788, 9625,
                                     9414, 10064, 9633, 9891, 8751, 8643, 9559, 8791, 9518,
                                     9968, 9726, 9036, 9085, 9603, 8909, 9454, 9739, 9223,
                                     9420, 8830, 9615, 8859, 9887, 9491, 8739, 8770, 9069,
                                     9278, 9831, 9291, 9089, 8976, 9611, 10082, 8673, 9113,
                                     10051) then 1
                    when user_id in (9752, 9510, 8893, 9196, 10038, 9839, 9820, 9064, 9930, 9529, 9267,
                                     9161, 9231, 8953, 9863, 8878, 10078, 9370, 8675, 9961,
                                     9007, 9207, 9539, 9335, 8700, 9598, 9068, 9082, 8916,
                                     10131, 9704, 9904, 9421, 9083, 9337, 9041, 8955, 10033,
                                     9137, 9539, 8855, 9117, 8771, 9226, 8733, 8851, 9749,
                                     10027, 9757, 9788, 8646, 9567, 9140, 9719, 10073, 9000,
                                     8971, 9437, 9958, 8683, 9410, 10075, 8923, 9255, 8995,
                                     9343, 10059, 9082, 9267, 9929, 8670, 9570, 9281, 8795,
                                     9082, 8814, 8795, 10067, 9700, 9432, 9783, 10081, 9591,
                                     8733, 9337, 9808, 9392, 9185, 8882, 8681, 8825, 9692,
                                     10048, 8682, 9631, 8942, 9910, 9428, 9500, 9527, 8655,
                                     8890, 9000, 8827, 9485, 9013, 9042, 10047, 8798, 9250,
                                     8929, 9161, 9545, 9333, 9230, 9841, 8659, 9181, 9880,
                                     9983, 9538, 9483, 9557, 9883, 9901, 9103, 10110, 8827,
                                     9530, 9310, 9711, 9383, 9527, 8968, 8973, 9497, 9753,
                                     8980, 8838, 9370, 8682, 8854, 8966, 9658, 9939, 8704,
                                     9281, 10113, 8697, 9149, 8870, 9959, 9127, 9203, 9635,
                                     9273, 9356, 10069, 9855, 8680, 9912, 8900, 9131, 10058,
                                     9479, 9259, 9368, 9908, 9468, 8902, 9292, 8742, 9672,
                                     9564, 8949, 9404, 9183, 8913, 8694, 10092, 8771, 8805,
                                     8794, 9179, 9666, 9095, 9935, 9190, 9183, 9631, 9231,
                                     9109, 9123, 8806, 9229, 9741, 9303, 9303, 10045, 9744,
                                     8665, 9843, 9634, 8812, 9684, 9616, 8660, 9498, 9877,
                                     9727, 9882, 8663, 9755, 8754, 9131, 9273, 9879, 9492,
                                     9920, 9853, 8803, 9711, 9885, 9560, 8886, 8644, 9636,
                                     10073, 10106, 9859, 8943, 8849, 8629, 8729, 9227, 9711,
                                     9282, 9312, 8630, 9735, 9315, 9077, 8999, 8713, 10079,
                                     9596, 8748, 9327, 9790, 8719, 9706, 9289, 9047, 9495,
                                     9558, 8650, 9784, 8935, 9764, 8712) then 2
                    else 0 end as ads_campaign,
               count(action) filter (WHERE action = 'cancel_order') OVER (PARTITION BY order_id) as is_canceled
        FROM   user_actions) t1
WHERE  ads_campaign in (1, 2)
   and is_canceled = 0
GROUP BY ads_campaign
ORDER BY cac desc

-- Задание 2




WITH orders_cost as (
    SELECT order_id, sum(price)as order_cost
    FROM
        (SELECT order_id, unnest(product_ids) as product_id
        FROM orders) t1
        LEFT JOIN products using(product_id)
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY order_id
)
                
-- Стоимость первой компании   (SUM(order_cost) - 250000)::decimal / SUM(order_cost) * 100 as cost_first_company
first_company as (
SELECT (SUM(order_cost) - 250000)::decimal / SUM(order_cost) * 100 as cost_first_company
FROM orders_cost LEFT JOIN user_actions using(order_id)
WHERE user_id IN (8804, 9828, 9524, 9667, 9165, 10013, 9625, 8879, 9145, 8657, 8706, 9476, 9813, 
                8940, 9971, 10122, 8732, 9689, 9198, 8896, 8815, 9689, 9075, 9071, 9528, 9896, 
                10135, 9478, 9612, 8638, 10057, 9167, 9450, 9999, 9313, 9720, 9599, 9351, 8638, 
                8752, 9998, 9431, 9660, 9004, 8632, 8896, 8750, 9605, 8867, 9535, 9494, 9762, 
                8990, 9526, 9786, 9654, 9144, 9391, 10016, 8988, 9009, 9061, 9004, 9550, 8707, 
                8788, 8988, 8853, 9836, 8810, 9916, 9660, 9677, 9896, 8933, 8828, 9108, 9180, 
                9897, 9960, 9472, 9818, 9695, 9965, 10023, 8972, 9035, 8869, 9662, 9561, 9740, 
                8723, 9146, 10103, 9963, 10103, 8715, 9167, 9313, 9679, 9251, 10001, 8867, 8707, 
                9945, 9562, 10013, 9020, 9317, 9002, 9838, 9144, 8911, 9505, 9313, 10134, 9197, 
                9398, 9652, 9999, 9210, 8741, 9963, 9422, 9778, 8815, 9512, 9794, 9019, 9287, 9561, 
                9321, 9677, 10122, 8752, 9810, 9871, 9162, 8876, 9414, 10030, 9334, 9175, 9182, 
                9451, 9257, 9321, 9531, 9655, 9845, 8883, 9993, 9804, 10105, 8774, 8631, 9081, 8845, 
                9451, 9019, 8750, 8788, 9625, 9414, 10064, 9633, 9891, 8751, 8643, 9559, 8791, 9518, 
                9968, 9726, 9036, 9085, 9603, 8909, 9454, 9739, 9223, 9420, 8830, 9615, 8859, 9887, 
                9491, 8739, 8770, 9069, 9278, 9831, 9291, 9089, 8976, 9611, 10082, 8673, 9113, 10051)
),
-- Стоимость второй компании     as cost_second_company            -- 
(
SELECT *
FROM orders_cost LEFT JOIN user_actions using(order_id)
WHERE user_id IN (9752, 9510, 8893, 9196, 10038, 9839, 9820, 9064, 9930, 9529, 9267, 9161, 9231, 
                8953, 9863, 8878, 10078, 9370, 8675, 9961, 9007, 9207, 9539, 9335, 8700, 9598, 
                9068, 9082, 8916, 10131, 9704, 9904, 9421, 9083, 9337, 9041, 8955, 10033, 9137, 
                9539, 8855, 9117, 8771, 9226, 8733, 8851, 9749, 10027, 9757, 9788, 8646, 9567, 
                9140, 9719, 10073, 9000, 8971, 9437, 9958, 8683, 9410, 10075, 8923, 9255, 8995, 
                9343, 10059, 9082, 9267, 9929, 8670, 9570, 9281, 8795, 9082, 8814, 8795, 10067, 
                9700, 9432, 9783, 10081, 9591, 8733, 9337, 9808, 9392, 9185, 8882, 8681, 8825, 
                9692, 10048, 8682, 9631, 8942, 9910, 9428, 9500, 9527, 8655, 8890, 9000, 8827, 
                9485, 9013, 9042, 10047, 8798, 9250, 8929, 9161, 9545, 9333, 9230, 9841, 8659, 
                9181, 9880, 9983, 9538, 9483, 9557, 9883, 9901, 9103, 10110, 8827, 9530, 9310, 
                9711, 9383, 9527, 8968, 8973, 9497, 9753, 8980, 8838, 9370, 8682, 8854, 8966, 
                9658, 9939, 8704, 9281, 10113, 8697, 9149, 8870, 9959, 9127, 9203, 9635, 9273, 
                9356, 10069, 9855, 8680, 9912, 8900, 9131, 10058, 9479, 9259, 9368, 9908, 9468, 
                8902, 9292, 8742, 9672, 9564, 8949, 9404, 9183, 8913, 8694, 10092, 8771, 8805, 
                8794, 9179, 9666, 9095, 9935, 9190, 9183, 9631, 9231, 9109, 9123, 8806, 9229, 
                9741, 9303, 9303, 10045, 9744, 8665, 9843, 9634, 8812, 9684, 9616, 8660, 9498, 
                9877, 9727, 9882, 8663, 9755, 8754, 9131, 9273, 9879, 9492, 9920, 9853, 8803, 
                9711, 9885, 9560, 8886, 8644, 9636, 10073, 10106, 9859, 8943, 8849, 8629, 8729, 
                9227, 9711, 9282, 9312, 8630, 9735, 9315, 9077, 8999, 8713, 10079, 9596, 8748, 
                9327, 9790, 8719, 9706, 9289, 9047, 9495, 9558, 8650, 9784, 8935, 9764, 8712)
)