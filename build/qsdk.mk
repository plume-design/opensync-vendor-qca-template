#
# QSDK configuration
#
# TOOLCHAIN_DIR and TARGET_CROSS variables are passed in
# as arguments from package/opensync Makefile
#

# add toolchain to the path
PATH           := $(PATH):$(TOOLCHAIN_DIR)/bin

CC             = $(TARGET_CROSS)gcc
CXX            = $(TARGET_CROSS)g++
AR             = $(TARGET_CROSS)ar
STRIP          = $(TARGET_CROSS)strip -g

TARGET_DIR     = $(STAGING_DIR)
LIB_DIR        = $(STAGING_DIR)/lib

SDK_INCLUDES  += -I$(TARGET_DIR)/include
SDK_INCLUDES  += -I$(TARGET_DIR)/usr/include
SDK_INCLUDES  += -I$(TARGET_DIR)/usr/include/protobuf-c
SDK_INCLUDES  += -I$(TOOLCHAIN_DIR)/include
SDK_INCLUDES  += -I$(TOOLCHAIN_DIR)/usr/include

SDK_LIB_DIR   += -L$(STAGING_DIR)/lib

SDK_CFLAGS    += -Os -pipe -fno-caller-saves -fhonour-copts
SDK_CFLAGS    += -Wno-error=unused-but-set-variable -msoft-float
SDK_CFLAGS    += -fasynchronous-unwind-tables -rdynamic
SDK_CFLAGS    += -DINET6 -D_U_="__attribute__((unused))"
SDK_CFLAGS    += -DMONT_NO_RFMON_MODE -DMONT_LINUX
SDK_CFLAGS    += -DQCA_10_4


CFLAGS        += $(SDK_CFLAGS) $(SDK_INCLUDES)
LIBS          += $(SDK_LIB_DIR)

CFLAGS        += -Wno-error=cpp

export STAGING_DIR
export CC
export CXX
export CFLAGS
export LIBS

WRT_DEFINES      += -DUSE_IOCTL_DEV
# Needed for offloading stats
