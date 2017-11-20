/*Austin Griffith
/*11/19/2017
/*Risk Management*/


/*random number generator for determining years of data*/
%let N = 1;
data random_numbers(keep = u k year);
call streaminit(903353429);

Max = 30;
do i = 1 to &N;
u = rand("Uniform");
k = ceil(Max*u); /*integer values from 1 to 30*/
year = 1980 + k;
output;
end;
run;
