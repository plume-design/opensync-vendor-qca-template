#include "osp_temp.h"
#include "osp_temp_platform.h"
#include "log.h"
#include "const.h"

static const struct temp_src osp_temp_srcs[] =
{
    { "wifi0", "2.4G", osp_temp_get_temperature_kernel },
    { "wifi1", "5G", osp_temp_get_temperature_kernel },
};

const struct temp_src* osp_temp_get_srcs(void)
{
    return osp_temp_srcs;
}

int osp_temp_get_srcs_cnt(void)
{
    return ARRAY_SIZE(osp_temp_srcs);
}
