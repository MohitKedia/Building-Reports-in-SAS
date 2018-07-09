libname sascase1 '/folders/myfolders/sample dataset';

proc import datafile = '/folders/myfolders/sample dataset/OLYMPICS.xls' out = sascase1.olympic dbms = xls
replace ; getnames = Yes; datarow = 2;

proc import datafile = '/folders/myfolders/sample dataset/OLYMPICS_DIGI.xls' out = sascase1.olympic_digi dbms = xls
replace ; getnames = Yes; datarow = 2;


data sascase1.olympic1;
set sascase1.olympic;
if probability = 0 then delete;
Forecast = probability*Total_Media_Value/100;
run;

data sascase1.olympic_digi1;
set sascase1.olympic_digi;
if probability = 0 then delete;
rename Total_Media_Value = Total_DigiMedia_Value;
Digi_Forecast = probability*Total_Media_Value/100;
run;


proc sql;
create table merged_olympic as
select a.* , b.Total_DigiMedia_Value
from sascase1.olympic1 as a left join sascase1.olympic_digi1 as b 
on a.Account_Name = b.Account_Name;
quit;
/* SUMMARY REPORT AND DETAILED REPORT */


ods pdf file = '/folders/myfolders/sample dataset/sascasestudy1_report.pdf' startpage=never;

proc report data = sascase1.olympic1 style(header) = [Foreground = Black Background= Grey];
column probability Total_Media_Value = Total_Media_Value1 Total_Media_Value Forecast;
define Total_Media_Value1/group 'Nbr_of_Optys' N ;
define Total_Media_Value /group 'Total Budget'  format = dollar16. sum;
define probability /group descending;
define Forecast / group 'Tot_Forecast' sum format = dollar18. ;
rbreak after / dol summarize style = [Foreground = Black Background = Grey];
title "Summary Report of London Olympic 2012 Pipeline" ;
run;

proc report data = sascase1.olympic_digi1 style(header) = [Foreground = Black Background= Grey];
column probability Total_DigiMedia_Value = Total_DigiMedia_Value1 Total_DigiMedia_Value Digi_Forecast;
define Total_DigiMedia_Value1/group 'Nbr_of_Optys' N;
define Total_DigiMedia_Value /group 'Digital_Budget' format = dollar16. sum;
define probability / group descending 'Prob_Digi';
define Digi_Forecast /'D_forecast' sum format = dollar20.;
rbreak after /dol skip summarize  style = [Foreground = Black Background = Grey];
run;

proc report data = merged_olympic style(header) = [Foreground = Black Background= Grey];
column probability Account_name Opportunity_Owner Total_Media_Value Total_DigiMedia_Value Deal_Comments;
define Account_name/group 'Client';
define Opportunity_Owner /group 'Champ';
define probability /order descending ;
define Total_Media_Value / 'Total Budget' format = dollar16.;
define Total_DigiMedia_Value / 'Digital Budget' format = dollar16.;
define Deal_Comments/ 'Deal Comments';
break after probability / suppress dol summarize style = [Foreground = Black Background = Grey];
rbreak after / dol summarize style = [Foreground = Dark Black Background = Grey];
title "Detailed Report by probability of London Olympic 2012";

run;

proc report data = merged_olympic style(header) = [Foreground = Black Background= Grey];
column Opportunity_Owner probability Account_name Total_Media_Value Total_DigiMedia_Value Deal_Comments;
define Account_name/group 'Client' ;
define Opportunity_Owner /order  'Champ';
define probability / order descending ;
define Total_Media_Value / 'Total Budget' format = dollar16.;
define Total_DigiMedia_Value / 'Digital Budget' format = dollar16.;
define Deal_Comments/ 'Deal Comments';
break after Opportunity_Owner /suppress dol summarize style = [Foreground = Black Background = Grey];
rbreak after / dol summarize  style = [Foreground = Black Background = Grey];
title "Detailed Report by Champ of London Olympic 2012";
run;

proc report data = merged_olympic style(header) = [Foreground = Black Background= Grey];
column Account_name Opportunity_Owner probability Total_Media_Value Total_DigiMedia_Value Deal_Comments;
define Account_name/group 'Client' ;
define Opportunity_Owner /group 'Champ';
define probability / group ;
define Total_Media_Value / 'Total Budget' format = dollar16.;
define Total_DigiMedia_Value / 'Digital Budget' format = dollar16.;
define Deal_Comments/ 'Deal Comments';
title "Detailed Report by Client of London Olympic 2012";
run;

ods pdf close ;


