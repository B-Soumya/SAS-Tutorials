/* 
1. create datasets 
2. print few variables
3. ALIAS
4. Filtering
5. Use of AND, OR, IN, Between
6. Calculated columns
7. Group by
8. Order for sorting
9. Having for filtering after aggregation
10. Case When for conditional column logic
11. LIKE - Pattern Rceognization
12. Joins (Inner, Left, Right, Full including exclusives)
13. String Functions
		Concatenation using pipeline and catx()
		REVERSE – Reverse a string
		REPLACE – Replace part of string (use TRANWRD() in SAS)
		SUBSTRING – Extract part of a string 
		INSTRING – Position of substring (INDEX() in SAS)
14. Real world applications
*/


/* create datasets */
data customers;
    input customer_id $ name $10. age gender $;
    datalines;
C001 Alice     34 F
C002 Bob       45 M
C003 Charlie   29 M
C004 Diana     40 F
C006 Eva       31 F
C007 Frank     50 M
C008 Grace     27 F
C009 Henry     38 M
C010 Christine 40 F
;
run;

data credit_usage;
    input customer_id $ month $ credit_limit amount_spent;
    datalines;
C001 Jan 5000 3200
C002 Jan 7000 6900
C003 Jan 4000 4100
C005 Jan 6000 3500
C006 Feb 6500 4000
C007 Feb 8000 7500
C009 Mar 9000 8800
C010 Mar 5000 2500
C001 Feb 5000 3100
C010 Feb 7500 7300
;



/* print few columns with renaming column*/
proc sql;
	select customer_id AS CID, credit_limit AS CL, Amount_spent as "Deducted Amount"n
	from credit_usage;
quit;
run;	

/* filtering data */
proc sql;
	select *
	from credit_usage
	where month = 'Jan';
quit;
run;

/* AND - multiple conditions */
/* use case: Select female customers older than 30 */
proc sql;
    select *
    from customers
    where gender = 'F' and age > 30;
quit;

/* OR - either this or that */
/* use case: customers who are either male or under 30 */
proc sql;
    select *
    from customers
    where gender = 'M' or age < 30;
quit;

/* IN – Match any of several values */
proc sql;
    select * 
    from customers
    where customer_id in ('C001', 'C003', 'C006');
quit;

/* BETWEEN – Range-based filter */
proc sql;
    select * 
    from customers
    where age between 30 and 40;
quit;

/* calculated column */
/* use case: See only high spenders (credit utilization > 90%) */
proc sql;
    select a.customer_id, a.name, b.month, 
           b.amount_spent, b.credit_limit,
           (b.amount_spent / b.credit_limit) * 100 as utilization_pct format=5.1
    from customers as a
    inner join credit_usage as b
    on a.customer_id = b.customer_id
    where (b.amount_spent / b.credit_limit) > 0.9;
quit;

/* group by clause */
/* use case: transactions per customer */
proc sql;
    select customer_id, count(*) as transaction_count
    from credit_usage
    group by customer_id;
quit;

/* ORDER BY - sorting dataframe */
proc sql;
    select customer_id, credit_limit, amount_spent
    from credit_usage
    order by amount_spent desc;
quit;

/* HAVING filters groups after aggregation */
/* Use Case 1: Total spend per customer, only show high spenders */
proc sql;
    select customer_id, 
           sum(amount_spent) as total_spent
    from credit_usage
    group by customer_id
    having total_spent > 7000
    order by total_spent desc;
quit;

/* Use Case 2: Average credit limit per customer */
proc sql;
    select customer_id, 
           avg(credit_limit) as avg_limit format=8.0
    from credit_usage
    group by customer_id
    having avg(credit_limit) between 6000 and 8000;
quit;

/* CASE WHEN – Conditional column logic */
proc sql;
    select customer_id, credit_limit, amount_spent,
           case 
               when amount_spent / credit_limit > 0.9 then 'High'
               when amount_spent / credit_limit between 0.6 and 0.9 then 'Moderate'
               else 'Low'
           end as usage_category
    from credit_usage;
quit;

/* LIKE - Pattern Matching */
/* Pattern	Meaning 
	 'A%'	Starts with A
	 '%e'	Ends with e
	 '%ra%'	Contains 'ra' anywhere
	 '____'	Exactly 4 characters */
proc sql;
    select * 
    from customers
    where name like 'A%';
quit;



/** Joins **/
/* Inner Join */
proc sql;
    create table inner_join as
    select a.*, b.month, b.credit_limit, b.amount_spent
    from customers as a
    inner join credit_usage as b
    on a.customer_id = b.customer_id;
quit;
run;

/* Left Join */
proc sql;
    create table left_join as
    select a.*, b.month, b.credit_limit, b.amount_spent
    from customers as a
    left join credit_usage as b
    on a.customer_id = b.customer_id;
quit;

/* Left Join Exclusive*/
proc sql;
    create table left_join_exclusive as
    select a.*, b.month, b.credit_limit, b.amount_spent
    from customers as a
    left join credit_usage as b
    on a.customer_id = b.customer_id
    where b.customer_id is null;
quit;

/* Right Join */
proc sql;
    create table right_join as
    select a.*, b.month, b.credit_limit, b.amount_spent
    from customers as a
    right join credit_usage as b
    on a.customer_id = b.customer_id;
quit;

/* Right Join Exclusive*/
proc sql;
    create table right_join_exclusive as
    select a.*, b.month, b.credit_limit, b.amount_spent
    from customers as a
    left join credit_usage as b
    on a.customer_id = b.customer_id
    where a.customer_id is null;
quit;

/* Full Join */
proc sql;
    create table full_join as
    select 
        coalesce(a.customer_id, b.customer_id) as customer_id,
        a.name, a.age, a.gender,
        b.month, b.credit_limit, b.amount_spent
    from customers as a
    full join credit_usage as b
    on a.customer_id = b.customer_id;
quit;

/* Full Join Exclusive*/
proc sql;
    create table full_join_exclusive as
    select 
        coalesce(a.customer_id, b.customer_id) as customer_id,
        a.name, a.age, a.gender,
        b.month, b.credit_limit, b.amount_spent
    from customers as a
    full join credit_usage as b
    on a.customer_id = b.customer_id
    where a.customer_id is null or b.customer_id is null;
quit;



/* Concatenation */
/* Use pipeline || */
proc sql;
    select customer_id, name, 
           name || ' (' || customer_id || ')' as full_label
    from customers;
quit;

/* Use CATX() */
proc sql;
    select customer_id, name,
           catx(' - ', name, customer_id) as full_label
    from customers;
quit;


/* REVERSE – Reverse a string */
proc sql;
    select name, reverse(name) as reversed_name
    from customers;
quit;


/* REPLACE – Replace part of string (use TRANWRD() in SAS) */
proc sql;
    select name, tranwrd(name, 'a', '@') as modified_name
    from customers;
quit;


/* SUBSTRING – Extract part of a string */
proc sql;
    select name, substr(name, 1, 3) as name_prefix, substr(name, 4) as name_suffix
    from customers;
quit;


/* INSTRING – Position of substring (INDEX() in SAS) */
proc sql;
    select lowcase(name), index(lowcase(name), 'a') as position_of_a
    from customers;
quit;



/** PRACTICAL SCENARIO DEALING using subqueries**/

/* Goal 1: List customers whose total amount spent is above the 
average of all customers and classify their spending level. */
proc sql;
    select a.customer_id, a.name, a.age, a.gender,
           sum(b.amount_spent) as total_spent,
           case 
               when sum(b.amount_spent) > 10000 then 'Premium'
               when sum(b.amount_spent) > 7000 then 'Standard'
               else 'Basic'
           end as spending_category
    from customers as a
    inner join credit_usage as b
    on a.customer_id = b.customer_id
    group by a.customer_id, a.name, a.age, a.gender
    having total_spent > (
        select avg(amount_spent)
        from credit_usage
    )
    order by total_spent desc;
quit;

/* Goal 2: Goal: Identify customers who spent more than 90% of their credit limit 
in any transaction in January, and whose total February spending is above 4000.*/
proc sql;
    select a.customer_id, a.name, b.month, 
           b.credit_limit, b.amount_spent,
           (b.amount_spent / b.credit_limit) * 100 as utilization_pct format=5.1,
           case 
               when (b.amount_spent / b.credit_limit) > 0.8 then '⚠️ High Utilization'
               else 'Normal'
           end as risk_status
    from customers as a
    inner join credit_usage as b
    on a.customer_id = b.customer_id
    where b.month = 'Jan'
    group by a.customer_id, a.name, b.month, b.credit_limit, b.amount_spent
    having sum(b.amount_spent) > 4000
    order by utilization_pct desc;
quit;






