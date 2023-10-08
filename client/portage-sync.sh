#!/bin/bash

SYNC_HOST="host.example.com"
HOST_FOLDER="/mnt/bigdata/gentoo_data/binhost-chroot/laptop/etc/portage/"
CLIENT_FOLDER="/etc/portage/"

sync() {
        rsync -avhl --progress --rsync-path="sudo rsync" -e ssh "${CLIENT_FOLDER}${1}" "xun@${SYNC_HOST}:${HOST_FOLDER}${1}" --delete
}

sync 'source-files/'
sync 'package.use/'
sync 'package.accept_keywords/'
sync 'package.mask/'
sync 'repos.conf/'
