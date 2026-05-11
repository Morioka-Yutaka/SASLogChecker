/* SASLogChecker — keyword scan against the dictionary
 *
 * Source: SASLogChecker/06_macros/logchk2directory.sas (lines 124-157).
 * The macro joins each log record against the term dictionary and
 * collects every keyword that appears as a substring of the record,
 * producing one row per matched record with a comma-separated "hit"
 * list. The original keeps ERROR/WARNING lines unconditionally (their
 * category is prepended to the hit list) and otherwise keeps a NOTE
 * or INFO line only when at least one keyword fired.
 *
 * The original uses a multidata hash plus FIND/FIND_NEXT to iterate
 * keywords for each record. This bundle performs the same substring
 * match using a PROC SQL cross-join on STRIP(record) and STRIP(term),
 * then aggregates the matched terms with CATX. The output is the same
 * shape the macro writes to its Excel summary: fname / cate / hit /
 * record. Filename is fabricated since this bundle runs against an
 * inline log sample rather than a directory scan.
 */

data term;
length term $400.;
term = "Missing values";                            output;
term = "is uninitialized";                          output;
term = "Division by zero";                          output;
term = "Invalid";                                   output;
term = "Character values have been converted to";   output;
term = "Numeric values have been converted to";     output;
term = "does not exist";                            output;
term = "was not found";                             output;
term = "reached past the end of a line";            output;
term = "LOST CARD";                                 output;
term = "stopped due to looping";                    output;
term = "will be overwritten by data set";           output;
term = "_ERROR_=1";                                 output;
run;

data term;
set term;
term = strip(term);
run;
proc sort data=term nodupkey;
by term;
run;

/* Inline log sample standing in for a directory of *.log files */
data raw_log;
length fname $50. record $400.;
fname = "trial01.log";
infile datalines truncover;
input record $char400.;
datalines4;
NOTE: SAS initialization used:
NOTE: Variable Y is uninitialized.
NOTE: Missing values were generated as a result of performing an operation on missing values.
NOTE: Character values have been converted to numeric values at the places given by:
ERROR: File WORK.MYDATA.DATA does not exist.
WARNING: Division by zero detected at line 5 column 8.
NOTE: SAS went to a new line when INPUT statement reached past the end of a line.
NOTE: DATA statement used (Total process time):
NOTE: There were 5 observations read from the data set WORK.A.
1                                                          The SAS System
ERROR: _ERROR_=1
NOTE: The data set WORK.B has 1 observations and 2 variables.
;;;;
run;

/* Classify by prefix exactly as the macros do */
data classified;
length fname $50. record _record $400. cate $10.;
set raw_log;
_record = strip(record);
_record = compress(_record, '0A'X || '0D'X || '0C'X);
cate = '';
if substr(_record, 1, 5) = 'ERROR'   then cate = 'ERROR';
if substr(_record, 1, 7) = 'WARNING' then cate = 'WARNING';
if substr(_record, 1, 4) = 'NOTE'    then cate = 'NOTE';
if substr(_record, 1, 5) = 'INFO:'   then cate = 'INFO';
line = _N_;
keep fname line record _record cate;
run;

/* SQL cross-join: each (record, term) pair where term occurs in record */
proc sql;
create table hits as
select c.line, c.fname, c.record, c.cate, t.term as matched_term
from classified c, term t
where index(strip(c._record), strip(t.term)) > 0
order by c.line, t.term;
quit;

/* Collapse to one row per record, with comma-separated hit list. */
data hits_per_line;
length fname $50. record $400. cate $10. hit $500.;
set hits;
by line;
retain hit;
if first.line then hit = '';
hit = catx(',', hit, matched_term);
if last.line then output;
keep line fname record cate hit;
run;

/* Add ERROR/WARNING records that had no keyword hit (still kept by macro) */
proc sql;
create table summary as
select c.line, c.fname, c.record, c.cate,
       coalesce(h.hit, '') as hit length=500
from classified c
left join hits_per_line h on c.line = h.line
where c.cate in ('ERROR', 'WARNING') or h.hit is not null
order by c.line;
quit;

/* The macro prepends cate for ERROR/WARNING rows: "ERROR,hit1,hit2" */
data summary;
length hit $500.;
set summary;
if cate in ('ERROR', 'WARNING') then hit = catx(',', cate, hit);
label fname = "FileName" cate = "Category"
      record = "Hit record" hit = "Hit keyword";
run;

proc print data=summary noobs label;
title "LogCheck_Result equivalent (matched + ERROR/WARNING rows)";
var fname line cate hit record;
run;

proc sql noprint;
select count(*) into :n_kept trimmed from summary;
quit;
%put NOTE: SASLogChecker matched/kept rows = &n_kept;
