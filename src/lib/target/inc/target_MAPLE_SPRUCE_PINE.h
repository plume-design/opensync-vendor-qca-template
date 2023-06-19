#ifndef TARGET_MAPLE_SPRUCE_PINE_H_INCLUDED
#define TARGET_MAPLE_SPRUCE_PINE_H_INCLUDED

#include "ioctl80211_client.h"
#include "ioctl80211_survey.h"
#include "ioctl80211_scan.h"
#include "ioctl80211_device.h"
#include "ioctl80211_capacity.h"
#include "ioctl80211_radio.h"


#define TARGET_ETHCLIENT_IFLIST     "eth0"

#define TARGET_CERT_PATH            "/var/certs"
#define TARGET_MANAGERS_PID_PATH    "/tmp/dmpid"
#define TARGET_OVSDB_SOCK_PATH      "/var/run/openvswitch/db.sock"
#define TARGET_LOGREAD_FILENAME     "/var/log/messages"


/******************************************************************************
 *  MANAGERS definitions
 *****************************************************************************/

/******************************************************************************
 *  CLIENT definitions
 *****************************************************************************/

/******************************************************************************
 *  SURVEY definitions
 *****************************************************************************/

/******************************************************************************
 *  NEIGHBOR definitions
 *****************************************************************************/

/******************************************************************************
 *  DEVICE definitions
 *****************************************************************************/

/******************************************************************************
 *  CAPACITY definitions
 *****************************************************************************/


#include "target_qca.h"
#include "target_common.h"

#endif /* TARGET_MAPLE_SPRUCE_PINE_H_INCLUDED */
