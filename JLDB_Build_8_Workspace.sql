-- 1. List the book title and retail price for all books with a retail price lower than the average retail price of all books sold by JustLee Books.
SELECT
  title,
  retail_price
FROM
  books
WHERE
  retail_price < (
    SELECT
      AVG(retail_price)
    FROM
      books
    WHERE
      seller = 'JustLee Books'
  );

-- 1. Determine which books cost less than the average cost of other books in the same category.
-- 1. Determine which orders were shipped to the same state as order 1014.
-- 1. Determine which orders had a higher total amount due than order 1008.
-- 1. Determine which author or authors wrote the books most frequently purchased by customers of JustLee Books.
-- 1. List the title of all books in the same category as books previously purchased by customer 1007. Don’t include books this customer has already purchased.
-- 1. List the shipping city and state for the order that had the longest shipping delay.
-- 1. Determine which customers placed orders for the least expensive book (in terms of regular retail price) carried by JustLee Books.
-- 1. Determine the number of different customers who have placed an order for books written or cowritten by James Austin. 
-- 1. Determine which books were published by the publisher of The Wok Way to Cook.