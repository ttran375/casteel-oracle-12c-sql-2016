-- # Lab Exercises Module 3 - Subqueries
-- From: Joan Casteel. 2015. Oracle 12c: SQL, 3rd Edition.
-- Boston: Course Technology.
-- Using the Just Lee Books database from P:\pgignac\comp214\JLDB_Build_8.sql and JLDB_Build_12.sql.
-- Use an sql sub-query statement to answer the following:
-- 1. List the book title and retail price for all books with a retail price 
-- lower than the average retail price of all books sold by JustLee Books.
SELECT
  b.Title,
  b.Retail
FROM
  Books b
WHERE
  b.Retail < (
    SELECT
      AVG(b2.Retail)
    FROM
      Books b2
  );

-- 2. Determine which books cost less than the average cost of other books in 
-- the same category.
SELECT
  b.ISBN,
  b.Title,
  b.Category,
  b.Cost,
  AVG(b2.Cost) AS AvgCategoryCost
FROM
  Books b
  JOIN Books b2 ON b.Category = b2.Category
  AND b.ISBN <> b2.ISBN
GROUP BY
  b.ISBN,
  b.Title,
  b.Category,
  b.Cost
HAVING
  b.Cost < AVG(b2.Cost);

-- 3. Determine which orders were shipped to the same state as order 1014.
SELECT DISTINCT
  o.Order#
FROM
  Orders o
WHERE
  o.ShipState = (
    SELECT
      ShipState
    FROM
      Orders
    WHERE
      Order# = 1014
  )
  AND o.Order# <> 1014;

-- 4. Determine which orders had a higher total amount due than order 1008.
SELECT
  Order# AS OrderID,
  TotalAmountDue
FROM
  (
    SELECT
      o.Order#,
      o.Customer#,
      o.OrderDate,
      o.ShipDate,
      o.ShipStreet,
      o.ShipCity,
      o.ShipState,
      o.ShipZip,
      o.ShipCost,
      SUM(o.ShipCost) OVER (
        PARTITION BY
          o.Order#
      ) AS TotalAmountDue
    FROM
      Orders o
    WHERE
      o.Order# <> 1008
  )
WHERE
  TotalAmountDue > (
    SELECT
      SUM(o.ShipCost) AS TotalAmountDue
    FROM
      Orders o
    WHERE
      o.Order# = 1008
  );

-- 5. Determine which author or authors wrote the books most frequently 
-- purchased by customers of JustLee Books.
SELECT
  ba.ISBN,
  b.Title,
  a.Lname,
  a.Fname
FROM
  BOOKAUTHOR ba
  JOIN AUTHOR a ON ba.AuthorID = a.AuthorID
  JOIN BOOKS b ON ba.ISBN = b.ISBN
  JOIN (
    SELECT
      oi.ISBN,
      COUNT(oi.ISBN) AS PurchaseCount
    FROM
      ORDERITEMS oi
    GROUP BY
      oi.ISBN
    ORDER BY
      PurchaseCount DESC
    FETCH FIRST
      1 ROWS ONLY
  ) tp ON ba.ISBN = tp.ISBN
ORDER BY
  tp.PurchaseCount DESC,
  a.Lname,
  a.Fname;

-- 6. List the title of all books in the same category as books previously 
-- purchased by customer 1007. Don’t include books this customer has already 
-- purchased.
SELECT DISTINCT
  b.Title
FROM
  Books b
  JOIN BookAuthor ba ON b.ISBN = ba.ISBN
  JOIN Author a ON ba.AuthorID = a.AuthorID
WHERE
  b.Category IN (
    SELECT DISTINCT
      b.Category
    FROM
      Customers c
      JOIN Orders o ON c.Customer# = o.Customer#
      JOIN OrderItems oi ON o.Order# = oi.Order#
      JOIN Books b ON oi.ISBN = b.ISBN
    WHERE
      c.Customer# = 1007
  )
  AND b.ISBN NOT IN (
    SELECT
      ISBN
    FROM
      OrderItems
    WHERE
      Order# IN (
        SELECT
          Order#
        FROM
          Orders
        WHERE
          Customer# = 1007
      )
  )
ORDER BY
  b.Title;

-- 7. List the shipping city and state for the order that had the longest 
-- shipping delay.
SELECT
  o.Order#,
  o.ShipCity,
  o.ShipState,
  (o.ShipDate - o.OrderDate) AS ShippingDelay
FROM
  Orders o
WHERE
  o.ShipDate IS NOT NULL
ORDER BY
  ShippingDelay DESC
FETCH FIRST
  1 ROW ONLY;

-- 8. Determine which customers placed orders for the least expensive book (in 
-- terms of regular retail price) carried by JustLee Books.
SELECT
  C.Customer#,
  C.LastName,
  C.FirstName,
  O.Order#,
  B.Title AS BookTitle,
  B.Retail AS RetailPrice
FROM
  Customers C
  JOIN Orders O ON C.Customer# = O.Customer#
  JOIN OrderItems OI ON O.Order# = OI.Order#
  JOIN Books B ON OI.ISBN = B.ISBN
WHERE
  B.Retail = (
    SELECT
      MIN(Retail)
    FROM
      Books
  )
ORDER BY
  B.Retail;

-- 9. Determine the number of different customers who have placed an order for 
-- books written or cowritten by James Austin.
SELECT
  COUNT(DISTINCT c.Customer#) AS NumberOfCustomers
FROM
  Customers c
  JOIN Orders o ON c.Customer# = o.Customer#
  JOIN OrderItems oi ON o.Order# = oi.Order#
  JOIN BookAuthor ba ON oi.ISBN = ba.ISBN
  JOIN Author a ON ba.AuthorID = a.AuthorID
WHERE
  a.Lname = 'AUSTIN'
  AND a.Fname = 'JAMES';

-- 10. Determine which books were published by the publisher of The Wok Way to 
-- Cook.
SELECT
  b.ISBN,
  b.Title,
  b.PubDate,
  b.Retail,
  b.Category
FROM
  Books_2 b
WHERE
  CONTAINS (
    b.ISBN,
    (
      SELECT
        ba.ISBN
      FROM
        BookAuthor ba
      WHERE
        ba.AuthorID = (
          SELECT
            a.AuthorID
          FROM
            Author a
          WHERE
            CONTAINS ('WOK WAY TO COOK')
        )
    )
  );