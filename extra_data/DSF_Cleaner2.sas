/*Austin Griffith
/*11/19/2017
/*Risk Management*/

OPTIONS ls = 70 nodate nocenter;
OPTIONS missing = '';

/*file paths need to be updated according to current computer*/
%let Ppath = P:\Risk;
%let Dpath = Q:\Data-ReadOnly\CRSP;

libname comp "&Cpath";
libname crsp "&Dpath";
libname risk "&Ppath";

/*--------------------------DSF--------------------------*/
/*data is on a daily basis*/
/*pulls data from dsf file*/
data dsf_input;
set crsp.dsf (keep = PERMNO DATE RET);
YEAR = year(DATE);
format DATE mmddyy10.;
if YEAR >= 1979 and YEAR <= 2010;
if missing(PERMNO) then delete;
if nmiss(RET) then delete;
run;

/*data for random time period*/
data dsf;
set dsf_input;
if YEAR < 2000 then delete;
run;

/*creates new set of data*/
/*used to determine random 200 permnos*/
data dsf_perm;
set dsf;
keep PERMNO;
run;

/*limits data to only one obs of each permno*/
proc sort data = dsf_perm nodupkey;
by PERMNO;
run;

/*takes 200 random obs from list of firms*/
proc surveyselect data = dsf_perm
method=srs
n = 200
seed = 903353429
out = dsf_200
noprint;
run;

/*sorts main dsf data by firm for merge*/
proc sort data = dsf;
by PERMNO;
run;

/*merges data, keeps 200 random firms*/
data risk_main;
merge dsf(in = a) dsf_200(in = b);
by PERMNO;
if a & b;
run;

/*--------------------------DSF 1980 to 1990--------------------------*/
/*sorts main dsf data by firm for merge*/
proc sort data = dsf_input;
by PERMNO;
run;

/*merges data, keeps 200 random firms*/
data dsf_limited;
merge dsf_input(in = a) dsf_200(in = b);
by PERMNO;
if a & b;
run;

/*gets desired year for comparison sample*/
data risk_comp;
set dsf_limited;
if YEAR > 1990 then delete;
if YEAR < 1980 then delete;
run;

/*--------------------------Historical--------------------------*/
/*gets historical return data year prior to sample 2005-2010*/
data main_hist;
set dsf_limited;
if YEAR = 1999;
run;

/*gets historical return data year prior to sample 2000-2010*/
data comp_hist;
set dsf_limited;
if YEAR = 1979;
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

proc export data = main_hist
dbms = csv
outfile= "&Ppath\returns_main_hist.csv"
replace;
run;

proc export data = comp_hist
dbms = csv
outfile= "&Ppath\returns_comp_hist.csv"
replace;
run;
