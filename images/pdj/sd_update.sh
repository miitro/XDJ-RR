#!/bin/sh

# sd_update.sh
#
# SD 強制アップデート処理
#
# なお、通常の USB update は initramfs で実施する.

sd_update()
{
	upddir=nandupdate

	if [ "$BOOTMODE" = "MMC" ]; then
		# SDブートの場合、SDカードを /mnt/sdcard にマウントしなおす.
		mkdir -p /mnt/sdcard
		mount /dev/mmcblk0p1 /mnt/sdcard

		# SDカードに $upddir がある場合、アップデートする.
		if [ -d /mnt/sdcard/$upddir ]; then
			cd /mnt/sdcard/$upddir

			echo "#### SD-Card update start !! ####"
			./update SD 0

			echo "#### SD-Card update end. ####"

			cd /
#			umount /mnt/sdcard

			exit 0
		fi
	fi
}
