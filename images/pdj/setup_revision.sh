#!/bin/sh

# setup_revision.sh

setup_release() {
	release=`fw_printenv -n release`
	if [ "$release" = "" ]
	then
		release="--.--"
	fi
}

# NANDブートの場合 u-boot 環境変数からリビジョン情報を取得する.
# サブマイコンのリビジョンは SPI 通信で取得するのでここでは取り扱わない
setup_revisions_nand() {
	# system
	rev_boot=`fw_printenv -n rev_boot`
	rev_kernel=`fw_printenv -n rev_kernel`
	rev_rootfs=`fw_printenv -n rev_rootfs`
#	rev_data=`fw_printenv -n rev_data`

	rev_system=$rev_boot
	if [ $rev_system -lt $rev_kernel ]	# TODO:
	then
		rev_system=$rev_kernel
	fi
	if [ $rev_system -lt $rev_rootfs ]	# TODO:
	then
		rev_system=$rev_rootfs
	fi
#	if [ $rev_system -lt $rev_data ]
#	then
#		rev_system=$rev_data
#	fi

	# apl
	rev_apl=`fw_printenv -n rev_apl`
}

# SDブートの場合 system.rev, apl.rev ファイルからシステム、アプリのリビジョンを取得する.
# サブマイコンのリビジョンは SPI 通信で取得するのでここでは取り扱わない
setup_revisions_sd() {
	if [ -f /etc/system.rev ]
	then
		rev_system=`cat /etc/system.rev | grep "Last Changed Rev" | sed -e "s/^Last Changed Rev:[ \t]*//g"`
	else
		rev_system="----"
	fi

	if [ -f /root/pdj/apl.rev ]
	then
		rev_apl=`cat /root/pdj/apl.rev | grep "Last Changed Rev" | sed -e "s/^Last Changed Rev:[ \t]*//g"`
	else
		rev_apl="----"
	fi
}
