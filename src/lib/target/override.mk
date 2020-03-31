##############################################################################
#
# TARGET specific layer library
#
##############################################################################

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_$(TARGET).h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc
UNIT_CFLAGS += -DCONFIG_INET_GRE_USE_GRETAP

ifneq ($(filter OS_GATEWAY_QCA53 OS_EXTENDER_QCA53,$(TARGET)),)

##
# Target layer sources
#
UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/target_$(TARGET).c

endif

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)
