-- Nivel 1
-- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    

-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

-- llistat de paisos que fan compres.

SELECT DISTINCT country
FROM transaction AS t
LEFT JOIN company AS c
ON t.company_id = c.id;


-- desde quants paisos es realitzen compres

SELECT COUNT(DISTINCT country) AS num_purchasing_countries
FROM transaction AS t
LEFT JOIN company AS c
ON t.company_id = c.id;


-- identificar la companyia amb la mitjana de vendes més gran.

SELECT 
		company_name,
        ROUND(AVG(amount), 2) max_avg_sale
FROM company AS c
LEFT JOIN transaction AS t
ON c.id = t.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY max_avg_sale DESC
LIMIT 1;


-- Exercici 3 Utilitzant només subconsultes (sense utilitzar JOIN):


-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN
	(SELECT id
    FROM company
    WHERE country = 'Germany')
AND declined = 0;

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT *
FROM company;

SELECT 	(SELECT company_name
		 FROM company
         WHERE id = transaction.company_id) AS company_name,
		amount
FROM transaction
WHERE amount >(
	SELECT AVG(amount)
    FROM transaction)
AND declined = 0
ORDER BY amount DESC;


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id,	
		(SELECT company_name
		 FROM company
         ) AS company_name
FROM company
WHERE id NOT IN
		(SELECT company_id
        FROM transaction);


    
-- NIVEL 2
-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
-- USANDO JOINS

SELECT 
        DATE_FORMAT(t.timestamp, '%Y-%m-%d') AS date,
        SUM(t.amount) AS sales_by_date
       
FROM transaction t
JOIN company c 
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY DATE_FORMAT(t.timestamp, '%Y-%m-%d')
ORDER BY sales_by_date DESC
LIMIT 5;
 
-- USANDO SUBCONSULTAS
SELECT 
        DATE_FORMAT(timestamp, '%Y-%m-%d') AS date,
		SUM(amount) AS sales_by_date
FROM transaction 
WHERE declined = 0
GROUP BY DATE_FORMAT(timestamp, '%Y-%m-%d')
ORDER BY sales_by_date DESC
LIMIT 5;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

-- USANDO JOINS
SELECT  c.country,
		ROUND(AVG(amount),2) AS avg_by_country
FROM transaction AS t
LEFT JOIN company AS c
ON t.company_id = c.id
WHERE declined = 0
GROUP BY c.country
ORDER BY avg_by_country DESC;

-- USANDO SUBCONSULTAS

SELECT country,
		(SELECT ROUND(AVG(amount),2) AS average
         FROM transaction AS t
         WHERE declined = 0 
         AND company_id  IN
				(SELECT id
                 FROM company
                 WHERE country = c.country)
         ) AS avg_by_country
FROM company AS c
GROUP BY country
ORDER BY avg_by_country DESC;


--  Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
SELECT *
FROM company
WHERE company_name = 'Non Institute';

-- usando joins

SELECT 	
		t.*
FROM transaction  t
LEFT JOIN company c
ON t.company_id = c.id
WHERE country = 'United Kingdom'
	AND c.id != 'b-2618'
	AND declined = 0;


-- subconsulta
SELECT *
FROM transaction
WHERE company_id IN
	(SELECT id
FROM company
WHERE country = 'United Kingdom'
		AND id != 'b-2618'
        AND declined = 0);


-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT *
FROM company;

SELECT company_name,
	   phone,
       country,
       DATE_FORMAT(timestamp, '%Y-%m-%d') AS date,
       amount
FROM company AS c
LEFT JOIN transaction AS t
ON c.id = t.company_id
WHERE DATE_FORMAT(timestamp, '%Y-%m-%d') IN ('2021-04-29', '2021-07-20','2022-03-13')
		AND amount BETWEEN 100 AND 200
ORDER BY date;


-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT company_id,
		COUNT(id) AS num_transactions,
        CASE WHEN COUNT(id) > 4 THEN 'más de 4' ELSE 'menos de 4' END AS performance
FROM transaction
GROUP BY company_id
ORDER BY num_transactions DESC;
