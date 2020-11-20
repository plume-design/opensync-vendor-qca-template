/**
 * @file connector.c
 * @brief Connector between OVSDB and an example database in JSON
 */

#include "connector.h"
#include "log.h"
#include "target.h"
#include "evx.h"

#define CONNECTOR_DB_FILE       "/etc/config/xm-example-config.json"

#define CONNECTOR_DEBOUNCE_TIME 2.0

typedef struct {
    ev_stat                    watcher;
    ev_debounce                debounce;
} connector_watcher_t;

static connector_watcher_t           g_db_update;
static struct connector_ovsdb_api   *g_connector_api;

/******************************************************************************
 *  PROTECTED definitions
 *****************************************************************************/

/* Update device info in AWLAN_Node table */
static bool connector_device_info_get(
        struct connector_ovsdb_api *api,
        json_t *db_file)
{
    connector_device_mode_e mode = CLOUD_MODE;
    connector_device_info_t info;

    // Process general device info
    json_t *jnode = json_object_get(db_file, "node");
    if (jnode &&  json_is_object(jnode))
    {

        json_t *value = json_object_get(jnode, "serial");
        if (value && json_is_string(value))
        {
            strcpy(info.serial_number,
                   json_string_value(value));
        }

        value = json_object_get(jnode, "version");
        if (value && json_is_string(value))
        {
            strcpy(info.platform_version,
                   json_string_value(value));
        }

        value = json_object_get(jnode, "model");
        if (value && json_is_string(value))
        {
            strcpy(info.model,
                   json_string_value(value));
        }

        value = json_object_get(jnode, "revision");
        if (value && json_is_string(value))
        {
            strcpy(info.revision,
                   json_string_value(value));
        }

        (api->connector_device_info_cb)(&info);

        // Process redirector_addr
        value = json_object_get(jnode, "redirector");
        if (value && json_is_string(value))
        {
            (api->connector_cloud_address_cb)(json_string_value(value));
        }

        // Process device_mode
        value = json_object_get(jnode, "mode");
        if (mode && json_is_string(value))
        {
            if (!strcmp("cloud", json_string_value(value)))
            {
                (api->connector_device_mode_cb)(CLOUD_MODE);
            }
            else if (!strcmp("monitor", json_string_value(value)))
            {
                (api->connector_device_mode_cb)(MONITOR_MODE);
            }
            else if (!strcmp("battery", json_string_value(value)))
            {
                (api->connector_device_mode_cb)(BATTERY_MODE);
            }
            else
            {
                LOGE("Unknown device_mode %s", json_string_value(value));
            }
        }
    }

    return true;
}

static bool connector_wifi_config_get(
        struct connector_ovsdb_api *api,
        json_t *db_file)
{
    struct schema_Wifi_Radio_Config     rconf;
    struct schema_Wifi_VIF_Config       vconf;
    uint8_t radio_idx = 0;
    uint8_t vif_idx = 0;

    json_t *jwifi = json_object_get(db_file, "wifi");
    if (jwifi && json_is_array(jwifi))
    {
        for (radio_idx = 0; radio_idx < json_array_size(jwifi); radio_idx++)
        {
            MEMZERO(rconf);
            rconf._partial_update = true;
            json_t *jradio = json_array_get(jwifi, radio_idx);
            json_t *value = json_object_get(jradio, "if_name");
            if (value && json_is_string(value))
            {
                SCHEMA_SET_STR(rconf.if_name, json_string_value(value));
                LOGD("Processing radio %s", rconf.if_name);
            }
            else
            {
                LOGE("Radio doesn't have if_name");
                return false;
            }

            // TODO: Currently no need to update radio since it is already pre-populated
            //(api->connector_radio_update_cb)(rconf);

            json_t *jvifs = json_object_get(jradio, "vif");
            if (jvifs && json_is_array(jvifs))
            {
                for (vif_idx = 0; vif_idx < json_array_size(jvifs); vif_idx++)
                {
                    MEMZERO(vconf);
                    vconf._partial_update = true;
                    json_t *jvif = json_array_get(jvifs, vif_idx);
                    json_t *jvif_value = json_object_get(jvif, "if_name");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        SCHEMA_SET_STR(vconf.if_name, json_string_value(jvif_value));
                        LOGD("Processing vif %s", vconf.if_name);
                    }

                    jvif_value = json_object_get(jvif, "ssid");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        SCHEMA_SET_STR(vconf.ssid, json_string_value(jvif_value));
                    }

                    // Security - example only WPA2 (core/lib/schema/include/schema_consts.h)
                    SCHEMA_KEY_VAL_APPEND(vconf.security, "encryption", "WPA-PSK");
                    SCHEMA_KEY_VAL_APPEND(vconf.security, "mode", "2");

                    // Process general device info
                    jvif_value = json_object_get(jvif, "psk");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        SCHEMA_KEY_VAL_APPEND(vconf.security, "key", json_string_value(jvif_value));
                    }

                    // Check if VIF is still enabled and needs updates
                    jvif_value = json_object_get(jvif, "enabled");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        if (strcmp(json_string_value(jvif_value), "true") == 0)
                        {
                            // Update OVS VIF
                            SCHEMA_SET_INT(vconf.enabled, true);
                            (api->connector_vif_update_cb)(&vconf, rconf.if_name);
                        }
                    }
                }
            }
        }
    }

    return true;
}

/**
 * Watcher to process the JSON file after debounce
 */
static void connector_db_update_process(struct ev_loop *loop, struct ev_debounce *w, int revents)
{
    json_t *db_file = json_load_file(CONNECTOR_DB_FILE, 0, NULL);
    if (!db_file)
    {
        LOGE("DB update: Unable to read db from file "CONNECTOR_DB_FILE);
        return;
    }

    connector_device_info_get(g_connector_api, db_file);
    connector_wifi_config_get(g_connector_api, db_file);
    /* TODO - Homework - process Wifi_Inet_Config update phase */

    json_decref(db_file);
}

static void connector_db_update_debounce(struct ev_loop *loop, ev_stat *w, int revents)
{
    ev_debounce_start(EV_DEFAULT, &g_db_update.debounce);
}

static void connector_db_watcher(struct ev_loop *loop)
{
    ev_stat_init(
            &g_db_update.watcher,
            connector_db_update_debounce,
            CONNECTOR_DB_FILE,
            0);

    ev_stat_start(loop, &g_db_update.watcher);

    ev_debounce_init(
            &g_db_update.debounce,
            connector_db_update_process,
            CONNECTOR_DEBOUNCE_TIME);
}

/******************************************************************************
 *  PUBLIC definitions
 *****************************************************************************/

bool connector_init(struct ev_loop *loop, const struct connector_ovsdb_api *api)
{
    json_t *db_file = json_load_file(CONNECTOR_DB_FILE, 0, NULL);
    if (!db_file)
    {
        LOGE("Init: Unable to read db from file "CONNECTOR_DB_FILE);
        return false;
    }

    // Store the function pointers for later use when we get updates
    // from the file and create a watcher for the file/database
    g_connector_api = (struct connector_ovsdb_api *)api;

    connector_device_info_get(g_connector_api, db_file);
    connector_wifi_config_get(g_connector_api, db_file);
    /* TODO - Homework - process Wifi_Inet_Config init phase */

    json_decref(db_file);

    connector_db_watcher(loop);

    return true;
}

bool connector_close(struct ev_loop *loop)
{
    // Close access to your DB
    return true;
}

bool connector_sync_mode(const connector_device_mode_e mode)
{
    // Handle device mode
    json_t *db_file = json_load_file(CONNECTOR_DB_FILE, 0, NULL);
    if (!db_file)
    {
        LOGE("Update mode (open file)");
        return false;
    }

    // Find mode and update it
    json_t *jnode = json_object_get(db_file, "node");
    if (jnode &&  json_is_object(jnode))
    {
        json_t *value = json_object_get(jnode, "mode");
        if (mode && json_is_string(value))
        {
            switch (mode)
            {
                case CLOUD_MODE:    json_string_set(value, "cloud"); break;
                case MONITOR_MODE:  json_string_set(value, "monitor"); break;
                case BATTERY_MODE:  json_string_set(value, "battery"); break;
                default: LOGE("Unknown device_mode %d", mode); goto error;
            }
        }
    }

    if (json_dump_file(db_file, CONNECTOR_DB_FILE, JSON_INDENT(1)))
    {
        LOGE("Update mode (write file)");
        goto error;
    }

    json_decref(db_file);
    return true;

error:
    json_decref(db_file);
    return false;
}

bool connector_sync_radio(const struct schema_Wifi_Radio_Config *rconf)
{
    /*
     * You can go over all radio settings or process just _changed flags to populate your DB
     * Example: if (rconf.channel_changed) set_new_channel(rconf.channel);
     */
    return true;
}

bool connector_sync_vif(const struct schema_Wifi_VIF_Config *vconf)
{
    /*
     * You can go over all radio settings or process just _changed flags to populate your DB
     * Example: if (vconf.ssid_changed) set_new_ssid(vconf.ssid);
     */

    json_t *db_file = json_load_file(CONNECTOR_DB_FILE, 0, NULL);
    if (!db_file)
    {
        LOGE("Update mode (open file)");
        return false;
    }
    uint8_t radio_idx = 0;
    uint8_t vif_idx = 0;

    json_t *jwifi = json_object_get(db_file, "wifi");
    if (jwifi && json_is_array(jwifi))
    {
        for (radio_idx = 0; radio_idx < json_array_size(jwifi); radio_idx++)
        {
            json_t *jradio = json_array_get(jwifi, radio_idx);
            json_t *jvifs = json_object_get(jradio, "vif");
            if (jvifs && json_is_array(jvifs))
            {
                for (vif_idx = 0; vif_idx < json_array_size(jvifs); vif_idx++)
                {
                    json_t *jvif = json_array_get(jvifs, vif_idx);

                    // Find VIF and update it
                    json_t *jvif_value = json_object_get(jvif, "if_name");
                    if (!jvif_value
                        || !json_is_string(jvif_value)
                        || strcmp(vconf->if_name, json_string_value(jvif_value)))
                    {
                        continue;
                    }

                    jvif_value = json_object_get(jvif, "ssid");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        json_string_set(jvif_value, vconf->ssid);
                    }

                    // Process general device info
                    jvif_value = json_object_get(jvif, "psk");
                    if (jvif_value && json_is_string(jvif_value))
                    {
                        json_string_set(jvif_value, SCHEMA_KEY_VAL(vconf->security, "key"));
                    }

                    jvif_value = json_object_get(jvif, "enabled");
                    if (jvif_value && json_is_boolean(jvif_value))
                    {
                        json_string_set(jvif_value, vconf->enabled ? "true" : "false");
                    }
                }
            }
        }
    }

    if (json_dump_file(db_file, CONNECTOR_DB_FILE, JSON_INDENT(1)))
    {
        LOGE("Update mode (write file)");
        goto error;
    }

    json_decref(db_file);
    return true;

error:
    json_decref(db_file);
    return true;
}

bool connector_sync_inet(const struct schema_Wifi_Inet_Config *iconf)
{
    /*
     * You can go over all inet settings or process just _changed flags to populate your DB
     * Example: if (inet->inet_addr_changed) set_new_ipl(inet->inet_addr);
     */
    return true;
}
