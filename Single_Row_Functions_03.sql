-- 3. Determine the amount of total profit generated by the book purchased on order 1002. Display the book title and profit. The profit should be formatted to display a dollar sign and two decimal places. Take into account that the customer might not pay the full retail price, and each item ordered can involve multiple copies.
SELECT
    B.Title,
    TO_CHAR(
        SUM(OI.Quantity * (B.Retail - B.Cost)),
        '$9,999.00'
    ) AS Profit
FROM
    Orders O
    JOIN OrderItems OI ON O.Order# = OI.Order#
    JOIN Books B ON OI.ISBN = B.ISBN
WHERE
    O.Order# = 1002
GROUP BY
    B.Title;
