
SELECT *  FROM orders_data

select * from customer_data

-- Q1-Total Revenue (order value)
SELECT sum(ORDER_TOTAL)AS Total_Revenue FROM orders_data

---Q2-Total Revenue (order value) by top 25 Customers

SELECT SUM(REV_) AS TOTAL_REV
FROM (
SELECT TOP 25 SUM(A.ORDER_TOTAL) AS REV_,A.CUSTOMER_KEY FROM ORDERS_DATA AS A
LEFT JOIN CUSTOMER_DATA AS B
ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
GROUP BY A.CUSTOMER_KEY
ORDER BY SUM(A.ORDER_TOTAL) DESC
) AS A

--Q3.Total number of orders 
SELECT count(order_number)as Total_order FROM orders_data

--Q4.Total orders by top 10 customers 
SELECT SUM(ORDER_CNT)as Total_order
FROM 
(
SELECT  top 10 b.customer_key,count(*)as order_cnt FROM ORDERS_DATA AS A
inner join CUSTOMER_DATA AS B
ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
GROUP BY b.customer_key
ORDER BY COUNT(*) DESC
) AS A



--Q6.Number of customers ordered once
SELECT COUNT(CUSTOMER_KEY) AS CNT_ FROM
(
SELECT CUSTOMER_KEY FROM orders_data
GROUP BY CUSTOMER_KEY
HAVING COUNT(ORDER_NUMBER)=1
) AS A

--Q7. Number of customers ordered multiple times 
SELECT DISTINCT COUNT(*) AS CUST_CNT FROM
(
SELECT CUSTOMER_KEY FROM orders_data
GROUP BY CUSTOMER_KEY
HAVING  COUNT(ORDER_NUMBER)>1
) AS A

--Q8.Number of customers referred to other customers 
SELECT COUNT(*) AS CNT_ FROM 
(SELECT CUSTOMER_ID FROM customer_data
WHERE Referred_Other_customers>=1
) AS A

--Q9.Which Month have maximum Revenue? 
SELECT TOP 1 SUM(ORDER_TOTAL)AS REV_,MONTH(ORDER_DATE)AS MONTH_ FROM orders_data
GROUP BY MONTH(ORDER_DATE)
ORDER BY SUM(ORDER_TOTAL) DESC

--Q10.Number of customers are inactive (that haven't ordered in the last 60 days)  

WITH CUSTOMER_LAST_ORDER AS (

SELECT C.CUSTOMER_KEY, max(O.ORDER_DATE) AS Last_order_date
FROM customer_data AS C 
INNER JOIN orders_data AS O
ON C.CUSTOMER_KEY=O.CUSTOMER_KEY
GROUP BY C.CUSTOMER_KEY),
LATEST_ORDER_DATE AS (
SELECT MAX(ORDER_DATE) AS MAX_ORDER_DATE
FROM orders_data
)
SELECT COUNT(*) AS INACTIVE_CUST FROM CUSTOMER_LAST_ORDER as clo, LATEST_ORDER_DATE as ldo
WHERE clo.Last_order_date IS NULL OR CLO.Last_order_date < DATEADD(DAY, -60, ldo.MAX_ORDER_DATE)



--Q11. Growth Rate  (%) in Orders (from Nov’15 to July’16)
WITH OrderCounts AS (
    SELECT 
        COUNT(CASE WHEN ORDER_DATE BETWEEN '2015-11-01' AND '2015-11-30' THEN 1 END) AS Nov_Orders,
        COUNT(CASE WHEN ORDER_DATE BETWEEN '2016-07-01' AND '2016-07-31' THEN 1 END) AS Jul_Orders
    FROM orders_data
)
SELECT 
    ((Jul_Orders - Nov_Orders) * 100.0 / Nov_Orders) AS GROWTH_RATE_PERCENTAGE
FROM OrderCounts

--Q12. Growth Rate (%) in Revenue (from Nov'15 to July'16) 
WITH OrderCounts AS (
    SELECT 
        COUNT(CASE WHEN ORDER_DATE BETWEEN '2015-11-01' AND '2015-11-30' THEN ORDER_TOTAL ELSE 0 END) AS Nov_Revenue,
        COUNT(CASE WHEN ORDER_DATE BETWEEN '2016-07-01' AND '2016-07-31' THEN ORDER_TOTAL ELSE 0 END) AS Jul_Revenue
    FROM orders_data
)
SELECT 
    ((Jul_Revenue - Nov_Revenue) * 100.0 / Nov_Revenue) AS GROWTH_RATE_PERCENTAGE
FROM OrderCounts

--13-What is the percentage of Male customers exists?
SELECT 100*
SUM(case
when gender='M'
THEN 1
ELSE 0
END )/COUNT(*)
FROM customer_data

--14-Which location have maximum customers?
SELECT top 1 count(customer_id) as cnt_,location FROM customer_data
group by location
order by count(customer_id) desc

--Q15. How many orders are returned? (Returns can be found if the order total value is negative value)
select count(order_number) as order_returned from orders_data
where order_total<0

--Q16. Which Acquisition channel is more efficient in terms of customer acquisition?
select top 1 count(customer_id) as cnt_,acquired_channel from customer_data
group by acquired_channel
order by count(customer_id) desc

SELECT * FROM orders_data
--Q17. Which location having more orders with discount amount? 
 select TOP 1 B.LOCATION,COUNT(A.DISCOUNT) AS DISC_ from orders_data as A
 LEFT JOIN customer_data AS B
 ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
 WHERE DISCOUNT>0
 GROUP BY B.LOCATION
 ORDER BY COUNT(A.DISCOUNT) DESC

 --Q18. Which location having maximum orders delivered in delay? 
 select Top 1 count(A.delivery_status) as Delay_orderno,(B.Location) from orders_data as A
 left join customer_data as b
 on A.customer_key=b.customer_key
 where A.DELIVERY_STATUS='Late'
 group by B.Location
 order by count(A.delivery_status) desc

 --Q19.What is the percentage of customers who are males acquired by APP channel? 
 
 SELECT 
 100* SUM(CASE
 WHEN GENDER='M' AND Acquired_Channel='APP'
 THEN 1
 ELSE 0
 END)/COUNT(*)
 FROM CUSTOMER_DATA
 select * from orders_data
 --Q20. What is the percentage of orders got canceled?
 select 
 100.0*sum(case 
 when order_status='Cancelled'
 then 1
 else 0
 end )/count(*) cancelled_percentage
 from orders_data
 
 --Q21. What is the percentage of orders done by happy customers (Note: Happy customers mean customer who referred other customers)
 select 
 100.0*sum(
 case
 when referred_other_customers =1
 then 1
 else 0
 end)/count(*) as Happy_cus_percentage
 from customer_data
 
 --Q22. Which Location having maximum customers through reference? 
 select top 1 count(referred_other_customers) as cust_max,location from customer_data
 group by location
 having count(referred_other_customers)>=1
 order by count(referred_other_customers) desc

 --Q23. What is order_total value of male customers who are belongs to Chennai and Happy customers (Happy customer definition is same in question 21)
 select SUM(B.ORDER_TOTAL) AS ORDER_TOTAL_VALUE,A.LOCATION,A.Gender from customer_data as A
 RIGHT JOIN ORDERS_DATA AS B
 ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
 WHERE A.LOCATION='Chennai' and A.gender='M' and A.REFERRED_OTHER_CUSTOMERS>=1
 GROUP BY A.LOCATION,A.Gender
 
 --Q24. Which month having maximum order value from male customers belongs to Chennai?
 select top 1 month(B.Order_date) as Month_,sum(B.Order_Total) as Order_Value,A.Location,A.Gender from customer_data as A
 RIGHT JOIN ORDERS_DATA AS B
 ON A.CUSTOMER_KEY=B.CUSTOMER_KEY
 where A.LOCATION='Chennai' and A.gender='M'
 group by month(B.Order_date),A.Location,A.Gender
 order by sum(B.Order_Total) desc

 


























