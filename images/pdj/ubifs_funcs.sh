#!/bin/sh

# ubifs_func.sh

initialize_ubifs()
{
	# ギャングライター書込後の初回起動時のみ UBIFS 領域をフォーマットして書き込む
	ubifs_formatted=`fw_printenv -n ubifs_formatted`

	if [ "$ubifs_formatted" != "true" ]; then
		echo "### initialize_ubifs() ###"

		mkdir -p /mnt/flash

		echo "mount -t tmpfs enter"
		mount -t tmpfs -o size=60m /dev/shm /mnt/flash
		result_mount_tmpfs=$?
		echo "mount -t tmpfs return [$result_mount_tmpfs]"

		# gui (mtd10) <- gui.tar.gz (mtd9)
		echo "nanddump -q --omitoob --bb=skipbad --length=0x800000 -f /mnt/flash/gui.tar.gz /dev/mtd9 enter"
		nanddump -q --omitoob --bb=skipbad --length=0x800000 -f /mnt/flash/gui.tar.gz /dev/mtd9		# 8MB
		result_nanddump=$?
		echo "nanddump -q --omitoob --bb=skipbad --length=0x800000 -f /mnt/flash/gui.tar.gz /dev/mtd9 return [$result_nanddump]"
		sync
#		ls -Fla /mnt/flash/gui.tar.gz
		echo "format_ubifs gui /dev/mtd10 /mnt/flash/gui.tar.gz enter"
		format_ubifs gui /dev/mtd10 /mnt/flash/gui.tar.gz
		result_gui=$?
		echo "format_ubifs gui /dev/mtd10 /mnt/flash/gui.tar.gz return [$result_gui]"
		rm -f /mnt/flash/gui.tar.gz
		sync

		# settings (mtd6)
		echo "format_ubifs settings /dev/mtd6 enter"
		format_ubifs settings /dev/mtd6
		result_settings=$?
		echo "format_ubifs settings /dev/mtd6 return [$result_settings]"
#		# settings (mtd6) <- settings.tar.gz (mtd8)
#		echo "nanddump -q --omitoob --bb=skipbad --length=0x20000 -f /mnt/flash/settings.tar.gz /dev/mtd8 enter"
#		nanddump -q --omitoob --bb=skipbad --length=0x20000 -f /mnt/flash/settings.tar.gz /dev/mtd8	# 128KB
#		result_nanddump=$?
#		echo "nanddump -q --omitoob --bb=skipbad --length=0x20000 -f /mnt/flash/settings.tar.gz /dev/mtd8 return [$result_nanddump]"
#		sync
#		echo "format_ubifs settings /dev/mtd6 /mnt/flash/settings.tar.gz enter"
#		format_ubifs settings /dev/mtd6 /mnt/flash/settings.tar.gz
#		result_settings=$?
#		echo "format_ubifs settings /dev/mtd6 /mnt/flash/settings.tar.gz return [$result_settings]"
#		rm -f /mnt/flash/settings.tar.gz
		sync

		if [ $result_gui -eq 0 ] && [ $result_settings -eq 0 ]
		then
			echo "### complete format_ubifs ###"
			fw_setenv ubifs_formatted true
		else
			echo "### error format_ubifs gui=$result_gui, settings=$result_settings ###"
		fi

		umount /mnt/flash
	fi
}

mount_ubifs()
{
	vol_name=$1
	vol_no=$2
	mount_point=$3

	echo "### mount_ubifs (${vol_name}, ${vol_no}, ${mount_point}) ###"

	echo "ubiattach /dev/ubi_ctrl -m ${vol_no} -d ${vol_no} enter"
	ubiattach /dev/ubi_ctrl -m ${vol_no} -d ${vol_no}
	result_attach=$?
	echo "ubiattach /dev/ubi_ctrl -m ${vol_no} -d ${vol_no} return [$result_attach]"

	# ubimkvolはアップデート時に実施済み
	#ubimkvol /dev/ubi${vol_no} -N ${vol_name} -m

	echo "mount -t ubifs ubi${vol_no}:${vol_name} ${mount_point} enter"
	mount -t ubifs ubi${vol_no}:${vol_name} ${mount_point}
	result_mount_ubifs=$?
	echo "mount -t ubifs ubi${vol_no}:${vol_name} ${mount_point} return [$result_mount_ubifs]"
}
