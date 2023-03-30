#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "build_version.h"
#include "util.h"
#include "log.h"
#include "os_nif.h"

#include "osp_unit.h"

bool osp_unit_serial_get(char *buff, size_t buffsz)
{
    memset(buff, 0, buffsz);

    os_macaddr_t mac;
    size_t n;

    // get eth0 MAC address
    if (true == os_nif_macaddr("eth0", &mac))
    {
        n = snprintf(buff, buffsz,
                     CONFIG_OSP_UNIT_QCA_TEMPLATE_SERIAL_PREFIX PRI(os_macaddr_plain_t),
                     FMT(os_macaddr_t, mac));
        if (n >= buffsz)
        {
            LOG(ERR, "buffer not large enough");
            return false;
        }
        return true;
    }

    return false;
}

bool osp_unit_id_get(char *buff, size_t buffsz)
{
    return osp_unit_serial_get(buff, buffsz);
}

bool osp_unit_model_get(char *buff, size_t buffsz)
{
    strscpy(buff, CONFIG_TARGET_MODEL, buffsz);
    return true;
}

bool osp_unit_sku_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_hw_revision_get(char *buff, size_t buffsz)
{
    snprintf(buff, buffsz, "%s", "Rev 1.0");
    return true;
}

bool osp_unit_platform_version_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_sw_version_get(char *buff, size_t buffsz)
{
    strscpy(buff, app_build_ver_get(), buffsz);
    return true;
}

bool osp_unit_vendor_name_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_vendor_part_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_manufacturer_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_factory_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_mfg_date_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_ovs_version_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_dhcpc_hostname_get(void *buff, size_t buffsz)
{
    char serial_num[buffsz];
    char model_name[buffsz];

    memset(serial_num, 0, (sizeof(char) * buffsz));
    memset(model_name, 0, (sizeof(char) * buffsz));

    if (!osp_unit_serial_get(serial_num, sizeof(serial_num)))
    {
        LOG(ERR, "Unable to get serial number");
        return false;
    }

    if (!osp_unit_model_get(model_name, sizeof(model_name)))
    {
        LOG(ERR, "Unable to get model name");
        return false;
    }

    snprintf(buff, buffsz, "%s_%s", serial_num, model_name);

    return true;
}
