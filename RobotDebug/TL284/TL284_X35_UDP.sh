#!/bin/sh
#while true;
for ((a=1; a<=50; a++))
do
   iperf -u -b 10M -i 1 -l 1400 -t 5 -p 56284 -c 172.250.164.52
   echo "sleep start"
   #x=$(( (RANDOM % 10) + 1 ))
   #sleep $x
   sleep 20
   echo  "$a sleep 35s end"
   #echo  "sleep $x end"
done
