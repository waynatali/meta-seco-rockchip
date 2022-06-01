#!/bin/bash

./upgrade_tool UL px30_loader_v1.11.115.bin
./upgrade_tool DI -u uboot.img 
./upgrade_tool DI -t trust.img
