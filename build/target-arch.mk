##
# TARGET definitions
#
# NOTE: A single vendor repository may contain multiple targets,
# which share some portions of code. This template contains two
# target implementations: OS_GATEWAY_QCA53 and OS_EXTENDER_QCA53.
#
QCA_TEMPLATE_TARGETS := OS_GATEWAY_QCA53 OS_EXTENDER_QCA53

OS_TARGETS          += $(QCA_TEMPLATE_TARGETS)

##
# QCA template targets
#
ifneq ($(filter $(TARGET),$(QCA_TEMPLATE_TARGETS)),)

VENDOR              := qca-template

PLATFORM            := qca

VENDOR_DIR          := vendor/$(VENDOR)
ARCH_MK             = $(VENDOR_DIR)/build/qsdk.mk
KCONFIG_TARGET      ?= $(VENDOR_DIR)/kconfig/targets/$(TARGET)


# TARGET specific settings

ifneq ($(filter OS_GATEWAY_QCA53 OS_EXTENDER_QCA53,$(TARGET)),)
VERSION_TARGET                  = PIRANHA2
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = qsdk53
endif

endif # QCA_TEMPLATE_TARGETS
