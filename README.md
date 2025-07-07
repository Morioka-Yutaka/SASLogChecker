# SASLogChecker
SAS log checker for extracting ERRORs, WARNINGs, and notable NOTEs — supports interactive and directory-wide runs.

![SASLogChecker](./SASLogChecker_small.png)  


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

# %logchk2directry
 Scans all log files (*.log or specified extension) in a  given folder, searches for errors, warnings, and specific keywords, and outputs a summary Excel file.
 ~~~sas     
Parameters:.                                              
 folder     = Path to the folder containing log files.    
 out_folder = Path to the folder for the output Excel file.  
 extension  = File extension to search (default: log) .
 ~~~
~~~sas                                                               
Example Usage:                                               
 %logcht2directry(folder=C:\logs, out_folder=C:\output);
~~~

<img width="372" height="86" alt="Image" src="https://github.com/user-attachments/assets/4cce3de0-7623-47a0-897c-e7abfc3dcdac" />
<br>
<img width="1583" height="442" alt="Image" src="https://github.com/user-attachments/assets/791be12d-cc9b-406a-9ba6-c74762d298d9" />

<br>

# English-Japanese contrast table and extracted keywords for noteworthy notes（注目すべきNoteについて英語と日本語の対照表と抽出キーワードについて）


