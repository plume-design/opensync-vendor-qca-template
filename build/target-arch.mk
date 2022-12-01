##
# TARGET definitions
#
# NOTE: A single vendor repository may contain multiple targets,
# which share some portions of code.
#
QCA_TEMPLATE_TARGETS := HAWKEYE HAWKEYE_RDP419 HAWKEYE_PINE AKRONITE DAKOTA MAPLE_PINE_PINE ALDER_PINE_PINE

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

ifneq ($(filter HAWKEYE,$(TARGET)),)
VERSION_TARGET                  = HAWKEYE
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter HAWKEYE_RDP419,$(TARGET)),)
VERSION_TARGET                  = HAWKEYE_RDP419
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter HAWKEYE_PINE,$(TARGET)),)
VERSION_TARGET                  = HAWKEYE_PINE
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter AKRONITE,$(TARGET)),)
VERSION_TARGET                  = AKRONITE
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter DAKOTA,$(TARGET)),)
VERSION_TARGET                  = DAKOTA
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter MAPLE_PINE_PINE,$(TARGET)),)
VERSION_TARGET                  = MAPLE_PINE_PINE
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

ifneq ($(filter ALDER_PINE_PINE,$(TARGET)),)
VERSION_TARGET                  = ALDER_PINE_PINE
CPU_TYPE                        = arm
DRIVER_VERSION                  = qca10_2_4_csu3
SDK                             = .
endif

endif # QCA_TEMPLATE_TARGETS
