##
# Vendor specific Makefile
#

include $(VENDOR_DIR)/build/profile.mk

##
# Enable vendor specific OVSDB hooks
#
VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding PSK and SSID for HAWKEYE/AKRONITE/DAKOTA/OS_EXTENDER_QCA53
# targets.
#
# BACKHAUL_PASS and BACKHAUL_SSID variables are required for generating the
# pre-populated WiFi related OVSDB entries needed for extender devices.
# (See also: ovsdb/<TARGET>/radio.json.sh)
#
ifeq ($(MAKECMDGOALS),rootfs)
ifneq ($(filter HAWKEYE HAWKEYE_RDP419 AKRONITE DAKOTA OS_EXTENDER_QCA53,$(TARGET)),)

ifeq ($(BACKHAUL_PASS),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_PASS)
endif

ifeq ($(BACKHAUL_SSID),)
$(error TARGET=$(TARGET): Please provide BACKHAUL_SSID)
endif

export BACKHAUL_PASS=$(BACKHAUL_PASS)
export BACKHAUL_SSID=$(BACKHAUL_SSID)

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
