#!/bin/sh

# usb_update.sh

mntpath=$1
language=$2

# copy shared libraries
cp -av ${mntpath}/lib/* /lib/
cp -av ${mntpath}/usr/lib/* /usr/lib/

# start update
echo "#### USB update start. ####"
./update USB ${language}
ret=$?

exit $ret
