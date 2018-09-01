# ewpfr
IBM i - Performance Analisis

This simple script based on PDI just create a couple of auxiliary tables and alias to performance data members, with a CSV output. 
You can easily convert this output into charts with Excel, GNumeric or OpenOffice.

It's really fast!

You need to make some small changes to the CONSTANTS, so they point to the IFS directory where this script lives.

How to run this script:

1) Use "ssh" to connect to your IBM i
2) CD to the directory where you've copied the files
3) ./EWPFR3.sh <First_Member> <Last_Member>

Requirements

* SSHD server running on IBM i
* BASH

Good Luck!
