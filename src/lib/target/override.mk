##############################################################################
#
# TARGET specific layer library
#
##############################################################################

UNIT_CFLAGS := $(filter-out -DTARGET_H=%,$(UNIT_CFLAGS))
UNIT_CFLAGS += -DTARGET_H=\"target_$(TARGET).h\"
UNIT_CFLAGS += -I$(OVERRIDE_DIR)/inc
UNIT_CFLAGS += -DCONFIG_INET_GRE_USE_GRETAP

##
# Target layer sources
#
#UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/target_$(TARGET).c

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)
