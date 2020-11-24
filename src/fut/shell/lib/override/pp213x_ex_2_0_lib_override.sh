#!/bin/sh
# Include basic environment config from default shell file and if any from FUT framework generated /tmp/fut_set_env.sh file
if [ -e "/tmp/fut_set_env.sh" ]; then
    source /tmp/fut_set_env.sh
else
    source /tmp/fut-base/shell/config/default_shell.sh
fi

############################################ INFORMATION SECTION - START ###############################################
#
#   PP213X-EX libraries overrides
#
############################################ INFORMATION SECTION - STOP ################################################


############################################ UNIT OVERRIDE SECTION - START #############################################

stop_healthcheck()
{
    log -deb "Healthcheck service not present on system"
    return 0
}

############################################ UNIT OVERRIDE SECTION - STOP ##############################################

###############################################################################
# DESCRIPTION:
#   Function checks if tx power is applied at system level.
#   Uses iwconfig to get tx power info from VIF interface.
#   Radio interface is not used for this model.
# INPUT PARAMETER(S):
#   $1  tx power (required)
#   $2  VIF interface name (required)
#   $3  radio interface name (required)
# RETURNS:
#   0   Tx power is not as expected.
#   1   Tx power is as expected.
# USAGE EXAMPLE(S):
#   check_tx_power_at_os_level 21 home-ap-24 wifi0
#   check_tx_power_at_os_level 21 wl0.2 wl0
###############################################################################
check_tx_power_at_os_level()
{
    fn_name="pp213x_ex_2_0_lib_override:check_tx_power_at_os_level"
    local NARGS=3
    [ $# -ne ${NARGS} ] &&
        raise "${fn_name} requires ${NARGS} input argument(s)" -arg
    wm2_tx_power=$1
    wm2_vif_if_name=$2
    wm2_radio_if_name=$3

    log -deb "$fn_name - Checking Tx-Power at OS level"
    wait_for_function_response 0 "iwconfig $wm2_vif_if_name | grep -qE Tx-Power[:=]$wm2_tx_power" &&
        log -deb "$fn_name - Tx-Power: $wm2_tx_power is set at OS level" ||
        (
            iwconfig "$wm2_vif_if_name"
            return 1
        ) || raise "Tx-Power: $wm2_tx_power is NOT set at OS level" -l "$fn_name" -tc
    return 0
}
