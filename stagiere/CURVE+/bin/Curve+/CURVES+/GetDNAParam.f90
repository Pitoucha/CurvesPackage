PROGRAM GetGrooveParam

character*128::data1,data2,line,input,snapin,nbasepairin
integer::i,error,snapout,nbasepairout

call getarg(1,input)
call getarg(2,snapin)
call getarg(3,nbasepairin)

read(snapin,'(i5)') snapout 
read(nbasepairin,'(i5)') nbasepairout 

   open(20,file=input)
   open(21,file='BP-Axis_Parameters',position='append')
   open(22,file='Intra-BP_Parameters',position='append')
   open(23,file='Inter-BP_Parameters',position='append')
   open(24,file='Backbone-S1_Parameters',position='append')
   open(25,file='Backbone-S2_Parameters',position='append')
   open(26,file='Groove_Parameters',position='append')


   do
      read(20,'(A128)',iostat=error) line
      if (error .ne. 0) exit




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! BP-Axis

      if (line(1:13) .eq. '  (A) BP-Axis') then
         read(20,'(A128)')
         do i=1,nbasepairout
            read(20,'(18x,a40)') data1
            write(21,'(i5,2x,i3,2x,a40)') snapout, i , data1
         enddo
         write(21,*) '    '
      endif

!  (A) BP-Axis        Xdisp   Ydisp   Inclin    Tip  Ax-bend
!
!    1) A   1-T  10   -1.95    1.35     9.1    -3.4     ---
!    2) T   2-A   9   -2.04    0.97    11.1    -4.4     1.8
!    3) A   3-T   8   -2.18   -0.18    14.2     8.0     1.8
!    4) T   4-A   7   -2.07    0.17    14.1    -2.1     1.5
!    5) A   5-T   6   -0.82    0.63    13.8    -8.1     1.2
!    6) T   6-A   5   -1.80    1.35    16.8     0.3     1.2
!    7) A   7-T   4   -0.74    0.04    14.8     8.9     0.8
!    8) T   8-A   3   -1.89   -0.68    16.9     5.1     0.7
!    9) A   9-T   2   -2.16    0.83     8.7    -4.3     0.9
!   10) T  10-A   1   -2.20    1.57    13.0     1.0     1.0
!
!       Average:      -1.78    0.61    13.2     0.1  Total bend =     8.1 (  1 to  10)





!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Intra-BP parameters

      if (line(1:25) .eq. '  (B) Intra-BP parameters') then
         read(20,'(A128)')
         read(20,'(A128)')
         read(20,'(A128)')
         do i=1,nbasepairout
            read(20,'(18x,a48)') data1
            write(22,'(i5,2x,i3,2x,a48)') snapout, i , data1
         enddo
         write(22,*) '    '
      endif

!  (B) Intra-BP parameters
!
!  Strands 1-2       Shear  Stretch Stagger  Buckle  Propel Opening
!
!    1) A   1-T  10    0.14    0.07    0.48     3.3   -18.2    -1.2
!    2) T   2-A   9    0.86    0.55    1.09     8.8   -23.9    27.0
!    3) A   3-T   8   -0.27    0.06    0.28    10.6    -8.4     7.4
!    4) T   4-A   7   -0.18    0.01   -0.38    14.3    -8.4     0.1
!    5) A   5-T   6    0.11    0.14    0.22    -9.6   -11.7     3.4
!    6) T   6-A   5    0.11    0.03    0.33    -3.2    -8.4    -0.4
!    7) A   7-T   4    0.35   -0.09   -0.07    -7.6   -24.1    -6.5
!    8) T   8-A   3    0.24   -0.10   -0.37   -18.4    -4.6     7.6
!    9) A   9-T   2    0.44   -1.64   -3.79   -44.9   -15.9    16.0
!   10) T  10-A   1    5.23   -0.87   -3.28   -32.5    27.3     9.9
!
!       Average:       0.71   -0.18   -0.55    -7.7    -9.8     6.3





!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Inter-BP parameters

      if (line(1:14) .eq. '  (C) Inter-BP') then
         read(20,'(A128)')
         do i=1,(nbasepairout-1)
            read(20,'(18x,a64)') data1
            write(23,'(i5,2x,i3,2x,a64)') snapout, i , data1
         enddo
         write(23,*) '    '
      endif

!  (C) Inter-BP       Shift   Slide    Rise    Tilt    Roll   Twist   H-Ris   H-Twi
!
!    1) A   1/T   2    0.75   -0.68    2.96    -3.0     5.4    29.8    2.55    30.8
!    2) T   2/A   3   -0.94   -0.97    4.02    -1.0     8.6    29.4    3.48    31.1
!    3) A   3/T   4    0.38   -0.45    3.12     3.3     7.3    29.0    2.71    30.5
!    4) T   4/A   5    0.69   -1.08    3.38    -7.9    20.5    25.9    2.88    29.2
!    5) A   5/T   6   -1.47   -1.19    3.46     0.5     2.5    31.3    3.07    31.8
!    6) T   6/A   7   -0.65    0.11    2.81    -0.7     0.3    33.4    2.64    33.5
!    7) A   7/T   8    1.67   -0.74    3.50     4.7    -3.0    38.4    3.53    38.8
!    8) T   8/A   9    0.56    0.68    5.20    26.9    31.1    16.1    5.13    23.8
!    9) A   9/T  10   -1.44    0.19    2.47    -4.5    16.9    61.2    2.03    65.6
!
!       Average:      -0.05   -0.46    3.44     2.0     9.9    32.6    3.11    34.9





!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Backbone parameters

      if (line(1:25) .eq. '  (D) Backbone Parameters') then
         read(20,'(A128)')
         read(20,'(A128)')
         read(20,'(A128)')
         do i=1,nbasepairout
            read(20,'(14x,a70)') data1
            write(24,'(i5,2x,i3,2x,a70)') snapout, i , data1
         enddo
         write(24,*) '    '
      endif

      if (line(1:11) .eq. '   Strand 2') then
         read(20,'(A128)')
         do i=1,nbasepairout
            read(20,'(14x,a70)') data1
            write(25,'(i5,2x,i3,2x,a70)') snapout, i , data1
         enddo
         write(25,*) '    '
      endif


!  (D) Backbone Parameters
!
!   Strand 1     Alpha  Beta   Gamma  Delta  Epsil  Zeta   Chi    Phase  Ampli  Puckr
!
!    1) A   1     ----   ----   63.8  102.1 -152.7  -80.2 -168.2   94.9   46.9  O1'en
!    2) T   2    -79.1  173.6   54.5  119.9 -161.7  -97.4 -107.4  131.1   47.2  C1'ex
!    3) A   3    -91.8 -178.4   58.7  132.9 -174.2 -103.0 -105.3  149.8   43.2  C2'en
!    4) T   4    -65.2  165.3   67.6  104.6 -162.6  -88.4 -152.9   94.3   48.3  O1'en
!    5) A   5    -56.3  176.8   35.9  131.9 -167.8 -119.8 -107.1  154.7   28.2  C2'en
!    6) T   6     57.0 -170.5  -82.1  154.5 -164.3  -90.1  -97.2 -147.3   37.8  C3'ex
!    7) A   7    -57.6  155.0   45.8  116.9  173.6  -79.3  -92.1  141.2   48.2  C1'ex
!    8) T   8    -76.2  175.8   67.7   88.2 -164.6  -91.1 -139.0   91.9   48.4  O1'en
!    9) A   9    -61.7  147.5   60.8  135.6 -167.2  -89.3 -122.3  141.8   50.5  C1'ex
!   10) T  10    -69.3  166.9   56.3  103.7   ----   ---- -146.3  126.2   37.9  C1'ex
!
!   Strand 2     Alpha  Beta   Gamma  Delta  Epsil  Zeta   Chi    Phase  Ampli  Puckr
!
!    1) T  10    -80.3 -169.2   59.9  132.4   ----   ---- -114.2  132.2   47.3  C1'ex
!    2) A   9    -75.4  171.0   57.8  108.2 -177.8  -86.4 -137.6  122.1   36.8  C1'ex
!    3) T   8    -71.1  169.5   53.8  112.0 -164.1  -83.1 -131.0  108.9   37.4  C1'ex
!    4) A   7    -87.8 -177.0   71.7  136.3 -164.2 -122.6 -112.4  147.4   45.1  C2'en
!    5) T   6    -66.1  177.8   57.5   93.4 -168.9  -65.1 -138.4   43.9   26.7  C4'ex
!    6) A   5    -80.3 -175.4   48.9  139.3  177.7 -105.0  -85.4  168.4   39.8  C2'en
!    7) T   4   -114.4  162.8   67.7  123.3 -149.8 -106.8 -141.4  136.0   33.9  C1'ex
!    8) A   3    -75.7  132.8   43.1  115.0  -66.9   94.0  -80.2  125.8   54.0  C1'ex
!    9) T   2    -79.9  166.0   68.4  115.4  -73.6  -57.9 -134.2  111.6   32.1  C1'ex
!   10) A   1     ----   ----   62.6  120.4 -171.6  -97.9 -137.6  126.8   49.6  C1'ex





!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Groove parameters

      if (line(7:23) .eq. 'Groove parameters') then
         read(20,'(A128)') 
         read(20,'(A128)') 
         read(20,'(A128)') 
         
         do i=1,(2*nbasepairout -3)
            read(20,'(2x,a6,8x,a30)') data1,data2
            write(26,'(i5,2x,a6,2x,a30)') snapout, data1, data2
         enddo
         write(26,*) '    '
     endif
  enddo



!  (E) Groove parameters
!
!   Level           W12     D12     W21     D21
!
!    1.5
!    2.0  T   2
!    2.5
!    3.0  A   3     3.2     5.3
!    3.5            5.8     4.5
!    4.0  T   4     9.8     2.8
!    4.5           11.8    -0.7
!    5.0  A   5    10.3     1.0    13.3     6.8
!    5.5           12.0    -0.1    12.6     7.6
!    6.0  T   6     9.2     2.4
!    6.5            5.9     4.4
!    7.0  A   7     4.2     4.4
!    7.5            5.0     4.5
!    8.0  T   8     5.7     4.4
!    8.5
!    9.0  A   9
!    9.5


close(20)
close(21)
close(22)
close(23)
close(24)
close(25)
close(26)

END 
