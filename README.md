# SASLogChecker
SAS log checker for extracting ERRORs, WARNINGs, and notable NOTEs — supports interactive and directory-wide runs.

![SASLogChecker](./SASLogChecker_small.png)  

# SASLogChecker

data a;
length x 8.;
run;

data b;
set a;
c= 10/0;
keep y;
run;

%logchk;

