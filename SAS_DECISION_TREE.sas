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
    26 52000 Bachelor 3 Male 0
    31 62000 Master 6 Female 1
    36 73000 PhD 11 Male 0
    41 83000 Bachelor 13 Female 1
    46 95000 Master 16 Male 1
    51 105000 PhD 21 Female 0
    56 115000 Bachelor 26 Male 0
    61 125000 Master 31 Female 1
    27 54000 Bachelor 4 Male 0
    32 64000 Master 7 Female 1
    37 74000 PhD 12 Male 0
    42 84000 Bachelor 14 Female 1
    47 97000 Master 17 Male 1
    52 106000 PhD 22 Female 0
    57 116000 Bachelor 27 Male 0
    62 126000 Master 32 Female 1
    28 56000 Bachelor 5 Male 0
    33 66000 Master 8 Female 1
    38 75000 PhD 13 Male 0
    43 85000 Bachelor 16 Female 1
    48 98000 Master 18 Male 1
    53 107000 PhD 23 Female 0
    58 117000 Bachelor 28 Male 0
    63 127000 Master 33 Female 1
    ;
run;



proc hpsplit data=mydata;
    target Target; /* Dependent variable */
    input Age Salary Experience Gender Education; /* Independent variables */
    partition fraction(validate=0.3); /* 70% training and 30% validation */
run;


/* Split the data into training and validation sets */
proc surveyselect data=mydata out=train_data samprate=0.7 outall; /* The above line keeps 70% of the data in the training set */
run;

/* Create a test dataset for the remaining 30% */
data test_data;
    set train_data;
    if selected = 0; /* 0 means test data, as `selected` variable is 1 for training data */
run;

/* Train dataset */
data train_data;
    set train_data;
    if selected = 1; /* 1 means training data */
run;

/* Building Decision tree on training data */
proc hpsplit data=train_data;
    target Target;
    input Age Salary Experience Gender Education;   
    output out=model_output; /* Save model output */
run;

/* Scoring the test dataset using the trained model */
proc hpsplit data=test_data;
    target Target;
    input Age Salary Experience Gender Education;
run;

proc print data=test_data;
run;













