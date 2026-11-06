--AIRTEL TELECOM SQL PROJECT - QUESTIONS
--Tables: PLANS, CUSTOMERS, RECHARGE_HISTORY, DATA_USAGE, COMPLAINTS, NETWORK_TOWERS

--BASIC LEVEL
use airtel

--Q1. Show all active customers from Delhi.
select Customer_ID, CONCAT(First_Name,' ',Last_Name) as full_name, Gender, age,City,Plan_ID,Status
from Customers_Airtel
where city ='delhi' 
And Status='active'

--Q2. Show unique cities where customers belong.
select distinct city 
from Customers_Airtel

--Q3. Show states having more than 100 customers.
select State,count(customer_id) as customers_count
from Customers_Airtel
group by State
having count(customer_id)>100

--Q4. Find the minimum and maximum recharge amount.
select MIN(price) as min_recharge_amount,MAX(price) as max_recharge_amount
from Plans_Airtel

--Q5. Calculate the average recharge amount by payment mode.
select Payment_Mode,AVG(amount) as avg_recharge_amount 
from Recharge_History_Airtel
group by Payment_Mode

--INTERMEDIATE LEVEL

--Q6. Show customers who never recharged.
select c.Customer_ID, CONCAT(c.first_name,' ',c.Last_Name) as full_name, c.City,c.Join_Date,
	c.Plan_ID,c.Status,isnull(cast(r.Recharge_ID as varchar(20)),'not found') as recharge_id
from Customers_Airtel as c
left join Recharge_History_Airtel as r
on c.Customer_ID=r.Customer_ID
where Recharge_ID is null

--Q7. Display the customer name, plan name, recharge amount, and recharge date.
select CONCAT(c.first_name,' ',c.Last_Name),p.Plan_Name,r.Amount,r.Recharge_Date
from Recharge_History_Airtel as r
inner join Customers_Airtel as c
on r.Customer_ID=c.Customer_ID
inner join Plans_Airtel as p
on c.Plan_ID=p.Plan_ID

--Q8. Top 5 cities with the maximum number of active customers.
select top 5 city,count(status)
from Customers_Airtel
where Status='active'
group by City
order by count(status) desc

--Q9. Display: full name, full name in upper case, first 3 letters of the first name, and the length of the full name.
select CONCAT(first_name,' ',Last_Name) as full_name,
	upper(CONCAT(first_name,' ',Last_Name)) as full_name_in_uppercase,
	LEFT(first_name,3) as left_3_char,
	LEN(CONCAT(first_name,' ',Last_Name)) as len_of_ful_name
from Customers_Airtel

--Q10. Display customers who have never raised a complaint.
select c.Customer_ID,CONCAT(c.First_Name,' ',c.Last_Name) as full_name,c.City
from Customers_Airtel as c
left join Complaints_Airtel as cp
on cp.Customer_ID=c.Customer_ID
where cp.Complaint_ID is null

--Q11. Find the oldest recharge transaction made by each customer.
with cte as (select ra.Recharge_ID, ra.Customer_ID, ra.Recharge_Date,
				ROW_NUMBER() over(partition by ra.customer_id order by ra.customer_id asc,
				ra.recharge_date asc) as ranked 
			from Recharge_History_Airtel as ra
			left join Customers_Airtel as ca
			on ra.Customer_ID=ca.Customer_ID)

select Recharge_ID,Customer_ID,Recharge_Date from cte where ranked=1

--Q12. Display all customers who have not recharged in the last 60 days.
select CONCAT(c.first_name,' ',c.Last_Name) as customer_name,c.City,
	c.Status, r.recharge_date as last_recharge_date
from Customers_Airtel as c
inner join recharge_history_airtel as r
	on c.customer_id=r.customer_id
where DATEDIFF(day, convert(date, r.recharge_date, 23), getdate())>=60
and c.Status ='inactive'
order by CONVERT(date, r.recharge_date, 23) desc


--Q13. Display the number of recharges made in each month of every year.
alter table recharge_history_airtel add month varchar(50), year int
update Recharge_History_Airtel set recharge_month=datename(month,recharge_date),recharge_year=YEAR(recharge_date)

select recharge_year,recharge_month,count(recharge_id) as number_of_recharge
from Recharge_History_Airtel
group by recharge_month, recharge_year
order by recharge_year desc, count(recharge_id) desc

--ADVANCED LEVEL
--Q14. Display the customer name, total recharge amount, and categorize each customer as PLATINUM (>=8000), GOLD (5000-7999), SILVER (3000-4999), or BRONZE (<3000).
--Sort the result by total recharge in descending order.
select CONCAT(ca.First_Name,' ',ca.Last_Name) as customer_name,
	SUM(isnull(rha.amount,0)) as total_recharge_amount,
case 
	when SUM(isnull(rha.amount,0))>=8000 then 'PLATINUM'
	when 7999>=SUM(isnull(rha.amount,0)) and SUM(isnull(rha.amount,0))>=5000 then 'GOLD'
	when 4999>=SUM(isnull(rha.amount,0)) and SUM(isnull(rha.amount,0))>=3000 then 'SILVER'
else 'BRONZE' end as category
from Customers_Airtel as ca
left join Recharge_History_Airtel as rha
on ca.Customer_ID=rha.Customer_ID
group by ca.Customer_ID, ca.First_Name,ca.Last_Name
order by total_recharge_amount desc

--Q15. Create a view that displays the customer name, city, and join date.
create view customer as select  CONCAT(first_name,' ',Last_Name) as customer_name, City, Join_Date from Customers_Airtel 

select * from customer

--Q16. Display the customer ID, customer name, and customer status. If the customer is active, display 'ACTIVE CUSTOMER', otherwise display 'INACTIVE CUSTOMER'.
select Customer_ID,CONCAT(first_name,' ',Last_Name) as customer_name,
case
when Status='Active' then 'ACTIVE CUSTOMER'
else 'INACTIVE CUSTOMER'
end as customer_status
from Customers_Airtel

--Q17. Display all customer IDs from the customers table and the complaints table without duplicate values.
select Customer_ID
from Customers_Airtel
union 
select Customer_ID from Complaints_Airtel

--Q18. Create a stored procedure to display all customer details.
create procedure customer_dl AS
BEGIN
	select * from Customers_Airtel
end

exec customer_dl

--Q19. Display the total recharge amount of each customer using a CTE.
with cte as( 
	select Customer_ID,SUM(amount) as amount from Recharge_History_Airtel
	group by Customer_ID
	)

select * from cte
order by Customer_ID asc

--Q20. Create a stored procedure to display all recharge records greater than a given amount.
create procedure recharge_amount @amount int as
begin
	select * from Recharge_History_Airtel
	where Amount>@amount
end

exec recharge_amount @amount=800

--Q21. Display all cities from the customers table and the network towers table without duplicate values.
select City from Customers_Airtel
union
select City from Network_Towers_Airtel

--Q22. Display all recharge transactions whose recharge amount is higher than the average recharge amount.
select Recharge_ID,Customer_ID,Amount
from Recharge_History_Airtel
where Amount>(select AVG(amount)
				from Recharge_History_Airtel)

--Q23. Rank all customers based on their total recharge amount.
select Customer_ID,SUM(amount) as total_amount,
	RANK() over(order by sum(amount) desc) as customer_rank
from  Recharge_History_Airtel
group by Customer_ID

--Q24. Create a stored procedure that accepts a city name as input and displays all active customers from that city.
create procedure all_details @city varchar(20) as
begin
	select Customer_ID,CONCAT(first_name,' ',Last_Name) as full_name,Gender,age,Join_Date,Plan_ID from Customers_Airtel
	where City=@city
	and Status='active'
end

exec all_details @city='mumbai'

--Q25. Create a stored procedure that accepts a customer ID as input and displays the customer's name, plan name, recharge amount, and recharge date.
alter procedure details @customer_id int as
begin 
	select CONCAT(ca.first_name,' ',ca.Last_Name) as full_name, pa.Plan_Name,rha.Amount,rha.Recharge_Date from Recharge_History_Airtel as rha
	left join Customers_Airtel as ca
	on rha.Customer_ID=ca.Customer_ID
	left join Plans_Airtel as pa
	on pa.Plan_ID=ca.Plan_ID
	where ca.Customer_ID=@customer_id
	order by rha.Recharge_Date desc
end

exec details @customer_id=1020

--BONUS QUESTIONS

--Q26. Find customers whose average monthly data usage exceeds 50 GB.
select Customer_ID, AVG(data_used_gb) as avg_monthly_usage
from Data_Usage_Airtel
group by Customer_ID
having AVG(data_used_gb)>50
order by avg_monthly_usage desc

--Q27. Display the number of complaints for each complaint type, broken down by their current status.
select Status,Complaint_Type,COUNT(complaint_id) as number_of_complain
from Complaints_Airtel
group by Status,Complaint_Type
order by Complaint_Type,
CHARINDEX(Status, 'Open,In Progress,Closed')

--Q28. Find the top 3 cities with the weakest average network tower signal strength.
select top 3 city,Signal_Strength,count(tower_id) as number_of_tower from Network_Towers_Airtel
group by City,Signal_Strength
order by Signal_Strength asc,count(tower_id) desc

--Q29. Identify customers who have raised more than 2 complaints.
select Customer_ID,COUNT(customer_id) from Complaints_Airtel
group by Customer_ID
having COUNT(customer_id)>2
order by COUNT(customer_id) desc

--Q30. For each customer, show every recharge along with a running total of their recharges ordered by recharge date.
select Customer_ID, Recharge_Date, Amount,
	SUM(amount) over(partition by customer_id
		order by convert(date, r.recharge_date, 23)
	rows between unbounded preceding and current row)
	as running_total
from Recharge_History_Airtel as r
order by Customer_ID, CONVERT(date, r.recharge_date, 23)
select * from Recharge_History_Airtel

--Q31. Create a stored procedure that accepts a complaint status as input and displays the 
--complaint ID, customer name, city, complaint type, status, and complaint date for all matching complaints.
alter procedure complaint @status varchar(20) as
begin
	select ca.Complaint_ID,CONCAT(c.first_name,' ',c.Last_Name) as full_name,c.City,ca.Complaint_Type,ca.Status,ca.Created_Date
	from Complaints_Airtel as ca
	left join Customers_Airtel as c
	on ca.Customer_ID=c.Customer_ID
	where ca.Status=@status
	order by Created_Date desc,ca.Complaint_ID asc
end

exec complaint @status='open' --in progress,open, closed
