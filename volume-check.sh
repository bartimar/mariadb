#!/bin/bash

# volume check

VOL_PATH=/var/lib/mysql

IFS=$'\n' # to ensure space-in-names are treated correctly in for loop
# actually Bluemix console (GUI) does not allow you to have whitespaces in volume names

vol_path=$(mount | grep nfs4 | cut -d\  -f3)

for i in $vol_path
do
	i=${i%/} # delete trailing slash
	[[ "$i" == "$VOL_PATH" ]] && exit 0
done


echo "ERROR: Volume is not mounted on $VOL_PATH"
echo "Start your container again with $VOL_PATH mounted"
exit 2
