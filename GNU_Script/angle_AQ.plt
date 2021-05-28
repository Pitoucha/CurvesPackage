set tmargin 0
set bmargin 0
set lmargin 3
set rmargin 3
unset xtics
unset ytics

set terminal pngcairo enhanced font "Arial, 14"
set encoding iso_8859_1
set output 'angle_WT.png'


set multiplot layout 3,1 


#set border 3

# Add a vertical dotted line at x=0 to show centre (mean) of distribution.
#set yzeroaxis


# Each bar is half the (visual) width of its x-range.
set boxwidth 0.1 absolute
#set style fill transparent solid 0.5 noborder
set style fill transparent solid 1.0

#set yrange [0:40]
set xrange [102:133]


binwidth=0.1
bin(x,width)=width*floor(x/width)

plot 'angle_apo_AQ.dat' using (bin($2,binwidth)):(1.0) smooth freq with boxes lt rgb 'black' t 'apo'
set xtics nomirror
set xtics scale 0 font ",14"
set xlabel "Angle (°)"
plot 'angle_cGAMP_AQ.dat' using (bin($2,binwidth)):(1.0) smooth freq with boxes lt rgb '#CC0000' t 'cGAMP'

unset multiplot

