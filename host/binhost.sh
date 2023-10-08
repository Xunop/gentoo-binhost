#!/bin/sh

#!/usr/bin/env bash

function BH_SHOW_HELP()
{
	echo "Build a package:"
	echo -e "	./binhost install app-editors/vim\n"
	echo "Update all packages:"
	echo -e "	./binhost update all/<env-name>\n"
	echo "Re-build all packages:"
	echo -e "	./binhost emptytree all/<env-name>\n"
	echo "Cleanup packages (depclean, python-updater, eclean, ect):"
	echo -e "	./binhost cleanup all/<env-name>\n"
	echo "Full documentation:"
	echo -e "	https://github.com/p8952/binhost-utils"
	exit
}

function BH_CHECK_ENV()
{
	if [[ ! -d $1 ]]; then
		eerror "Enviroment $1 does not exist"
		exit 1
	fi

	if [ ! -f "$1/bin/bash" ];then
	    echo "/bin/bash does not exist under $1. Extract a stage3 tarball here and try again."
	    exit
	fi

       # for dir in bin boot dev etc home lib media mnt opt proc root run sbin sys tmp usr var; do
       # 	if [[ ! -d $1/$dir ]]; then
       # 		eerror "Enviroment $1 does not contain stage3 files"
       # 		exit 1
       # 	fi
       # done

	cd $1
	if [ ! -d "$1/var/tmp/portage" ]; then
		echo "setting up /var/tmp/portage.."
		mkdir -p var/tmp/portage
		chown -R portage:portage var/tmp/portage
	fi
	if [ ! -d "$1/var/notmpfs" ]; then
		echo "setting up /var/notmpfs.."
		mkdir -p var/notmpfs
		chown -R portage:portage var/notmpfs
	fi
	if [ ! -f "$1/etc/resolv.conf" ]; then
		echo "copying resolv.conf from main system.."
		cp --dereference /etc/resolv.conf etc/resolv.conf
	fi
	if [ ! -d "$1/etc/portage/repos.conf" ]; then
		echo "setting up new repos.conf.."
		mkdir -p "etc/portage/repos.conf"
		cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
	fi
	if [ ! -d "$1/var/cache/distfiles" ]; then
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
}

function BH_EMERGE()
{
	if [[ $2 == "install" ]]; then
		chroot $1 /bin/bash -c "source /etc/profile && /usr/bin/emerge $3"
	elif [[ $2 == "update" ]]; then
		chroot $1 /bin/bash -c "source /etc/profile && /usr/bin/emerge-webrsync \
					&& /usr/bin/emerge --update --newuse --deep @world"
	elif [[ $2 == "emptytree" ]]; then
		chroot $1 /bin/bash -c "source /etc/profile && /usr/bin/emerge --emptytree @world"
	elif [[ $2 == "cleanup" ]]; then
		chroot $1 /bin/bash -c "source /etc/profile && /usr/bin/emerge --depclean"
		#chroot $1 /usr/bin/revdep-rebuild
		#chroot $1 /usr/sbin/python-updater
		#chroot $1 /usr/sbin/perl-cleaner --all
		#chroot $1 /usr/bin/eclean packages
		#chroot $1 /usr/bin/eclean distfiles
	fi
}

function BH_CLEANUP()
{
	chroot $1 /bin/bash -c "source /etc/profile && /usr/sbin/emaint -f binhost"

	for dir in dev proc sys var/cache/distfiles; do
		if grep -qs $1/$dir /proc/mounts; then
			echo "Unmounting $dir from $(basename $1)"
			umount -l /$1/$dir
		fi
	done
}

# Gentoo binhost chroot directory
BH_CHROOT_DIR="/mnt/bigdata/gentoo_data/binhost-chroot/laptop"
BH_SELECTED_OPTS=0
BH_SELECTED_PKGS=0

if [[ $1 == "install" ]]; then
	if [[ $# -eq 2 ]]; then
		BH_SELECTED_OPTS=$1
		BH_SELECTED_PKGS=$2
	else
		BH_SHOW_HELP
	fi
elif [[ $1 == "update" ]]; then
	if [[ $# -eq 1 ]]; then
		BH_SELECTED_OPTS=$1
		BH_SELECTED_PKGS=0
	else
		BH_SHOW_HELP
	fi
elif [[ $1 == "emptytree" ]]; then
	if [[ $# -eq 1 ]]; then
		BH_SELECTED_OPTS=$1
		BH_SELECTED_PKGS=0
	else
		BH_SHOW_HELP
	fi
elif [[ $1 == "cleanup" ]]; then
	if [[ $# -eq 1 ]]; then
		BH_SELECTED_OPTS=$1
		BH_SELECTED_PKGS=0
	else
		BH_SHOW_HELP
	fi
else
	BH_SHOW_HELP
fi

#proxys="http://127.0.0.1:10809"
#export http_proxy="$proxys"
#export https_proxy="$proxys"
#export all_proxy="$proxys"
#export ALL_PROXY="$proxys"
#export HTTP_PROXY="$proxys"
#export HTTPS_PROXY="$proxys"

echo "Redy to install $BH_SELECTED_PKGS"
BH_CHECK_ENV $BH_CHROOT_DIR
BH_EMERGE $BH_CHROOT_DIR $BH_SELECTED_OPTS $BH_SELECTED_PKGS
BH_CLEANUP $BH_CHROOT_DIR
