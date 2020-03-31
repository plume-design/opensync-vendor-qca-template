##
# QSDK/OpenWRT image packing specifics -- note that is required only by OpenSync
# QCA reference board.
#
# Doc: QCA_Networking_2017.SPF.5.3 CSU1
#

.PHONY = image-create

##
# SDK
#
SDK_DIR                 = $(SDK_BASE)/qsdk
SDK_CONFIG              = $(VENDOR_DIR)/qca-sdk-config
SDK_BUILD               = $(VENDOR_DIR)/build
SRC_ROOTFS              = $(VENDOR_DIR)/rootfs
SDK_TARGET_DIR          = build_dir/$(TARGET_SPEC)
SDK_HOST_DIR            = build_dir/host
SDK_KERNEL_DIR          = $(SDK_DIR)/build_dir/linux-$(SDK_CHIP)_generic_uClibc-0.9.33.2
SDK_BIN                 = $(SDK_DIR)/bin/$(SDK_CHIP)
SDK_IMAGE_DIR           = $(CURDIR)/$(IMAGEDIR)
SDK_CHIP                = ipq806x
SDK_KERNEL_DIR          = $(SDK_DIR)/build_dir/target-arm_cortex-a7_uClibc-1.0.14_eabi/linux-$(SDK_CHIP)
SDK_FACTORY             = $(SDK_BASE)/IPQ4019.ILQ.5.3/common/build
SDK_TARGET_IMAGE_NAME   = $(SDK_FACTORY)/ipq/openwrt-ipq806x-ipq40xx-ubi-root.img
SDK_FACTORY_IMAGE_NAME  = $(SDK_FACTORY)/bin/nornand-ipq40xx-single.img
SDK_UBOOT_IMAGE_NAME    = $(SDK_FACTORY)/ipq/openwrt-ipq40xx-u-boot-stripped.elf
SDK_FIT_IMAGE_NAME      = $(SDK_FACTORY)/ipq/openwrt-ipq40xx-fitimage.img
SDK_FULL_FIT_IMAGE_NAME = $(SDK_FACTORY)/ipq/openwrt-ipq40xx-full-fitimage.img

##
# Image create
#
IMAGE_VERSION  := $(shell $(call version-gen,make))
IMAGE_FIT      := opensync-ref-$(TARGET)-ap-fit-$(IMAGE_VERSION).img
IMAGE_FULL_FIT := opensync-ref-$(TARGET)-ap-full-fit-$(IMAGE_VERSION).img

image-create:

	$(NQ) "Generating initial bootconfig image"
	$(Q)($(VENDOR_DIR)/tools/gen_bootcfg.py \
		--file $(SDK_BIN)/bootcfg1.bin  --img_cnt 1 --version $(IMAGE_VERSION) --badcnt_thrld 15 )

	$(NQ) "Generating empty bootcfg2 image"
	$(Q)(tr '\0' '\377' < /dev/zero | dd bs=1024 count=64 of=$(SDK_BIN)/bootcfg2_empty.bin)

	# Copy pregenerated u-boot apps for ref board
	$(Q)cp $(VENDOR_DIR)/tools/openwrt-ipq40xx-u-boot-app-bootcfg.bin $(SDK_BIN)/
	$(Q)cp $(VENDOR_DIR)/tools/openwrt-ipq40xx-u-boot-app-bt.bin $(SDK_BIN)/
	$(Q)cp $(VENDOR_DIR)/tools/uboot-beacon-firmware.bin $(SDK_BIN)/

	$(NQ) "Calling QCA update_premium.py"
	$(Q)(cd $(SDK_FACTORY) && \
		IMAGE_VERSION=$(IMAGE_VERSION) \
		IMAGE_DEPLOYMENT_PROFILE=$(IMAGE_DEPLOYMENT_PROFILE) \
		python update_premium.py )

	$(NQ) "Creating FIT images"
	$(Q)$(call mk-fit-image,$(SDK_FACTORY)/plumefit.cfg,$(SDK_FIT_IMAGE_NAME))
	$(Q)$(call mk-fit-image,$(SDK_FACTORY)/full-plumefit.cfg,$(SDK_FULL_FIT_IMAGE_NAME))

	$(NQ) "Copying build artifacts"
	$(Q)(cd $(SDK_FACTORY)/bin && \
		ls *.img | while read F; do \
				cp -a $$F $(SDK_IMAGE_DIR)/$${F%%.*}-$(IMAGE_VERSION).img ; \
				( cd $(SDK_IMAGE_DIR) && \
					md5sum $${F%%.*}-$(IMAGE_VERSION).img > $${F%%.*}-$(IMAGE_VERSION).img.md5.save) ; \
			done)

	$(Q)$(call copy-and-create-md5-img,$(SDK_TARGET_IMAGE_NAME),$(IMAGE_VERSION),$(SDK_IMAGE_DIR),img)
	$(Q)$(call copy-rename-and-create-md5-img,$(SDK_FIT_IMAGE_NAME),$(IMAGE_FIT),$(SDK_IMAGE_DIR))
	$(Q)$(call copy-rename-and-create-md5-img,$(SDK_FULL_FIT_IMAGE_NAME),$(IMAGE_FULL_FIT),$(SDK_IMAGE_DIR))

##
# This function will call mkimage with a given config file; set the correct value for field "signed"
# $1 - mkimage config file
# $2 - output FIT image
#
define mk-fit-image
	$(NQ) "Building FIT upgrade image: $(2)"
	$(Q)if [ -n "${IMAGE_SIGN}" ] && [ "${IMAGE_SIGN}" -eq 1 ]; then \
		sed -e 's/\(^\s*signed = \).*/\1"yes";/g' $(1) > $(shell dirname "$(1)")/tmp_mkimage_fit.its ; \
		echo "signing" ; \
	else \
		sed -e 's/\(^\s*signed = \).*/\1"no";/g' $(1) > $(shell dirname "$(1)")/tmp_mkimage_fit.its ; \
		echo "not signing" ; \
	fi
	$(Q)mkimage -f $(shell dirname "$(1)")/tmp_mkimage_fit.its $(2)
	$(Q)rm -f $(shell dirname "$(1)")/tmp_mkimage_fit.its
endef

##
# This function will copy image to destination with rename and MD5 calculation
# $1 - source filename
# $2 - image suffix
# $3 - destination directory
# $4 - suffix (img or img.ecc ...)
#
define copy-and-create-md5-img
	$(Q)cp -a $(1) "$(3)/$(subst .$(4),,$(notdir $(1)))-$(2).$(4)"
	$(Q)(cd $(3) && \
		md5sum  $(subst .$(4),,$(notdir $(1)))-$(2).$(4)> $(subst .$(4),,$(notdir $(1)))-$(2).$(4).md5.save)
endef

##
# This function will copy image to destination with rename and MD5 calculation
# $1 - source filename
# $2 - new image name
# $3 - destination directory
#
define copy-rename-and-create-md5-img
	$(NQ) "Copy and rename $1 $2 $3"
	$(Q)cp -a $(1) $(3)/$(2)
	$(Q)(cd $(3) && md5sum $(2) > $(2).md5.save)
endef
