#!/bin/sh

# write the serial number to a json file on USB storage media.
# this script is called by udev rules.

mountp=$1
hfsplus=$2

#mountp=.
#echo mountp=${mountp}
#echo hfsplus=${hfsplus}

model=XDJ-RR
#echo model=${model}

#uuid=`uuid -v4`
#md5=`echo ${model} | md5sum | cut -d' ' -f1`
md5=3db3df1428d0cb60f8bcb7d2f6a548ba

#fname=${uuid}-alog_1.json
fname=${md5}-alog_1.json
#echo fname=${fname}

path1=${mountp}/PIONEER		# vfat/exfat
#echo path1=${path1}
path2=${mountp}/.PIONEER	# hfsplus
#echo path2=${path2}

# check "PIONEER" directory exists
if [ ${hfsplus} -eq 1 ]; then
	if [ ! -d ${path2} ]; then
		#echo "${path2} is not found."
#		mkdir -p ${path2}
#		sync
		exit 1
	fi
	#echo "path2=${path2} is found."
	p_path=${path2}
else
	if [ ! -d ${path1} ]; then
		#echo "${path1} is not found."
		exit 1
	fi
	#echo "path1=${path1} is found."
	p_path=${path1}
fi
#echo p_path=${p_path}

log_path=${p_path}/log
#echo log_path=${log_path}
if [ ! -d ${log_path} ]; then
	mkdir -p ${log_path}
	sync
fi

out_file=${log_path}/${fname}
#echo out_file=${out_file}

max_file_size=100000	# 100kB
#max_file_size=1000
#echo max_file_size=${max_file_size}

# check json file exists
if [ -w ${out_file} ]; then
	# check file size
	file_size=`wc -c ${out_file} | cut -d' ' -f1`
	#echo file_size=${file_size}
	if [ ${file_size} -ge ${max_file_size} ]; then
		#echo "file_size=${file_size} >= ${max_file_size}"
		exit 1
	fi
fi

if [ ! -x /usr/bin/fw_printenv ]; then
	#echo "fw_printenv not found."
	exit 1
fi

#media=SD
media=USB

serial=`fw_printenv -n serial_num`
#serial=ABCD123456EF
#echo serial=${serial}
if [ -z "${serial}" ]; then
	#echo serial=${serial} length zero
	exit 1
fi

firm_ver=`fw_printenv -n release`
#firm_ver=1.00
#echo firm_ver=${firm_ver}
if [ -z "${firm_ver}" ]; then
	#echo firm_ver=${firm_ver} length zero
	exit 1
fi

time=`date "+%Y-%m-%d %H:%M:%S"`
#echo time=${time}

# write on json file
#{"session_id": "0", "time": "2023-06-07 00:00:00", "model": "CDJ-2000NXS2", "serial": "OIMP000069TP", "firm_ver": "1.85++", "uid": "0", "action": "Action", "name": "MOUNT", "str1": "USB"}

echo {\"session_id\": \"0\", \"time\": \"${time}\", \"model\": \"${model}\", \"serial\": \"${serial}\", \"firm_ver\": \"${firm_ver}\", \"uid\": \"0\", \"action\": \"Action\", \"name\": \"MOUNT\", \"str1\": \"${media}\"} >> ${out_file}
#echo {\"session_id\": \"0\", \"time\": \"${time}\", \"model\": \"${model}\", \"serial\": \"${serial}\", \"firm_ver\": \"${firm_ver}\", \"uid\": \"0\", \"action\": \"Action\", \"name\": \"MOUNT\", \"str1\": \"${media}\"}
sync

exit 0
