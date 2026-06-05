/*
Create Database telecomanalyticsDB
*/

CREATE DATABASE TelecomAnalyticsDB
GO

USE TelecomAnalyticsDB
GO


/*
Create Tables and Inserting Data into the Tables for the Database
*/

--1. Customers Table-----------------------------

--Table creation-----------------------

CREATE TABLE customers(
		customer_id INT PRIMARY KEY,
		customer_type NVARCHAR(50),
		age INT,
		city NVARCHAR(50),
		signup_date DATE,
		year NVARCHAR(20),
		month NVARCHAR(20)
		);

--Data Insertion-----------------------

BULK INSERT customers
FROM 'C:\Users\91768\Documents\FortuneCloud\Assignments\Capstone Project\SQL\customers.csv'
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
	);

SELECT * FROM customers;


--2. Network Usage Table-------------------------

--Table Creation-----------------------

CREATE TABLE network_usage(
		usage_id INT PRIMARY KEY,
		customer_id INT,
		usage_date DATE,
		year NVARCHAR(20),
		month NVARCHAR(20),
		data_used_gb FLOAT,
		call_time INT,
		network_type NVARCHAR(10),
		high_usage_customer NVARCHAR(20)
		FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id)
		);

--Data Insertion-----------------------

BULK INSERT network_usage
FROM 'C:\Users\91768\Documents\FortuneCloud\Assignments\Capstone Project\SQL\network usage.csv'
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
	);

SELECT * FROM network_usage;

--3. Network Issue Table-------------------------

--Table Creation-----------------------

CREATE TABLE network_issue(
		issued_id INT PRIMARY KEY,
		customer_id INT,
		issued_date DATE,
		year NVARCHAR(20),
		month NVARCHAR(20),
		issue_tyoe NVARCHAR(20),
		resolution_time_hrs INT,
		resolved NVARCHAR(20),
		FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id)
		);

--Data Insertion-----------------------

BULK INSERT network_issue
FROM 'C:\Users\91768\Documents\FortuneCloud\Assignments\Capstone Project\SQL\network issues.csv'
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
	);


--4. Billing Table-------------------------------

--Table Creation-----------------------

CREATE TABLE billing(
		bill_id INT PRIMARY KEY,
		customer_id INT,
		bill_month DATE,
		year NVARCHAR(20),
		month NVARCHAR(20),
		bill_amount	INT,
		payment_status NVARCHAR(20),
		FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id)
		);

--Data Insertion-----------------------

BULK INSERT billing
FROM 'C:\Users\91768\Documents\FortuneCloud\Assignments\Capstone Project\SQL\billing.csv'
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
	);


/*
SQL Tasks
*/

/*
1.Write Joins across all tables
*/

SELECT *
FROM customers C
JOIN network_usage NU
ON C.customer_id = NU.customer_id
JOIN network_issue NI
ON C.customer_id = NI.customer_id
JOIN billing B
ON C.customer_id = B.customer_id;


/*
2. Complaint complaint rate per customer
Complaint Rate = Total Complaints/Total Usage Records
*/

SELECT 
	NU.customer_id,
	CAST(COUNT(DISTINCT NI.issued_id) * 1.0/ 
	COUNT(DISTINCT NU.usage_id) AS DECIMAL(10,2))AS Complaint_Rate
FROM network_usage NU
LEFT JOIN network_issue NI
ON NU.customer_id = NI.customer_id
GROUP BY NU.customer_id
ORDER BY NU.customer_id;


/*
Windows Functions for Monthly Trend Analysis
*/

--1. Monthly Complaints--------------------------

SELECT 
	FORMAT(issued_date, 'yyyy-MM') AS Complaint_month,
	COUNT(issued_id) AS monthly_complaints
FROM network_issue
GROUP BY FORMAT(issued_date, 'yyyy-MM');

-------------------

SELECT
	year,
	month,
	COUNT(issued_id) AS monthly_complaints
FROM network_issue
GROUP BY year, month
ORDER BY year;


--2. Running Total Complaints--------------------

WITH montly_data AS(
	SELECT
		DATEFROMPARTS(YEAR(issued_date), MONTH(issued_date), 1) AS complaint_month,
		COUNT(issued_id) AS monthly_complaints
	FROM network_issue
	GROUP BY YEAR(issued_date), MONTH(issued_date)
	)
SELECT
	complaint_month,
	monthly_complaints,
	SUM(monthly_complaints) OVER (ORDER BY complaint_month) AS running_total_complaints
FROM montly_data;


--3. Montly Complaint Trend per City or Month over Month Trend-----------------

SELECT 
	C.city,
	FORMAT(NI.issued_date, 'yyyy-MM') AS complaint_month,
	COUNT(NI.issued_id) AS montly_city_complaints,
	COUNT(issued_id) - 
		LAG(COUNT(issued_id)) OVER (PARTITION BY C.city ORDER BY FORMAT(NI.issued_date, 'yyyy-MM')) AS month_difference
FROM network_issue NI
JOIN customers C
ON NI.customer_id = C.customer_id
GROUP BY C.city, FORMAT(NI.issued_date, 'yyyy-MM');


--Creating a view for total complaints and avg_resolution_time-------

CREATE VIEW VW_customer_complaint_analysis
AS
SELECT
	C.customer_id,
	C.city,
	COUNT(NI.issued_id) AS total_complaints,
	AVG(resolution_time_hrs) AS avg_resolution_time_hrs
FROM customers C
LEFT JOIN network_issue NI
ON C.customer_id = NI.customer_id
GROUP BY C.customer_id, C.city;

SELECT * FROM VW_customer_complaint_analysis;


/*
Business Questions to Answer
*/

--1. Which Cities require urgent network improvements----------------

SELECT 
	C.city,
	COUNT(NI.issued_id) AS total_issues,
	AVG(NI.resolution_time_hrs) AS avg_resolution_time
FROM customers C
JOIN network_issue NI
ON C.customer_id = NI.customer_id
GROUP BY C.city
ORDER BY total_issues DESC;


--2. Does poor network Quality effect Payments and Churn-------------

SELECT
	C.customer_id,
	COUNT(NI.issued_id) AS complaints,
	COUNT(CASE WHEN B.payment_status = 'Delayed' THEN 1 END) AS payments_delayed
FROM customers C
LEFT JOIN network_issue NI
ON C.customer_id = NI.customer_id
LEFT JOIN billing B
ON C.customer_id = B.customer_id
GROUP BY C.customer_id
ORDER BY complaints DESC;


--3. Are 5G users experiencing fewer issues--------------------------

SELECT
	NU.network_type,
	COUNT(NI.issued_id) AS total_issues
FROM network_usage NU
LEFT JOIN network_issue NI
ON NU.customer_id = NI.customer_id
GROUP BY NU.network_type;