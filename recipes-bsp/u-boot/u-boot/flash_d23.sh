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
	exit $1;
}

wic_name=""

if [ ! -f $FLASHTOOL ]
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
		b) # Run miniloader and write uboot and trust images
			${FLASHTOOL} db px30_loader_v1.11.115.bin
			sleep 3
			${FLASHTOOL} wl 0x4000 uboot.img
			${FLASHTOOL} wl 0x6000 trust.img
			exit
			;;
		a) # Run miniloader and write the whole image
			wic_name=$OPTARG
			if [[ "$OPTARG" == *".wic"* ]]; then
				( ${FLASHTOOL} db px30_loader_v1.11.115.bin && sleep 3 ) || echo "Bootloader is already in eMMC"
				${FLASHTOOL} wl 0 "$wic_name"
			else
				echo "Only *.wic image file is supported!"
			fi
			exit
			;;
		*) # Invalid option
			usage 1
			;;
	esac
done
shift "$(( OPTIND - 1 ))"

string="$1"
if [ -z "$1" ] || [ "${string:0:1}" != "-" ] || [ "$1" == "-" ]; then
    usage 1
fi
