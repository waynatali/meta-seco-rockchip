# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

inherit ${@'auto-patch' if "seco-px30-d23" in d.getVar('MACHINEOVERRIDES').split(":") else ''}
