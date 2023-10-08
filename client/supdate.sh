#!/bin/sh

if [[ $# -eq 0 ]]; then
        script_dir=$(cd $(dirname $0) && pwd)
        bash $script_dir/portage-sync.sh
        exec ssh -i user@host.example.com \
                "sudo bash /home/xun/Workspace/gentoo-binhost-chroot/binhost \
                update"
else
        echo 'Dont need to select package.'
fi
