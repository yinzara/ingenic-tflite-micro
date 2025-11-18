################################################################################
#
# ingenic-tflite-micro
#
################################################################################

INGENIC_TFLITE_MICRO_VERSION = 0.0.2
INGENIC_TFLITE_MICRO_SITE = $(call github,yinzara,ingenic-tflite-micro,v$(INGENIC_TFLITE_MICRO_VERSION))
INGENIC_TFLITE_MICRO_LICENSE = Apache-2.0
INGENIC_TFLITE_MICRO_LICENSE_FILES = LICENSE
INGENIC_TFLITE_MICRO_INSTALL_STAGING = YES

INGENIC_TFLITE_MICRO_CONF_OPTS = \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TESTS=OFF

$(eval $(cmake-package))
