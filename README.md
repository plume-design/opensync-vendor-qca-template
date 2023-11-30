OpenSync QCA Template
=====================

Reference/template QCA vendor layer implementation provides support for reference
QCA based targets.

This vendor layer provides example target implementations for the following
reference boards:
* `HAWKEYE` - gateway and extender mode (QCA reference board)
* `HAWKEYE_RDP419` - gateway and extender mode (QCA reference board with Pine chipset)
* `HAWKEYE_PINE` - gateway and extender mode (QCA reference board with Pine chipset)
* `AKRONITE` - gateway and extender mode (QCA reference board)
* `DAKOTA` - gateway and extender mode (QCA reference board)
* `MAPLE_PINE_PINE` - gateway and extender mode (QCA reference board)
* `ALDER_PINE_PINE` - gateway and extender mode (QCA reference board)
* `ALDER_WAIKIKI` - gateway and extender mode (QCA reference board)
* `MAPLE_SPRUCE_PINE` - gateway and extender mode (QCA reference board)

#### Reference software versions

* Components and versions:

    | Component                    | Version     |         |
    |------------------------------|-------------|---------|
    | OpenSync core                | 5.6.x       | public  |
    | OpenSync vendor/qca-template | 5.6.x       | public  |
    | OpenSync platform/qca        | 5.6.x       | public  |
    | Qualcomm SDK                 | 11.x        | private |

#### Reference board information

* Interfaces:

    | Interface     | Description                                       |
    |---------------|---------------------------------------------------|
    | eth0          | WAN ethernet interface                            |
    | eth1          | LAN ethernet interface                            |
    | br-home       | LAN bridge                                        |
    | wifi0         | 2.4G wireless phy interace                        |
    | wifi1         | 5G lower wireless phy interace                    |
    | wifi2         | 5G upper wireless phy interace                    |
    | bhaul-ap-XX   | 2.4G and 5G backhaul VAPs                         |
    | home-ap-XX    | 2.4G and 5G home VAPs                             |
    | onboard-ap-XX | 2.4G and 5G onboard VAPs                          |
    | bhaul-sta-XX  | 2.4G and 5G station interfaces (extender only)    |


OpenSync root dir
-----------------

OpenSync build system requires a certain directory structure in order to ensure
modularity. Key components are:

* OpenSync core:             `OPENSYNC_ROOT/core`
* OpenSync QCA platform:     `OPENSYNC_ROOT/platform/qca`
* OpenSync QCA template:     `OPENSYNC_ROOT/vendor/qca-template`
* OpenSync service provider: `OPENSYNC_ROOT/service-provider/local` ([local](https://github.com/plume-design/opensync-service-provider-local) given as an example which needs to be replaced with your service provider)

Follow these steps to populate the OPENSYNC_ROOT directory:

```
$ git clone https://github.com/plume-design/opensync.git OPENSYNC_ROOT/core
$ git clone https://github.com/plume-design/opensync-platform-qca.git OPENSYNC_ROOT/platform/qca
$ git clone https://github.com/plume-design/opensync-vendor-qca-template.git OPENSYNC_ROOT/vendor/qca-template
$ git clone https://github.com/plume-design/opensync-service-provider-local.git OPENSYNC_ROOT/service-provider/local
$ mkdir -p OPENSYNC_ROOT/3rdparty
```

The resulting layout should be as follows:

```
OPENSYNC_ROOT
├── 3rdparty
│   └── ...
├── core
│   ├── 3rdparty -> ../3rdparty
│   ├── build
│   ├── doc
│   ├── images
│   ├── interfaces
│   ├── kconfig
│   ├── Makefile
│   ├── ovsdb
│   ├── platform -> ../platform
│   ├── README.md
│   ├── src
│   ├── vendor -> ../vendor
│   └── work
├── platform
│   └── qca
├── service-provider
│   └── ...
└── vendor
    └── qca-template
```


QCA SDK
-------

To integrate the OpenSync package into QCA SDK, follow the steps below:

1. Go to `SDK_ROOT` directory, download the source code and required packages
   for specific target by following the instructions from SDK release notes.

2. Unpack OpenSync related QSDK overlays (package, dependencies, patches) to
   the `SDK_ROOT` directory:

```
$ tar xzvf opensync-sdk-qca*.tar.gz -C SDK_ROOT
```

Note that for this step the provided patches or overlays must match the QSDK
version you are using. If working with a different QSDK version, manual
modifications will probably be required.

3. Add the OpenSync package feed to the QSDK:

```
$ mkdir SDK_ROOT/qsdk/qca/feeds/opensync
$ cp -rf SDK_ROOT/opensync-sdk-qca*/opensync qsdk/qca/feeds/opensync/
```

4. Copy the target related certificates to the OpenSync package feed:

```
$ mkdir qsdk/qca/feeds/opensync/opensync/files
$ cp <certificates> SDK_ROOT/qsdk/qca/feeds/opensync/opensync/files/
```

5. To update to specific version of OpenSync, the sample sed command below can be
   used (replace the placeholder "x.y.z" with the desired version of OpenSync):

```
$ cd SDK_ROOT/qsdk/qca/feeds/opensync/opensync/
$ sed -i 's/2.0.5/x.y.z/g' Makefile
```

6. Create the OpenSync package link in `qca/feeds`:

```
$ cd SDK_ROOT/qsdk/
$ echo src-link opensync ../qca/feeds/opensync >>feeds.conf
```

7. Prepare the SDK for build (as instructed in `SDK_ROOT/qsdk/README`):

```
$ ./scripts/feeds update -a
$ ./scripts/feeds install -a
```

NOTE: Provided information is based on QCA SDK version `11.x`. In case you are
using some other QCA SDK version, these steps can be used as a general guidance,
but may require some modifications.


Build
-----

To build the OpenSync as part of the QSDK, follow the steps below.

Regenerate the complete configuration file:

```
$ cd SDK_ROOT/qsdk
$ cp qca/configs/qsdk/ipq_[premium/enterprise].config .config
```

Update the configuration file for the specific chipset architecture:

```
$ sed -i "s/TARGET_ipq_ipq806x/TARGET_ipq_ipqxxxx/g" .config
$ mv prebuilt/ipqxxxx/ipq_premium/* prebuilt/ipqxxxx/
```

Note: To build 64-bit binaries, use `ipqxxxx_64`.

The OpenSync `TARGET` and some other build-time variables are defined in the QSDK,
in the `.config` file. To configure the OpenSync package, run:

```
$ echo "CONFIG_PACKAGE_opensync=y" >>.config
$ echo "CONFIG_OPENSYNC_NL_SUPPORT=y" >>.config
$ echo "CONFIG_<TARGET_NAME>=y" >>.config

$ make defconfig
$ make
```

Specify a valid target and provide the onboard SSID and password.
Note that CONFIG_OPENSYNC_NL_SUPPORT must be enabled.


Alternatively, configuration can be performed using interactive `menuconfig`:

```
$ make menuconfig

  OpenSync --->
      <*> opensync........................................... OpenSync QSDK package
      OpenSync configuration --->
          [*] OpenSync enable NL support
      Target (None) --->
          (X) None
          ( ) Dakota
          ( ) Maple Pine Pine
          ( ) Akronite
          ( ) Hawkeye
          ( ) Hawkeye Pine
          ...

$ make
```

To rebuild only the OpenSync package:

```
$ cd SDK_ROOT/qsdk
$ make package/opensync/{clean,compile} V=s
```

Note that additional build-time variables `BACKHAUL_PASS` and `BACKHAUL_SSID`
used to be passed into the make command but have since been deprecated because
they are set in service-provider repositories based on the chosen
`IMAGE_DEPLOYMENT_PROFILE`. See `Makefile` for details.


Image install
-------------

#### Full image reflash

Copy the xxxx-ipqxxxx-single.img to the TFTP server boot directory.
Set the IP address and server IP using the TFTP process:

```
$ set ipaddr 192.168.1.11
$ set serverip 192.168.1.xx (TFTP server address)
$ ping ${serverip}
$ set imgaddr "0x44000000"
$ set bootargs console=ttyMSM0,115200n8
$ tftpboot 0x44000000 xxxx-ipqxxxx_-single.img
$ source $imgaddr:script
$ reset
```

#### OpenSync package re-install

```
$ cd /tmp
$ curl -O <package-url>
$ tar xzvf <package-file> -C /
```


Run
---

OpenSync will be automatically started at startup -- see `/etc/rc.d/S99opensync`.

To manually start, stop, or restart OpenSync, use the following command:

```
$ /etc/init.d/opensync stop|start|restart
```


Device access
-------------

The preferred way to access the reference device is through the serial console.

SSH access is also available on all interfaces:
* Username: `osync`
* Password: `osync123`


Notes
-----

Note that the template vendor layer is used to implement and build a fully
functional OpenSync reference device running on QCA hardware. Due to this fact
some of the code, files, and configurations are not a part of OpenSync.
This needs to be considered when adapting OpenSync to other devices.


#### Files

Non-OpenSync system configs and scripts:

```
./rootfs/common/etc/profile
./rootfs/common/etc/banner
./rootfs/common/etc/shadow
./rootfs/common/etc/group
./rootfs/common/etc/passwd
./rootfs/common/etc/config/system
./rootfs/common/etc/config/wireless
./rootfs/common/etc/config/network
```

Non-OpenSync service startup scripts:

```
./rootfs/common/etc/init.d/syslog
./rootfs/common/etc/init.d/dropbear
./rootfs/common/etc/init.d/watchdog
./rootfs/common/etc/init.d/firewall
./rootfs/common/etc/init.d/debugnet
```

Non-OpenSync reference image related files:

```
./build/build-qsdk
./build/qsdk53-arm.mk
./build/image.mk
./tools/openwrt-ipq40xx-u-boot-app-bootcfg.bin
./tools/openwrt-ipq40xx-u-boot-app-bt.bin
./tools/uboot-beacon-firmware.bin
./tools/gen_bootcfg.py
./tools/jenkins-pack.sh
```


OpenSync resources
------------------

For further information please visit: https://www.opensync.io/
