/*
1. create library
2. create table (datalines, cards)
3. Rename and Reorder columns (RENAME, PROC SORT)
4. Alter table (SET)
5. Create new table from existing table
6. Add new columns (fixed, conditional (IF-THEN-ELSE), calculated)
7. Date related functions
8. Date Formatting
9. INFORMAT FORMAT for Date
10. Concatenation multiple columns
11. Sorting dataset
12. Subsetting/Filtering Data with the WHERE Statement
13. Subsetting/Filetring Data with the IF Statement
14. Complex Filtering
15. Customizing Output (NOBS, VAR, KEEP, DROP)
16. Export data into csv/xlsx/txt format
17. save data in customized library
18. Import data into csv/xlsx/txt format
*/



/** Create Customized Library **/
libname sbasak "~/sasuser.v94/"; /* No subfolder */



/** create new table using datalines **/
data employees;
    length Department $ 20; /* Set the length of the Department variable */
    input ID $ Name $ Age Department $ Salary;
    datalines;
001 John 28 HR 55000
002 Alice 34 IT 60000
003 Bob 25 Marketing 48000
004 Sarah 40 IT 75000
005 Steve 29 HR 52000
;
run;

proc print data=employees;
run;

/** create new table using cards **/
data products;
    input ProductID $ ProductName $ Price Stock;
    cards;
P001 Laptop 1200 30
P002 Phone 800 50
P003 Tablet 450 100
P004 Monitor 300 75
P005 Keyboard 50 150
;
run;

proc print data=products;
run;



/** Reordering columns and renaming in existing table **/
data employees;
    set employees(rename=(ID=Employee_ID
                          Name=Employee_Name
                          Age=Emp_Age
                          Department=Dept
                          Salary=Emp_Salary));
    /* Reordering columns by using KEEP to define order */
    keep Employee_ID Employee_Name Emp_Age Dept Emp_Salary;
run;

proc print data=employees;
run;

/* Reordering columns and renaming and save as new table */
data employees_final;
    set employees(keep=ID Name Department Age Salary);
    rename ID=Employee_ID
	       Name=Employee_Name
	       Department=Dept
	       Age=Emp_Age
	       Salary=Emp_Salary;
run;

proc print data=employees_final;
run;



/* Add a Date Column */
data employees_final;
    set employees_final;
    /* Add a new column with a default value (e.g., '01JAN2020') */
    DOJ = '01JAN2020'd;  /* Format the date correctly */
    
    /* Applying a format to the DOJ column */
    format DOJ date9.;  /* Use the DATE9. format (e.g., 01JAN2018) */
run;

proc print data=employees_final;
run;


/* Add date based on condition*/
data employees_final;
    set employees_final;
    /* Assigning a different date based on the department */
    if Dept = 'HR' then DOO = '01JAN2018'd;
    else if Dept = 'IT' then DOO = '15MAR2019'd;
    else DOO = '01JAN2020'd; /* Default date for others */
   
    /* Applying a format to the DOJ column */
    format DOO date9.;  /* Use the DATE9. format (e.g., 01JAN2018) */
run;

proc print data=employees_final;
run;


/* Add a Calculated Column */
data products;
    set products;
    /* Add a new calculated column */
    Total_Price = Price * Stock;  /* Define the calculated column correctly */
run;

proc print data=products;
run;



/** Date Formats and Robust Functions**/
data floor_manager;
    input Employee_ID $ Name $;
    /* Create a column Today with today's date */
    Today = today(); /* SAS function to get today's date */
    format Today DATE9.;
    datalines;
001 John
002 Alice
003 Bob
004 Sarah
005 Steve
;
run;

proc print data=floor_manager;
run;

/** Robubust Dates **/
data floor_manager;
    set floor_manager;
    
    /* Extract from today's date */
   
    MONDAY = intnx('WEEK', today(), 0, 'B')+1;  /* First day of the week (Monday) */
    format MONDAY MMDDYY8.;
    
    DAY = today();  /* Day of the month */
    format DAY DAY.;
    
    MONTH = today();  /* Month of the year */
    format MONTH MONTH.;
    
    YEAR = today();  /* Year of the current date */
    format YEAR YEAR.;
    
    QUARTER = qtr(today()); /* Quarter of the year */
    format QUARTER QUARTER.;
    
    /* Get Week Number of the Year */
    Week_Number = week(today());  /* Week number of the current year */

    /* Get Day of the Week (e.g., Monday, Tuesday, etc.) */
    Day_of_Week = put(today(), dayname.);  /* Day of the week (Monday, Tuesday, etc.) */
    
    
    /* Tomorrow's date */
    Tomorrow = today() + 1;  /* Adding 1 day to today's date to get tomorrow's date */
    format Tomorrow DATE9.;  /* You can choose any format you want */
   	
   	/* Add 1 month to today's date */
    One_Month_After = intnx('month', today(), 1);
    format One_Month_After date9.;  /* Format the new column to show in date9. format */
    
    /* Add 1 year to today's date */
    One_Year_After = intnx('year', today(), 1, 'same');
    format One_Year_After date9.;  /* Format the new column to show in date9. format */
   
    /* First day of the current month */
    First_Day_Of_Current_Month = intnx('month', today(), 0, 'b');
    format First_Day_Of_Current_Month date9.;  /* Format as date */
    
    /* Last day of the current month */
    Last_Day_Of_Current_Month = intnx('month', today(), 0, 'e');
    format Last_Day_Of_Current_Month date9.;  /* Format as date */
    
    /* nth day of the current month (e.g., 10th day) */
    Nth_Day_Of_Current_Month = intnx('day', First_Day_Of_Month, 9);  /* 10th day, as 9 days after the first day */
    format Nth_Day_Of_Current_Month date9.;  /* Format as date */
           	
   	/* First day of the last month */
    First_Day_Of_Last_Month = intnx('month', today(), -1, 'b');
    format First_Day_Of_Last_Month date9.;  /* Format as date */
    
    /* Last day of the last month */
    Last_Day_Of_Last_Month = intnx('month', today(), -1, 'e');
    format Last_Day_Of_Last_Month date9.;  /* Format as date */
    
    /* nth day of the last month (e.g., 10th day) */
    Nth_Day_Of_Last_Month = intnx('day', First_Day_Of_Last_Month, 9);  /* 10th day, as 9 days after the first day */
    format Nth_Day_Of_Last_Month date9.;  /* Format as date */
   	
run;

proc print data=floor_manager;
run;

data date_formats;
    /* Set the current date using TODAY() function */
    Current_Date = today();
    
    /* Apply various date formats and create columns with corresponding names */
    format 
    	DATETIME DATETIME.
        DATE7 DATE7.
        DATE9 DATE9.
        MMDDYY8 MMDDYY8.
        MMDDYY10 MMDDYY10.
        DDMMYY8 DDMMYY8.
        DDMMYY10 DDMMYY10.
        YYMMDD8 YYMMDD8.
        YYMMDD10 YYMMDD10.
        MONYY7 MONYY7.
        WORDDATE WORDDATE.
        JULIAN JULIAN.
        WEEKDATE WEEKDATE.;

    /* Create individual columns for each format */
    DATETIME = Current_Date;    
    Date7 = Current_Date;
    Date9 = Current_Date;
    MMDDYY8 = Current_Date;
    MMDDYY10 = Current_Date;
    DDMMYY8 = Current_Date;
    DDMMYY10 = Current_Date;
    YYMMDD8 = Current_Date;
    YYMMDD10 = Current_Date;
    MONYY7 = Current_Date;
    WORDDATE = Current_Date;
    JULIAN = Current_Date;
    WEEKDATE = Current_Date;
    
run;

proc print data=date_formats;
run;



/** FORMAT INFORMAT **/
data fertility;
   input First_Name $ Last_Name $ Age Height Date_of_Birth :DATE9.;
   informat Date_of_Birth DATE9.;  /* Read date as DATE9. */
   format Date_of_Birth ddmmyy10.; /* Format the date as dd/mm/yyyy */
   label First_Name = 'First Name' Last_Name = 'Last Name';  /* Add labels with spaces */
   datalines;
John Cina 25 5.9 15MAR1996
Jane Due 30 5.5 22SEP1990
;
run;

proc print data=fertility label;
run;



/** Concatenation **/
data fertility;
   set fertility;  /* Read data from the existing 'fertility' dataset */
   
   /* Concatenate First_Name and Last_Name into Full_Name */
   Full_Name = catx(' ', First_Name, Last_Name);  /* Concatenate with a space */
   label Full_Name = 'Full Name';  /* Label the new variable */

run;

proc print data=fertility; /* Ensure labels are used in the output */
run;



/** Sort a dataset **/

/* Sorting the dataset by the Stock variable */
title "One Column Sorting";
proc sort data=products;
    by Stock;  /* Sorting by 'Stock' in ascending order */
run;
/* Printing the sorted dataset */
proc print data=products;
run;


/* Sorting the dataset by Stock in descending order */
title "Multiple Column Sorting";
proc sort data=products;
    by Price descending Stock;  /* Sorting 'Price' in ascending order and 'Stock' in descending order*/
run;
/* Printing the sorted dataset */
proc print data=products;
run;


/* Sorting the dataset by Stock in descending order and save as sorted_data in work library */
proc sort data=products OUT=sorted_data;
    by Price descending Stock;  /* Sorting 'Price' in ascending order and 'Stock' in descending order*/
run;
/* Printing the sorted dataset */
proc print data=products;
run;


/* Sorting the dataset by Stock in descending order and save as sorted_data_prodcts in customized library */
proc sort data=products OUT=SBASAK.sorted_data_prodcts;
    by Price descending Stock;  /* Sorting 'Price' in ascending order and 'Stock' in descending order*/
run;
/* Printing the sorted dataset */
proc print data=products;
run;



/** Subsetting Data with the WHERE Statement **/
/* Subsetting data using WHERE in PROC PRINT */
proc print data=products;
    where Stock > 50;  /* Only display products with stock greater than 50 */
run;

/* Subsetting data using WHERE in DATA step */
data filtered_products;
    set products;
    where Stock > 50;  /* Keep only products with stock greater than 50 */
run;

proc print data=filtered_products;
run;



/** Subsetting Data with the IF Statement **/
/* Subsetting data using IF in DATA step */
data cheap_products;
    set products;
    if Price < 500 then quality = 'cheap';  /* Keep only products with price less than 500 */
run;

proc print data=cheap_products;
run;



/** Using both WHERE and IF for complex subsetting **/
data complex_filtered_products;
    set products;
    where Stock > 50;  /* First, keep products where Stock > 50 */
    if Price < 400;    /* Then, among them, only keep products where Price < 500 */
run;

proc print data=complex_filtered_products;
run;



/** Customizing Output **/

/* NOOBS statement (Row Index will not come in output) */
proc print data=products noobs;
run;

/* VAR statement (Name of the variables or columns you want to print) */
proc print data=products;
var  ProductName	Price	Stock;
run;


/* keep statement (selects specific variables to retain in the dataset) */
DATA products_keep;
    SET products;
    KEEP productname price;
RUN;

proc print data=products_keep;
run;


/* drop statement (removes specific variables from the dataset) */
DATA products_drop;
    SET products;
    DROP Stock;
RUN;

proc print data=products_drop;
run;



/** Export Data into csv, xlsx, txt format **/
proc export data=fertility
    outfile="~/fertility.csv"
    dbms=csv replace;
run;

proc export data=products
    outfile="~/products.xlsx"
    dbms=xlsx replace;
run;

proc export data=products
    outfile="~/products.txt"
    dbms=dlm replace;
    delimiter='|';  /* Use '|' as delimiter */
run;



/** save data in customized library**/

proc datasets lib=sbasak; /* Check datasets available in the library */
run;

data sbasak.products; /* save products data in sbasak library */
    set products;
run;

proc copy in=work out=sbasak; /* save multiple data in sbasak library */
    select products fertility employees;
run;



/** Import Data into csv, xlsx, txt format **/
/* ✔ Step 1: Upload your file using the Server Files and Folders panel. */
/* ✔ Step 2: Use PROC IMPORT for CSV, Excel, or TXT files. */
/* ✔ Step 3: Save the dataset in sbasak for permanent storage. */

proc import datafile="~/products.xlsx"
    out=sbasak.imported_products
    dbms=xlsx
    replace;
run;

proc import datafile="~/napolean-battles.csv"
    out=sbasak.napolean_battles
    dbms=csv
    replace;
    guessingrows=max;
run;

proc import datafile="~/products.txt"
    out=sbasak.imported_products_txt
    dbms=dlm
    replace;
    delimiter='|';  /* Change based on your delimiter: ',' or '\t' for tab */
    guessingrows=max;
run;