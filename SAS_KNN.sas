
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


/* K-Means Clustering using PROC FASTCLUS */
proc fastclus data=mydata maxclusters=2;
    var Age Salary Experience; /* Variables to use for clustering */
run;





