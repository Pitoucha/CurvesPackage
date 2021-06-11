#THIRD=ARG3
#print "script name        : ", ARG0
#print "first argument     : ", ARG1
#print "second argument     : ", ARG2
#print "third argument     : ", THIRD 
#print "number of arguments: ", ARGC 

cd ARG2

set terminal postscript eps enhanced solid color
set output "Histograms_Output/".ARG4.".eps"

set tmargin 3
set bmargin 3
set lmargin 3
set rmargin 3

unset xtics
unset ytics

set style fill solid 1.0 noborder
set boxwidth ARG1 absolute

bin_width = ARG1;

bin_number(x) = floor(x/bin_width)
rounded(x) = bin_width * ( bin_number(x) + 0.5 )

set key font ",14"
set key left width 2

set auto x
set xtics nomirror
set xtics font ",14"

set auto y
set ytics nomirror

set xlabel ARG5." ".ARG6." ".ARG7 

plot ARG3 using (rounded($1)):(1) smooth frequency with boxes lt rgb "#2E49F4" notitle 
