#!/bin/bash
export CHROOT_BASE="/mnt/bigdata/gentoo_data/binhost-chroot/laptop"

if [ ! -d "${CHROOT_BASE}" ];then
    echo "${CHROOT_BASE} does not exist. Exiting."
    exit
fi
if [ ! -f "${CHROOT_BASE}/bin/bash" ];then
    echo "/bin/bash does not exist under ${CHROOT_BASE}. Extract a stage3 tarball here and try again."
    exit
fi

cd $CHROOT_BASE
if [ ! -d "${CHROOT_BASE}/var/tmp/portage" ]; then
	echo "setting up /var/tmp/portage.."
	mkdir -p var/tmp/portage
	chown -R portage:portage var/tmp/portage
fi
if [ ! -d "${CHROOT_BASE}/var/notmpfs" ]; then
	echo "setting up /var/notmpfs.."
	mkdir -p var/notmpfs
	chown -R portage:portage var/notmpfs
fi
if [ ! -f "${CHROOT_BASE}/etc/resolv.conf" ]; then
	echo "copying resolv.conf from main system.."
	cp --dereference /etc/resolv.conf etc/resolv.conf
fi
if [ ! -d "${CHROOT_BASE}/etc/portage/repos.conf" ]; then
	echo "setting up new repos.conf.."
	mkdir -p "etc/portage/repos.conf"
	cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
fi
if [ ! -d "${CHROOT_BASE}/var/cache/distfiles" ]; then
	echo "Creating /var/cache/distifles folder.."
	mkdir -p "var/cache/distfiles"	
fi

mount -t proc proc proc
mount --rbind /dev dev
mount --rbind /sys sys
mount --rbind /mnt/bigdata/gentoo_data/distfiles var/cache/distfiles
mount --make-rslave sys
mount --make-rslave dev
mount --make-rslave proc
# mount --rbind /var/tmp/portage var/tmp/portage
# mount --make-rslave var/tmp/portage
# mount --rbind /var/notmpfs var/notmpfs
# mount --make-rslave var/notmpfs

chroot $CHROOT_BASE /bin/bash

umount -R var/cache/distfiles
# umount -R var/notmpfs
# umount -R var/tmp/portage
umount -R *

cd

#source /etc/profile
#env-update
