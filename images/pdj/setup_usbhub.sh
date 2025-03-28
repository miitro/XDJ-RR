#!/bin/sh

# setup_usbhub.sh

# #define XDJ_RX2_USBAHUB_RST	IMX_GPIO_NR(3, 31)
reset_usbhub_a()
{
	gpio -o 3 31 0
	usleep 10
	gpio -o 3 31 1
#	usleep 500
	return 0
}

# define XDJ_RX2_USBBHUB_RST	IMX_GPIO_NR(5, 18)
reset_usbhub_b()
{
	gpio -o 5 18 0
	usleep 10
	gpio -o 5 18 1
#	usleep 500
	return 0
}


# USB2512B は SMBus Block Write のみ対応なので
# 0x??01 (= "1byte write + data") を i2c で word(2byte) write する.

# $1 : i2c bus number
# $2 : slave address
# $3 : data address
# $4 : data value (word: 0x????)
i2c_write_word()
{
#	usleep 1000	# 1msec
#	i2cset -y $1 $2 $3 $4 w 2> /dev/null
#	i2cset -y $1 $2 $3 $4 w >/dev/null 2>&1
	i2cset -y $1 $2 $3 $4 w >/dev/null
	ret=$?

	if [ $ret -ne 0 ]; then
		echo "error: i2cset -y $1 $2 $3 $4 w"
	fi
	return $ret
}

# for USB-A
setup_usbhub_a()
{
	echo "### setup_usbhub_a ###"

	bus=0		# I2C1
	slave=0x2c	# USB2512B

	i2c_write_word $bus $slave 0xff 0x0001		# Status/Command
	if [ $? -ne 0 ]; then
		return 1
	fi

	i2c_write_word $bus $slave 0x00 0x2401		# Vendor ID LSB
	i2c_write_word $bus $slave 0x01 0x0401		# Vendor ID MSB
	i2c_write_word $bus $slave 0x02 0x1201		# Product ID LSB
	i2c_write_word $bus $slave 0x03 0x2501		# Product ID MSB
	i2c_write_word $bus $slave 0x04 0xb301		# Device ID LSB
	i2c_write_word $bus $slave 0x05 0x0b01		# Device ID MSB
	i2c_write_word $bus $slave 0x06 0x9b01		# Configuration Data Byte1
	i2c_write_word $bus $slave 0x07 0x2001		# Configuration Data Byte2
	i2c_write_word $bus $slave 0x08 0x0201		# Configuration Data Byte3
	i2c_write_word $bus $slave 0x09 0x0001		# Non-Removable Devices
	i2c_write_word $bus $slave 0x0a 0x0001		# Port Disable (Self)
	i2c_write_word $bus $slave 0x0b 0x0001		# Port Disable (Bus)
	i2c_write_word $bus $slave 0x0c 0x0101		# Max Power (Self)
	i2c_write_word $bus $slave 0x0d 0x3201		# Max Power (Bus)
	i2c_write_word $bus $slave 0x0e 0x0101		# Hub Controller Max Current (Self)
	i2c_write_word $bus $slave 0x0f 0x3201		# Hub Controller Max Current (Bus)
	i2c_write_word $bus $slave 0x10 0x3201		# Power-on Time
	i2c_write_word $bus $slave 0x11 0x0001		# Language ID High
	i2c_write_word $bus $slave 0x12 0x0001		# Language ID Low
	i2c_write_word $bus $slave 0x13 0x0001		# Manufacturer String Length
	i2c_write_word $bus $slave 0x14 0x0001		# Product String Length
	i2c_write_word $bus $slave 0x15 0x0001		# Serial String Length
	i2c_write_word $bus $slave 0x16 0x0001		# [0x16-0x53] Manufacturer String
	i2c_write_word $bus $slave 0x54 0x0001		# [0x54-0x91] Product String
	i2c_write_word $bus $slave 0x92 0x0001		# [0x92-0xcf] Serial String
	i2c_write_word $bus $slave 0xd0 0x0001		# Battery Charging Enable
	i2c_write_word $bus $slave 0xf6 0x0001		# Boost_Up
	i2c_write_word $bus $slave 0xf8 0x0001		# Boost_x:0
	i2c_write_word $bus $slave 0xfa 0x0001		# Port Swap
	i2c_write_word $bus $slave 0xfb 0x0001		# Port Map 12
#	i2c_write_word $bus $slave 0xfc 0x0001		# Port Map 34

	i2c_write_word $bus $slave 0xff 0x0101		# Status/Command

	return 0
}

# for USB-B
setup_usbhub_b()
{
	echo "### setup_usbhub_b ###"

	bus=1		# I2C2
	slave=0x2c	# USB2512B

	i2c_write_word $bus $slave 0xff 0x0001		# Status/Command
	if [ $? -ne 0 ]; then
		return 1
	fi

	# Vendor ID: 0x08e4 - "Pioneer DJ"
	i2c_write_word $bus $slave 0x00 0x7301		# Vendor ID LSB
	i2c_write_word $bus $slave 0x01 0x2b01		# Vendor ID MSB

	# Product ID: 0x0006 - "????"
	i2c_write_word $bus $slave 0x02 0x0601		# Product ID LSB
	i2c_write_word $bus $slave 0x03 0x0001		# Product ID MSB

	# Device ID: 0x0100 - "????"
	i2c_write_word $bus $slave 0x04 0x0001		# Device ID LSB
	i2c_write_word $bus $slave 0x05 0x0101		# Device ID MSB

	i2c_write_word $bus $slave 0x06 0x9b01		# Configuration Data Byte1
	i2c_write_word $bus $slave 0x07 0x2001		# Configuration Data Byte2
	i2c_write_word $bus $slave 0x08 0x0101		# Configuration Data Byte3
	i2c_write_word $bus $slave 0x09 0x0001		# Non-Removable Devices
	i2c_write_word $bus $slave 0x0a 0x0001		# Port Disable (Self)
	i2c_write_word $bus $slave 0x0b 0x0001		# Port Disable (Bus)
	i2c_write_word $bus $slave 0x0c 0x0001		# Max Power (Self)
	i2c_write_word $bus $slave 0x0d 0x3201		# Max Power (Bus)
	i2c_write_word $bus $slave 0x0e 0x0101		# Hub Controller Max Current (Self)
	i2c_write_word $bus $slave 0x0f 0x3201		# Hub Controller Max Current (Bus)
	i2c_write_word $bus $slave 0x10 0x3201		# Power-on Time
	i2c_write_word $bus $slave 0x11 0x0401		# Language ID High
	i2c_write_word $bus $slave 0x12 0x0901		# Language ID Low

	i2c_write_word $bus $slave 0x13 0x1601		# Manufacturer String Length
							# "AlphaTheta Corporation" = 22(0x16)
	i2c_write_word $bus $slave 0x14 0x0f01		# Product String Length
							# "Generic USB Hub" = 15(0x0f)
	i2c_write_word $bus $slave 0x15 0x0010		# Serial String Length

	# [0x16-0x53] Manufacturer String
	# "AlphaTheta Corporation"
	i2c_write_word $bus $slave 0x16 0x4101		# 'A'
	i2c_write_word $bus $slave 0x17 0x0001		# 
	i2c_write_word $bus $slave 0x18 0x6c01		# 'l'
	i2c_write_word $bus $slave 0x19 0x0001		# 
	i2c_write_word $bus $slave 0x1a 0x7001		# 'p'
	i2c_write_word $bus $slave 0x1b 0x0001		# 
	i2c_write_word $bus $slave 0x1c 0x6801		# 'h'
	i2c_write_word $bus $slave 0x1d 0x0001		# 
	i2c_write_word $bus $slave 0x1e 0x6101		# 'a'
	i2c_write_word $bus $slave 0x1f 0x0001		# 
	i2c_write_word $bus $slave 0x20 0x5401		# 'T'
	i2c_write_word $bus $slave 0x21 0x0001		# 
	i2c_write_word $bus $slave 0x22 0x6801		# 'h'
	i2c_write_word $bus $slave 0x23 0x0001		# 
	i2c_write_word $bus $slave 0x24 0x6501		# 'e'
	i2c_write_word $bus $slave 0x25 0x0001		# 
	i2c_write_word $bus $slave 0x26 0x7401		# 't'
	i2c_write_word $bus $slave 0x27 0x0001		# 
	i2c_write_word $bus $slave 0x28 0x6101		# 'a'
	i2c_write_word $bus $slave 0x29 0x0001		# 
	i2c_write_word $bus $slave 0x2a 0x2001		# ' '
	i2c_write_word $bus $slave 0x2b 0x0001		# 
	i2c_write_word $bus $slave 0x2c 0x4301		# 'C'
	i2c_write_word $bus $slave 0x2d 0x0001		# 
	i2c_write_word $bus $slave 0x2e 0x6f01		# 'o'
	i2c_write_word $bus $slave 0x2f 0x0001		# 
	i2c_write_word $bus $slave 0x30 0x7201		# 'r'
	i2c_write_word $bus $slave 0x31 0x0001		# 
	i2c_write_word $bus $slave 0x32 0x7001		# 'p'
	i2c_write_word $bus $slave 0x33 0x0001		# 
	i2c_write_word $bus $slave 0x34 0x6f01		# 'o'
	i2c_write_word $bus $slave 0x35 0x0001		# 
	i2c_write_word $bus $slave 0x36 0x7201		# 'r'
	i2c_write_word $bus $slave 0x37 0x0001		# 
	i2c_write_word $bus $slave 0x38 0x6101		# 'a'
	i2c_write_word $bus $slave 0x39 0x0001		# 
	i2c_write_word $bus $slave 0x3a 0x7401		# 't'
	i2c_write_word $bus $slave 0x3b 0x0001		# 
	i2c_write_word $bus $slave 0x3c 0x6901		# 'i'
	i2c_write_word $bus $slave 0x3d 0x0001		# 
	i2c_write_word $bus $slave 0x3e 0x6f01		# 'o'
	i2c_write_word $bus $slave 0x3f 0x0001		# 
	i2c_write_word $bus $slave 0x40 0x6e01		# 'n'
	i2c_write_word $bus $slave 0x41 0x0001		#

	# [0x54-0x91] Product String
	# "Generic USB Hub"
	i2c_write_word $bus $slave 0x54 0x4701		# 'G'
	i2c_write_word $bus $slave 0x55 0x0001		#
	i2c_write_word $bus $slave 0x56 0x6501		# 'e'
	i2c_write_word $bus $slave 0x57 0x0001		#
	i2c_write_word $bus $slave 0x58 0x6e01		# 'n'
	i2c_write_word $bus $slave 0x59 0x0001		#
	i2c_write_word $bus $slave 0x5a 0x6501		# 'e'
	i2c_write_word $bus $slave 0x5b 0x0001		#
	i2c_write_word $bus $slave 0x5c 0x7201		# 'r'
	i2c_write_word $bus $slave 0x5d 0x0001		#
	i2c_write_word $bus $slave 0x5e 0x6901		# 'i'
	i2c_write_word $bus $slave 0x5f 0x0001		#
	i2c_write_word $bus $slave 0x60 0x6301		# 'c'
	i2c_write_word $bus $slave 0x61 0x0001		#
	i2c_write_word $bus $slave 0x62 0x2001		# ' '
	i2c_write_word $bus $slave 0x63 0x0001		#
	i2c_write_word $bus $slave 0x64 0x5501		# 'U'
	i2c_write_word $bus $slave 0x65 0x0001		#
	i2c_write_word $bus $slave 0x66 0x5301		# 'S'
	i2c_write_word $bus $slave 0x67 0x0001		#
	i2c_write_word $bus $slave 0x68 0x4201		# 'B'
	i2c_write_word $bus $slave 0x69 0x0001		#
	i2c_write_word $bus $slave 0x6a 0x2001		# ' '
	i2c_write_word $bus $slave 0x6b 0x0001		#
	i2c_write_word $bus $slave 0x6c 0x4801		# 'H'
	i2c_write_word $bus $slave 0x6d 0x0001		#
	i2c_write_word $bus $slave 0x6e 0x7501		# 'u'
	i2c_write_word $bus $slave 0x6f 0x0001		#
	i2c_write_word $bus $slave 0x70 0x6201		# 'b'
	i2c_write_word $bus $slave 0x71 0x0001		#

	i2c_write_word $bus $slave 0x92 0x0001		# [0x92-0xcf] Serial String

	i2c_write_word $bus $slave 0xd0 0x0001		# Battery Charging Enable
	i2c_write_word $bus $slave 0xf6 0x0001		# Boost_Up
	i2c_write_word $bus $slave 0xf8 0x0001		# Boost_x:0
	i2c_write_word $bus $slave 0xfa 0x0001		# Port Swap
	i2c_write_word $bus $slave 0xfb 0x0001		# Port Map 12
#	i2c_write_word $bus $slave 0xfc 0x0001		# Port Map 34

	i2c_write_word $bus $slave 0xff 0x0101		# Status/Command

	return 0
}
