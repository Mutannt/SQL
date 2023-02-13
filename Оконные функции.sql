-- 1. Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте
-- все товары по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:

-- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
-- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
-- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).

-- Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank
SELECT product_id,
       name,
       price,
       row_number() OVER (ORDER BY price desc) as product_number,
       rank() OVER (ORDER BY price desc) as product_rank,
       dense_rank() OVER (ORDER BY price desc) as product_dense_rank
FROM   products
-- ==================================================================================================================
-- 2. Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке
-- для каждой записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price.
-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара — просто поделите
-- одну колонку на другую. Полученные доли округлите до двух знаков после запятой. Колонку с долями назовите share_of_max.

-- Выведите всю информацию о товарах, включая значения в новых колонках.
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, max_price, share_of_max

-- Пояснение:
-- В этой задаче окном выступает вся таблица. Сортировку внутри окна указывать не нужно.
-- С результатом агрегации по окну можно проводить арифметические и логические операции.
-- Также к нему можно применять и другие функции — например, округление, как в этой задаче.
SELECT product_id, name, price,
max(price) OVER () AS max_price,
ROUND(price / max(price) OVER (), 2) AS share_of_max
FROM products
ORDER BY price DESC, product_id
-- =================================================================================================================================
-- 3. Примените две оконные функции к таблице products — одну с агрегирующей функцией MAX,
-- а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены.
-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. Поместите результат вычислений в две колонки max_price и min_price.

-- Выведите всю информацию о товарах, включая значения в новых колонках.
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.

-- Поля в результирующей таблице: product_id, name, price, max_price, min_price

-- После того как решите задачу, проанализируйте полученный результат и подумайте, почему получились именно такие расчёты.
-- При необходимости вернитесь к первому шагу и ещё раз внимательно ознакомьтесь с тем, как работает рамка окна при указании сортировки.
SELECT product_id, name, price,
max(price) OVER (ORDER BY price DESC) AS max_price,
min(price) OVER (ORDER BY price DESC) AS min_price
FROM products
ORDER BY price DESC, product_id
-- =====================================================================================================================================
-- 4. Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням.
-- При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions).
-- Колонку с днями назовите date, а колонку с числом заказов — orders_count.

-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией SUM
-- для расчёта накопительной суммы числа заказов. Не забудьте для окна задать инструкцию ORDER BY по дате.
-- Колонку с накопительной суммой назовите orders_cum_count. В результате такой операции значение накопительной
-- суммы для последнего дня должно получиться равным общему числу заказов за весь период.

-- Сортировку результирующей таблицы делать не нужно.
-- Поля в результирующей таблице: date, orders_count, orders_cum_count

SELECT date, orders_count,
SUM(orders_count) OVER (ORDER BY date) AS orders_cum_count
FROM(
    SELECT creation_time::DATE as date, count(product_ids) as orders_count
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY creation_time::DATE
) t1

-- 5. Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа. Для этого примените оконную функцию ROW_NUMBER
-- к колонке с временем заказа. Не забудьте указать деление на партиции по пользователям и сортировку внутри партиций. Отменённые заказы
-- не учитывайте. Новую колонку с порядковым номером заказа назовите order_number. Результат отсортируйте сначала по возрастанию id пользователя,
-- затем по возрастанию order_number. Добавьте LIMIT 1000.

-- Поля в результирующей таблице: user_id, order_id, time, order_number

SELECT user_id, order_id, time,
row_number() over (partition by user_id order by time) AS order_number
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
ORDER BY user_id, order_number
limit 1000

-- 6. Дополните запрос из предыдущего задания и с помощью оконной функции для каждого заказа каждого пользователя рассчитайте,
-- сколько времени прошло с момента предыдущего заказа. 
-- Для этого сначала в отдельном столбце с помощью LAG сделайте смещение по столбцу time на одно значение назад.
-- Столбец со смещёнными значениями назовите time_lag. Затем отнимите от каждого значения в колонке time новое значение
-- со смещением (либо можете использовать уже знакомую функцию AGE). Колонку с полученным интервалом назовите time_diff.
-- Менять формат отображения значений не нужно, они должны иметь примерно следующий вид:
-- 3 days, 12:18:22

-- По-прежнему не учитывайте отменённые заказы. Также оставьте в запросе порядковый номер каждого заказа, рассчитанный на прошлом шаге.
-- Результат отсортируйте сначала по возрастанию id пользователя, затем по возрастанию порядкового номера заказа. Добавьте LIMIT 1000.
-- Поля в результирующей таблице: user_id, order_id, time, order_number, time_lag, time_diff

-- Пояснение:
-- Не забывайте про деление на партиции и сортировку внутри окна.
-- Также обратите внимание, что в результате смещения для первых заказов каждого пользователя в колонке time_lag получились
-- пропущенные значения. Для таких записей функция не нашла предыдущих значений и вернула NULL. То же самое произошло в записях
-- пользователей с одним заказом — внутри партиции с одной записью просто некуда сдвигаться.
-- Образовавшиеся пропущенные значения убирать из результата не нужно.

SELECT user_id, order_id, time, 
row_number() over (partition by user_id order by time) AS order_number,
lag(time) over (partition by user_id order by time) AS time_lag,
time - lag(time) over (partition by user_id order by time) AS time_diff
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
ORDER BY user_id, order_number
limit 1000

-- 7. На основе запроса из предыдущего задания для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами.
-- Не считайте этот показатель для тех пользователей, которые за всё время оформили лишь один заказ. Полученное среднее значение (интервал)
-- переведите в часы, а затем округлите до целого числа. Колонку со средним значением часов назовите hours_between_orders. Результат
-- отсортируйте по возрастанию id пользователя.

-- Добавьте LIMIT 1000.
-- Поля в результирующей таблице: user_id, hours_between_orders

-- Пояснение:
-- Чтобы перевести среднее значение интервала в часы, необходимо извлечь из него количество секунд, а затем поделить это значение на количество
-- секунд в одном часе. Для извлечения количества секунд из интервала можно воспользоваться следующей конструкцией:
-- SELECT EXTRACT(epoch FROM INTERVAL '3 days, 1:21:32')

-- Результат:
-- 264092	

-- Функция EXTRACT работает аналогично функции DATE_PART, которую мы рассматривали на прошлых уроках, но имеет несколько иной синтаксис.
-- Попробуйте воспользоваться функцией EXTRACT в этой задаче.

-- В результате всех расчётов для каждого пользователя у вас должно получиться целое число часов, которое в среднем проходит между заказами.
-- Подумайте, как убрать из данных пользователей с одним заказом.

-- Повторять все предыдущие оконные функции из предыдущего запроса не обязательно — оставьте только самое необходимое.

WITH subquery1 AS (
    SELECT user_id, order_id, time, 
    row_number() over (partition by user_id order by time) AS order_number,
    lag(time) over (partition by user_id order by time) AS time_lag,
    time - lag(time) over (partition by user_id order by time) AS time_diff,
    count(*) over (partition by user_id) AS count_order
    FROM user_actions
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
)

SELECT user_id, ROUND(EXTRACT(epoch FROM AVG_time_diff) / 3600) AS hours_between_orders
FROM (
    SELECT user_id, AVG(time_diff) AS AVG_time_diff
    FROM subquery1
    WHERE count_order != 1
    GROUP BY user_id
) t1
ORDER BY user_id
limit 1000

--  2 способ
SELECT user_id, round(extract(epoch FROM   avg(time_diff))/3600) as hours_between_orders
FROM   (SELECT user_id,
               order_id,
               time,
               time - lag(time, 1) OVER (PARTITION BY user_id
                                         ORDER BY time) as time_diff
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
WHERE  time_diff is not null
GROUP BY user_id
ORDER BY user_id limit 1000

-- 8. Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. Вы уже делали это в одной из предыдущих задач.
-- При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). Колонку с числом заказов назовите
-- orders_count.

-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией AVG для расчёта скользящего
-- среднего числа заказов. Скользящее среднее для каждой записи считайте по трём предыдущим дням. Подумайте, как правильно задать границы рамки,
-- чтобы получить корректные расчёты.

-- Полученные значения скользящего среднего округлите до двух знаков после запятой. Колонку с рассчитанным показателем назовите moving_avg.
-- Сортировку результирующей таблицы делать не нужно.
-- Поля в результирующей таблице: date, orders_count, moving_avg

-- Пояснение:
-- При решении задачи можете пробовать разные границы рамки и проверять себя вручную. Важно для каждой даты учесть в расчётах именно 3 предыдущих дня.
-- Заполнять пропущенные значения в этой задаче не нужно. Подумайте, почему они могли появиться.

SELECT date, orders_count,
ROUND(avg(orders_count) OVER (order by date RANGE BETWEEN '3 days' PRECEDING AND '1 days' PRECEDING), 2) AS moving_avg
FROM
(SELECT creation_time::date as date, count(product_ids) as orders_count
FROM   orders
WHERE  order_id not in (SELECT order_id FROM   user_actions WHERE  action = 'cancel_order')
GROUP BY creation_time::date
ORDER BY date) t1

-- 9. Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре заказов больше, чем в среднем все курьеры.
-- Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов. Затем в отдельном
-- столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры. После этого сравните число
-- заказов, доставленных каждым курьером, со средним значением в новом столбце. Если курьер доставил больше заказов, чем в среднем все
-- курьеры, то в отдельном столбце с помощью CASE укажите число 1, в противном случае укажите 0.

-- Колонку с результатом сравнения назовите is_above_avg, колонку с числом доставленных заказов каждым курьером — delivered_orders,
-- а колонку со средним значением — avg_delivered_orders. При расчёте среднего значения округлите его до двух знаков после запятой.
-- Результат отсортируйте по возрастанию id курьера.

-- Поля в результирующей таблице: courier_id, delivered_orders, avg_delivered_orders, is_above_avg

-- Пояснение:
-- Таблицу с курьерами и числом доставленных заказов сформируйте на основе таблицы courier_actions и перед применением оконных функций
-- поместите её в подзапрос.

-- С этой задачей можно справиться и без конструкции CASE, если сконвертировать результат логической операции (TRUE или FALSE) в тип
-- данных INT. Можете попробовать решить задачу разными способами.

SELECT courier_id, delivered_orders,
ROUND(AVG(delivered_orders) OVER (), 2) AS avg_delivered_orders,
CASE
    WHEN delivered_orders > AVG(delivered_orders) OVER () THEN 1
    ELSE 0
END AS is_above_avg
FROM
    (SELECT courier_id, count(order_id) AS delivered_orders
    FROM courier_actions
    WHERE action = 'deliver_order' and date_part('month', time) = 9
    GROUP BY courier_id) t1
ORDER BY courier_id

-- 10. Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте
-- среднюю цену всех товаров. Колонку с этим значением назовите avg_price. Затем с помощью оконной функции и оператора FILTER в отдельной
-- колонке рассчитайте среднюю цену товаров без учёта самого дорогого. Колонку с этим средним значением назовите avg_price_filtered.
-- Полученные средние значения в колонках avg_price и avg_price_filtered округлите до двух знаков после запятой.

-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара,
-- затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, avg_price, avg_price_filtered

-- Пояснение:
-- В этой задаче окном снова выступает вся таблица. Сортировку внутри окна указывать не нужно.

SELECT product_id, name, price,
ROUND(AVG(price) OVER (), 2) AS avg_price,
ROUND(AVG(price) FILTER (WHERE product_id != (SELECT product_id FROM products order by price desc limit 1)) OVER (), 2) AS avg_price_filtered
FROM products
ORDER BY price DESC, product_id

-- *11. Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте, сколько заказов сделал
-- и сколько отменил каждый пользователь на момент совершения нового действия.

-- Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — числа оформленных и числа
-- отменённых заказов. Если пользователь оформляет заказ, то число оформленных им заказов увеличивайте на 1, если отменяет
-- — увеличивайте на 1 количество отмен.

-- Колонки с накопительными суммами числа оформленных и отменённых заказов назовите соответственно created_orders и canceled_orders.
-- На основе этих двух колонок для каждой записи пользователя посчитайте показатель cancel_rate, т.е. долю отменённых заказов в общем
-- количестве оформленных заказов. Значения показателя округлите до двух знаков после запятой. Колонку с ним назовите cancel_rate.

-- В результате у вас должны получиться три новые колонки с динамическими показателями, которые изменяются во времени с каждым новым
-- действием пользователя.

-- В результирующей таблице отразите все колонки из исходной таблицы вместе с новыми колонками. Отсортируйте результат по колонкам
-- user_id, order_id, action, time — по возрастанию значений в каждой. Добавьте LIMIT 1000.

-- Поля в результирующей таблице:
-- user_id, order_id, action, time, created_orders, canceled_orders, cancel_rate

-- Пояснение:
-- Подумайте, как правильно задать окна и какие фильтры в них нужно указать.
-- Не забудьте изменить тип данных при делении двух целочисленных значений.

SELECT user_id, order_id, action, time, created_orders, canceled_orders,
ROUND(canceled_orders::decimal / created_orders, 2) AS cancel_rate
FROM
(SELECT user_id, order_id, action, time,
COUNT(order_id) FILTER (WHERE action = 'create_order') OVER (PARTITION BY user_id ORDER BY time) AS created_orders,
COUNT(order_id) FILTER (WHERE action = 'cancel_order') OVER (PARTITION BY user_id ORDER BY time) AS canceled_orders
FROM user_actions) t1
ORDER BY user_id, order_id, action, time
LIMIT 1000

-- 12. Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов. Выведите id курьеров,
-- количество доставленных заказов и порядковый номер курьера в соответствии с числом доставленных заказов.

-- У курьера, доставившего наибольшее число заказов, порядковый номер должен быть равен 1, а у курьера с наименьшим числом заказов —
-- числу, равному десяти процентам от общего количества курьеров в таблице courier_actions.

-- При расчёте номера последнего курьера округляйте значение до целого числа.

-- Колонки с количеством доставленных заказов и порядковым номером назовите соответственно orders_count и courier_rank.
-- Результат отсортируйте по возрастанию порядкового номера курьера.
-- Поля в результирующей таблице: courier_id, orders_count, courier_rank 

-- Пояснение:
-- Если у двух курьеров оказалось одинаковое число доставленных заказов, более высокий ранг мы присвоим курьеру с меньшим id.
-- Например, если у курьеров с id 10 и 80 оказалось максимальное число заказов, то первый ранг мы присвоим курьеру с id 10.

WITH courier_count AS (
    SELECT count(distinct courier_id)
    FROM   courier_actions
)

SELECT courier_id, orders_count, courier_rank
FROM
    (SELECT courier_id,
    COUNT(order_id) AS orders_count,
    row_number() OVER (order by COUNT(order_id) desc, courier_id) AS courier_rank
    FROM courier_actions
    WHERE action = 'deliver_order'
    GROUP BY courier_id
    ORDER BY courier_rank) t1
WHERE  courier_rank <= round((SELECT * FROM   courier_count)*0.1)

-- 13. С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей компании 10 и более дней.
-- Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.

-- Будем считать, что наш сервис предлагает самые выгодные условия труда и поэтому за весь анализируемый период ни один курьер
-- не уволился из компании. Возможные перерывы между сменами не учитывайте — для нас важна только разница во времени между первым
-- действием курьера и текущей отметкой времени. Текущей отметкой времени, относительно которой необходимо рассчитывать продолжительность
-- работы курьера, считайте время последнего действия в таблице courier_actions. Учитывайте только целые дни, прошедшие с первого выхода
-- курьера на работу (часы и минуты не учитывайте).

-- В результат включите три колонки: id курьера, продолжительность работы в днях и число доставленных заказов. Две новые колонки назовите
-- соответственно days_employed и delivered_orders. Результат отсортируйте сначала по убыванию количества отработанных дней, затем
-- по возрастанию id курьера.
-- Поля в результирующей таблице: courier_id, days_employed, delivered_orders

-- Пояснение: 
-- Для решения задачи помимо оконной функции вам могут пригодиться функция DATE_PART и оператор FILTER.
-- Число дней, которые отработал курьер, — это количество дней, прошедших с первого принятого заказа до времени последней записи
-- в таблице courier_actions.

-- Можно другим способом
WITH subquery1 AS (
SELECT *
FROM
(SELECT courier_id, order_id,
    date_part('day', MIN(time) OVER (PARTITION BY courier_id)) AS min,
    date_part('day', MAX(time) OVER()) AS max,
    date_part('day', MAX(time) OVER() - MIN(time) OVER (PARTITION BY courier_id)) as days_employed
FROM courier_actions
WHERE action = 'deliver_order') t1
WHERE days_employed >= 10
),
subq_delivered_orders AS (
    SELECT courier_id, count(order_id) AS delivered_orders
    FROM subquery1
    GROUP BY courier_id
),
subquery3 AS (
    SELECT DISTINCT courier_id, min, max, days_employed
    FROM subquery1
)

SELECT  courier_id, delivered_orders, days_employed
FROM
    subq_delivered_orders
    LEFT JOIN subquery3 using(courier_id)
ORDER BY days_employed desc, courier_id

-- 14. На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа, ежедневную выручку сервиса
-- и долю стоимости каждого заказа в ежедневной выручке, выраженную в процентах. В результат включите следующие колонки:
-- id заказа, время создания заказа, стоимость заказа, выручку за день, в который был совершён заказ, а также долю стоимости
-- заказа в выручке за день, выраженную в процентах.

-- При расчёте долей округляйте их до трёх знаков после запятой.

-- Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени), потом по убыванию доли заказа
-- в выручке за день, затем по возрастанию id заказа.

-- При проведении расчётов отменённые заказы не учитывайте.
-- Поля в результирующей таблице:
-- order_id, creation_time, order_price, daily_revenue, percentage_of_daily_revenue

WITH subquery1 AS (
SELECT DISTINCT order_id, creation_time, creation_time_date,
sum(price) OVER(PARTITION BY order_id) AS order_price,
sum(price) OVER(PARTITION BY creation_time_date) AS daily_revenue,
ROUND(sum(price) OVER(PARTITION BY order_id) / sum(price) OVER(PARTITION BY creation_time_date)* 100, 3) AS percentage_of_daily_revenue
FROM
    (SELECT order_id, creation_time, creation_time::date AS creation_time_date, unnest(product_ids) AS product_id
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
ORDER BY creation_time_date DESC, percentage_of_daily_revenue DESC, order_id)
    

SELECT order_id, creation_time, order_price, daily_revenue, percentage_of_daily_revenue
FROM subquery1

-- 15. На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите её в колонке daily_revenue.
-- Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. Прирост выручки отразите как в абсолютных
-- значениях, так и в % относительно предыдущего дня. Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с
-- относительным — revenue_growth_percentage.

-- Для самого первого дня укажите прирост равным 0 в обеих колонках. При проведении расчётов отменённые заказы не учитывайте.
-- Результат отсортируйте по колонке с датами по возрастанию.

-- Метрики daily_revenue, revenue_growth_abs, revenue_growth_percentage округлите до одного знака при помощи ROUND().
-- Поля в результирующей таблице: date, daily_revenue, revenue_growth_abs, revenue_growth_percentage

WITH subquery1 AS (
SELECT DISTINCT date, SUM(price) AS daily_revenue
FROM
    (SELECT order_id, creation_time, creation_time::date AS date, unnest(product_ids) AS product_id
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY date)

SELECT date, daily_revenue,
COALESCE(daily_revenue - lag(daily_revenue) over (order by date), 0) AS revenue_growth_abs,
COALESCE(ROUND((daily_revenue - lag(daily_revenue) over (order by date))*100::decimal /  lag(daily_revenue) over (order by date), 1), 0) AS revenue_growth_percentage
FROM subquery1
ORDER BY date

-- **16. С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, оформленных в нашем сервисе.
-- В качестве результата выведите одно число. Колонку с ним назовите median_price. Отменённые заказы не учитывайте.

-- Поле в результирующей таблице: median_price

-- Пояснение:
-- Запрос должен учитывать два возможных сценария: для чётного и нечётного числа заказов. Встроенные функции для расчёта
-- квантилей применять нельзя.

WITH subquery1 AS (
    SELECT sum, ROW_NUMBER() OVER()
    FROM
    (SELECT order_id, sum(price)
    FROM
        (SELECT order_id, unnest(product_ids) AS product_id
        FROM orders
        WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
        LEFT JOIN products using(product_id)
    GROUP BY order_id
    ORDER BY sum) t2)

SELECT distinct
CASE
    WHEN (SELECT count(*) FROM subquery1)::decimal % 2 = 0 THEN (SELECT avg(sum) FROM subquery1 WHERE row_number = (SELECT avg(row_number) FROM subquery1) - 0.5 or row_number =   (SELECT avg(row_number) FROM subquery1) + 0.5)
    ELSE (SELECT sum FROM subquery1 WHERE row_number = (SELECT avg(row_number) FROM subquery1))
END median_price
FROM subquery1

-- 2 Вариант.
WITH main_table AS (
SELECT
    order_price,
    ROW_NUMBER() OVER ( ORDER BY order_price) AS row_number,
    COUNT(*) OVER() AS total_rows
FROM
    (SELECT SUM(price) AS order_price FROM (SELECT 
                                    order_id,
                                    product_ids,
                                    UNNEST(product_ids) AS product_id
                                    FROM orders
                                    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                                    ) t3
                                    LEFT JOIN products USING(product_id)
GROUP BY order_id) t1
)

SELECT
  AVG(order_price) AS median_price
FROM main_table
WHERE row_number BETWEEN total_rows / 2.0 AND total_rows / 2.0 + 1

-- 3 Вариант. Функция для расчёта квантилей
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sum) AS median_price
FROM
(SELECT order_id, sum(price)
FROM
    (SELECT order_id, unnest(product_ids) AS product_id
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
    LEFT JOIN products using(product_id)
GROUP BY order_id
ORDER BY sum) t2