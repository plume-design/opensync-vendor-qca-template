#
# OpenSync QSDK package
#
# Requires that OpenSync build root is in $(PKG_DIR)/src/
#

include $(TOPDIR)/rules.mk

PKG_NAME := opensync
PKG_VERSION := 2.0
PKG_RELEASE := 5
OPENSYNC_VERSION := $(PKG_VERSION).$(PKG_RELEASE)


include $(INCLUDE_DIR)/package.mk

OPENSYNC_DEPS := openvswitch libev jansson zlib openssl protobuf-c libprotobuf-c libmosquitto qca-wifi libnl qca-cfg80211 kmod-qca-wifi
OPENSYNC_DEPS += libcurl libiw mxml libpcap btconfig qca-hostap libnetfilter-conntrack libmnl libstdc
OPENSYNC_DEPS += @BUSYBOX_CONFIG_TIMEOUT

OPENSYNC_DEPS := $(foreach X,$(OPENSYNC_DEPS),+$(X))
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

ifeq ($(filter $(CONFIG_TARGET_ipq_ipq40xx) $(CONFIG_TARGET_ipq_ipq40xx_64), y),y)
OPENSYNC_TARGET := DAKOTA
endif
ifeq ($(filter $(CONFIG_TARGET_ipq_ipq806x) $(CONFIG_TARGET_ipq_ipq806x_64), y),y)
OPENSYNC_TARGET := AKRONITE
endif

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

define Download/core
  URL_FILE:=osync_$(OPENSYNC_VERSION).zip
  FILE:=opensync-core-osync_$(OPENSYNC_VERSION).zip
  URL:=https://github.com/plume-design/opensync/archive/
endef
$(eval $(call Download,core))

define Download/platform
  URL_FILE:=osync_$(OPENSYNC_VERSION).zip
  FILE:=opensync-platform-osync_$(OPENSYNC_VERSION).zip
  URL:=https://github.com/plume-design/opensync-platform-qca/archive/
endef
$(eval $(call Download,platform))

define Download/vendor
  URL_FILE:=osync_$(OPENSYNC_VERSION).zip
  FILE:=opensync-vendor-osync_$(OPENSYNC_VERSION).zip
  URL:=https://github.com/plume-design/opensync-vendor-qca-template/archive/
endef
$(eval $(call Download,vendor))

define Build/Prepare
	@echo === Build/Prepare
	$(CP) $(STAGING_DIR)/root-ipq/usr/lib/libqca_tools.so $(STAGING_DIR)/usr/lib/

	mkdir -p $(PKG_BUILD_DIR)
	unzip $(DL_DIR)/opensync-core-osync_$(OPENSYNC_VERSION).zip -d $(PKG_BUILD_DIR)/
	mv $(PKG_BUILD_DIR)/opensync-osync_$(OPENSYNC_VERSION) $(PKG_BUILD_DIR)/core

	mkdir -p $(PKG_BUILD_DIR)/platform
	unzip $(DL_DIR)/opensync-platform-osync_$(OPENSYNC_VERSION).zip -d $(PKG_BUILD_DIR)/platform
	mv $(PKG_BUILD_DIR)/platform/opensync-platform-qca-osync_$(OPENSYNC_VERSION) $(PKG_BUILD_DIR)/platform/qca

	mkdir -p $(PKG_BUILD_DIR)/vendor
	unzip $(DL_DIR)/opensync-vendor-osync_$(OPENSYNC_VERSION).zip -d $(PKG_BUILD_DIR)/vendor
	mv $(PKG_BUILD_DIR)/vendor/opensync-vendor-qca-template-osync_$(OPENSYNC_VERSION) $(PKG_BUILD_DIR)/vendor/qca-template

	$(Build/Prepare/Default)
endef

define Build/Compile
	@echo === Build/Compile
	@echo
	$(CP) $(STAGING_DIR)/root-ipq/usr/lib/libqca_tools.so $(STAGING_DIR)/usr/lib/
	$(MAKE) -C $(PKG_BUILD_DIR)/core rootfs V=1 \
		TARGET=$(OPENSYNC_TARGET) \
		TOOLCHAIN_DIR=$(TOOLCHAIN_DIR) \
		TARGET_CROSS=$(TARGET_CROSS) \
		TARGET_DIR_NAME=$(TARGET_DIR_NAME) \
		BACKHAUL_SSID=$(CONFIG_OPENSYNC_ONBOARD_SSID) \
		BACKHAUL_PASS=$(CONFIG_OPENSYNC_ONBOARD_PSK) \
		CONF_OPENSYNC_NL_SUPPORT=$(CONFIG_OPENSYNC_NL_SUPPORT) \
		ARCH_64BIT=$(CONFIG_ARCH_64BIT)
	@echo
endef

define Package/opensync/install
	@echo ======Package/opensync/install
	$(CP) $(STAGING_DIR)/root-ipq/usr/lib/libqca_tools.so $(STAGING_DIR)/usr/lib/
	$(MAKE) -C $(PKG_BUILD_DIR)/core rootfs-install-only \
		TARGET=$(OPENSYNC_TARGET) \
		INSTALL_ROOTFS_DIR=$(1)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/opensync/bin
	$(INSTALL_DIR) $(1)/ini
	$(INSTALL_DIR) $(1)/usr/share/openvswitch
	$(CP) $(PKG_BUILD_DIR)/core/work/$(OPENSYNC_TARGET)/bin/ovsh $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/work/$(OPENSYNC_TARGET)/rootfs/usr/opensync/scripts/delayed-reboot $(1)/usr/opensync/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/work/$(OPENSYNC_TARGET)/rootfs/usr/opensync/scripts/logpull.sh $(1)/usr/opensync/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/work/$(OPENSYNC_TARGET)/rootfs/ini/global.ini $(1)/ini/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/work/$(OPENSYNC_TARGET)/rootfs/usr/opensync/etc/opensync.ovsschema $(1)/usr/share/openvswitch/vswitch.ovsschema

endef

define Build/Clean
	@echo === Build/Clean $(OPENSYNC_TARGET)
	$(MAKE) -C $(PKG_BUILD_DIR)/core clean \
		TARGET=$(OPENSYNC_TARGET)
endef

# Don't run RSTRIP as we need rpath for OpenSync lib
RSTRIP := @echo SKIP RSTRIP:

$(eval $(call BuildPackage,opensync))
