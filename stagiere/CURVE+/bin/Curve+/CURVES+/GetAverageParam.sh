#!/bin/bash

#./script npair nsnapshots 

for i in Xdisp Shear Shift Ydisp Stretch Slide Inclin Stagger Rise Tip Buckle Tilt Ax-bend Propel Roll Opening Twist H-Ris H-Twi W12 D12 W21 D21 Alpha1 Beta1 Gamma1 Delta1 Epsil1 Zeta1 Chi1 Phase1 Ampli1 Alpha2 Beta2 Gamma2 Delta2 Epsil2 Zeta2 Chi2 Phase2 Ampli2
   do for j in `seq 1 1 $1`
      do

 cat $i-$j.dat | awk '{sum += $2} { i += 1 }  END{print '$j' , sum/i} ' >> $i-average.dat
      done
done
