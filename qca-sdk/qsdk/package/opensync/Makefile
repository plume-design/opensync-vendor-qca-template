#
# OpenSync QSDK package
#
# Requires that OpenSync build root is in $(PKG_DIR)/src/
#

include $(TOPDIR)/rules.mk

PKG_NAME := opensync
PKG_RELEASE := 1.0.0

include $(INCLUDE_DIR)/package.mk

OPENSYNC_DEPS := openvswitch libev jansson zlib openssl protobuf-c libprotobuf-c libmosquitto
OPENSYNC_DEPS += htpdate libcurl libiw mxml libpcap btconfig qca-hostap-10.4 libnetfilter-conntrack libmnl libstdcpp
OPENSYNC_DEPS += qca-wifi-fw qca-wifi-fw-10.4 qca-wifi-fw-hw4-10.4-asic qca-wifi-fw-hw5-10.4-asic
OPENSYNC_DEPS := $(foreach X,$(OPENSYNC_DEPS),+$(X))

define Package/opensync
	SECTION    := net
	CATEGORY   := OpenSync
	TITLE      := OpenSync QSDK package
	MAINTAINER := OpenSync <info@opensync.io>
	DEPENDS    := $(OPENSYNC_DEPS)
endef

define Package/opensync/description
	OpenSync QSDK package
endef

define Package/opensync/config
	source "$(SOURCE)/Config.in"
endef

define Build/Configure
	@echo === Build/Configure
endef

define Build/Compile
	@echo === Build/Compile
	@echo
	$(MAKE) -C src/core rootfs \
		TARGET=$(CONFIG_OPENSYNC_TARGET) \
		TOOLCHAIN_DIR=$(TOOLCHAIN_DIR) \
		TARGET_CROSS=$(TARGET_CROSS) \
		OS_ONBOARDING_SSID=$(CONFIG_OPENSYNC_ONBOARD_SSID) \
		OS_ONBOARDING_PSK=$(CONFIG_OPENSYNC_ONBOARD_PSK)
	@echo
endef

define Package/opensync/install
	$(MAKE) -C src/core rootfs-install-only \
		TARGET=$(CONFIG_OPENSYNC_TARGET) \
		INSTALL_ROOTFS_DIR=$(1)
endef

define Build/Clean
	@echo === Build/Clean $(CONFIG_OPENSYNC_TARGET)
	$(MAKE) -C src/core clean \
		TARGET=$(CONFIG_OPENSYNC_TARGET)
endef

# Don't run RSTRIP as we need rpath for OpenSync lib
RSTRIP := @echo SKIP RSTRIP:

$(eval $(call BuildPackage,opensync))
