#!/bin/bash

NATOMS=$(($1+1))

sed '1d' snapshots.pdb > snapshots.tmp 

for f in `seq 1 1 274`

do

head -n $NATOMS snapshots.tmp > snapshot-$f.pdb

mv snapshots.tmp snapshots.tmp2

sed '1,'$NATOMS'd' snapshots.tmp2 > snapshots.tmp

done
