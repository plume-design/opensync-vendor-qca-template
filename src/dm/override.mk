###############################################################################
#
# DM overrides
#
###############################################################################

UNIT_SRC := $(filter-out src/dm_hook.c,$(UNIT_SRC))

UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/dm_hook.c
UNIT_SRC_TOP += $(OVERRIDE_DIR)/src/dm_reboot_trigger.c
