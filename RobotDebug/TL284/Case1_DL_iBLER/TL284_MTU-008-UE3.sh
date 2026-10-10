#!/bin/sh
a = 0
while true;
#for ((a=1; a<=50; a++))
do
   iperf -u -b 20M -i 1 -l 1400 -t 20 -p 2843 -c 172.250.164.58
   #iperf -u -b 5M -i 1 -l 1400 -t 60 -p 56284 -c 172.250.164.52
   #iperf -u -b 1M -i 1 -l 1400 -t 10 -p 56286 -c 172.250.164.58
   echo "sleep start"
   #x=$(( (RANDOM % 10) + 1 ))
   #sleep $x
   sleep 20
   ((a++))
   echo  "Num: $a sleep 15s end"
   #echo  "sleep $x end"
done
