#!/bin/sh

# decrypt_autoexec.sh

decrypt_autoexec()
{
	filename=$1
	pathname=`dirname $filename`
	mntdir=/mnt/iso
	aeskey=/usr/local/pdj/aes256.key
	result=1

	# check for cryptoloop module
	if ( ! grep "^cryptoloop" /proc/modules > /dev/null 2>&1 )
	then
		#echo "$0: Please enable 'cryptoloop' module (modprobe cryptoloop)"
		#exit 1
		modprobe cryptoloop
	fi

	# -N no hash is only on Debian/Ubuntu
	NOHASH=""
	if ( losetup 2>&1 | grep "\-N" > /dev/null )
	then
		NOHASH="-N"
	fi

	# make mount directory
	mkdir -p $mntdir > /dev/null 2>&1

	# decript fs
	for dev in /dev/loop[0-7]
	do
		cat $aeskey | losetup -e aes $NOHASH -p 0 $dev $filename
		if [ $? -eq 0 ]
		then
			echo "$0: Using $dev..."
			if mount $dev $mntdir
			then
				cd $mntdir
				./autoexec.sh $pathname
				result=$?
				cd /
				umount $mntdir
			fi
			losetup -d $dev
			break
		fi
	done

	if [ $result -ne 0 ]
	then
		echo "$0:autoexec error"
	fi
	return $result
}

#
# decrypt_autoexec.sh <mount_point>
#
mount_point=$1

if [ -f $mount_point/autoexec.bin ]
then
	decrypt_autoexec $mount_point/autoexec.bin
fi

exit 0
