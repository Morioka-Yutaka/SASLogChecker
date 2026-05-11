/* SASLogChecker — line-prefix categorization
 *
 * Source: SASLogChecker/06_macros/interact_logchk.sas (lines 69-76) and
 * the parallel block in logchk2directory.sas (lines 139-142). Both
 * macros do the same first pass on every log record: strip CR/LF/FF
 * from each line, look at its leading characters, and assign a
 * Category of ERROR, WARNING, NOTE, INFO, or (implicit) blank when
 * the line is informational chatter.
 *
 * This bundle takes a small sample of realistic SAS log content,
 * runs only the categorization step, and prints the per-line result.
 * Real macro use case: feeding the cate column into the per-category
 * summary (t005) and into the subsetting-if that keeps only matched
 * rows (t003 / the original macro's body).
 */

data raw_log;
length record $400.;
infile datalines truncover;
input record $char400.;
datalines4;
NOTE: Variable Y is uninitialized.
NOTE: Missing values were generated as a result of performing an operation on missing values.
NOTE: DATA statement used (Total process time):
NOTE: There were 5 observations read from the data set WORK.A.
ERROR: File WORK.MYDATA.DATA does not exist.
WARNING: Division by zero detected at line 5 column 8.
INFO: The variable y on data set WORK.X will be overwritten by data set WORK.Y.
1                                                          The SAS System
NOTE: SAS went to a new line when INPUT statement reached past the end of a line.
NOTE: PROCEDURE SORT used (Total process time):
;;;;
run;

/* Mirror the macro's CR/LF compress + prefix-based categorize */
data classified;
length record $400. _record $400. cate $10.;
set raw_log;
_record = strip(record);
_record = compress(_record, '0A'X || '0D'X || '0C'X);
cate = '';
if substr(_record, 1, 5) = 'ERROR'   then cate = 'ERROR';
if substr(_record, 1, 7) = 'WARNING' then cate = 'WARNING';
if substr(_record, 1, 4) = 'NOTE'    then cate = 'NOTE';
if substr(_record, 1, 5) = 'INFO:'   then cate = 'INFO';
label record = 'Log line' cate = 'Category';
keep record cate;
run;

proc print data=classified noobs label;
title "interact_logchk-style prefix categorization";
run;

proc freq data=classified;
tables cate / nocum nopercent missing;
title "Category counts (incl. uncategorized chatter lines)";
run;
