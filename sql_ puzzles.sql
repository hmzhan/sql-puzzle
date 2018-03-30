/*11. outer table and subquery, correlated subquery*/
SELECT workorder_id 
FROM Projects AS P1
WHERE step_nbr=0
      AND step_status='C'
	  AND 'W'=ALL(SELECT step_status
	              FROM Projects AS P2 
				  WHERE step_nbr <> 0
				        AND P1.workorder_id=P2.workorder_id)



/*correlated subquery*/
SELECT DISTINCT c.LastName, c.FirstName, e.BusinessEntityId
FROM Person.Person AS c INNER JOIN HumanResources.Employee As e
ON c.BusinessEntityId=c.BusinessEntityId
WHERE 5000.00 IN
    (SELECT Bonus
	 FROM Sales.SalesPerson sp 
	 WHERE e.BusinessEntityId=sp.BusinessEntityId)


/*13*/
SELECT R1.course_nbr, R1.student_name, MIN(R1.teacher_name), NULL
FROM Register AS R1 
GROUP BY R1.course_nbr, R1.student_name
HAVING COUNT(*)=1
UNION 
SELECT R1.course_nbr, R1.student_name, MIN(R1.teacher_name), MAX(R1.teacher_name)
FROM Register AS R1 
GROUP BY R1.course_nbr, R1.student_name
HAVING COUNT(*)=2
UNION 
SELECT R1.course_nbr, R1.student_name, MIN(R1.teacher_name), '--More--'
FROM Register AS R1 
GROUP BY R1.course_nbr, R1.student_name
HAVING COUNT(*)>2


SELECT course_nbr, student_name, MIN(teacher_name),
       CASE COUNT(*) WHEN 1 THEN NULL 
                     WHEN 2 THEN MAX(teacher_name)
                     ELSE '--More--' END
FROM Register 
GROUP BY course_nbr, student_name


SELECT course_nbr, student_name, MIN(teacher_name),
       CASE WHEN COUNT(*)=1 THEN NULL 
	        WHEN COUNT(*)=2 THEN MAX(teacher_name)
			ELSE '--More--' END
FROM Register 
GROUP BY course_nbr, student_name




	 
/*14*/	 
SELECT e1.last_name, e1.first_name, h1.phone_nbr AS Home, f1.phone_nbr AS FAX
FROM (Personnel AS e1 LEFT JOIN Phones AS h1 ON e1.emp_id=h1.emp_id AND h1.phone_type='home')
LEFT JOIN Phones AS f1 ON e1.emp_id=f1.emp_id AND f1.phone_type='fax'

SELECT e1.last_name, e1.first_name, e1.emp_id, h1.phone_nbr
FROM Personnel AS e1 
LEFT JOIN 
(SELECT * FROM Phones WHERE phone_type='home') h1 
ON e1.emp_id=h1.emp_id
LEFT JOIN 
(SELECT * FROM Phones WHERE phone_type='fax') f1 
ON e1.emp_id=f1.emp_id


/*IMPORTANT*/
SELECT e1.emp_id, e1.first_name, e1.last_name,
       MAX(CASE WHEN p1.phone_type='hom' THEN p1.phone_nbr
	            ELSE NULL) AS home_phone,
	   MAX(CASE WHEN p1.phone_type='fax' THEN p1.phone_nbr
	            ELSE NULL) AS fax_phone
FROM Personnel AS e1 
LEFT JOIN 
Phones AS p1 ON p1.emp_id=e1.emp_id
GROUP BY e1.emp_id, e1.first_name, e1.last_name





/*15*/
SELECT c.emp_name, c.sal_date AS curr_date, c.sal_amt AS curr_amt,
       p.sal_date AS prev_date, p.sal_amt AS prev_amt
FROM 
(SELECT emp_name, sal_date, sal_amt, RANK() OVER(PARTITION BY emp_name ORDER BY sal_date DESC)
  FROM Salaries) c 
LEFT JOIN 
(SELECT emp_name, sal_date, sal_amt, RANK() OVER(PARTITION BY emp_name ORDER BY sal_date DESC)
 FROM Salaries) p 
ON p.emp_name=c.emp_name
WHERE c.pos=1 AND p.pos=2 


SELECT s1.emp_name,
       MAX(CASE WHEN rn=1 THEN sal_date ELSE NULL END) AS curr_date,
	   MAX(CASE WHEN rn=1 THEN sal_amt ELSE NULL END) AS curr_amt,
	   MAX(CASE WHEN rn=2 THEN sal_date ELSE NULL END) AS prev_date,
	   MAX(CASE WHEN rn=2 THEN sal_amt ELSE NULL END) AS prev_date
FROM 
(SELECT emp_name, sal_date, sal_amt,
        RANK() OVER(PARTITION BY emp_name ORDER BY sal_date DESC) AS rn 
 FROM Salaries) s1 
WHERE s1.rn<3
GROUP BY s1.emp_name




/*19 three biggest sales and salespeople in each district*/
/*row_number(), rank(), dense_rank()*/
SELECT s1.district_nbr, s1.sales_person
FROM 
(SELECT district_nbr, sales_person, 
        DENSE_RANK() OVER(PARTITION BY district_nbr ORDER BY sales_amt DESC) as rank_nbr
 FROM SalesData) s1 
WHERE s1.rank_nbr<=3 



/*20*/
/*COUNT NOT NULL VALUES*/
SELECT test_name
FROM TestResults
GROUP BY test_name
HAVING COUNT(*)=COUNT(comp_date)


select sum(case when a is null then 1 else 0 end) count_nulls
     , count(a) count_not_nulls 
from us;



/*21*/
/*IMPORTANT: columns after joining two tables*/
SELECT ps1.pilot
FROM PilotSkills ps1 
LEFT JOIN Hangar h1 
ON ps1.plane=h1.plane 
GROUP BY ps1.pilot 
HAVING COUNT(ps1.plane)=(SELECT COUNT(plane) FROM Hangar)
       AND COUNT(h1.plane)=(SELECT COUNT(plane) FROM Hangar)



/*23*/	   





/*24*/
SELECT *
FROM MyTable
WHERE SIGN(F1)+SIGN(F2)+...+SIGN(F10)=1



/*25 correlated subquery*/
SELECT s0.order_nbr,
       (SELECT sch_date
	    FROM ServiceSchedule AS s1
		WHERE s.sch_seq=1 
		      AND s1.order_nbr=s0.order_nbr) AS processed,
	   (SELECT sch_date 
	    FROM ServiceSchedule AS s2
		WHERE s2.sch_seq=2 
		      AND s2.order_nbr=s0.order_nbr) AS completed,
	   (SELECT sch_date
        FROM ServiceSchedule AS s3
        WHERE s3.sch_seq=3
              AND s3.order_nbr=s0.order_nbr) AS confirmed
FROM ServiceSchedule AS s0
WHERE service_type=	01


SELECT order_nbr,
       MAX(CASE WHEN sch_seq=1 THEN sch_date ELSE NULL END) AS processed,
	   MAX(CASE WHEN sch_seq=2 THEN sch_date ELSE NULL END) AS completed,
	   MAX(CASE WHEN sch_seq=3 THEN sch_date ELSE NULL END) AS confirmed
FROM ServiceSchedule
GROUP BY order_nbr


/*26*/




/*27 correlated subquery, difficult!!!*/
SELECT sp1.sno, sp2.sno 
FROM SupParts AS sp1 
INNER JOIN SupParts AS sp2 
ON sp1.pno=sp2.pno AND sp1.sno<sp2.sno 
GROUP BY sp1.sno, sp2.sno 
HAVING (SELECT COUNT(*) FROM SupParts AS sp3
        WHERE sp3.sno=sp1.sno)
	   =(SELECT COUNT(*) FROM SupParts AS sp4
	    WHERE sp4.sno=sp2.sno)

		
SELECT DISTINCT sp1.sno, sp2.sno 
FROM SupParts AS sp1 
INNER JOIN SupParts AS sp2 
ON sp1.pno=sp2.pno AND sp1.sno<sp2.sno 
WHERE (SELECT COUNT(*) FROM SupParts AS sp3
        WHERE sp3.sno=sp1.sno)
	   =(SELECT COUNT(*) FROM SupParts AS sp4
	    WHERE sp4.sno=sp2.sno)



/*29*/
SELECT check_amt, COUNT(*) AS check_cnt 
FROM Payroll 
GROUP BY check_amt
HAVING COUNT(*)=(SELECT MAX(check_cnt)
                 FROM (SELECT COUNT(*) AS check_cnt
				       FROM Payroll 
					   GROUP BY check_amt))


SELECT po.check_amt, COUNT(*) AS check_cnt
FROM Payroll 
GROUP BY check_amt 
HAVING COUNT(*) >= ALL(SELECT COUNT(*) AS check_cnt
                       FROM Payroll
					   GROUP BY check_amt)

				
SELECT check_amt, COUNT(*) OVER(PARTITION BY check_amt) AS check_cnt
FROM Payroll 
				


		
/*30*/				
SELECT customer_name, DAYS(MAX(sale_date)-MIN(sale_date))/(COUNT(*)-1.0) AS avg_gap
FROM Sales 
GROUP BY customer_name 
HAVING COUNT(*)>1 




/*Correlated Subquery*/

/*Many queries can be evaluated by executing the subquery once and substituting the resulting value or values into the WHERE clause of the outer query. In queries that include a correlated subquery (also known as a repeating subquery), the subquery depends on the outer query for its values. This means that the subquery is executed repeatedly, once for each row that might be selected by the outer query.
This query retrieves one instance of each employee's first and last name for which the bonus in the SalesPerson table is 5000 and for which the employee identification numbers match in the Employee and SalesPerson tables.
USE AdventureWorks2008R2;
GO
SELECT DISTINCT c.LastName, c.FirstName, e.BusinessEntityID 
FROM Person.Person AS c JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = c.BusinessEntityID 
WHERE 5000.00 IN
    (SELECT Bonus
    FROM Sales.SalesPerson sp
    WHERE e.BusinessEntityID = sp.BusinessEntityID) ;
GO
Here is the result set.
LastName FirstName BusinessEntityID
-------------------------- ---------- ------------
Ansman-Wolfe Pamela 280
Saraiva José 282
(2 row(s) affected)
The previous subquery in this statement cannot be evaluated independently of the outer query. It needs a value for Employee.BusinessEntityID, but this value changes as SQL Server examines different rows in Employee.
That is exactly how this query is evaluated: SQL Server considers each row of the Employee table for inclusion in the results by substituting the value in each row into the inner query. For example, if SQL Server first examines the row for Syed Abbas, the variable Employee.BusinessEntityID takes the value 285, which SQL Server substitutes into the inner query.
USE AdventureWorks2008R2;
GO
SELECT Bonus
FROM Sales.SalesPerson
WHERE BusinessEntityID = 285;
The result is 0 (Syed Abbas did not receive a bonus because he is not a sales person), so the outer query evaluates to:
USE AdventureWorks2008R2;
GO
SELECT LastName, FirstName
FROM Person.Person AS c JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = c.BusinessEntityID 
WHERE 5000 IN (0.00)
Because this is false, the row for Syed Abbas is not included in the results. Go through the same procedure with the row for Pamela Ansman-Wolfe. You will see that this row is included in the results.
Correlated subqueries can also include table-valued functions in the FROM clause by referencing columns from a table in the outer query as an argument of the table-valued function. In this case, for each row of the outer query, the table-valued function is evaluated according to the subquery.*/





/*Primary Key Constraints
A table typically has a column or combination of columns that contain values that uniquely identify each row in the table. This column, or columns, is called the primary key (PK) of the table and enforces the entity integrity of the table. Because primary key constraints guarantee unique data, they are frequently defined on an identity column.
When you specify a primary key constraint for a table, the Database Engine enforces data uniqueness by automatically creating a unique index for the primary key columns. This index also permits fast access to data when the primary key is used in queries. If a primary key constraint is defined on more than one column, values may be duplicated within one column, but each combination of values from all the columns in the primary key constraint definition must be unique.
As shown in the following illustration, the ProductID and VendorID columns in the Purchasing.ProductVendor table form a composite primary key constraint for this table. This makes sure that that every row in the ProductVendor table has a unique combination of ProductID and VendorID. This prevents the insertion of duplicate rows.
Composite PRIMARY KEY constraint
A table can contain only one primary key constraint.
A primary key cannot exceed 16 columns and a total key length of 900 bytes.
The index generated by a primary key constraint cannot cause the number of indexes on the table to exceed 999 nonclustered indexes and 1 clustered index.
If clustered or nonclustered is not specified for a primary key constraint, clustered is used if there no clustered index on the table.
All columns defined within a primary key constraint must be defined as not null. If nullability is not specified, all columns participating in a primary key constraint have their nullability set to not null.
If a primary key is defined on a CLR user-defined type column, the implementation of the type must support binary ordering.
Foreign Key Constraints
A foreign key (FK) is a column or combination of columns that is used to establish and enforce a link between the data in two tables to control the data that can be stored in the foreign key table. In a foreign key reference, a link is created between two tables when the column or columns that hold the primary key value for one table are referenced by the column or columns in another table. This column becomes a foreign key in the second table.
For example, the Sales.SalesOrderHeader table has a foreign key link to the Sales.SalesPerson table because there is a logical relationship between sales orders and salespeople. The SalesPersonID column in the SalesOrderHeader table matches the primary key column of the SalesPerson table. The SalesPersonID column in the SalesOrderHeader table is the foreign key to the SalesPerson table. By creating this foreign key relationship, a value for SalesPersonID cannot be inserted into the SalesOrderHeader table if it does not already exist in the SalesPerson table.
Indexes on Foreign Key Constraints
Unlike primary key constraints, creating a foreign key constraint does not automatically create a corresponding index. However, manually creating an index on a foreign key is often useful for the following reasons:
Foreign key columns are frequently used in join criteria when the data from related tables is combined in queries by matching the column or columns in the foreign key constraint of one table with the primary or unique key column or columns in the other table. An index enables the Database Engine to quickly find related data in the foreign key table. However, creating this index is not required. Data from two related tables can be combined even if no primary key or foreign key constraints are defined between the tables, but a foreign key relationship between two tables indicates that the two tables have been optimized to be combined in a query that uses the keys as its criteria.
Changes to primary key constraints are checked with foreign key constraints in related tables.*/


/*31*/



/*32*/




/*OVER clause*/

SELECT ROW_NUMBER() OVER(PARTITION BY PostalCode ORDER BY SalesYTD DESC) AS rn,
       p.LastName,
	   s.SalesYTD,
	   a.PostalCode 
FROM Sales.SalesPerson AS s 
     INNER JOIN Person.Person AS p 
	 ON s.BusinessEntityID=p.BusinessEntityID
	 INNER JOIN Person.Address AS a
	 ON a.AddressID=p.BusinessEntityID
WHERE TerritoryID IS NOT NULL 
      AND SalesYTD <> 0 
ORDER BY PostalCode


/*over, aggregate function*/
SELECT SalesOrderID, ProductID, OrderQty,
       SUM(OrderQty) OVER(PARTITION BY SalesOrderID) AS Total,
	   AVG(OrderQty) OVER(PARTITION BY SalesOrderID) AS Mean,
	   COUNT(OrderQty) OVER(PARTITION BY SalesOrderID) AS how_many,
	   MIN(OrderQty) OVER(PARTITION BY SalesOrderID) AS Minimum,
	   MAX(OrderQty) OVER(PARTITION BY SalesOrderID) AS Maximum
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN(43659, 43664)



SELECT SalesOrderID, ProductID, OrderQty,
       SUM(OrderQty) OVER(PARTITION BY SalesOrderID) AS Total,
	   CAST(1.*OrderQty/SUM(OrderQty) OVER(PARTITION BY SalesOrderId) * 100 AS DECIMAL(5,2)) AS Percent_by_ProductID 
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN(43659, 43664)



/*35 moving average, cumulative total*/
SELECT req_date, req_qty,
       SUM(req_qty) OVER(ORDER BY req_date DESC ROWS UNBOUNDED PRECEDING) AS req_onhand_qty
FROM InventoryAdjustments
ORDER BY req_date


/*36 double duty*/
SELECT person, 
       CASE WHEN COUNT(*)=1 THEN role ELSE 'B' END AS duty 
FROM Roles 
WHERE role IN ('O','D')
GROUP BY person 



/*37 MOVING AVERAGE*/
SELECT sample_time, AVG(load) OVER(ORDER BY sample_time DESC ROWS 4 PRECEDING)
FROM Samples 
WHERE EXTRACT (MINUTE FROM sample_time) = 00 





/*45*/

SELECT cust_id,
       SUM(CASE WHEN bill_date BETWEEN CURRENT_TIMESTAMP-INTERVAL 30 DAYS AND CURRENT_TIMESTAMP THEN pizza_amt ELSE 0.00) AS age1,
	   SUM(CASE WHEN bill_date BETWEEN CURRENT_TIMESTAMP-INTERVAL 60 DAYS AND CURRENT_TIMESTAMP-INTERVAL 31 DAYS THEN pizza_amt ELSE 0.00) AS age2,
	   SUM(CASE WHEN bill_date BETWEEN CURRENT_TIMESTAMP-INTERVAL 90 DAYS AND CURRENT_TIMESTAMP-INTERVAL 61 DAYS THEN pizza_amt ELSE 0.00) AS age3,
	   SUM(CASE WHEN bill_date < CURRENT_TIMESTAMP-INTERVAL 91 DAYS AND CURRENT_TIMESTAMP THEN pizza_amt ELSE 0.00) AS age4
FROM FriendsofPepperoni


/*46 SALES PROMOTIONS*/






SELECT account_id, product_id, cust_id, avail_balance
FROM account
WHERE open_emp_id <> (SELECT e.emp_id
    FROM employee e INNER JOIN branch b 
	ON e.assigned_branch_id=b.branch_id
	WHERE e.title='Head Teller' AND b.city='Woburn')

	
SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id IN (SELECT superior_emp_id FROM employee)


SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id NOT IN (SELECT superior_emp_id
      FROM employee
	  WHERE superior_emp_id IS NOT NULL)


SELECT account_id, cust_id, product_id, avail_balance
FROM account
WHERE avail_balance > ANY (SELECT a.avail_balance
      FROM account a INNER JOIN individual i 
	  ON a.cust_id=i.cust_id
	  WHERE i.fname='Frank' AND i.lname='Tucker')
	  

SELECT account_id, product_id, cust_id
FROM account
WHERE open_branch_id=(SELECT branch_id
      FROM branch 
	  WHERE name='Woburn Branch')
	  AND open_emp_id IN (SELECT emp_id
	  FROM employee
	  WHERE title='Teller' OR title='Head Teller')
	  
SELECT account_id, product_id, cust_id
FROM account
WHERE (open_branch_id, open_emp_id) IN
    (SELECT b.branch_id, e.emp_id
	 FROM branch b INNER JOIN employee e 
	 ON b.branch_id=e.assigned_branch_id
	 WHERE b.name='Woburn Branch'
	 AND (e.title='Teller' OR e.title='Head Teller')

	 
SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c
WHERE 2=(SELECT COUNT(*)
     FROM account a 
     WHERE a.cust_id=c.cust_id)
	 

SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c
WHERE (SELECT SUM(a.avail_balance)
     FROM account a 
	 WHERE a.cust_id=c.cust_id)
     BETWEEN 5000 AND 10000


SELECT d.dept_id, d.name, e_cnt.how_many num_employees
FROM department d INNER JOIN 
(SELECT dept_id, COUNT(*) how_many
 FROM employee
 GROUP BY dept_id) e_cnt
ON d.dept_id=e_cnt.dept_id
 
	 
SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id
HAVING COUNT(*)=(SELECT MAX(emp_cnt.how_many)
    FROM (SELECT COUNT(*) how_many
          FROM account 
          GROUP BY open_emp_id) emp_cnt)


		  
	 
SELECT c.cust_id, c.fed_id,
    CASE
      WHEN c.cust_type_cd='I'
        THEN CONCAT(i.fname, ' ', i.lname)
      WHEN c.cust_type_cd='B'
        THEN b.name
      ELSE 'Unknown'
    END name
FROM customer c LEFT OUTER JOIN individual i 
ON c.cust_id=i.cust_id
LEFT OUTER JOIN business b 
ON c.cust_id=b.cust_id

	
	 
	 
SELECT a.account_id, a.cust_id, a.open_date, a.product_id
FROM account a INNER JOIN
  (SELECT emp_id, assigned_branch_id
   FROM employee
   WHERE start_date < '2007-01-01'
         AND (title='Teller' OR title='Head Teller')) e 
ON a.open_emp_id = e.emp_id
INNER JOIN 
  (SELECT branch_id
   FROM branch
   WHERE name='Woburn Branch') b 
ON e.assigned_branch_id=b.branch_id


# account: account_id, cust_id, open_date, product_id, open_emp_id
# employee: emp_id, assigned_branch_id, start_date, title 
# branch: branch_id, name 
# results: account_id, cust_id, open_date, product_id


SELECT a.account_id, a.cust_id, a.open_date, a.product_id
FROM account a INNER JOIN
(SELECT emp_id, assigned_branch_id
 FROM employee) e 
ON a.open_emp_id=e.emp_id
INNER JOIN 
(SELECT branch_id
 FROM branch) b
ON e.assigned_branch_id=b.branch_id




SELECT a.account_id, e.emp_id, b_a.name open_branch, b_e.name emp_branch
FROM account a INNER JOIN branch b_a
ON a.open_branch_id=b_a.branch_id
INNER JOIN employee e 
ON a.open_emp_id=e.emp_id
INNER JOIN branch b_e
ON e.assigned_branch_id=b_e.branch_id
WHERE a.product_id='CHK'


/*date variable*/
SELECT DATEPART(year, OrderDate) as OrderYear,
       DATEPART(month, OrderDate) as OrderMonth,
	   DATEPART(day, OrderDate) as OrderDay
FROM Orders 
WHERE OrderId=1 



SELECT b.driver_id, b.city_id, b.request_at_week, b.how_many, b.row_num
 FROM	  
 (SELECT a.driver_id, a.city_id, a.request_at_week, COUNT(a.Status) AS how_many, ROW_NUMBER() OVER(PARTITION BY a.city_id, a.request_at_week ORDER BY COUNT(a.Status) DESC) AS row_num
   FROM	  
   (SELECT driver_id, city_id, Status, request_at, CAST(SWITCHOFFSET(CAST(t.request_at AS VARCHAR), '-08:00') AS DATE) AS request_at_day,
           DATEPART(WEEK, SWITCHOFFSET(CAST(t.request_at AS VARCHAR), '-08:00')) AS request_at_week
     FROM trips 
    WHERE Status='completed') a	  
  WHERE a.city_id IN (1,6,12)
        AND a.request_at_day BETWEEN '2013-06-03' AND '2013-06-24'
  GROUP BY a.city_id, a.driver_id, a.request_at_week) b
WHERE b.row_num <= 3




select id,
from 
(SELECT id, row_number() over(order by salary desc) as rs 
from example) a 
where a.rs=2 


select s1.emp_name,
       max(case when rn=1 then sal_date else null end) as current_date,
	   max(case when rn=2 then sal_date else null end) as prev_date,
	   max(case when rn=1 then sal_amt else null end) as current_amt,
	   max(case when rn=2 then sal_amt else null end) as prev_amt
from
(select emp_name, sal_date, sal_amt
       rank() over(partition by emp_name order by sal_date desc) as rn
from data1) as s1
where s1.rn<=2
group by emp_name 


select district_nbr, sales_person
from 
(select district_nbr, sales_person,
       dense_rank() over(partition by district_nbr order by sales_amt desc) as rn
from salesdata) s1 
where s1.rn<3




/*other info*/

INSERT INTO /*insert new records in a table*/

INSERT INTO table_name (column1, column2, column3,...)
VALUES (value1, value2, value3,...)

INSERT INTO Customers (CustomerName, ContactName, Address, City, PostalCode, Country)
VALUES ('Cardinal','Tom B. Erichsen','Skagen 21','Stavanger','4006','Norway');


UPDATE /*update existing records in a table*/

UPDATE table_name 
SET column1=value1, column2=value2, ...
WHERE some_column=some_value

UPDATE Customers
SET ContactName='Alfred Schmidt', City='Hamburg'
WHERE CustomerName='Alfreds Futterkiste';


DELETE /*delete rows in a table*/

DELETE FROM table_name 
WHERE some_column=some_value

DELETE FROM Customers
WHERE CustomerName='Alfreds Futterkiste' AND ContactName='Maria Anders';


CREATE TABLE /*create a table in database*/

CREATE TABLE table_name
(
column_name1 data_type(size) constraint_name,
column_name2 data_type(size) constraint_name,
column_name3 data_type(size) constraint_name,
....
);
NOT NULL /*indicate that a column cannot store NULL value*/
UNIQUE /*ensures that each row for a column much have a unique value */
PRIMARY KEY /*combination of NOT NULL and UNIQUE. Ensures that a column have a unique identity which helps to find a particular record in a table mroe easily and quickly*/
FOREIGH KEY /*ensure the referential integrity of the data in one table to match values in another table*/
CHECK /*ensures that the value in a column meets a specific condition*/
DEFAULT /*specifies a default value for a column*/


CREATE TABLE Persons
(
P_Id int NOT NULL,
LastName varchar(255) NOT NULL,
FirstName varchar(255),
Address varchar(255),
City varchar(255),
CONSTRAINT uc_PersonID UNIQUE (P_Id,LastName)
)



FOREIGN KEY /*foreign key in one table points to primary key in another table*/

/*Note that the "P_Id" column in the "Orders" table points to the "P_Id" column in the "Persons" table.
The "P_Id" column in the "Persons" table is the PRIMARY KEY in the "Persons" table.
The "P_Id" column in the "Orders" table is a FOREIGN KEY in the "Orders" table.
The FOREIGN KEY constraint is used to prevent actions that would destroy links between tables.*/


CREATE INDEX /*create indexes in tables, allow the database application to find data fast without reading the whole table*/


DELETE 
/*The DELETE command is used to remove rows from a table. 
A WHERE clause can be used to only remove some rows. 
If no WHERE condition is specified, all rows will be removed. 
After performing a DELETE operation you need to COMMIT or ROLLBACK the transaction 
to make the change permanent or to undo it. Note that this operation will cause all DELETE triggers on the table to fire.*/
DROP 
/*The DROP command removes a table from the database. 
All the tables' rows, indexes and privileges will also be removed. 
No DML triggers will be fired. The operation cannot be rolled back.*/
TRUNCATE
/*TRUNCATE removes all rows from a table. The operation cannot be rolled back and no triggers will be fired. 
As such, TRUCATE is faster and doesn't use as much undo space as a DELETE*/



CREATE VIEW /*A view is a virtual table*/

CREATE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition

CREATE OR REPLACE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition



/*My SQL and SQL server: <> not equal to*/
/*My SQL and SQL server: in, not in*/













