##
# Deployment profile controls default cloud connection settings
# for OS_EXTENDER_QCA53.
#
# Here we have an example of two profiles (dev and prod), which
# are identical.
#
# NOTE: To use the OpenSync cloud, one must use a profile that sets
# CONTROLLER_ADDR to "ssl:wildfire.plume.tech:443".
#
VALID_IMAGE_DEPLOYMENT_PROFILES = dev prod

export IMAGE_DEPLOYMENT_PROFILE ?= dev

ifeq ($(IMAGE_DEPLOYMENT_PROFILE),dev)
CONTROLLER_ADDR="ssl:wildfire.plume.tech:443"
IMAGE_PROFILE_SUFFIX="$(IMAGE_DEPLOYMENT_PROFILE)"
endif

ifeq ($(IMAGE_DEPLOYMENT_PROFILE),prod)
CONTROLLER_ADDR="ssl:wildfire.plume.tech:443"
IMAGE_PROFILE_SUFFIX="$(IMAGE_DEPLOYMENT_PROFILE)"
endif


ifeq ($(CONTROLLER_ADDR),)
$(error TARGET=$(TARGET): Please add IMAGE_DEPLOYMENT_PROFILE section for $(IMAGE_DEPLOYMENT_PROFILE))
endif
