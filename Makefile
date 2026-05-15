##
# Vendor specific Makefile
#

##
# Enable vendor specific OVSDB hooks
#
VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding PSK and SSID
#
# BACKHAUL_PASS and BACKHAUL_SSID variables are required for generating the
# pre-populated WiFi related OVSDB entries needed for extender devices.
# (See also: core/ovsdb/20_kconfig.radio.json.sh)
#
ifeq ($(MAKECMDGOALS),rootfs)
ifneq ($(filter AKRONITE DAKOTA MAPLE_PINE_PINE ALDER_PINE_PINE MAPLE_SPRUCE_PINE MIAMI_WAIKIKI MIAMI_PEBBLE IPQ5424_RDP466,$(TARGET)),)

ifeq ($(BACKHAUL_PASS),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_PASS)
endif

ifeq ($(BACKHAUL_SSID),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_SSID)
endif

endif
endif

##
# OpenSync reference board image build
#
ifeq ($(MAKECMDGOALS),image-create)
include $(VENDOR_DIR)/build/image.mk
ifeq ($(SDK_BASE),)
$(error image-create TARGET=$(TARGET): Please provide SDK_BASE)
endif
endif
