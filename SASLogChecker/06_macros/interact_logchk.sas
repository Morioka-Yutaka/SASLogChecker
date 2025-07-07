/*** HELP START ***//*

Program Name : interact_logchk.sas (Macro)
 Author       : [Yutaka Morioka]
 Created On   : [2025-07-04]
 Purpose      : Automated SAS log message checker
                 - Intended for interactive execution via a SAS 9.4 GUI custom tool button
                 - Assumes a Windows environment only
                 - Designed to handle mixed encoding environments (SJIS, Unicode, Latin)
                   by matching Japanese messages through HEX string comparisons
                 - Categorizes and displays log messages as ERROR, WARNING, NOTE, or INFO

 Main Features:
   - Always detects all **ERROR** and **WARNING** messages in the SAS log
   - Additionally scans for specific **NOTE** and **INFO** patterns
     These patterns are explicitly chosen by the author based on practical experience
     and do not represent an exhaustive list of all possible SAS notes or info messages.

   [Examples of targeted NOTE / INFO messages:]
     - "Missing values were generated ..."
     - "Variable x is uninitialized"
     - "Division by zero detected ..."
     - "Mathematical operations could not be performed ..."
     - "Invalid argument ..."
     -"Character values have been converted to numeric values"
     -"Numeric values have been converted to character values"
     - "Unreferenced label defined"
     - "WHERE clause has been replaced"
     - "DATA STEP stopped due to looping"
     - "will be overwritten by data set ..."
     - "MERGE statement has more than one data set with repeats of BY values"
     - "Library does not exist"
     - "was not found" (file/format)
     - "reached past the end of a line" (LOST CARD)
     - "Statement not executed due to NOEXEC option"
     - "A CASE expression has no ELSE clause ..."
     - "Some tick values have been thinned"
     - "GROUP BY clause has been discarded because neither SELECT nor HAVING ..."
     - "Processing on disk occurred during summarization"
     - "The log axis cannot support zero or negative values"
     - "lines were truncated"
     - "outside the axis range"
     - "infinite likelihood assumed"
     - "definite matrix is not positive definite"

   - Many of these messages are matched using HEX strings
     to ensure compatibility with multi-byte character encodings (SJIS, Unicode, Latin).

 Limitations:
   - Uses `dm` commands for interactive control, which do not work in Unix or batch mode.
   - The set of HEX patterns may need updates if SAS session encoding differs
     from the original environment where this macro was developed.

License : MIT

*//*** HELP END ***/

%macro interact_logchk;
options nosource;

%put NOTE:Log Check Start;
%local __obs __obs_e __obs_w __obs_n __obs_i  _orientation;
%let _orientation = %sysfunc(getoption(orientation));
options orientation=portrait;

%do i=1 %to 20;
	dm 'next VIEWTABLE:libref.dataset; end;';
%end;

filename tempf temp;
dm log 'print file=tempf replace';

data __log;
length cate $10. record $400. hex_record  $2000. target $400.  FL $1. ;
	infile tempf truncover end=eof;
	input record 1-400 ;
  call missing(FL);
	_record = strip(record);
  _record = compress(_record,'0A'X || '0D'X|| '0C'X);
	if substr(_record , 1 , 5 ) = 'ERROR'   then cate ='ERROR';
	if substr(_record , 1 , 7 ) = 'WARNING' then cate ='WARNING';
	if substr(_record , 1 , 4 ) = 'NOTE'   then cate ='NOTE';
	if substr(_record , 1 , 5 ) = 'INFO:' 	then cate ='INFO';
  hex_record=put(_record,$hex.);
  if CATE in ('ERROR','WARNING') then FL="Y";

  /*For Japanese Note [SJIS enviroment]*/
  if index(hex_record,"5F4552524F525F3D31") then do;FL="Y"; target="5F4552524F525F3D31"x;end;
  if CATE in ("NOTE","INFO") then do;
    /*Missing values were generated as a result of performing an operation on missing values.*/
    if index(hex_record,"8C8791B9926C82F08ADC82F182BE8C768E5A") then do;FL="Y"; target="8C8791B9926C82F08ADC82F182BE8C768E5A"x;end;
    /*Variable x is uninitialized.*/
    if index(hex_record,"8F898AFA89BB82B382EA82C482A282DC82B982F1") then do;FL="Y"; target="8F898AFA89BB82B382EA82C482A282DC82B982F1"x;end;
    /* Division by zero detected during the compilation phase, detected at line x column x.*/   
    if index(hex_record,"3082C982E682E98F9C8E5A") then do;FL="Y"; target="3082C982E682E98F9C8E5A"x;end;
    /*Division by zero detected at line  column */   
    if index(hex_record,"3082C982E682E98F9C8E5A") then do;FL="Y"; target="3082C982E682E98F9C8E5A"x;end;
    /*Mathematical operations could not be performed at the following places. The results of the operations have been set to missing values.*/  
    if index(hex_record,"89898E5A8EAE82F08C768E5A82C582AB82C882A982C182BD") then do;FL="Y"; target="89898E5A8EAE82F08C768E5A82C582AB82C882A982C182BD"x;end;
    /*Invalid third argument to function XXXX at line x column x.*/   
    if index(hex_record,"88F8909482CD96B38CF8") then do;FL="Y"; target="88F8909482CD96B38CF8"x;end;
    /*Invalid argument x to function XXXX. Missing values may be generated.*/   
    if index(hex_record,"96B38CF882C888F89094") then do;FL="Y"; target="96B38CF882C888F89094"x;end;
    /*Invalid argument x to function XXXX. Missing values may be generated.*/
    if index(hex_record,"96B38CF882C888F89094") then do;FL="Y"; target="96B38CF882C888F89094"x;end;
    /*Numeric values have been converted to character values at the places given by: (Line):(Column).*/   
    if index(hex_record,"82C995CF8AB782B582DC82B582BD") then do;FL="Y"; target="82C995CF8AB782B582DC82B582BD"x;end;
    /*Character values have been converted to numeric values at the places given by: (Line):(Column).    */
    if index(hex_record,"82C995CF8AB782B582DC82B582BD") then do;FL="Y"; target="82C995CF8AB782B582DC82B582BD"x;end;
    /*The meaning of an identifier after a quoted string might change in a future SAS release.  Inserting white space between a quoted string and the succeeding identifier is recommended.*/   
    if index(hex_record,"88F89770958482C588CD82DC82EA82BD95B68E9A97F182CC") then do;FL="Y"; target="88F89770958482C588CD82DC82EA82BD95B68E9A97F182CC"x;end;
    /*At least one W.D format was too small for the number to be printed. The decimal may be shifted by the "BEST" format.*/    
    if index(hex_record,"9094926C82F08376838A8393836782B782E982C982CD8FAC82B382B782AC82E9") then do;FL="Y"; target="9094926C82F08376838A8393836782B782E982C982CD8FAC82B382B782AC82E9"x;end;
    /*Unreferenced label defined: .*/   
    if index(hex_record,"96A28E518FC682CC83898378838B92E88B6082C582B7") then do;FL="Y"; target="96A28E518FC682CC83898378838B92E88B6082C582B7"x;end;
    /*WHERE clause has been replaced.*/  
    if index(hex_record,"57484552458EAE82F0927582AB8AB782A682DC82B582BD") then do;FL="Y"; target="57484552458EAE82F0927582AB8AB782A682DC82B582BD"x;end;
    /*DATA STEP stopped due to looping.*/    
    if index(hex_record,"838B815B837682AA94AD90B682B582BD82BD82DF") then do;FL="Y"; target="838B815B837682AA94AD90B682B582BD82BD82DF"x;end;
    /*INFO: The variable y on data set WORK.X will be overwritten by data set WORK.*/    
    if index(hex_record,"82C982E682C182C48FE38F9182AB") then do;FL="Y"; target="82C982E682C182C48FE38F9182AB"x;end;
    /*MERGE statement has more than one data set with repeats of BY values.*/    
    if index(hex_record,"4259926C82F08C4A82E895D482B7") then do;FL="Y"; target="4259926C82F08C4A82E895D482B7"x;end;
    /*Library X does not exist.*/    
    if index(hex_record,"91B68DDD82B582DC82B982F1") then do;FL="Y"; target="91B68DDD82B582DC82B982F1"x;end;
    /*The file WORK.XX (memtype=DATA) was not found, but appears on a DELETE statement.*/ 
    if index(hex_record,"8CA982C282A982E882DC82B982F1") then do;FL="Y"; target="8CA982C282A982E882DC82B982F1"x;end;
    /*Format $XXX was not found or could not be loaded.*/   
     if index(hex_record,"8CA982C282A982E782C882A2") then do;FL="Y"; target="8CA982C282A982E782C882A2"x;end;
    /*Invalid data for z in line .*/    
    if index(hex_record,"96B38CF882C88366815B835E") then do;FL="Y"; target="96B38CF882C88366815B835E"x;end;
    /*SAS went to a new line when INPUT statement reached past the end of a line.*/
    if index(hex_record,"8F49925B82C9924282B582BD") then do;FL="Y"; target="8F49925B82C9924282B582BD"x;end;
    /*LOST CARD.    */
    if index(hex_record,"4C4F535443415244") then do;FL="Y"; target="4C4F535443415244"x;end;
    /*Statement not executed due to NOEXEC option.*/
    if index(hex_record,"4E4F4558454383498376835683878393") then do;FL="Y"; target="4E4F4558454383498376835683878393"x;end;
    /*A CASE expression has no ELSE clause. Cases not accounted for by the WHEN clauses will result in a missing value for the CASE expression.*/
    if index(hex_record,"434153458EAE82C9454C53458BE5") then do;FL="Y"; target="434153458EAE82C9454C53458BE5"x;end;
    /*Some of the tick values have been thinned.*/    
    if index(hex_record,"8AD488F8") then do;FL="Y"; target="8AD488F8"x;end;
    /*A GROUP BY clause has been discarded because neither the SELECT clause nor the optional HAVING clause of the associated table-expression referenced a summary function.*/   
    if index(hex_record,"96B38E8B") then do;FL="Y"; target="96B38E8B"x;end;
    /*Processing on disk occurred during summarization.*/   
    if index(hex_record,"836683428358834E8F88979D82AA94AD90B682B582DC82B582BD") then do;FL="Y"; target="836683428358834E8F88979D82AA94AD90B682B582DC82B582BD"x;end;
    /*The log axis cannot support zero or negative values for the axis from plot data or due to default or assigned BASELINEINTERCEPT value. The axis type will be changed to LINEAR.*/   
    if index(hex_record,"838D834F8EB282CD") then do;FL="Y"; target="838D834F8EB282CD"x;end;
    /*One or more lines were truncated.*/    
    if index(hex_record,"90D882E88ECC82C482E782EA82BD8D73") then do;FL="Y"; target="90D882E88ECC82C482E782EA82BD8D73"x;end;
    /*outside the axis range*/  
    if index(hex_record,"94CD88CD8A4F") then do;FL="Y"; target="94CD88CD8A4F"x;end;
    /*An infinite likelihood is assumed in iteration 5*/ 
    if index(hex_record,"696E66696E697465") then do;FL="Y"; target="696E66696E697465"x;end;
    /*because of a nonpositive definite estimated R matrix for ID x.*/    
    if index(hex_record,"646566696E697465") then do;FL="Y"; target="646566696E697465"x;end;
    /*Estimated G matrix is not positive definite.*/    
    if index(hex_record,"8D7397F182CD90B392E8926C") then do;FL="Y"; target="8D7397F182CD90B392E8926C"x;end;
    /*The generalized Hessian matrix is not positive definite.*/   
    if index(hex_record,"95B68E9A82F092B482A682C482A282DC82B7") then do;FL="Y"; target="95B68E9A82F092B482A682C482A282DC82B7"x;end;
    
    if index(hex_record,"95CF909482AA82A082E882DC82B982F1") then do;FL="Y"; target="95CF909482AA82A082E882DC82B982F1"x;end;
    if index(hex_record,"8FAC9094935F82AA835683748367") then do;FL="Y"; target="8FAC9094935F82AA835683748367"x;end;
    if index(hex_record,"838D815B836882C582AB82DC82B982F1") then do;FL="Y"; target="838D815B836882C582AB82DC82B982F1"x;end;
    if index(hex_record,"975C96F196BC") then do;FL="Y"; target="975C96F196BC"x;end;
    if index(hex_record,"836683748348838B8367") then do;FL="Y"; target="836683748348838B8367"x;end;
  end;
  if index(record,"_ERROR_=1") then do;FL="Y"; target="_ERROR_=1";end;
  if CATE in ("NOTE","INFO") then do;
      /*Missing values were generated as a result of performing an operation on missing values.*/
      if index(record,"Missing values") then do;FL="Y"; target="Missing values";end;
      /*Variable x is uninitialized.*/
      if index(record,"is uninitialized") then do;FL="Y"; target="is uninitialized";end;
      /*Division by zero detected during the compilation phase, detected at line x column x.*/   
      if index(record,"Division by zero") then do;FL="Y"; target="Division by zero";end;
      /*Division by zero detected at line x column x*/
      if index(record,"Division by zero") then do;FL="Y"; target="Division by zero";end;
      /*Mathematical operations could not be performed at the following places. The results of the operations have been set to missing values.*/     
      if index(record,"Mathematical operations could not") then do;FL="Y"; target="Mathematical operations could not";end; 
      /*Invalid third argument to function XXXXX at line x column x.*/     
      if index(record,"Invalid") then do;FL="Y"; target="Invalid";end;
      /*Invalid (or missing) arguments to the XXXX function have caused the function to return a missing value*/
      if index(record,"Invalid") then do;FL="Y"; target="Invalid";end;
      /*Invalid argument x to function XXXX. Missing values may be generated.*/     
      if index(record,"Invalid") then do;FL="Y"; target="Invalid";end;
      /* Character values have been converted to numeric values at the places given by: (Line):(Column).*/
      if index(record,"Character values have been converted to") then do;FL="Y"; target="Character values have been converted to";end;
      /*Numeric values have been converted to character values at the places given by: (Line):(Column).*/
      if index(record,"Numeric values have been converted to") then do;FL="Y"; target="Numeric values have been converted to";end;
      /*The meaning of an identifier after a quoted string might change in a future SAS release.  Inserting white space between a quoted string and the succeeding identifier is recommended.*/
      if index(record,"The meaning of an identifier") then do;FL="Y"; target="The meaning of an identifier ";end;
      /*At least one W.D format was too small for the number to be printed. The decimal may be shifted by the BEST format.*/      
      if index(record,"too small for ") then do;FL="Y"; target="too small for";end;
      /*Unreferenced label defined: y.*/     
      if index(record,"Unreferenced label") then do;FL="Y"; target="Unreferenced label";end;
      /*WHERE clause has been replaced.*/    
      if index(record,"WHERE clause has been replaced") then do;FL="Y"; target="WHERE clause has been replaced";end;
      /*DATA STEP stopped due to looping.*/
      if index(record,"stopped due to looping") then do;FL="Y"; target="stopped due to looping";end;
      /*INFO: The variable y on data set WORK.X will be overwritten by data set WORK.Y.*/
      if index(record,"will be overwritten by data set") then do;FL="Y"; target="will be overwritten by data set";end;
      /*MERGE statement has more than one data set with repeats of BY values.*/
      if index(record,"repeats of BY values") then do;FL="Y"; target="repeats of BY values";end;
      /* Library X does not exist.*/
      if index(record,"does not exist") then do;FL="Y"; target="does not exist";end;
      /*The file WORK.XX (memtype=DATA) was not found, but appears on a DELETE statement.*/
      if index(record,"was not found") then do;FL="Y"; target="was not found";end;
       /*Format $XXX was not found or could not be loaded.*/
      if index(record,"was not found") then do;FL="Y"; target="was not found";end;
      /*Invalid data for z in line .*/
      if index(record,"Invalid") then do;FL="Y"; target="Invalid";end;
      /*SAS went to a new line when INPUT statement reached past the end of a line.*/
      if index(record,"reached past the end of a line") then do;FL="Y"; target="reached past the end of a line";end;
      /* LOST CARD.*/
      if index(record,"LOST CARD") then do;FL="Y"; target="LOST CARD";end;
     /*Statement not executed due to NOEXEC option.*/
      if index(record,"NOEXEC") then do;FL="Y"; target="NOEXEC";end;
      /*A CASE expression has no ELSE clause. Cases not accounted for by the WHEN clauses will result in a missing value for the CASE expression.*/    
      if index(record,"A CASE expression has no ELSE clause") then do;FL="Y"; target=" A CASE expression has no ELSE clause";end;
      /*Some of the tick values have been thinned.*/      
      if index(record,"have been thinned") then do;FL="Y"; target="have been thinned";end;
      /*A GROUP BY clause has been discarded because neither the SELECT clause nor the optional HAVING clause of the associated table-expression referenced a summary function.*/      
      if index(record,"discarded because neither") then do;FL="Y"; target="discarded because neither";end;
      /*Processing on disk occurred during summarization.*/ 
      if index(record,"Processing on disk occurred during summarization.") then do;FL="Y"; target="Processing on disk occurred during summarization.";end;
      /*The log axis cannot support zero or negative values for the axis from plot data or due to default or assigned BASELINEINTERCEPT value. The axis type will be changed to LINEAR.*/     
      if index(record,"log axis cannot support") then do;FL="Y"; target="log axis cannot support";end;
      /* One or more lines were truncated.*/      
      if index(record,"lines were truncated") then do;FL="Y"; target="lines were truncated";end;
      /*outside the axis range*/      
      if index(record,"outside the axis range") then do;FL="Y"; target="outside the axis range";end;
      /*An infinite likelihood is assumed in iteration x because of a nonpositive definite estimated R matrix for ID */
      if index(record,"infinite likelihood i") then do;FL="Y"; target="infinite likelihood i";end;
      /*Estimated G matrix is not positive definite.*/
      if index(record,"definite") then do;FL="Y"; target="definite";end;
      /*The generalized Hessian matrix is not positive definite.*/
      if index(record,"definite") then do;FL="Y"; target="definite";end;
  end;
  line=_N_;
  if FL="Y";
  label cate='Category' record='Text' line='Line' Target="Target Keyword";
  drop _record hex_record FL;
run;
%let __obs_e = 0;
proc sql noprint;
	select count(*) into: __obs   trimmed from __log ;
	select count(*) into: __obs_e trimmed from __log where cate="ERROR";
	select count(*) into: __obs_w trimmed from __log where cate="WARNING";
	select count(*) into: __obs_n trimmed from __log where cate="NOTE";
	select count(*) into: __obs_i trimmed from __log where cate="INFO";
quit;

filename tempf clear;
%if &__obs ne 0 %then %do;
	dm 'post "ERROR:【&__obs_e.】  WARNING:【&__obs_w.】  NOTE:【&__obs_n.】"';
	dm "viewtable __log";
%end;
%else %do;
	dm 'post "There were no applicable suspicious logs."';
%end;

options source;
options orientation=&_orientation;


%mend interact_logchk;
