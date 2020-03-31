#include <stdbool.h>
#include <ev.h>

#include "dm.h"
#include "dm_reboot_trigger.h"

// DM hook - placeholder for vendor override

bool dm_hook_init(struct ev_loop *loop)
{
    dm_reboot_trigger_init(loop);
    return true;
}

bool dm_hook_close()
{
    return true;
}
