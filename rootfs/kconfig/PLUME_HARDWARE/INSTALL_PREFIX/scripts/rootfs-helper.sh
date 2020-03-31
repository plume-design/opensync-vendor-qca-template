#!/bin/sh

RFS1=rootfs
RFS2=rootfs2
MTDBLOCK=/dev/mtdblock

get_active_partition()
{
    ubimtd=$(for word in `cat /proc/cmdline`; do echo $word | grep ubi.mtd; done)
    echo $ubimtd | cut -d'=' -f2
}

get_inactive_partition()
{
    active=$(get_active_partition)
    if [ $active = $RFS1 ]; then
        echo $RFS2
    else
        echo $RFS1
    fi
}

get_part_mtd()
{
    cat /proc/mtd | grep '"'$1'"' | cut -d':' -f1
}

attach_inactive_ubi()
{
    inactive_part=$(get_inactive_partition)
    inactive_mtd=$(get_part_mtd $inactive_part)
    ubiattach -p /dev/$inactive_mtd $1 >/dev/null 2>&1
}

detach_inactive_ubi()
{
    ubidetach -d 1 2>&1
}

mount_inactive_rootfs()
{
    attach_inactive_ubi
    ubi_mtd=$(cat /proc/mtd | grep '"ubi_rootfs"' | cut -d':' -f1 | tail -n1)
    ubi_mtdblock=${ubi_mtd/mtd/$MTDBLOCK}
    mkdir -p $1
    mount  -t squashfs $ubi_mtdblock $1 >/dev/null 2>&1
}

umount_inactive_rootfs()
{
    ubi_mtd=$(cat /proc/mtd | grep '"ubi_rootfs"' | cut -d':' -f1 | tail -n1)
    ubi_mtdblock=${ubi_mtd/mtd/$MTDBLOCK}
    umount $ubi_mtdblock
}
