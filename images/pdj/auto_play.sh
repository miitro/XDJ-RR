#!/bin/sh

# auto_play.sh

auto_play()
{
	sleep 5

	if [ ! -x /usr/bin/aplay ]; then
		echo "/usr/bin/aplay is not found."
		return 1
	fi
	if [ ! -x /usr/bin/arecord ]; then
		echo "/usr/bin/arecord is not found."
		return 1
	fi

	wavfile_master=m.wav
	wavfile_booth=b.wav
	wavfile_headphone=h.wav

	filepath=/media/usb1/sda1

	if [ -f ${filepath}/${wavfile_master} ]; then
		echo "${filepath}/${wavfile_master} is found."
		mode=master
	elif [ -f ${filepath}/${wavfile_booth} ]; then
		echo "${filepath}/${wavfile_booth} is found."
		mode=booth
	elif [ -f ${filepath}/${wavfile_headphone} ]; then
		echo "${filepath}/${wavfile_headphone} is found."
		mode=headphone
	else
		echo "wavefile is not found."
		return 1
	fi

	# dummy start AUX (ESAI) input to start audio clock.
	echo "arecord -Dhw:0,0 -r44100 -fS24_LE -c2 -d1 -twav > /dev/null"
	arecord -Dhw:0,0 -r44100 -fS24_LE -c2 -d1 -twav > /dev/null

	while :
	do

		case "$mode" in
			"master" )
				echo "aplay -Dplughw:1,0 ${filepath}/${wavfile_master}"
				aplay -Dplughw:1,0 ${filepath}/${wavfile_master} ;;
			"booth" )
				echo "aplay -Dplughw:1,2 ${filepath}/${wavfile_booth}"
				aplay -Dplughw:1,2 ${filepath}/${wavfile_booth} ;;
			"headphone" )
				echo "aplay -Dplughw:1,1 ${filepath}/${wavfile_headphone}"
				aplay -Dplughw:1,1 ${filepath}/${wavfile_headphone} ;;
			* )
				break ;;
		esac

	done

	return 0
}
