#!/bin/bash

set -e

FLASHTOOL="${FLASHTOOL:-./rkdeveloptool}"

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

if ! [ -e $FLASHTOOL ]
then
	echo "$FLASHTOOL not found"
	usage 2
fi

# Get the options
while getopts ":hba:" option; do
	case $option in
		h) # display help
			usage
			;;
		b) # Upgrade Loader and Download Images
			${FLASHTOOL} UL px30_loader_v1.11.115.bin
			${FLASHTOOL} WL 0x4000 uboot.img
			${FLASHTOOL} WL 0x6000 trust.img
			exit
			;;
		a) # Upgrade Loader and Write LBA
			wic_name=$OPTARG
			${FLASHTOOL} UL px30_loader_v1.11.115.bin
			${FLASHTOOL} WL 0 "$wic_name"
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
