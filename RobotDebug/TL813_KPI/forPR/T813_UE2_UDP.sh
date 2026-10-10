#!/bin/sh
a = 0
while true;
#for ((a=1; a<=50; a++))
do
   iperf -u -b 2M -i 1 -l 1400 -t 20 -p 56823 -c 172.250.236.122
   echo "sleep start"
   sleep 20
   #((a++))
   #echo  "Num: $a sleep 15s end"
done
