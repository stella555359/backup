#!/bin/bash

ShFileSignature="TL284"
ps -ef |grep $ShFileSignature > "Runing_iperf.txt"
ps -ef |grep 172.250.164.52 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.38 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.58 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.60 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.48 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.35 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.63 >> "Runing_iperf.txt"
ps -ef |grep 172.250.164.30 >> "Runing_iperf.txt"

awk '/\/bin\/bash/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' > tmp_iperf.txt
awk '/\/bin\/sh/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.52/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.38/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.58/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.60/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.48/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.35/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.63/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt
awk '/172.250.164.30/ && /iperf/' Runing_iperf.txt| awk -F'vrf4_sg6 ' '{print $2}'| awk -F' ' '{print $1}' >> tmp_iperf.txt

while read line; do
	if [ -n "$line" ]; then
	#$line不为空，则执行下面的指令
		echo "Executed: kill -9 $line"
		kill -9 "$line"
	fi
done < tmp_iperf.txt
#rm -f tmp_iperf.txt
#rm -f Runing_iperf.txt




