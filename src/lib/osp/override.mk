##############################################################################
#
# OSP layer library override
#
##############################################################################

UNIT_SRC_TOP += $(if $(CONFIG_OSP_UNIT_QCA_TEMPLATE), $(OVERRIDE_DIR)/src/osp_unit_qca_template.c)
