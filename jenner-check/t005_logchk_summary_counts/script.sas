/* SASLogChecker — per-category summary counts
 *
 * Source: SASLogChecker/06_macros/interact_logchk.sas (lines 232-243).
 * After the per-line scan, the macro counts how many flagged rows fall
 * into each category and tucks the result into four macro variables
 * (__obs_e, __obs_w, __obs_n, __obs_i). Those numbers feed the SAS
 * GUI's confirmation popup:
 *
 *     dm 'post "ERROR:[&__obs_e.]  WARNING:[&__obs_w.]  NOTE:[&__obs_n.]"';
 *
 * The popup itself is a Windows-GUI artifact (`dm` command), so this
 * bundle builds the popup *content* in pure SAS: PROC SQL INTO :var
 * for the counts, then %PUT to surface them to the log, and PROC FREQ
 * for a tabular cross-check.
 */

data flagged;
length cate $10. record $400.;
infile datalines truncover dsd dlm='|';
input cate $ record $;
datalines4;
ERROR|File WORK.MYDATA.DATA does not exist.
ERROR|File WORK.LOOKUP.DATA does not exist.
ERROR|_ERROR_=1
WARNING|Division by zero detected at line 5 column 8.
WARNING|Apparent invocation of macro XYZ not resolved.
NOTE|Variable Y is uninitialized.
NOTE|Missing values were generated.
NOTE|Character values have been converted to numeric values.
NOTE|Numeric values have been converted to character values.
NOTE|SAS went to a new line when INPUT statement reached past the end of a line.
INFO|The variable y on data set WORK.X will be overwritten by data set WORK.Y.
;;;;
run;

/* PROC SQL INTO — the exact form the macro uses */
proc sql noprint;
select count(*) into :__obs   trimmed from flagged;
select count(*) into :__obs_e trimmed from flagged where cate = 'ERROR';
select count(*) into :__obs_w trimmed from flagged where cate = 'WARNING';
select count(*) into :__obs_n trimmed from flagged where cate = 'NOTE';
select count(*) into :__obs_i trimmed from flagged where cate = 'INFO';
quit;

%put NOTE: SASLogChecker summary --;
%put NOTE: Total flagged rows : &__obs;
%put NOTE: ERROR   count       : &__obs_e;
%put NOTE: WARNING count       : &__obs_w;
%put NOTE: NOTE    count       : &__obs_n;
%put NOTE: INFO    count       : &__obs_i;

/* What the `dm post` popup would display */
%put NOTE: dm-post message would be: ERROR:[&__obs_e.]  WARNING:[&__obs_w.]  NOTE:[&__obs_n.];

/* PROC FREQ cross-check */
proc freq data=flagged;
tables cate / nocum;
title "interact_logchk: per-category counts";
run;

/* Per-category sample listing — what `dm "viewtable __log"` would show */
proc print data=flagged noobs label;
title "Flagged log rows";
label cate="Category" record="Text";
run;
