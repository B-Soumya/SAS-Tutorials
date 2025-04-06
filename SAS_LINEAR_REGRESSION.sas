data mydata;
    input age income education_level purchased;
    datalines;
22 35000 1 0
25 40000 2 0
30 60000 3 1
35 58000 2 1
40 62000 3 1
45 80000 4 1
23 37000 1 0
32 54000 2 1
29 50000 2 1
41 72000 3 1
27 45000 1 0
36 64000 3 1
50 85000 4 1
21 30000 1 0
28 48000 2 0
;
run;

proc print data=mydata; run;



/** Multiple Linear Regression (NON ML APPROACH) **/

/* Predicting income using age and education_level */
proc reg data=mydata;
    model income = age education_level;
    title "Multiple Linear Regression: Predicting Income from Age and Education";
run;
quit;

/* Scatter Plot with Regression Line (Income vs Age) */
proc sgplot data=mydata;
    reg x=age y=income / lineattrs=(color=blue thickness=2);
    title "Scatter Plot with Regression Line: Income vs Age";
run;

/* Correlation Matrix (to inspect variable relationships) */
proc corr data=mydata;
    var age income education_level;
    title "Correlation Matrix";
run;




/** Multiple Linear Regression (ML APPROACH) **/


/* Step 1: Split Data into Training and Testing Sets (70/30 Split) */
proc surveyselect data=mydata out=split_data seed=1234
    samprate=0.7 outall;
run;

data train test;
    set split_data;
    if selected then output train;
    else output test;
run;

proc print data=train (obs=5); title "Training Data (First 5 Rows)"; run;
proc print data=test (obs=5); title "Testing Data (First 5 Rows)"; run;


/* Step 2: Train on train dataset: */
proc reg data=train outest=reg_estimates;
    model income = age education_level;
    title "Training: Multiple Linear Regression on Train Data";
run;
quit;


/* Step 3: Predict on test data */
proc score data=test score=reg_estimates out=linear_predicted type=parms;
    var age education_level;
run;

proc print data=linear_predicted (obs=5);
    title "Linear Regression Predictions on Test Data";
run;


/* Step 4: Model evaluation */
data linear_predicted;
    set linear_predicted;
    predicted_income = MODEL1;
run;

data linear_eval;
    set linear_predicted;
    error = income - predicted_income;
    abs_error = abs(error);
    squared_error = error ** 2;
run;

proc means data=linear_eval mean;
    var abs_error squared_error;
    output out=eval_metrics mean=mae mse;
run;

proc sql;
    select 
        sum((income - predicted_income)**2) as ss_residual,
        sum((income - avg_income)**2) as ss_total
    into :ssr, :sst
    from (
        select *, (select mean(income) from linear_predicted) as avg_income
        from linear_predicted
    );
quit;

%let r_squared = %sysevalf(1 - (&ssr / &sst));

data final_metrics;
    set eval_metrics;
    rmse = sqrt(mse);
    r_squared = &r_squared;
    keep mae mse rmse r_squared;
run;






