# 📱 Airtel Telecom – SQL Project

A SQL project on a telecom dataset built in **Microsoft SQL Server (SSMS)**. It uses six related tables (customers, plans, recharges, data usage, complaints, and network towers) to answer 31 business questions, from simple filters to CTEs, window functions, views, and stored procedures.

---

## 🗂️ Repository Structure

| File | Description |
|------|-------------|
| `customers_airtel.csv` | Customer profiles – name, gender, age, city, state, join date, plan, status |
| `plans_airtel.csv` | Prepaid plans and prices |
| `recharge_history_airtel.csv` | Every recharge transaction with amount, payment mode, and date |
| `data_usage_airtel.csv` | Data usage records per customer |
| `complaints_airtel.csv` | Customer complaints with type, status, and created date |
| `network_towers_airtel.csv` | Network towers by city with signal strength |
| `Airtel_Project_Questions.txt` | The 31 questions solved in this project |
| `arun_airtel_soln.sql` | My SQL solution |
| `Airtel_SQL_Project_Solutions.sql` | My mentor SQL solution |
| `README.md` | Project documentation |

> ⚠️ Rename the files above to match the exact names in your repo.

---

## 🧱 Database Schema

Database name: `airtel`

| Table | Key columns |
|-------|-------------|
| `Customers_Airtel` | `Customer_ID`, `First_Name`, `Last_Name`, `Gender`, `Age`, `City`, `State`, `Join_Date`, `Plan_ID`, `Status` |
| `Plans_Airtel` | `Plan_ID`, `Plan_Name`, `Price` |
| `Recharge_History_Airtel` | `Recharge_ID`, `Customer_ID`, `Amount`, `Payment_Mode`, `Recharge_Date` |
| `Data_Usage_Airtel` | Monthly data usage per customer (used in the bonus question on data usage) |
| `Complaints_Airtel` | `Complaint_ID`, `Customer_ID`, `Complaint_Type`, `Status`, `Created_Date` |
| `Network_Towers_Airtel` | `Tower_ID`, `City`, `Signal_Strength` |

**Relationships**
- `Customers_Airtel.Plan_ID` → `Plans_Airtel.Plan_ID`
- `Recharge_History_Airtel.Customer_ID` → `Customers_Airtel.Customer_ID`
- `Complaints_Airtel.Customer_ID` → `Customers_Airtel.Customer_ID`
- `Data_Usage_Airtel.Customer_ID` → `Customers_Airtel.Customer_ID`

> Check the column lists against your CSV headers, especially for `Data_Usage_Airtel`.

---

## ⚙️ Setup Instructions

1. Open **SQL Server Management Studio (SSMS)**.
2. Create the database:
   ```sql
   CREATE DATABASE airtel;
   USE airtel;
   ```
3. Right-click the database → **Tasks → Import Flat File** and import each CSV with these table names:
   `Customers_Airtel`, `Plans_Airtel`, `Recharge_History_Airtel`, `Data_Usage_Airtel`, `Complaints_Airtel`, `Network_Towers_Airtel`.
4. Check data types, for example `Join_Date`, `Recharge_Date`, and `Created_Date` as `date`, and `Amount` and `Price` as numeric.
5. Open `arun_airtel_sol.sql` and run the queries one by one.

---

## ❓ Questions Solved

### 🔹 Basic Level
1. Show all active customers from Delhi.
2. Show unique cities where customers belong.
3. Show states having more than 100 customers.
4. Find the minimum and maximum recharge amount.
5. Calculate the average recharge amount by payment mode.

### 🔹 Intermediate Level
6. Show customers who never recharged.
7. Display the customer name, plan name, recharge amount, and recharge date.
8. Top 5 cities with the maximum number of active customers.
9. Display full name, full name in upper case, first 3 letters of the first name, and the length of the full name.
10. Display customers who have never raised a complaint.
11. Find the oldest recharge transaction made by each customer.
12. Display all customers who have not recharged in the last 60 days.
13. Display the number of recharges made in each month of every year.

### 🔹 Advanced Level
14. Categorize customers as PLATINUM, GOLD, SILVER, or BRONZE based on total recharge amount.
15. Create a view that displays the customer name, city, and join date.
16. Display customer status as 'ACTIVE CUSTOMER' or 'INACTIVE CUSTOMER'.
17. Display all customer IDs from the customers and complaints tables without duplicates.
18. Create a stored procedure to display all customer details.
19. Display the total recharge amount of each customer using a CTE.
20. Create a stored procedure to display recharge records greater than a given amount.
21. Display all cities from the customers and network towers tables without duplicates.
22. Display recharge transactions higher than the average recharge amount.
23. Rank all customers based on their total recharge amount.
24. Create a stored procedure that accepts a city name and shows its active customers.
25. Create a stored procedure that accepts a customer ID and shows the name, plan name, recharge amount, and date.

### 🔹 Bonus Questions
26. Find customers whose average monthly data usage exceeds 50 GB.
27. Display the number of complaints for each complaint type, broken down by status.
28. Find the top 3 cities with the weakest average network tower signal strength.
29. Identify customers who have raised more than 2 complaints.
30. For each customer, show every recharge with a running total ordered by recharge date.
31. Create a stored procedure that accepts a complaint status and shows all matching complaints.

---

## 🛠️ SQL Concepts Used

- Filtering and sorting: `WHERE`, `ORDER BY`, `TOP`, `DISTINCT`
- Aggregation: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`, `GROUP BY`, `HAVING`
- Joins: `INNER JOIN`, `LEFT JOIN`
- String functions: `CONCAT()`, `UPPER()`, `LEFT()`, `LEN()`
- Date functions: `DATENAME()`, `YEAR()`
- Conditional logic: `CASE WHEN`
- Set operators: `UNION`
- Subqueries and CTEs
- Window functions: `ROW_NUMBER()`, `RANK()`
- Views
- Stored procedures with input parameters

---

## 💡 Sample Queries

**Customer tiers by total recharge (Q14)**

```sql
SELECT CONCAT(ca.First_Name, ' ', ca.Last_Name) AS customer_name,
       SUM(ISNULL(rha.Amount, 0)) AS total_recharge_amount,
       CASE
           WHEN SUM(ISNULL(rha.Amount, 0)) >= 8000 THEN 'PLATINUM'
           WHEN SUM(ISNULL(rha.Amount, 0)) >= 5000 THEN 'GOLD'
           WHEN SUM(ISNULL(rha.Amount, 0)) >= 3000 THEN 'SILVER'
           ELSE 'BRONZE'
       END AS category
FROM Customers_Airtel AS ca
LEFT JOIN Recharge_History_Airtel AS rha
    ON ca.Customer_ID = rha.Customer_ID
GROUP BY ca.Customer_ID, ca.First_Name, ca.Last_Name
ORDER BY total_recharge_amount DESC;
```

**Customer ranking by total recharge (Q23)**

```sql
SELECT Customer_ID,
       SUM(Amount) AS total_amount,
       RANK() OVER (ORDER BY SUM(Amount) DESC) AS customer_rank
FROM Recharge_History_Airtel
GROUP BY Customer_ID;
```

**Stored procedure with a parameter (Q24)**

```sql
CREATE PROCEDURE all_details @city VARCHAR(20) AS
BEGIN
    SELECT Customer_ID, CONCAT(First_Name, ' ', Last_Name) AS full_name,
           Gender, Age, Join_Date, Plan_ID
    FROM Customers_Airtel
    WHERE City = @city AND Status = 'active';
END;

EXEC all_details @city = 'Mumbai';
```

---

## 📊 Key Insights

> Fill this in after running the queries with your actual results.

- **Top city by active customers:** _your value_
- **Most used payment mode:** _your value_
- **Customer tier split (Platinum / Gold / Silver / Bronze):** _your value_
- **Customers who never recharged:** _your value_
- **Most common complaint type:** _your value_
- **City with the weakest network signal:** _your value_

---

## 🚀 How to Use This Repo

1. Clone the repository.
2. Import the six CSV files into SQL Server as described above.
3. Run `arun_airtel_sol.sql` in SSMS.
4. Compare your results and note your findings in Key Insights.

---

## 👤 Author

**Arun**
Data & Accounts Analyst | Excel · SQL · Python · Power BI

Feedback and suggestions are welcome.
