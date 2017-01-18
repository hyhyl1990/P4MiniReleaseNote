#! /bin/bash

#-----------------------------------------------------------------------
#Function:EchoInfo
#-----------------------------------------------------------------------
function EchoInfo()
{
	echo -e "\e[1;32m-----------------------------------------------------------------------\e[0m"
	echo -e "\e[1;32m                          $1 \e[0m"
	echo -e "\e[1;32m-----------------------------------------------------------------------\e[0m"
}

#-----------------------------------------------------------------------
#Function:echo single line
#-----------------------------------------------------------------------
function EchoInfoSingleLine()
{
	echo -e "\e[1;32m             $1 \e[0m"
}

EchoInfo "Weclome"
#EchoInfoSingleLine "Please check the file config.ini"

#-----------------------------------------------------------------------
#get the p4 env information
#-----------------------------------------------------------------------
p4port=`grep  "P4PORT" config.ini | cut -d "=" -f 2`
p4user=`grep  "P4USER" config.ini | cut -d "=" -f 2`
if [ "" = "$p4port" -o "" = "$p4user" ]
then
	EchoInfoSingleLine "the p4port and p4user cann't be blank!"
	exit
fi
P4PORT=$p4port
P4USER=$p4user
export P4PORT
export P4USER

#-----------------------------------------------------------------------
#print the p4 env info
#-----------------------------------------------------------------------
EchoInfoSingleLine "your p4 env info is as below"
p4 set

#-----------------------------------------------------------------------
#login p4
#-----------------------------------------------------------------------
EchoInfoSingleLine "              login p4"
p4 login

#-----------------------------------------------------------------------
#get the Branch Information
#-----------------------------------------------------------------------
begin=`grep -n "Branch Information START" config.ini | cut -d ":" -f 1`
end=`grep -n "Branch Information END" config.ini | cut -d ":" -f 1`
sed -n "$((${begin}+1)) ,$((${end}-1))p" config.ini > filedirec.txt

#-----------------------------------------------------------------------
#get the CL Information
#get the STARTCL and ENDCL
#-----------------------------------------------------------------------
startcl=`grep "STARTCL" config.ini | cut -d "=" -f 2`
endcl=`grep "ENDCL" config.ini | cut -d "=" -f 2`
#check whether the cl range is valid or not
if [ $startcl -gt $endcl ]
then
	EchoInfoSingleLine "the endcl should be larger than startcl"
	exit
fi

#-----------------------------------------------------------------------
#delete the temp file
#-----------------------------------------------------------------------
rm -f filelog*.txt clname1.txt clname.txt

echo
EchoInfoSingleLine "   Please wait for seconds......"
echo

#-----------------------------------------------------------------------
#read the directory line by line
#get the cls and submitter of each directory
#-----------------------------------------------------------------------
#read all directories
cat filedirec.txt | while read filedirec
do
	# the command "p4 filelog" can get the history the file or directory on p4
	p4 filelog $filedirec >> filelog1.txt
	#get the lines begin with "... #"
	sed -n '/^... #/p' filelog1.txt >> filelog2.txt
	#get the 4th and 9th column
	# the 4th cloumn is cl num, and the 9th column is submitter
	cut -d ' ' -f 4,9 filelog2.txt >> clname.txt
done

#-----------------------------------------------------------------------
#delete the blank lines of clname1.txt
# in case of the blank lines
#-----------------------------------------------------------------------
sed '/^$/d' clname.txt > clname1.txt

#-----------------------------------------------------------------------
#check cl range
# if startcl = 0 && endcl =0 (that is the default value),
# then we will get all the cls
# else will get cl between startcl and endcl
#-----------------------------------------------------------------------
#print the title of the result file (cl , submitter)
#echo cl submitter > clname.txt
rm clname.txt

# if startcl != 0 | endcl != 0
# that is, the user input the startcl or endcl instead of using the default value
if [ $startcl -ne 0 -o $endcl -ne 0 ]
then
	cat clname1.txt | while read line
	do
		# get the cl num
		# the 1st column is cl
		cl=`echo $line | cut -d " " -f 1`
		# check wheter the cl value is beteen the startcl and endcl
		# if yes, it is the needed cl
		if [ $cl -ge $startcl -a $cl -le $endcl ]
		then
			echo $line | cut -d "@" -f 1 >> clname.txt
		fi
	done
else
	# this is default case
	# that is, the startcl is 0 and the endcl is 0
	# so, we don't need to check the cl value
	cat clname1.txt | while read line
	do
		echo $line | cut -d "@" -f 1 >> clname.txt
	done
fi

#-----------------------------------------------------------------------
# delete the repeat lines in clname.txt
#-----------------------------------------------------------------------
cat clname.txt | sort | uniq > result.txt

#-----------------------------------------------------------------------
# print the result hint on the screeen
#-----------------------------------------------------------------------
EchoInfoSingleLine "the result has been put to the result.txt"

#gedit clname.txt

#-----------------------------------------------------------------------
#delete the temp files
#-----------------------------------------------------------------------
rm -f filelog*.txt clname*.txt filedirec.txt 

#-----------------------------------------------------------------------
#show the files
#-----------------------------------------------------------------------
#ls
echo

