SELECT * FROM customer_final;
SELECT * FROM transactions_final;

#1
SELECT 
    tr_f.ID_client,
    AVG(tr_f.Sum_payment) AS average_check,
    SUM(tr_f.Sum_payment) / 12 AS avg_monthly_spending,
	COUNT(tr_f.Id_check) AS total_operations
FROM transactions_final AS tr_f
WHERE tr_f.date_new >= '2015-06-01' AND tr_f.date_new <= '2016-06-01'
GROUP BY tr_f.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(tr_f.date_new, '%Y-%m')) = 12;


#2
SELECT 
   DATE_FORMAT(tr_f.date_new, '%Y-%m') AS 'Месяц',
# Средний чек в этом месяце
    ROUND(AVG(tr_f.Sum_payment), 2) AS 'Средний чек',
# Количество операций в этом месяце
    COUNT(tr_f.Id_check) AS 'Кол-во операций', 
# Количество клиентов в этом месяце
    COUNT(DISTINCT tr_f.ID_client) AS 'Кол-во клиентов',    
# Доля операций месяца от всего года
    ROUND((COUNT(tr_f.Id_check) / SUM(COUNT(tr_f.Id_check)) OVER()) * 100, 2) AS '% операций от года',    
# Доля выручки месяца от всего года
    ROUND((SUM(tr_f.Sum_payment) / SUM(SUM(tr_f.Sum_payment)) OVER()) * 100, 2) AS '% суммы от года',    
# % соотношение клиентов M / F / NA
    ROUND((COUNT(DISTINCT CASE WHEN c.Gender = 'M' THEN tr_f.ID_client END) / COUNT(DISTINCT tr_f.ID_client)) * 100, 2) AS '% клиентов Мужчин',
    ROUND((COUNT(DISTINCT CASE WHEN c.Gender = 'F' THEN tr_f.ID_client END) / COUNT(DISTINCT tr_f.ID_client)) * 100, 2) AS '% клиентов Женщин',
    ROUND((COUNT(DISTINCT CASE WHEN c.Gender NOT IN ('M', 'F') OR c.Gender IS NULL THEN tr_f.ID_client END) / COUNT(DISTINCT tr_f.ID_client)) * 100, 2) AS '% клиентов Без пола',
# Доля затрат M / F / NA от суммы этого месяца
    ROUND((SUM(CASE WHEN c.Gender = 'M' THEN tr_f.Sum_payment ELSE 0 END) / SUM(tr_f.Sum_payment)) * 100, 2) AS '% затрат Мужчин',
    ROUND((SUM(CASE WHEN c.Gender = 'F' THEN tr_f.Sum_payment ELSE 0 END) / SUM(tr_f.Sum_payment)) * 100, 2) AS '% затрат Женщин',
    ROUND((SUM(CASE WHEN c.Gender NOT IN ('M', 'F') OR c.Gender IS NULL THEN tr_f.Sum_payment ELSE 0 END) / SUM(tr_f.Sum_payment)) * 100, 2) AS '% затрат Без пола'
FROM transactions_final AS tr_f
LEFT JOIN customer_final AS c ON tr_f.ID_client = c.Id_client
WHERE tr_f.date_new >= '2015-06-01' AND tr_f.date_new <= '2016-06-01'
GROUP BY DATE_FORMAT(tr_f.date_new, '%Y-%m')
ORDER BY 1;

#3
SELECT 
    # распределяем по группам
    CASE 
        WHEN c.Age IS NULL THEN 'Нет данных'
        WHEN c.Age BETWEEN 0 AND 19 THEN '0-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS 'Возрастная группа',
    
    # Считаем сумму и штуки за весь период
    ROUND(SUM(tr_f.Sum_payment), 2) AS 'Общая сумма затрат',
    COUNT(tr_f.Id_check) AS 'Общее кол-во операций'

FROM transactions_final AS tr_f
LEFT JOIN customer_final AS c ON tr_f.ID_client = c.Id_client
WHERE tr_f.date_new >= '2015-06-01' AND tr_f.date_new <= '2016-06-01'
GROUP BY 1
ORDER BY 1;


