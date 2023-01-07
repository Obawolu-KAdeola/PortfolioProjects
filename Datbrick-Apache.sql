
--Modifying columns in a table to  match schema 

CREATE OR REPLACE TEMPORARY VIEW q1Results AS
 SELECT
  discountId,
  code,
  price * 100 AS price
FROM
  discounts;

SELECT
  *
FROM
  q1Results

--Modify the columns in table discounts2 to match the provided schema.

CREATE OR REPLACE TEMPORARY VIEW q2Results AS
  SELECT
  active,
  cents / 100 AS price
FROM
  discounts2;
  
SELECT
  *
FROM
  q2Results

--Perform a join of two tables purchases and prices.

SELECT
  purchases.transactionId, 
  purchases.itemId, 
  prices.value
FROM 
  purchases
INNER JOIN prices on purchases.itemId = prices.itemId


--Perform an outer join on two tables discounts and products store the results into q2Results view.

CREATE OR REPLACE TEMPORARY VIEW q2Results AS
SELECT discounts.*,
products.itemId,
products.amount
FROM discounts
FULL OUTER JOIN products
ON discounts.itemName = products.itemName;

SELECT
  *
FROM
  q2Results;


--Perform a cross join on two tables stores and articles.

SELECT *
FROM stores
CROSS JOIN articles;


--Extract the year and month from the Timestamp field in the table timetable1 and store records with only the 12th month into q1Results table.

CREATE OR REPLACE TEMPORARY VIEW q1Results AS 
  WITH datesTable AS
    (SELECT
    CAST(Timestamp AS timestamp) AS date FROM timetable1)
  SELECT date, 
  year(date) AS year, 
  month(date) AS month
  FROM datesTable
  WHERE month(date) =12;
  
SELECT * FROM q1Results;


--Extract the year, month and dayofyear from the Timestamp field in the table timetable2 and return records for only the 4th month.

CREATE OR REPLACE TEMPORARY VIEW q2Results AS
  WITH datesTable AS
    (SELECT
    CAST(Timestamp AS timestamp) AS date FROM timetable2)
  SELECT date, 
  year(date) AS year, 
  month(date) AS month,
  dayofyear(Date) AS DayOfYear
  FROM datesTable
  WHERE month(date) = 4;
  
SELECT * FROM q2Results;


--Compute the minimum value from the Amount field for each unique value in the TrueFalse field in the table revenue1.

CREATE OR REPLACE TEMPORARY VIEW q1Results AS
  SELECT count(*) AS count FROM revenue1
  GROUP BY TrueFalse;

SELECT * FROM q1Results;


--Compute the maximum value from the Amount field for each unique value in the TrueFalse field in the table revenue2.

  
CREATE OR REPLACE TEMPORARY VIEW q2results AS
  SELECT TrueFalse, max(Amount) AS MaxAmount 
  FROM revenue2
  GROUP BY TrueFalse;
  
SELECT * FROM q2Results;



--Compute the average of the Amount field for each unique value in the TrueFalse field in the table revenue3.

CREATE OR REPLACE TEMPORARY VIEW q3Results AS
  SELECT TrueFalse, avg(Amount) AS AvgAmount 
  FROM revenue3
  GROUP BY TrueFalse;

SELECT * FROM q3Results;


--Calculate the total Amount for YesNo values of true and false in 2002 and 2003 from the table revenue4.

CREATE OR REPLACE TEMPORARY VIEW q4Results AS
  SELECT * 
  FROM (SELECT Year, YesNo, Amount
        FROM (SELECT year(CAST(UTCTime AS timestamp)) as Year,
                     YesNo,
                     Amount 
              FROM revenue4) 
        WHERE Year > 2001 AND Year <= 2003)
  PIVOT ( round( sum(Amount), 2) AS total FOR Year in (2002, 2003) );
  
  SELECT * FROM q4Results;


--Compute sums of amount grouped by aisle after dropping null values from products table.


CREATE OR REPLACE TEMPORARY VIEW q5Results AS
  SELECT aisle, sum(amount) FROM products 
  WHERE (itemId IS NOT NULL AND aisle IS NOT NULL) 
  GROUP BY aisle;
  
SELECT * FROM q5Results



--Compute averages of income grouped by itemName and month such that the results include averages across all months as well as a subtotal for an individual month from the sales table.

CREATE OR REPLACE TEMPORARY VIEW q6Results AS
  SELECT 
    COALESCE(itemName, "All items") AS itemName,
    COALESCE(month(date), "All months") AS month,
    ROUND(AVG(revenue), 2) as avgRevenue
  FROM sales
  GROUP BY ROLLUP (itemName, month(date))
  ORDER BY itemName, month;

SELECT * FROM q6Results;


--Get a distinct list of authors who have contributed blog posts in the "Company Blog" category.

CREATE OR REPLACE TEMPORARY VIEW results AS
  SELECT 
   DISTINCT (EXPLODE(authors)) AS author,
   categories
  FROM databricksBlog
  WHERE array_contains(categories, "Company Blog");
  
SELECT * FROM results;


--Use the TRANSFORM function and the table finances to calculate interest for all cards issued to each user.

SELECT firstName, lastName, 
TRANSFORM(expenses, card -> ROUND(card.charges * 0.0625, 2)) AS interest 
FROM finances


--Use the table from Question 1, finances, to flag users whose records indicate that they made a late payment.


CREATE OR REPLACE TEMPORARY VIEW q2Results AS
  SELECT firstName, lastName,
  EXISTS(expenses, card -> TO_DATE(card.paymentDue) > TO_DATE(card.lastPayment)) AS lateFee
  FROM finances;

SELECT * FROM q2Results


--Use the REDUCE function to produce a query on the table charges that calculates total charges in dollars and total charges in Japanese Yen.

CREATE OR REPLACE TEMPORARY VIEW q3Results AS
  SELECT firstName, lastName, allCharges, 
  REDUCE (allCharges, CAST(0 AS DOUBLE), (charge, acc) -> charge + acc) AS totalDollars,
  REDUCE (allCharges, CAST(0 AS DOUBLE), (charge, acc) -> charge + acc, acc -> ROUND(acc * 107.26, 2)) AS totalYen
  FROM charges;

SELECT * FROM q3Results

