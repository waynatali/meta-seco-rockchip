#!/bin/bash

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
	exit;
}

wic_name=""
status=$?

status_check()
{
	if [ $status -eq 0 ];then
		echo "Success!"  1>&2; exit;
	else
		echo "Something went wrong!"  1>&2; exit;
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
			status_check
			;;
		a) # Upgrade Loader and Write LBA
			wic_name=$OPTARG
			sudo ./upgrade_tool UL px30_loader_v1.11.115.bin
			sudo ./upgrade_tool WL 0 "$wic_name"
			status_check
			;;
		*) # Invalid option
			usage
			;;
	esac
done
shift "$(( OPTIND - 1 ))"

string = "$1"
if [ -z "$1" ] || [ "${string:0:1}" != "-" ] || [ "$1" == "-" ]; then
    usage
fi
