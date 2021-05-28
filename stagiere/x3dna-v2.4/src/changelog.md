## V2.4.2
* Simplified `get_3dna_homedir()` --- the X3DNA environment variable must be set, no longer checking for `$HOME/`
* Revised `residue_ident()` to account for special cases as in http://forum.x3dna.org/md-simulations/analysis-of-helical-parameter-of-dna-with-unnatural

## 3DNA change log (for v2.3.2)

### 2017-nov-02
* revised `output_ave_std()` for leading spaces with ave./s.d.
* revised `cehs_cmdline()` to handle stdin. Now `find_pair 355d.pdb | cehs` is acceptable.

## Previous logs

```
Friday, 07-22-2005
[1] For special cases with regard to step parameters, e.g.
	0.00   20.00    0.00  180.00    0.00    0.00

  the rebuilt structure is correct, but the "analyze" routine gives
  wrong structural parameters. This is because the z-axes are perfectly
  antiparallel, and thus the hinge axis can not be uniquely defined
  based purely on z1 and z2, but must take consideration of x- and y-
  axes.

  Corrected!

[2] is RollTilt angle is > 180, then the re-calculated structure parameters are
    not identical to the original, e.g.

Your six input step parameters:
    Shift    Slide     Rise     Tilt     Roll    Twist
   0.0000  20.0000   0.0000 160.0000 160.0000   0.0000
Recalculated parameters (for verification):
  20.0000   0.0000   0.0000 -94.5584 -94.5584   0.0000

However, these two sets are IDENTICAL, because they correspond to the same
relative base-pair geometry.

Position of the 2nd base-pair:   13.9293   6.0707  13.0046

Direction cosines of x-axis:      0.1544   0.8456   0.5110
Direction cosines of y-axis:      0.8456   0.1544  -0.5110
Direction cosines of z-axis:     -0.5110   0.5110  -0.6912

The set with RollTilt < 180 are the default.

[3] Modify "step_hel" to also output recalculated parameters as shown in [2]
    above for verification purpose.

[4] correction for "wired" to "weird" ... so funny


Sunday, July 24, 2005

[1] take model number into consideration, add more info in array Miscs
[2] fgets include \n before adding \0!!!

Monday, July, 2005

[1] modify "cehs" to account for B-/Z-junction by adding -n option
[2] improve blocview
[3] add bz_check in frame_mol

To do list:
   whenever bpstep_par is used, we need to verify bz_check
   get into it when real B/Z structure are available.

Tuesday, August 23, 2005

  In file $X3DNA/BASEPARS/help3dna.dat
   for help to "rotate_mol", the example section should be
   rotate_mol -t=rotmat.dat sample.pdb sample_rmat.pdb

Wednesday, August-24-2005
   [1] in 'rotate_mol', fix a bug when the rotation matrix in column-wise
          orientation. Initially, there were no difference between the
          two options (row-wise or column-wise).

   [2] add a new functionality in 'rotate_mol' so that the rebuilt structure
       can be transformed into the same orientation as in the original one.
       E.g.,
               find_pair -t bdl084.pdb stdout | analyze
               cp ref_frames.dat bdl084_frame.dat
               rebuild -atomic bp_step.par bdl084_3dna.pdb
               rotate_mol -o=bdl084_frame.dat bdl084_3dna.pdb bdl084_bp1.pdb
      another option is with -t=ref_row.dat -l

Friday, September-9-2005
   [1] add functionalities in "ana_fncs.c"/"analyze.c" to generate the O1P/O2P
       coordinates w.r.t. the middle-frame.
   [2] wrote Perl script "OP_Mxyz" to extract the info in tabular format.

Saturday, September-18-2005
   [1] modifies cehs.c for array phos to include O1P/O2P label, since
       analyze has been changes to getting their coordinates w.r.t. the
       middle frame.

Tuesday 9-20-2005
   [1] combine #include files, and put them all in "x3dna.h"
   [2] use cxref to get cross references among the C functions.

Thursday 9-22-2005
   [1] fixed a bug in read_pdb -- "Miscs" matrix; set 29th column to '\0' and
       increase NMISC to 34
   [2] move output of P coordinates w.r.t. the middle from to below those for
       O1P and O2P, to make aveS and aveH correct for later on classification.

Tuesday 9-27-2005
   [1] change time function from clock to time & difftime which gives real time
       in seconds passed from starting to the end of the program run.
   [2] revise the code by creating a function print_used_time() that is
       called by find_pair, analyze etc to simplify the process.

Monday 10-10-2005
   [1] change read_pdb for AtomName --- Fei reported the non-PDB format
              way of naming AtomName e.g. 'C4  ' instead of ' C4 '
       taking this special case into consideration

Sunday 10-30-2005
   [1] change analysis routines to make B-Z junction analysis the default
       -n to set bz = 0 ---- the previous behavior
       analyze.c; cehs.c

   [2] make hetatm = 1 the default, i.e., taking consideration of HETATM
       add option -a to account for only ATOM records

   [3] fixing bugs in handling special case for atoms names:
          a). check for 1st $character  AND 2nd char as well, so that
              standard cases, e.g., "MN  " in pd0001 won't be mistaken.
          b). move the section upwards for further processing.

   [4] name this new version v1.6 for public release.
```
