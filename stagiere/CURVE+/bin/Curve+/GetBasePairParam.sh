#!/bin/bash

#./script npair nsnapshots 

for i in Xdisp Shear Shift Ydisp Stretch Slide Inclin Stagger Rise Tip Buckle Tilt Ax-bend Propel Roll Opening Twist H-Ris H-Twi W12 D12 W21 D21 Alpha1 Beta1 Gamma1 Delta1 Epsil1 Zeta1 Chi1 Phase1 Ampli1 Alpha2 Beta2 Gamma2 Delta2 Epsil2 Zeta2 Chi2 Phase2 Ampli2
   do for j in `seq 1 1 $4`
      do for k in `seq $1 $2 $3`
         do
         if  [ $i == W12 ] || [ $i == Alpha1 ] || [ $i == Alpha2 ]
            then COL=4
            elif [ $i == Xdisp ] || [ $i == Shear ] ||  [ $i == Shift ] ||  [ $i == D12 ] || [ $i == Beta1 ] || [ $i == Beta2 ] 
               then COL=5
            elif [ $i == Ydisp ] || [ $i == Stretch ] ||  [ $i == Slide ] ||  [ $i == W21 ] || [ $i == Gamma1 ] || [ $i == Gamma2 ]                
               then COL=6
            elif [ $i == Inclin ] || [ $i == Stagger ] ||  [ $i == Rise ] ||  [ $i == D21 ] || [ $i == Delta1 ] || [ $i == Delta2 ]
               then COL=7
            elif [ $i == Tip ] || [ $i == Buckle ] ||  [ $i == Tilt ] || [ $i == Epsil1 ] || [ $i == Epsil2 ]
               then COL=8
            elif [ $i == Ax-bend ] || [ $i == Propel ] ||  [ $i == Roll ] || [ $i == Zeta1 ] || [ $i == Zeta2 ]
               then COL=9
            elif [ $i == Opening ] || [ $i == Twist ] || [ $i == Chi1 ] || [ $i == Chi2 ] 
               then COL=10
            elif [ $i == H-Ris ] || [ $i == Phase1 ] || [ $i == Phase2 ]
               then COL=11
            elif [ $i == H-Twi ] || [ $i == Ampli1 ] || [ $i == Ampli2 ]
               then COL=12
            else echo "INVALID PARAMETER, choose between:"
                 echo
                 echo "Xdisp Ydisp Inclin Tip Ax-bend"
                 echo "For BP-Axis parameters"
                 echo
                 echo "Shear Stretch Stagger Buckle Propel Opening"
                 echo "For Intra-BP parameters"
                 echo
                 echo "Shift Slide Rise Tilt Roll Twist H-Ris H-Twi"
                 echo "For  Inter-BP parameters"
                 echo 
                 echo "Alpha1 Beta1 Gamma1 Delta1 Epsil1 Zeta1 Chi1 Phase1 Ampli1"
                 echo "For Backbone parameters of the first strand"
                 echo 
                 echo "Alpha2 Beta2 Gamma2 Delta2 Epsil2 Zeta2 Chi2 Phase2 Ampli2"
                 echo "For Backbone parameters of the second strand"
                 echo 
                 echo "W12 D12 W21 D21"
                 echo "For Groove parameters"
         fi
         if [ $i == Xdisp ] || [ $i == Shear ] || [ $i == Shift ] || [ $i == Ydisp ] || [ $i == Stretch ] || [ $i == Slide ] || [ $i == Inclin ] || [ $i == Stagger ] || [ $i == Rise ] || [ $i == Tip ] || [ $i == Buckle ] || [ $i == Tilt ] || [ $i == Ax-bend ] || [ $i == Propel ] || [ $i == Roll ] || [ $i == Opening ] || [ $i == Twist ] || [ $i == H-Ris ] || [ $i == H-Twi ]
            then 
            sed -n '/'$i'/,/Average/'p'' snapanal-$k.lis | grep ''$j')' | awk '{print '$k' , $'$COL' }'
         elif [ $i == Alpha1 ] || [ $i == Beta1 ] || [ $i == Gamma1 ] || [ $i == Delta1 ] || [ $i == Epsil1 ] || [ $i == Zeta1 ] || [ $i == Chi1 ] || [ $i == Phase1 ] || [ $i == Ampli1 ]
            then sed -n '/Strand 1/,/Strand 2/'p'' snapanal-$k.lis | grep ''$j')' | awk '{print '$k' , $'$COL' }'
         elif [ $i == Alpha2 ] || [ $i == Beta2 ] || [ $i == Gamma2 ] || [ $i == Delta2 ] || [ $i == Epsil2 ] || [ $i == Zeta2 ] || [ $i == Chi2 ] || [ $i == Phase2 ] || [ $i == Ampli2 ]
            then sed -n '/Strand 2/,/Groove parameters/'p'' snapanal-$k.lis | grep ''$j')' | awk '{print '$k' , $'$COL' }'
         elif [ $i == W12 ]
            then echo -ne $k \ ; sed -n '/'$i'/,/$d/'p'' snapanal-$k.lis | grep ' '$j' ' | cut -c 17-22  
         elif [ $i == D12 ]
            then echo -ne $k \ ; sed -n '/'$i'/,/$d/'p'' snapanal-$k.lis | grep ' '$j' ' | cut -c 25-30  
         elif [ $i == W21 ]  
            then echo -ne $k \ ; sed -n '/'$i'/,/$d/'p'' snapanal-$k.lis | grep ' '$j' ' | cut -c 33-38
         elif [ $i == W21 ]  
            then echo -ne $k \ ; sed -n '/'$i'/,/$d/'p'' snapanal-$k.lis | grep ' '$j' ' | cut -c 41-46
         fi
         done > $i-$j.tmp
         sed '/       /d' $i-$j.tmp > $i-$j.dat
         rm $i-$j.tmp
      done
   done
