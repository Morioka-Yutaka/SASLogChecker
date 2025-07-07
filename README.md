# SASLogChecker
SAS log checker for extracting ERRORs, WARNINGs, and notable NOTEs — supports interactive and directory-wide runs.

![SASLogChecker](./SASLogChecker_small.png)  


# SASLogChecker

~~~sas  
data a;
length x 8.;
run;

data b;
set a;
c= 10/0;
keep y;
run;
~~~

Submit, logchk;
~~~sas  
%logchk;
~~~
<img width="209" height="116" alt="Image" src="https://github.com/user-attachments/assets/e9bef2c0-4626-4656-8d98-8f358a7774a9" />
