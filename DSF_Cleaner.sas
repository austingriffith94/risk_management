/*Austin Griffith
/*11/19/2017
/*Risk Management*/

OPTIONS ls = 70 nodate nocenter;
OPTIONS missing = '';

/*file paths need to be updated according to current computer*/
%let Ppath = P:\Assignment 7;
%let Dpath = Q:\Data-ReadOnly\CRSP;

libname comp "&Cpath";
libname crsp "&Dpath";
libname risk "&Ppath";

/*--------------------------DSF--------------------------*/
/*data is on a daily basis*/
/*pulls data from dsf file*/
data dsf_comp;
set crsp.dsf (keep = PERMNO DATE RET);
YEAR = year(DATE);
format DATE mmddyy10.;
if YEAR >= 2000 and YEAR <= 2010;
if missing(PERMNO) then delete;
if nmiss(RET) then delete;
run;

/*data for random time period*/
data dsf;
set dsf_comp;
if YEAR >= 2005 or YEAR <= 2010;
run;

/*creates new set of data*/
/*used to determine random 100 permnos*/
data dsf_perm;
set dsf;
keep PERMNO;
run;

/*limits data to only one obs of each permno*/
proc sort data = dsf_perm nodupkey;
by PERMNO;
run;

/*takes 100 random obs from list of firms*/
proc surveyselect data = dsf_perm
method=srs
n = 100
seed = 903353429
out = dsf_100
noprint;
run;

/*sorts main dsf data by firm for merge*/
proc sort data = dsf;
by PERMNO;
run;

/*merges data, keeps 100 random firms*/
data risk_main;
merge dsf(in = a) dsf_100(in = b);
by PERMNO;
if a & b;
run;

/*--------------------------DSF 2000 to 2010--------------------------*/
/*sorts main dsf data by firm for merge*/
proc sort data = dsf_comp;
by PERMNO;
run;

/*merges data, keeps 100 random firms*/
data risk_comp;
merge dsf_comp(in = a) dsf_100(in = b);
by PERMNO;
if a & b;
run;

/*--------------------------Export--------------------------*/
/*export data to csv*/
proc export data = risk_main
dbms = csv
outfile= "&Ppath\returns_main.csv"
replace;
run;

proc export data = risk_comp
dbms = csv
outfile= "&Ppath\returns_comp.csv"
replace;
run;
