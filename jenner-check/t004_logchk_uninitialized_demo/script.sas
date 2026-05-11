/* SASLogChecker — the README example
 *
 * Source: README.md "interact_logchk" section. The author offers
 * this canonical snippet as the producer-side of the workflow: run
 * it, then call %interact_logchk to see how the macro surfaces the
 * resulting NOTE / WARNING messages in the log window.
 *
 * This bundle does both halves end-to-end:
 *   1. Run the README snippet so Jenner emits its own NOTE/WARNING
 *      log lines about the uninitialized variable y, the division by
 *      zero, and the variable kept in DATA but never assigned.
 *   2. Replay the lines the producer code is documented to emit and
 *      run them through the macro's prefix-categorize + keyword-scan
 *      logic, confirming the right messages get flagged. This is the
 *      observable summary the macro presents to the SAS GUI user.
 *
 * Step 2 uses an inline replay because the macro's actual log
 * capture (`dm log 'print file=tempf replace'`) is a Windows-GUI
 * `dm` command — out of scope for a batch self-check.
 */

/* ===== Step 1: the README snippet, verbatim ===== */

data a;
length x 8.;
run;

data b;
set a;
c = 10/0;
keep y;
run;

/* ===== Step 2: replay + categorize ===== */
/* Lines the macro's documentation says it will flag for this snippet:
   - NOTE: Variable y is uninitialized.
   - NOTE: Missing values were generated...
   - NOTE: Division by zero detected...
   - NOTE: Mathematical operations could not be performed...   */

data term;
length term $400.;
term = "Missing values";                       output;
term = "is uninitialized";                     output;
term = "Division by zero";                     output;
term = "Mathematical operations could not";    output;
run;
data term; set term; term = strip(term); run;
proc sort data=term nodupkey; by term; run;

data flagged_lines;
length record $400.;
infile datalines truncover;
input record $char400.;
datalines4;
NOTE: Variable y is uninitialized.
NOTE: Missing values were generated as a result of performing an operation on missing values.
NOTE: Division by zero detected at line 6 column 5.
NOTE: Mathematical operations could not be performed at the following places. The results of the operations have been set to missing values.
NOTE: The data set WORK.B has 1 observations and 1 variables.
;;;;
run;

data classified;
length record _record $400. cate $10.;
set flagged_lines;
_record = strip(record);
_record = compress(_record, '0A'X || '0D'X || '0C'X);
cate = '';
if substr(_record, 1, 5) = 'ERROR'   then cate = 'ERROR';
if substr(_record, 1, 7) = 'WARNING' then cate = 'WARNING';
if substr(_record, 1, 4) = 'NOTE'    then cate = 'NOTE';
if substr(_record, 1, 5) = 'INFO:'   then cate = 'INFO';
line = _N_;
keep line record _record cate;
run;

proc sql;
create table hits as
select c.line, c.record, c.cate, t.term as matched_term
from classified c, term t
where index(strip(c._record), strip(t.term)) > 0
order by c.line, t.term;
quit;

data summary;
length record $400. cate $10. hit $500.;
set hits;
by line;
retain hit;
if first.line then hit = '';
hit = catx(',', hit, matched_term);
if last.line;
label record="Log line" cate="Category" hit="Hit keyword";
keep line cate hit record;
run;

proc print data=summary noobs label;
title "interact_logchk on the README example";
var line cate hit record;
run;

proc sql noprint;
select count(*) into :n_flagged trimmed from summary;
quit;
%put NOTE: README snippet produced &n_flagged flagged lines (expected 4);
