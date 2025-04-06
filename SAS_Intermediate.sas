/*
1. Handling missing values	(IF ... THEN, PROC MEANS, PROC FREQ)
2. Removing duplicates	(PROC SORT NODUPKEY/NODUP)
3. Handling outliers (PROC UNIVARIATE, IF conditions)
4. Standardizing data (UPCASE, LOWCASE, PROPCASE)
5. PROC FORMAT for data labeling
6. Data Aggregation & Summarization:
		PROC MEANS/ PROC SUMMARY for descriptive statistics
		PROC FREQ for frequency tables
		PROC UNIVARIATE for distribution analysis
7. Rank and Dense Rank Dataset using proc rank
8. Merging Dataset
*/


/* Create Dataset */
DATA students;
    INPUT Name $ Age Marks Subject $4.;
    DATALINES;
    John 18 85 Math
    Alice 19 90 Stat
    Bob . 78 Eco
    Alice 19 90 Stat
    Tom 18 . Eco
    shyam 17 87 
    Johny 18 110 Stat 
    ;
RUN;

PROC PRINT DATA=students;
RUN;



/** Replacing Missing Values with constant value **/
DATA students_cleaned;
    SET students;
    IF Age = . THEN Age = 18;  /* Replacing missing Age with 18 */
    IF Marks = . THEN Marks = 60; /* Replacing missing Marks with 60 */
    IF Subject = '' THEN Subject = 'Eco';
RUN;

PROC PRINT DATA=students_cleaned;
RUN;



/** Replacing Missing Values with mean, median, mode **/
/* Step 1: Calculate Mean and Median for Numeric Variables */
PROC MEANS DATA=students NOPRINT;
    VAR Age Marks;
    OUTPUT OUT=stats MEAN=mean_Age mean_Marks MEDIAN=median_Age median_Marks;
RUN;

/* Step 2: Find Mode for Categorical Variables */
PROC FREQ DATA=students ORDER=FREQ;
    TABLES Subject / OUT=mode_table;
RUN;

/* Step 3: Sort mode_table by Frequency */
PROC SORT DATA=mode_table;
    BY DESCENDING COUNT;
RUN;

/* Step 4: Replace Missing Values */
DATA students_filled;
    SET students;
    
    /* Merge Mean & Median Values */
    IF _N_ = 1 THEN SET stats;
    
    /* Replace Missing Numeric Values */
    IF Age = . THEN Age = median_Age; /* Replacing with Median */
    IF Marks = . THEN Marks = mean_Marks; /* Replacing with Mean */

    /* Replace Missing Categorical Values with Mode */
    IF Subject = '' THEN DO;
        SET mode_table(OBS=1 KEEP=Subject RENAME=(Subject=mode_Subject)); 
        Subject = mode_Subject;
    END;
RUN;

/* Print the Final Cleaned Data */
PROC PRINT DATA=students_filled;
RUN;



/* Removing Duplicate Records */
PROC SORT DATA=students_cleaned NODUPKEY OUT=students_nodup;
    BY Name Age Marks;
RUN;

PROC PRINT DATA=students_nodup;
RUN;



/*  Detecting Outliers in Marks */
PROC UNIVARIATE DATA=students_cleaned;
    VAR Marks;
    HISTOGRAM Marks;
RUN;

DATA students_outlier;
    SET students;
    IF Marks > 100 THEN Marks = 100; /* Capping extreme values */
RUN;

proc print data = students_outlier;
run;



/** Standardizing data **/
DATA students_standard;
    SET students_cleaned;
    upper_name = UPCASE(Name); /* Converts names to uppercase */
    lower_name = LOWCASE(Name); /* Converts names to uppercase */
    prop_name = PROPCASE(Name); /* Converts names to uppercase */
RUN;

PROC PRINT DATA=students_standard;
RUN;



/** PROC FORMAT for labelling **/
/* Step 1: Define Format for Marks */
PROC FORMAT;
    VALUE marks_fmt
        80 - HIGH = 'Excellent'
        60 -< 80 = 'Good'
        40 -< 60 = 'Average'
        LOW -< 40 = 'Fail';
RUN;

/* Step 2: Apply Format in a New Dataset */
DATA students_formatted;
    SET students_cleaned;
    Marks_Label = PUT(Marks, marks_fmt.); /* Apply Format */
RUN;

/* Step 3: Print Data with Formatted Marks */
PROC PRINT DATA=students_formatted LABEL;
    LABEL Marks_Label = 'Performance';
RUN;



/** aggregation based on category **/
proc sort data=students_formatted;
by Subject;
run;

proc print data=students_formatted;
run;

proc print data=students_formatted;
by Subject;
sum Marks;
run;

proc print data=students_formatted;
by Subject;
pageby Subject;
sum Marks;
run;



/** PROC MEANS/PROC SUMMARY for descriptive statistics **/
proc means data=students_formatted;
run;

proc means data=students n nmiss mean median std var min max sum range;
run;

proc means data=students_formatted n mean std min max sum;
    class Subject; /* Groups results by Subject */
run;

proc means data=students_formatted n mean std min max sum;
    var Marks;
    output out=summary_results mean=Avg_Marks sum=Total_Marks;
run;

proc print data=summary_results;  /* Display the stored summary */
run;


proc summary data=students_formatted;
    var Marks;
    output out=summary_results n= mean= std= min= max= sum= range=/ autoname;
run;

proc print data=summary_results; /* Print the stored summary */
run;

/* class & by for groupwise split */
proc means data=students_formatted n mean std min max sum;
    class Subject;
run;

proc means data=students_formatted n mean std min max sum;
    by Subject;
run;

/* weighted average */
proc means data=students_formatted mean;
    var Marks;
    weight Marks;
run;



/** PROC FREQ for frequency analysis **/

/* Basic Frequency Table (Displays counts & percentages for each unique value in Subject) */
proc freq data=students_formatted;
    tables Subject;
run;

/* Frequency Table with Percentages (NOCUM removes cumulative percentages) */
proc freq data=students_formatted;
    tables Subject / nocum;
run;

/* Two-Way Frequency Table (Displays crosstabulation or contingency table) */
proc freq data=students_formatted;
    tables Subject * marks_label;
run;

/* Chi-Square Test for Independence */
proc freq data=students_formatted;
    tables Subject * marks_label / chisq;
run;

/* Adding Row & Column Percentages (NOROW, NOCOL, NOPERCENT remove unwanted percentages) */
proc freq data=students_formatted;
    tables Subject * marks_label / norow nocol nopercent;
run;

/* Output Results to a Dataset */
proc freq data=students_formatted;
    tables Subject / out=freq_results;
run;

proc print data=freq_results;
run;



/** PROC UNIVARIATE for distribution analysis **/

/* Basic Summary Statistics */
PROC UNIVARIATE DATA=students_formatted; /* work for both students and students_formatted */
    VAR Age Marks;
RUN;

/* Identify Outliers with ID */
PROC UNIVARIATE DATA=students;
    VAR Marks;
    ID Name;
RUN;

/* Normality Tests (Shapiro-Wilk, Kolmogorov-Smirnov, Anderson-Darling) */
PROC UNIVARIATE DATA=students NORMAL;
    VAR Marks;
RUN;

/* add plots */
ODS GRAPHICS ON;
PROC UNIVARIATE DATA=students PLOT;
    VAR Marks;
    ID Name;
RUN;
ODS GRAPHICS OFF;

/* Overlay Histogram with Normal Curve */
PROC UNIVARIATE DATA=students;
    VAR Marks;
    HISTOGRAM / NORMAL;
RUN;

/* Trimmed Mean and Winsorized Mean */
/* Removes extreme 10% of values before calculating mean (trimmed) */
/* Replaces extreme values with nearest 10th percentile value (winsorized) */
PROC UNIVARIATE DATA=students TRIM=0.1 WINSOR=0.1;
    VAR Marks;
RUN;

/* Groupwise Statistics using BY Statement */
PROC SORT DATA=students_cleaned;
    BY Subject;
RUN;

PROC UNIVARIATE DATA=students_cleaned;
    BY Subject;
    VAR Marks;
RUN;

/* Export Specific Output (Mean, Median, etc.) */
PROC UNIVARIATE DATA=students NOPRINT;
    VAR Marks;
    OUTPUT OUT=marks_summary
        MEAN=mean_marks
        MEDIAN=median_marks
        STD=std_marks
        N=n_obs
        NMISS=n_missing;
RUN;

PROC PRINT DATA=marks_summary;
RUN;

/* ODS Output Tables */
ODS TRACE ON;
PROC UNIVARIATE DATA=students;
    VAR Marks;
RUN;
ODS TRACE OFF;

ODS OUTPUT Moments=moments_table;

/* visualize any specific plot */
PROC UNIVARIATE DATA=students;
    VAR Marks;
    HISTOGRAM / NORMAL LOGNORMAL EXPONENTIAL MIDPOINTS=70 TO 120 BY 10;
    INSET MEAN MEDIAN STD / POS=NE;
RUN;

/* Check Skewness and Kurtosis Only */
ODS SELECT Moments;
PROC UNIVARIATE DATA=students;
    VAR Marks;
RUN;



/* rank and dense rank using proc rank */
proc sort data=students_cleaned;
    by subject descending marks;
run;

/* rank */
proc rank data=students_cleaned out=ranked_marks ties=low;
    var marks;
    ranks spend_rank;
run;

/* dense rank */
proc rank data=students_cleaned out=dense_ranked_marks ties=dense;
    var marks;
    ranks spend_dense_rank;
run;

proc rank data=students_cleaned out=dense_ranked_marks ties=dense;
	by subject;
    var marks;
    ranks spend_dense_rank;
run;



/** merge datasets **/

/* create bank customers data */
data bank_customers;
    input customer_id $ name $ age gender $;
    datalines;
C001 Alice 34 F
C002 Bob 45 M
C003 Charlie 29 M
C004 Diana 40 F
;
run;

/* create bank customer's credit usage data */
data credit_usage;
    input customer_id $ month $ credit_limit amount_spent;
    datalines;
C001 Jan 5000 3200
C002 Jan 7000 6900
C003 Jan 4000 4100
C005 Jan 6000 3500
;
run;

/* Step 1: Sort both datasets by customer_id */
proc sort data=bank_customers; by customer_id; run;
proc sort data=credit_usage; by customer_id; run;

/* Step 2: Merge using DATA step (Full Join-style) */
data merged_full;
    merge bank_customers(in=a) credit_usage(in=b);
    by customer_id;
run;

proc print data = merged_full;
run;

