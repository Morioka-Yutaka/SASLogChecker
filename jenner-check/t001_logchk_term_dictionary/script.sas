/* SASLogChecker — keyword dictionary build
 *
 * Source: SASLogChecker/06_macros/logchk2directory.sas (lines 42-123).
 * The macro builds a 50+ row dictionary of SAS log keywords that
 * flag noteworthy NOTE / INFO messages — things a reviewer wants to
 * see in a batch-run summary. This bundle exercises the dictionary-
 * construction phase: emit each term as its own row, then PROC SORT
 * NODUPKEY to collapse intentional duplicates (the original macro
 * lists "Division by zero" twice, "Invalid" three times, etc.).
 *
 * The English-side terms are kept verbatim from the original. The
 * Japanese hex-literal entries are out of scope for this single-bundle
 * check, but the dedup-on-text behaviour applies identically once they
 * are included.
 */

data term;
length term $400.;
key = 1;
term = "Missing values";                            output;
term = "is uninitialized";                          output;
term = "Division by zero";                          output;
term = "Mathematical operations could not";         output;
term = "Invalid";                                   output;
term = "Character values have been converted to";   output;
term = "Numeric values have been converted to";     output;
term = "The meaning of an identifier";              output;
term = "too small for";                             output;
term = "Unreferenced label";                        output;
term = "WHERE clause has been replaced";            output;
term = "stopped due to looping";                    output;
term = "will be overwritten by data set";           output;
term = "repeats of BY values";                      output;
term = "does not exist";                            output;
term = "was not found";                             output;
term = "Invalid";                                   output;  /* repeat */
term = "reached past the end of a line";            output;
term = "LOSTCARD";                                  output;
term = "NOEXEC";                                    output;
term = "A CASE expression has no ELSE clause";      output;
term = "_ERROR_=1";                                 output;
term = "have been thinned";                         output;
term = "discarded because neither";                 output;
term = "Processing on disk occurred during summarization."; output;
term = "log axis cannot support";                   output;
term = "lines were truncated";                      output;
term = "outside the axis range";                    output;
term = "infinite likelihood i";                     output;
term = "definite";                                  output;
term = "Division by zero";                          output;  /* repeat */
run;

/* Strip whitespace before dedup, exactly as the macro does */
data term;
set term;
term = strip(term);
run;

proc sort data=term nodupkey;
by term;
run;

proc print data=term noobs label;
title "Distinct flagged-term dictionary (after NODUPKEY)";
label term = "Term";
run;

proc sql noprint;
select count(*) into :nterms trimmed from term;
quit;

%put NOTE: SASLogChecker term dictionary built with &nterms distinct terms;
