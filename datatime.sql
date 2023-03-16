-- Из таблицы user_actions получите информацию о всех отменах заказов, которые пользователи совершали в течение августа 2022
-- года по средам с 12:00 до 15:59. Результат отсортируйте по времени отмены заказа — от самых последних отмен к самым первым.
-- Поля в результирующей таблице: user_id, order_id, action, time

SELECT user_id, order_id, action, time
FROM user_actions
WHERE action = 'cancel_order' and date_part('month', time) = 8 and date_part('dow', time) = 3 and
date_part('hour', time) >=12 and date_part('hour', time) <=15 and date_part('minute', time) <=59
ORDER BY time desc



