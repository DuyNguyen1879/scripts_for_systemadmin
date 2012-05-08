#!/bin/bash

#This script is only for GANGLIA
###Apache Log parser
#Parse XX minutes log to find out
#total 2XX, 3XX, 4XX, and 5XX.
#page respose time as total pages respose in 
#between 0-5, 6-10, 11-20, 21 + sec. 
#Aslo to find out top 10 refferer and top 10 high hits ips.
#

if [ $# -ne 2 ] ; then
	echo "Usage: $0 logfilepath  pattern " >&2 ; 
	exit 1
fi

##
path=$1
pattern=$2
sdate=$(cat /tmp/last_check_date)
edate=$(date +%Y:%H:%M:%S)
GMETRIC=/usr/bin/gmetric
##

sed -n "/$sdate/,/$edate/ {p;}" ${path} |grep ${pattern} > /tmp/$$.txt

##Total Hits
hits="$(wc -l < "/tmp/$$.txt" | sed 's/[^[:digit:]]//g')"
#${GMETRIC} --name=Total_${pattern}_pages --value=${hits} --type=float
echo "Total Hits for ${pattern} are ${hits}"

##Status Code
echo Status codes and its count are as below 
awk '{print $9}' "/tmp/$$.txt" | sort |uniq -c > /tmp/$$.code
while read line    
	do    
	a=${line}
#	${GMETRIC} --name=${pattern}_$(echo ${a} | awk '{print $2}') --value=$(echo ${a} | awk '{print $1}')  --type=float
	echo count is  $(echo ${a} | awk '{print $1}')  for status code $(echo ${a} | awk '{print $2}')   
	done < /tmp/$$.code   

##Request Time
echo Request time count 0-5 sec 
#${GMETRIC} --name=${pattern}_0-5_sec --value=$(awk '{if ($11/100000 <= 5) print $0}' /tmp/$$.txt | wc -l) --type=float
awk '{if ($11/100000 <= 5) print $0}' /tmp/$$.txt | wc -l
echo Request time count 6-10 sec
#${GMETRIC} --name=${pattern}_6-10_sec --value=$(awk '{if ($11/100000 >= 6) print $0}' /tmp/$$.txt | awk '{if ($11/100000 <= 10) print $0}'  | wc -l) --type=float
awk '{if ($11/100000 >= 6) print $0}' /tmp/$$.txt | awk '{if ($11/100000 <= 10) print $0}'  | wc -l
echo Request time count 11-20 sec
#${GMETRIC} --name=${pattern}_11-20_sec --value=$(awk '{if ($11/100000 >= 11) print $0}' /tmp/$$.txt | awk '{if ($11/100000 <= 20) print $0}'  | wc -l) --type=float
awk '{if ($11/100000 >= 11) print $0}' /tmp/$$.txt | awk '{if ($11/100000 <= 20) print $0}'  | wc -l
#echo Request time count 21+ sec
#${GMETRIC} --name=${pattern}_21plus_sec --value=$(awk '{if ($11/100000 >= 21) print $0}' /tmp/$$.txt | wc -l) --type=float
awk '{if ($11/100000 >= 21) print $0}' /tmp/$$.txt | wc -l

##Top IP hits
awk '{print $1}' /tmp/$$.txt | sort | uniq -c | head -n10

##Top Refferere
awk '{print $12}' /tmp/$$.txt | sort | uniq -c | head -n10

echo $edate > /tmp/last_check_date
rm /tmp/$$.txt
rm /tmp/$$.code
exit 0


##`date +%Y%b%d`

