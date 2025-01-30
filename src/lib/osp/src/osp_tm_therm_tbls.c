#include "osp_tm.h"
#include "const.h"


static const struct osp_tm_therm_state osp_tm_therm_tbl[] =
{
    {{ 0,  0  }, { 15, 3 }, 0 },
    {{ 85, 85 }, { 3,  1 }, 5500 }
};

const struct osp_tm_therm_state* osp_tm_get_therm_tbl()
{
    return osp_tm_therm_tbl;
}

int osp_tm_get_therm_states_cnt()
{
    return ARRAY_SIZE(osp_tm_therm_tbl);
}
