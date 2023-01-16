#!/bin/sh
vboxmanage list hdds | grep -B4 /sata* | grep '^UUID' | awk -F ':           ' '{print $2}' > uuids
while read disk_uuid; do 
vboxmanage closemedium $disk_uuid --delete
done < uuids
rm uuids
