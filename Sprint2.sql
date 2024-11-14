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
INNER JOIN company AS c
ON t.company_id = c.id;


-- desde quants paisos es realitzen compres

SELECT COUNT(DISTINCT country) AS num_purchasing_countries
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id;


-- identificar la companyia amb la mitjana de vendes més gran.

SELECT 
		company_name,
        ROUND(AVG(amount), 2) max_avg_sale
FROM transaction AS t
INNER JOIN company AS c
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
    WHERE country = 'Germany');

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT	company_name,
		country
FROM company
WHERE id IN 
		(SELECT company_id
		 FROM  transaction
		 WHERE amount > (SELECT AVG(amount) 
		 FROM transaction));



-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id, company_name
FROM company c
WHERE NOT EXISTS (
    SELECT company_id
    FROM transaction t
    WHERE t.company_id = c.id);

    
-- NIVEL 2
-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

-- USANDO SUBCONSULTAS
SELECT 
        DATE(timestamp) AS date,
		SUM(amount) AS sales_by_date
FROM transaction 
WHERE declined = 0
GROUP BY date
ORDER BY sales_by_date DESC
LIMIT 5;


-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT  c.country,
		ROUND(AVG(amount),2) AS avg_by_country
FROM transaction AS t
INNER JOIN company AS c
ON t.company_id = c.id
WHERE declined = 0
GROUP BY c.country
ORDER BY avg_by_country DESC;



--  Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- usando joins

SELECT *
FROM transaction t
INNER JOIN company c
ON t.company_id = c.id
WHERE c.country = 
		(SELECT country
		 FROM company
		 WHERE company_name = "Non Institute");

-- subconsulta
SELECT *
FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = (
        SELECT  country
        FROM company
        WHERE company_name = 'Non Institute'
        LIMIT 1)
);





-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT *
FROM company;

SELECT company_name,
	   phone,
       country,
       DATE(timestamp) AS date,
       amount
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20','2022-03-13')
		AND amount BETWEEN 100 AND 200
ORDER BY date;


-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT	company_name,
		company_id,
		COUNT(t.id) AS num_transactions,
        CASE WHEN COUNT(t.id) > 4 THEN 'más de 4' ELSE 'menos de 4' END AS performance
FROM transaction AS t
INNER JOIN company AS c
ON  t.company_id = c.id
GROUP BY company_id
ORDER BY num_transactions DESC;



