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
# Handle onboarding psk and ssid for HAWKEYE/AKRONITE/DAKOTA/OS_EXTENDER_QCA53
# target during build.
#
# Note that BACKHAUL_PASS and BACKHAUL_SSID variables are required
# for generating pre-populated WiFi related OVSDB entries required by extender
# devices. (See: ovsdb/<TARGET>/radio.json.sh)
#
ifeq ($(MAKECMDGOALS),rootfs)
ifneq ($(filter HAWKEYE AKRONITE DAKOTA OS_EXTENDER_QCA53,$(TARGET)),)

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
# OpenSync ref board image build
#
ifeq ($(MAKECMDGOALS),image-create)
include $(VENDOR_DIR)/build/image.mk
ifeq ($(SDK_BASE),)
$(error image-create TARGET=$(TARGET): Please provide SDK_BASE)
endif
endif
