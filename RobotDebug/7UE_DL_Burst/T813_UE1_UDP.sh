#!/bin/sh
while true;
do
	   iperf -c 100.76.95.90 -u -t 20 -i 1 -p 56813 -P 2 -f m -b 2M -l 1400B -T 64
	   echo "sleep start"
	   sleep 20
           echo  "sleep end"
	   done
