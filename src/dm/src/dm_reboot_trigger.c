#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <ev.h>

#include "log.h"
#include "ovsdb.h"
#include "ovsdb_update.h"
#include "ovsdb_sync.h"
#include "ovsdb_table.h"
#include "ovsdb_cache.h"
#include "schema.h"
#include "util.h"
#include "target.h"
#include "os_util.h"

#include "dm_reboot_trigger.h"

/**
 * Globals
 */

static ovsdb_table_t table_Wifi_Test_Config;
static ovsdb_table_t table_Wifi_Test_State;

/**
 * Private
 */

static bool cmd_delayed_reboot(const char *delay)
{
    char cmd[512];
    long delay_val;

    if (!os_strtoul((char *)delay, &delay_val, 0))
    {
        LOGE("Invalid delay value: %s", delay);
        return false;
    }

    snprintf(cmd, sizeof(cmd), CONFIG_INSTALL_PREFIX"/scripts/delayed-reboot %ld", delay_val);

    if (fork() == 0)
    {
        // Child
        system(cmd);
        exit(0);
    }

    return true;
}

static void callback_Wifi_Test_Config(
        ovsdb_update_monitor_t *mon,
        struct schema_Wifi_Test_Config *tconfig_old,
        struct schema_Wifi_Test_Config *tconfig)
{
    struct schema_Wifi_Test_State tstate;

    if (mon->mon_type == OVSDB_UPDATE_NEW &&
        strcmp("reboot", tconfig->test_id) == 0)
    {
        const char *delay = SCHEMA_KEY_VAL(tconfig->params, "arg");

        LOGI("Reboot requested! :: delay=%s", delay);

        if (delay && cmd_delayed_reboot(delay))
        {
            memset(&tstate, 0, sizeof(tstate));
            SCHEMA_SET_STR(tstate.test_id,  "reboot");
            SCHEMA_SET_STR(tstate.state,    "RUNNING");

            if (!ovsdb_table_upsert(&table_Wifi_Test_State, &tstate, false))
            {
                LOGE("Unable to update Wifi_Test_State");
            }
        }
        else
        {
            LOGE("Unable to execute reboot");
        }
    }
}

/**
 * Public
 */

bool dm_reboot_trigger_init(struct ev_loop *loop)
{
    LOGI("Initializing DM reboot tables...");

    // Initialize OVSDB tables
    OVSDB_TABLE_INIT_NO_KEY(Wifi_Test_Config);
    OVSDB_TABLE_INIT_NO_KEY(Wifi_Test_State);

    // Initialize OVSDB monitor callbacks after DB is initialized
    OVSDB_TABLE_MONITOR(Wifi_Test_Config, false);

    return true;
}
