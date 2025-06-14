/*
Macro functions (to manipulate text and variables)
Loops (to repeat actions dynamically)
Code generation techniques (to write SAS code on-the-fly)
*/


/** Macro Functions **/
%let var = Revenue;

%put %upcase(&var);     * Output: REVENUE;
%put %substr(&var, 1, 3); * Output: Rev;
%put %length(&var);       * Output: 7;



/** Macro Loops **/

/* Syntax */
%macro loop;
  %do i = 1 %to 5;
    %put Iteration: &i;
  %end;
%mend;

%loop

/* Loop with Parameters */
%macro loop_years(start, end);
  %do year = &start %to &end;
    %put Processing year: &year;
  %end;
%mend;

%loop_years(2020, 2025)



/** Dynamic Code Generation **/
%macro freq_loop(varlist);
  %let n = %sysfunc(countw(&varlist));

  %do i = 1 %to &n;
    %let var = %scan(&varlist, &i);

    proc freq data=sashelp.class;
      tables &var;
    run;

  %end;
%mend;

%freq_loop(name sex age)



/* Nested Macros & Variable Indirection */
%let var1 = age;
%let var2 = height;
%let var3 = weight;

%macro loop_vars;
  %do i = 1 %to 3;
    %put Variable &i is &&var&i;
  %end;
%mend;

%loop_vars



/** Conditional Processing **/
%macro print_condition(num);
  %if &num > 0 %then %put Positive;
  %else %if &num = 0 %then %put Zero;
  %else %put Negative;
%mend;

%print_condition(-5)
