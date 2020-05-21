##
# Vendor specfic Makefile
#

include $(VENDOR_DIR)/build/profile.mk

##
# Enable vendor specific OVSDB hooks
#
VENDOR_OVSDB_HOOKS := $(VENDOR_DIR)/ovsdb/common
VENDOR_OVSDB_HOOKS += $(VENDOR_DIR)/ovsdb/$(TARGET)

##
# Handle onboarding psk and ssid for HAWKEYE/AKRONITE/DAKOTA/OS_EXTENDER_QCA53 target during build.
#
# Note that OS_ONBOARDING_PSK and OS_ONBOARDING_SSID variables are required
# for generating pre-populated wifi related OVSDB entries required by extender
# devices. (See: ovsdb/<TARGET>/radio.json.sh)
#
ifeq ($(MAKECMDGOALS),rootfs)
ifneq ($(filter HAWKEYE AKRONITE DAKOTA OS_EXTENDER_QCA53,$(TARGET)),)

ifeq ($(OS_ONBOARDING_PSK),)
$(error TARGET=$(TARGET): Please provide OS_ONBOARDING_PSK)
endif

ifeq ($(OS_ONBOARDING_SSID),)
$(error TARGET=$(TARGET): Please provide OS_ONBOARDING_SSID)
endif

export OS_ONBOARDING_PSK=$(OS_ONBOARDING_PSK)
export OS_ONBOARDING_SSID=$(OS_ONBOARDING_SSID)

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
