##############################################################################
#
# BCM unit override for connector
#
##############################################################################

UNIT_SRC := $(CONNECTOR_COMMON_SRC)

UNIT_SRC_VENDOR := $(VENDOR_DIR)/$(UNIT_PATH)
UNIT_SRC_CONNECTOR := $(UNIT_SRC_VENDOR)/$(TARGET)

UNIT_CFLAGS += -I$(VENDOR_DIR)/$(UNIT_PATH)
UNIT_CFLAGS += -I$(VENDOR_DIR)/$(UNIT_PATH)/inc

UNIT_DEPS += src/lib/evx

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)

UNIT_SRC_TOP := $(UNIT_SRC_VENDOR)/connector.c
