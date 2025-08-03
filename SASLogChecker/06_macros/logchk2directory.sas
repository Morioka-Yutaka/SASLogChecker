/*** HELP START ***//*

Macro Name : logchk2directory
Authoer: Yutaka Morioka
License : MIT
Overview:
Scans all log files (*.log or specified extension) in a
given folder, searches for errors, warnings, and specific
keywords, and outputs a summary Excel file.
Character Encoding Support:
- This macro can handle log files encoded in Shift-JIS
or UTF-8.
- Japanese keywords are included as hex literals to avoid
garbled text and ensure matching regardless of session
encoding.
Important Notes:
- This macro is designed for Windows only.
The file path delimiter "\" and path handling logic
(e.g., KSCAN, KREVERSE) assume a Windows environment.
It will not work as-is on Unix/Linux/MacOS systems.
Parameters:
folder     = Path to the folder containing log files
out_folder = Path to the folder for the output Excel file
extension  = File extension to search (default: log)
Example Usage:
%logchk2directory(folder=C:\logs, out_folder=C:\output);

*//*** HELP END ***/

%macro logchk2directory(folder = ,out_folder= ,extension = log);
%put NOTE: extension is set &extension.;
%if %length(&folder) EQ 0 %then %do;
%put %str(ER)%str(ROR: folder is a mandatory parameter. Please provide the folder reference where target log giles are located.);
%goto exit;
%end;
%if %length(&out_folder) EQ 0%then %do;
%let out_folder = &folder;
%end;
%put NOTE: folder is set &folder;
%put NOTE: out_folder is set &out_folder;
filename _log_  "&folder.\*.&extension" ;
data term;
length term $400.;
key=1;
term="Missing values";output;
term="is uninitialized";output;
term="Division by zero";output;
term="Mathematical operations could not";output;
term="Invalid";output;
term="Character values have been converted to";output;
term="Numeric values have been converted to";output;
term="The meaning of an identifier";output;
term="too small for";output;
term="Unreferenced label";output;
term="WHERE clause has been replaced";output;
term="stopped due to looping";output;
term="will be overwritten by data set";output;
term="repeats of BY values";output;
term="does not exist";output;
term="was not found";output;
term="Invalid";output;
term="reached past the end of a line";output;
term="LOSTCARD";output;
term="NOEXEC";output;
term="A CASE expression has no ELSE clause";output;
term="_ERROR_=1";output;
term="have been thinned";output;
term="discarded because neither";output;
term="Processing on disk occurred during summarization.";output;
term="log axis cannot support";output;
term="lines were truncated";output;
term="outside the axis range";output;
term="infinite likelihood i";output;
term="definite";output;
term="8C8791B9926C82F08ADC82F182BE8C768E5A"x;output;
term="8F898AFA89BB82B382EA82C482A282DC82B982F1"x;output;
term="3082C982E682E98F9C8E5A"x;output;
term="3082C982E682E98F9C8E5A"x;output;
term="89898E5A8EAE82F08C768E5A82C582AB82C882A982C182BD"x;output;
term="88F8909482CD96B38CF8"x;output;
term="96B38CF882C888F89094"x;output;
term="96B38CF882C888F89094"x;output;
term="82C995CF8AB782B582DC82B582BD"x;output;
term="82C995CF8AB782B582DC82B582BD"x;output;
term="88F89770958482C588CD82DC82EA82BD95B68E9A97F182CC"x;output;
term="9094926C82F08376838A8393836782B782E982C982CD8FAC82B382B782AC82E9"x;output;
term="96A28E518FC682CC83898378838B92E88B6082C582B7"x;output;
term="57484552458EAE82F0927582AB8AB782A682DC82B582BD"x;output;
term="838B815B837682AA94AD90B682B582BD82BD82DF"x;output;
term="82C982E682C182C48FE38F9182AB"x;output;
term="4259926C82F08C4A82E895D482B7"x;output;
term="91B68DDD82B582DC82B982F1"x;output;
term="8CA982C282A982E882DC82B982F1"x;output;
term="8CA982C282A982E782C882A2"x;output;
term="96B38CF882C88366815B835E"x;output;
term="8F49925B82C9924282B582BD"x;output;
term="4C4F535443415244"x;output;
term="4E4F4558454383498376835683878393"x;output;
term="434153458EAE82C9454C53458BE5"x;output;
term="5F4552524F525F3D31"x;output;
term="8AD488F8"x;output;
term="96B38E8B"x;output;
term="836683428358834E8F88979D82AA94AD90B682B582DC82B582BD"x;output;
term="838D834F8EB282CD"x;output;
term="90D882E88ECC82C482E782EA82BD8D73"x;output;
term="94CD88CD8A4F"x;output;
term="696E66696E697465"x;output;
term="646566696E697465"x;output;
term="8D7397F182CD90B392E8926C"x;output;
term="95B68E9A82F092B482A682C482A282DC82B7"x;output;
term="95CF909482AA82A082E882DC82B982F1"x;output;
term="8FAC9094935F82AA835683748367"x;output;
term="838D815B836882C582AB82DC82B982F1"x;output;
term="975C96F196BC"x;output;
term="836683748348838B8367"x;output;
run;
data term;
set term;
term=strip(term);
run;
proc sort data=term nodupkey;
by term;
run;
data log;
length fname _fname $200. cate $10. record term $400.  hit $500.;
	infile _log_ filename=_fname truncover ;
	input record 1-400 ;
	if 0 then set term;
	if _N_=1 then do;
		declare hash h1(dataset:"term" ,multidata:"Y");
		h1.definekey("key");
		h1.definedata("term");
		h1.definedone();
	end;
	fname=kreverse(kscan(kreverse(_fname),1,"\"));
	
	_record = strip(record);
_record = compress(_record,'0A'X || '0D'X|| '0C'X);
	if substr(_record, 1 , 5 ) = 'ERROR'     then cate ='ERROR';
	if substr(_record, 1 , 7 ) = 'WARNING' then cate	='WARNING';
	if substr(_record , 1 , 4 ) = 'NOTE'     then cate ='NOTE';
	if substr(_record, 1 , 5 ) = 'INFO:' 	  then cate ='INFO';
	key=1;
	hit="";
	call missing(hit);
	  rc=h1.find();
	  do while( rc eq 0);
	     if index(strip(_record),strip(term)) then do;
hit=catx(",",hit,term);
end;
	     rc=h1.find_next();
	  end;
	  if cate in ("ERROR","WARNING") then hit=catx(",",cate,hit);
	  if cate in ("ERROR","WARNING") or hit ne "";
label fname="FileName" cate="Category" hit="Hit keyword" _record="Hit recorf";
keep fname cate _record hit  ;
run;
proc sql noprint;
	select count(*) into:logobs
	from log;
quit;
%if &logobs ne 0 %then %do;
%end;
%else %do;
data log;
	mes="There were no applicable suspicious logs.";
	run;
%end;
ods excel
file="&out_folder\LogCheck_Result.xlsx";
proc print data=log noobs label;
run;
ods excel close;
%EXIT:;
%mend;
