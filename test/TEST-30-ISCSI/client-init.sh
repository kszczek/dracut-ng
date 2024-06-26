#!/bin/sh
. /lib/dracut-lib.sh

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
command -v plymouth > /dev/null 2>&1 && plymouth --quit
exec > /dev/console 2>&1

export TERM=linux
export PS1='initramfs-test:\w\$ '
stty sane
echo "made it to the rootfs! Powering down."
while read -r dev _ fstype opts rest || [ -n "$dev" ]; do
    [ "$fstype" != "ext4" ] && continue
    echo "iscsi-OK $dev $fstype $opts" | dd oflag=direct,dsync of=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_marker status=none
    break
done < /proc/mounts

if getargbool 0 rd.shell; then
    strstr "$(setsid --help)" "control" && CTTY="-c"
    setsid $CTTY sh -i
fi

sync
poweroff -f
