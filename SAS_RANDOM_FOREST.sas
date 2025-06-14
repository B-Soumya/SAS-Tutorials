
data mydata;
    input Age Salary Education $ Experience Gender $ Target;
    datalines;
    25 50000 Bachelor 2 Male 0
    30 60000 Master 5 Female 1
    35 70000 PhD 10 Male 0
    40 80000 Bachelor 12 Female 1
    45 90000 Master 15 Male 1
    50 100000 PhD 20 Female 0
    55 110000 Bachelor 25 Male 0
    60 120000 Master 30 Female 1
    ;
run;

/* Random Forest using PROC HPFOREST */
proc hpforest data=mydata;
    input Age Salary Experience; /* Numeric inputs */
    target Target; /* Dependent variable */
run;


/* Step 1: Create Train-Test Split */
data mydata_split;
    set mydata;
    /* Generate a random number between 0 and 1 */
    rand = ranuni(123);  /* 123 is the seed for reproducibility */
    
    /* Assign 70% to training and 30% to testing */
    if rand <= 0.7 then train_test = 'Train';
    else train_test = 'Test';
run;

/* Check the split (just to confirm) */
proc freq data=mydata_split;
    tables train_test;
run;

/* Step 2: Train a Random Forest using Training Data */
proc hpforest data=mydata_split;
    where train_test = 'Train';  /* Only use the training data */
    input Age Salary Experience; /* Numeric inputs */
    target Target; /* Dependent variable */
run;

/* Step 3: Test the Model on the Test Data */
proc hpforest data=mydata_split;
    where train_test = 'Test';  /* Only use the test data */
    input Age Salary Experience;
    target Target;
    score out=predictions;  /* Output predictions */
run;

/* Step 4: Evaluate the Model's Performance */
proc freq data=predictions;
    tables Target*P_Target / chisq;  /* Confusion matrix */
run;

proc print data=predictions;
run;



