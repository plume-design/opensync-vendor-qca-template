#include "log.h"
#include "const.h"
#include "osp_tm.h"
#include "osp_temp.h"


int osp_tm_init(
        const struct osp_tm_therm_state **tbl,
        unsigned int *therm_state_cnt,
        unsigned int *temp_src_cnt,
        void **priv)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);

    *tbl = osp_tm_get_therm_tbl();
    *therm_state_cnt = osp_tm_get_therm_states_cnt();
    *temp_src_cnt = osp_temp_get_srcs_cnt();
    *priv = NULL;

    return 0;
}

void osp_tm_deinit(void *priv)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
}

int osp_tm_get_fan_rpm(void *priv, unsigned int *rpm)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return 0;
}

int osp_tm_set_fan_rpm(void *priv, unsigned int rpm)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return 0;
}
