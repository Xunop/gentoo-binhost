#!/bin/bash

if [[ $# -eq 1 ]]; then
        script_dir=$(cd $(dirname $0) && pwd)
        bash $script_dir/portage-sync.sh
        exec ssh -i user@host.example.com \
                "sudo bash /home/xun/Workspace/gentoo-binhost-chroot/binhost \
                install $1"
else
        echo 'Need to select package.'
fi
