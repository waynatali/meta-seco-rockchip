#!/bin/bash

set -e

usage()
{
	# Display Help
	echo "Script that runs the Rockchip's upgrade tool to burn images into emmc."
	echo
	echo "Usage: $0 [-a -b -h]"
	echo "options are:"
	echo "-h    Print this help."
	echo "-b    Burn uboot into emmc."
	echo "-a <wic image file>"
	echo "      Burn wic image (uboot and rootfs) into emmc."
	1>&2;
	exit $0;
}

wic_name=""

	fi
}

# Get the options
while getopts ":hba:" option; do
	case $option in
		h) # display help
			usage
			;;
		b) # Upgrade Loader and Download Images
			sudo ./upgrade_tool UL px30_loader_v1.11.115.bin
			sudo ./upgrade_tool DI -u uboot.img
			sudo ./upgrade_tool DI -t trust.img
			exit
			;;
		a) # Upgrade Loader and Write LBA
			wic_name=$OPTARG
			sudo ./upgrade_tool UL px30_loader_v1.11.115.bin
			sudo ./upgrade_tool WL 0 "$wic_name"
			exit
			;;
		*) # Invalid option
			usage 1
			;;
	esac
done
shift "$(( OPTIND - 1 ))"

string = "$1"
if [ -z "$1" ] || [ "${string:0:1}" != "-" ] || [ "$1" == "-" ]; then
    usage 1
fi
