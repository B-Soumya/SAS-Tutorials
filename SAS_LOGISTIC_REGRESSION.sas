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


/** Multiple Logistic Regression (NON ML APPROACH) **/

/* Predicting purchased using age, income, and education_level */
proc logistic data=mydata;
    model purchased(event='1') = age income education_level;
    title "Multiple Logistic Regression: Predicting Purchase";
run;

/* Predict Probabilities and Save Results */
proc logistic data=mydata;
    model purchased(event='1') = age income education_level;
    output out=predicted p=prob;
    title "Logistic Regression: Predicting Purchase";
run;

/* Plot Predicted Probabilities vs Age */
proc sgplot data=predicted;
    scatter x=age y=prob / markerattrs=(symbol=circle color=blue);
    series x=age y=prob / lineattrs=(color=red thickness=2);
    title "Predicted Probability of Purchase vs Age";
run;

/* Confusion Matrix Using PROC FREQ */
data classified;
    set predicted;
    predicted_label = (prob >= 0.5);
run;

proc freq data=classified;
    tables purchased*predicted_label / norow nocol nopercent;
    title "Confusion Matrix: Actual vs Predicted";
run;





/** Multiple Logistic Regression (ML APPROACH) **/


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


/* Step 2: Train Model and Save Scoring Equation */
proc logistic data=train;
    model purchased(event='1') = age income education_level;
    output out=logistic_pred_test p=pred_prob;
    title "Logistic Regression: Train on Training Data and Predict on Test Data";
run;


/* Step 3: Use PROC LOGISTIC + SCORE on test data */
proc logistic data=train;
    model purchased(event='1') = age income education_level;
    score data=test out=logistic_scored outroc=rocdata;
    title "Logistic Regression Scoring on Test Set";
run;


/* Step 4: Build Confusion Matrix Using P_1 */
data logistic_result;
    set logistic_scored;
    predicted_label = (P_1 >= 0.5);
run;

proc freq data=logistic_result noprint;
    tables purchased*predicted_label / out=confusion_matrix;
run;

proc print data=confusion_matrix;
    title "Confusion Matrix Table";
run;


/* Step 5: Calculate Accuracy, Precision, Recall, F1Score */
/* Step 5.1: Initialize all counts to 0 */
data metrics_prep;
    length label $2;
    retain TP FP TN FN 0;

    /* Manually read the confusion matrix into metrics */
    set confusion_matrix;

    if purchased=1 and predicted_label=1 then TP = count;
    else if purchased=0 and predicted_label=1 then FP = count;
    else if purchased=0 and predicted_label=0 then TN = count;
    else if purchased=1 and predicted_label=0 then FN = count;

    keep TP FP TN FN;
run;

/* Step 5.2: Combine into one row */
proc sql;
    create table metrics as
    select 
        sum(TP) as TP,
        sum(FP) as FP,
        sum(TN) as TN,
        sum(FN) as FN
    from metrics_prep;
quit;

/* Step 5.3: Compute metrics */
data metrics_final;
    set metrics;
    total = TP + TN + FP + FN;

    accuracy = (TP + TN) / total;
    precision = (TP / (TP + FP));
    recall = (TP / (TP + FN));
    f1_score = 2 * (precision * recall) / (precision + recall);
run;

/* Step 5.4: Display metrics */
proc print data=metrics_final label noobs;
    var TP FP TN FN accuracy precision recall f1_score;
    label
        TP = "True Positives"
        FP = "False Positives"
        TN = "True Negatives"
        FN = "False Negatives"
        accuracy = "Accuracy"
        precision = "Precision"
        recall = "Recall"
        f1_score = "F1 Score";
    title "Classification Metrics Based on Confusion Matrix";
run;


/* Step 6: Add ROC Curve and AUC */
proc logistic data=train plots=roc;
    model purchased(event='1') = age income education_level;
    score data=test out=scored outroc=rocdata;
    title "Area under the curve (AUC) for Logistic Regression on Test Data";
run;

proc sgplot data=rocdata;
    series x=_1mspec_ y=_sensit_;
    lineparm x=0 y=0 slope=1 / lineattrs=(pattern=shortdash color=gray);
    title "ROC Curve (Sensitivity vs 1 - Specificity)";
run;









