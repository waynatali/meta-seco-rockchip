# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

PACKAGECONFIG:append:seco-px30-d23:class-target = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'dri3 gallium', 'osmesa', d)}"

EXTRA_OEMESON:append:seco-px30-d23 = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', '-Dglx=dri', '', d)}"
