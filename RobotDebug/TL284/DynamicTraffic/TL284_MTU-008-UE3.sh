#!/bin/bash

a = 0
while true;
#for ((a=1; a<=50; a++))
do
	# 方法一：用$RANDOM（Bash内置随机数，范围0~32767）取模+1，确保结果1~50
	#random_num=$(( RANDOM % 50 + 1 ))

	# 方法二：生成MIN~MAX的随机数（通用公式：$(( RANDOM % (MAX - MIN + 1) + MIN ))）
	ThpMIN=1
	ThpMAX=20
	Thp_random_num=$(( RANDOM % (ThpMAX - ThpMIN + 1) + ThpMIN ))
	UDP_BANDWIDTH="${Thp_random_num}M" # 随机数作为带宽（单位：Mbit/s，1~50M）

	TestDurationMIN=20
	TestDurationMAX=20
	TEST_DURATION=$(( RANDOM % (TestDurationMAX - TestDurationMIN + 1) + TestDurationMIN ))   #unit:second

	SleepTimer=20		#unit:second
	
   iperf -u -b $UDP_BANDWIDTH -i 1 -l 1400 -t $TEST_DURATION -p 2843 -c 172.250.164.58
   #iperf -u -b 5M -i 1 -l 1400 -t 60 -p 56284 -c 172.250.164.52
   #iperf -u -b 1M -i 1 -l 1400 -t 10 -p 56286 -c 172.250.164.58
   echo "sleep start"
   #x=$(( (RANDOM % 10) + 1 ))
   #sleep $x
   sleep $SleepTimer
   ((a++))
   echo  "Num: $a sleep ${SleepTimer}s end"
   #echo  "sleep $x end"
done
