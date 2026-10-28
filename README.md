# SASLogChecker
SASLogChecker is a collection of SAS macros designed to efficiently scan and review SAS log files.  
It automatically detects and summarizes key messages such as ERROR, WARNING, and potentially critical NOTE messages that often require attention.  

The tool can be used both interactively — for example, by running %interact_logchk to check the current log window — and in batch mode to process all log files in a directory using %logchk2directory(folder=…, out_folder=…), generating summary reports such as Excel outputs.  

The package is built with multilingual environments in mind, supporting both English and Japanese log messages. Users can define keyword lists to match and extract important messages, including Japanese NOTE statements (e.g., “変数 X は初期化されていません” / “Variable X is not initialized”), and view them side by side in a structured summary.

<img width="300" height="300" alt="Image" src="https://github.com/user-attachments/assets/fcc404a6-a654-4a01-90ba-6b7607752688" /> 


# %interact_logchk
Interactive Logchk..<br>
Extracts and displays ERROR, WARNING, and noteworthy NOTEs currently displayed in the log window.<br>
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
👆If you run the above code, the log window will look like below

<img width="436" height="251" alt="Image" src="https://github.com/user-attachments/assets/9ce51e5e-26a8-42f0-97df-587e81f2751a" />

Submit,  %interact_logchk;
~~~sas  
%interact_logchk;
~~~
<img width="209" height="116" alt="Image" src="https://github.com/user-attachments/assets/e9bef2c0-4626-4656-8d98-8f358a7774a9" />
<br>
<br>
<img width="452" height="108" alt="Image" src="https://github.com/user-attachments/assets/777915eb-9085-4576-b0c0-6568bc43cfe4" />
<br>
<br>
日本語環境でもそのまま動くのでご安心を．<br>
<img width="554" height="96" alt="Image" src="https://github.com/user-attachments/assets/64476e2b-72fa-4dc5-ad10-6d3b8c2afdec" />
<br>
<br>
<img width="221" height="114" alt="Image" src="https://github.com/user-attachments/assets/5a6a9e63-10d3-425b-9652-196ce7e38924" />
<br>
👆If there is no Issue, you will see a message box like this
<br>
<br>
<img width="494" height="102" alt="Image" src="https://github.com/user-attachments/assets/4b416d57-6353-4125-9fd3-29fe0c5b5cd7" />
<br>
<br>
<img width="395" height="365" alt="Image" src="https://github.com/user-attachments/assets/50fef62e-d188-40b0-93dd-4557c5242c53" />
<br>
👆You can create a new button on the SAS toolbar and tie the macro execution to a switch, so you can check the log with a single click!

# %logchk2directory
 Scans all log files (*.log or specified extension) in a  given folder, searches for errors, warnings, and specific keywords, and outputs a summary Excel file.
 ~~~sas     
Parameters:.                                              
 folder     = Path to the folder containing log files.    
 out_folder = Path to the folder for the output Excel file.  
 extension  = File extension to search (default: log) .
 ~~~
~~~sas                                                               
Example Usage:                                               
 %logchk2directory(folder=C:\logs, out_folder=C:\output);
~~~

<img width="372" height="86" alt="Image" src="https://github.com/user-attachments/assets/4cce3de0-7623-47a0-897c-e7abfc3dcdac" />
<br>
<img width="1583" height="442" alt="Image" src="https://github.com/user-attachments/assets/791be12d-cc9b-406a-9ba6-c74762d298d9" />

<br>

# English-Japanese contrast table and extracted keywords for noteworthy notes（注目すべきNoteについて英語と日本語の対照表と抽出キーワードについて）


No | Issue Appearance Sample Codes | Message(Japanese) | Message(English) | Target keywords | Target keywords(japanese) | Target keywords to Hex.(japanese)
-- | -- | -- | -- | -- | -- | --
1 | data x;x= 1+.;run; | 欠損値を含んだ計算により、以下の箇所で欠損値が生成されました。 | Missing values were generated as a result of performing an operation on missing values. | Missing values | 欠損値を含んだ計算 | 8C8791B9926C82F08ADC82F182BE8C768E5A
2 | data x;length x 8. ;run; | 変数xは初期化されていません | Variable x is uninitialized. | is uninitialized | 初期化されていません | 8F898AFA89BB82B382EA82C482A282DC82B982F1
3 | data x;x= 1/0;run; | コンパイルフェーズの途中の行 8 カラム 5で、0による除算が発生しました。 | Division by zero detected during the compilation phase, detected at line 11 column 5. | Division by zero | 0による除算 | 3082C982E682E98F9C8E5A
4 | data x;set sashelp.class;x=age/0;run; | 行 12 カラム 6で、0による除算が発生しました。 | Division by zero detected at line 15 column 6 | Division by zero | 0による除算 | 3082C982E682E98F9C8E5A
5 | data x;set sashelp.class;x=age/0;run; | 以下の箇所で演算式を計算できなかったため、結果を欠損値に設定しました。 | Mathematical operations could not be performed at the following places. The results of the operations have been set to missing values. | Mathematical operations could not | 演算式を計算できなかった | 89898E5A8EAE82F08C768E5A82C582AB82C882A982C182BD
6 | data x;x=substr("x",1,-1);run; | 関数SUBSTR(行 18 カラム 3)の第3引数は無効です。 | Invalid third argument to function SUBSTR at line 18 column 3. | Invalid | 引数は無効 | 88F8909482CD96B38CF8
7 | proc sql; select year(.) from sashelp.class;quit; | YEAR関数への引数が無効または欠落により、関数が欠損値を戻しました。 | Invalid (or missing) arguments to the YEAR function have caused the function to return amissing value | Invalid | 無効な引数 | 96B38CF882C888F89094
8 | proc sql; select substr(name,1,-1) from sashelp.class;quit; | 無効な引数3 (関数SUBSTR)です。欠損値が生成される可能性があります。 | Invalid argument 3 to function SUBSTR. Missing values may be generated. | Invalid | 無効な引数 | 96B38CF882C888F89094
9 | data x;length x 8.;x="x";run; | 以下の箇所で文字値を数値に変換しました。(行:カラム) | Character values have been converted to numeric values at the places given by: (Line):(Column). | Character values have been converted to | に変換しました | 82C995CF8AB782B582DC82B582BD
10 | data x;length x $1.;x=1;run; | 以下の箇所で数値を文字値に変換しました。(行:カラム) | Numeric values have been converted to character values at the places given by: (Line):(Column). | Numeric values have been converted to | に変換しました | 82C995CF8AB782B582DC82B582BD
11 | data x;x="A";if x ="A"EQ"B";run; | 引用符で囲まれた文字列の後の識別子の意味は、将来のSASリリースで変わる可能性があります。引用符で囲まれた文字列と識別子の間にスペースを挿入することをお勧めします。 | The meaning of an identifier after a quoted string might change in a future SAS release.  Inserting white space between a quoted string and the succeeding identifier is recommended. | The meaning of an identifier | 引用符で囲まれた文字列の | 88F89770958482C588CD82DC82EA82BD95B68E9A97F182CC
12 | data x;x=100;y = put(x, 2.);run; | 数値をプリントするには小さすぎるW.D出力形式がありました。      "BEST"出力形式によって小数点がシフトされる場合があります。 | At least one W.D format was too small for the number to be printed. The decimal may be      shifted by the "BEST" format. | too small for | 数値をプリントするには小さすぎる | 9094926C82F08376838A8393836782B782E982C982CD8FAC82B382B782AC82E9
13 | data x;x=1;y:run; | yは未参照のラベル定義です。 | Unreferenced label defined: y. | Unreferenced label | 未参照のラベル定義です | 96A28E518FC682CC83898378838B92E88B6082C582B7
14 | data x;set sashelp.class;where age =10;where age =15;run; | WHERE式を置き換えました | WHERE clause has been replaced. | WHERE clause has been replaced | WHERE式を置き換えました | 57484552458EAE82F0927582AB8AB782A682DC82B582BD
15 | data x;if 0 then set sashelp.class;run; | ループが発生したため、DATAステップの実行を中止しました。 | DATA STEP stopped due to looping. | stopped due to looping | ループが発生したため | 838B815B837682AA94AD90B682B582BD82BD82DF
16 | options msglevel=i;data x y;x=1;y=1;run;data z;merge x y;by x;run; | INFO: 変数y (データセット WORK.X) はデータセットWORK.Yによって上書きされます。 | INFO: The variable y on data set WORK.X will be overwritten by data set WORK.Y. | will be overwritten by data set | によって上書き | 82C982E682C182C48FE38F9182AB
17 | data x y;x=1;y=1;output;x=1;y=1;output;run;data z;merge x y;by x;run; | MERGEステートメントにBY値を繰り返すデータセットが複数あります。 | MERGE statement has more than one data set with repeats of BY values. | repeats of BY values | BY値を繰り返す | 4259926C82F08C4A82E895D482B7
18 | libname x "xxxxx"; | ライブラリXは存在しません | Library X does not exist. | does not exist | 存在しません | 91B68DDD82B582DC82B982F1
19 | proc datasets;delete xx;quit; | ファイルWORK.XX (memtype=DATA)は見つかりませんが、DELETEステートメントに存在します。 | The file WORK.XX (memtype=DATA) was not found, but appears on a DELETE statement. | was not found | 見つかりません | 8CA982C282A982E882DC82B982F1
20 | options nofmterr;data x;format x $xxx.;x = "x";run; | 出力形式$XXXが見つからないか、またはロードできません。 | Format $XXX was not found or could not be loaded. | was not found | 見つからない | 8CA982C282A982E782C882A2
21 | data x;infile cards;input x $1. y $1. z;cards;xyzrun; | zに対して、無効なデータが行296カラム3-3にあります。 | Invalid data for z in line 106 3-3. | Invalid | 無効なデータ | 96B38CF882C88366815B835E
22 | data x;infile cards;input x $1. y $1. z $100.;cards;xy;run; | INPUTステートメントが行の終端に達したので、次の行を読み込みます | SAS went to a new line when INPUT statement reached past the end of a line. | reached past the end of a line | 終端に達した | 8F49925B82C9924282B582BD
23 | data x;infile cards;input x $1. y $1. z $100.;cards;xy;run; | LOST CARD. | LOST CARD. | LOSTCARD | LOSTCARD | 4C4F535443415244
24 | proc sql noexec; select age from sashelp.class;quit; | NOEXECオプションが指定されているため、ステートメントは実行されません。 | Statement not executed due to NOEXEC option. | NOEXEC | NOEXECオプション | 4E4F4558454383498376835683878393
25 | proc sql noexec; select case when age =10 then "x" end  as x from sashelp.class;quit; | CASE式にELSE句がありません。すべてのWHEN句の条件に合わなかった場合、CASE式の結果は欠損値になります。 | A CASE expression has no ELSE clause. Cases not accounted for by the WHEN clauses will result in a missing value for the CASE expression. | A CASE expression has no ELSE clause | CASE式にELSE句 | 434153458EAE82C9454C53458BE5
26 | data x;infile cards;input x $1. y $1. z;cards;xyzrun; | x=x y=y z=. _ERROR_=1 _N_=1 | x=x y=y z=. _ERROR_=1 _N_=1 | _ERROR_=1 | _ERROR_=1 | 5F4552524F525F3D31
27 | proc sgplot data=sashelp.class;scatter x=age y=height;xaxis values=(1 to 1000);run; | 目盛値の一部が間引かれました。 | Some of the tick values have been thinned. | have been thinned | 間引 | 8AD488F8
28 | proc sql ; select age from sashelp.class group by age order by age;quit; | 関連するテーブルのSELECT句もHAVING句も要約関数を引用していないので、GROUP BY句は無視されました。 | A GROUP BY clause has been discarded because neither the SELECT clause nor the optional HAVING clause of the associated table-expression referenced a summary function. | discarded because neither | 無視 | 96B38E8B
29 | /*This NOTE is dangerous to put out.*//*このNOTEは出すと危険*/ | 要約化中にディスク処理が発生しました | Processing on disk occurred during summarization. | Processing on disk occurred during summarization. | ディスク処理が発生しました | 836683428358834E8F88979D82AA94AD90B682B582DC82B582BD
30 | data x;x=1;y=0;run;proc sgplot data=x;scatter x=x y=y;yaxis type=log;run; | デフォルトまたは割り当てられた BASELINEINTERCEPT値のために、ログ軸はプロットデータのゼロおよび負の値をサポートしません。軸タイプは LINEARに変更されます。 | The log axis cannot support zero or negative values for the axis from plot data or due to default or assigned BASELINEINTERCEPT value. The axis type will be changed to LINEAR. | log axis cannot support | ログ軸は | 838D834F8EB282CD
31 | filename x temp ;data _null_;file x;put "12345";run;data x;infile x lrecl=2;input x ;run; | 切り捨てられた行があります。 | One or more lines were truncated. | lines were truncated | 切り捨てられた行 | 90D882E88ECC82C482E782EA82BD8D73
32 | data x;    a = 1; Y = 2; output;    a = 2; Y = 3; output;    a = 3; Y = 4; output;    a = 4; Y = 5; output;    a = 5; Y = 3; output;    a = 6; Y = 7; output;    a = 7; Y = 4; output;    a = 8; Y = 8; output;    a = 9; Y = 4; output;run;proc gplot data = x;    plot Y * A / vaxis = axis1 haxis = axis2 ;    symbol1 c = black V = dot I = join;    axis1      order = (1 to 5 by 1)      origin=(10, 30)      ;    axis2      order=( 1 to 10 by 1 )      origin=(10, 30)    ;run; | 範囲外 | outside the axis range | outside the axis range | 範囲外 | 94CD88CD8A4F
33 | --- | An infinite likelihood is assumed in iteration 5because of a nonpositive definite estimated R matrix for ID 1. | An infinite likelihood is assumed in iteration 5because of a nonpositive definite estimated R matrix for ID 1. | infinite likelihood i | infinite likelihood i | 696E66696E697465
34 | --- | Estimated G matrix is not positive definite. | Estimated G matrix is not positive definite. | definite | definite | 646566696E697465
35 | --- | ヘッセ行列は正定値ではありません | The generalized Hessian matrix is not positive definite. | definite | 行列は正定値 | 8D7397F182CD90B392E8926C
36 | --- | 文字を超えています |   |   | 文字を超えています | 95B68E9A82F092B482A682C482A282DC82B7
37 | --- | 変数がありません |   |   | 変数がありません | 95CF909482AA82A082E882DC82B982F1
38 | --- | 小数点がシフト |   |   | 小数点がシフト | 8FAC9094935F82AA835683748367
39 | --- | ロードできません |   |   | ロードできません | 838D815B836882C582AB82DC82B982F1
40 | --- | 予約名 |   |   | 予約名 | 975C96F196BC
41 | --- | デフォルト |   |   | デフォルト | 836683748348838B8367

# version history<br>
0.2.0(28Ocutober2026):Enhance logchk2directory for cross-platform compatibility.
0.1.2(20October2025): %interact_logchk() Fixed an issue where garbled characters appeared in message boxes in SJIS environments.<br>
0.1.1(04Auguat2025): Macro name changed to %logchk2directory (old name %logchk2directry)<br>
0.1.0(07july2025): Initial version<br>

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!
