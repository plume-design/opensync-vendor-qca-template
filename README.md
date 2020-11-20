OpenSync QCA Template
=====================

Reference/template QCA vendor layer implementation provides support for reference
QCA based targets.

This vendor layer provides two example target implementations based on the
reference hardware (described below), as well as example targets for several
reference boards:
* `OS_GATEWAY_QCA53` - gateway mode only (Plume hardware)
* `OS_EXTENDER_QCA53` - gateway and extender mode (Plume hardware)
* `HAWKEYE` - gateway and extender mode (QCA reference board)
* [Work in progress] `AKRONITE` - gateway and extender mode (QCA reference board)
* [Work in progress] `DAKOTA` - gateway and extender mode (QCA reference board)

Note that this README file mainly describes `OS_GATEWAY_QCA53` and
`OS_EXTENDER_QCA53` targets, but some information also applies to QCA
reference board targets.

#### Reference software versions

* Components and versions:

    | Component                    | Version     |         |
    |------------------------------|-------------|---------|
    | OpenSync core                | 2.0.x       | public  |
    | OpenSync vendor/qca-template | 2.0.x       | public  |
    | OpenSync platform/qca        | 2.0.x       | public  |
    | Qualcomm SDK                 | 5.3 or 11.0 | private |

Note that Plume hardware based targets use Qualcomm SDK 5.3.

#### Plume reference device information

* Chipset: IPQ4019

* Interfaces:

    | Interface     | Description                                       |
    |---------------|---------------------------------------------------|
    | eth0          | WAN ethernet interface                            |
    | eth1          | LAN ethernet interface                            |
    | br-wan        | WAN bridge                                        |
    | br-home       | LAN bridge                                        |
    | wifi0         | 2.4G wireless phy interace                        |
    | wifi1         | 5G lower wireless phy interace                    |
    | wifi2         | 5G upper wireless phy interace                    |
    | bhaul-ap-XX   | 2.4G and 5G backhaul VAPs                         |
    | home-ap-XX    | 2.4G and 5G home VAPs                             |
    | onboard-ap-XX | 2.4G and 5G onboard VAPs                          |
    | bhaul-sta-XX  | 2.4G and 5G station interfaces (extender only)    |

SW and HW information of Plume hardware is given for easier understanding of
the target layer implementation.


OpenSync root dir
-----------------

OpenSync build system requires a certain directory structure in order to ensure
modularity. Key components are:

* OpenSync core:         `OPENSYNC_ROOT/core`
* OpenSync QCA platform: `OPENSYNC_ROOT/platform/qca`
* OpenSync QCA template: `OPENSYNC_ROOT/vendor/qca-template`

Follow these steps to populate the OPENSYNC_ROOT directory:

```
$ git clone https://github.com/plume-design/opensync.git OPENSYNC_ROOT/core
$ git clone https://github.com/plume-design/opensync-platform-qca.git OPENSYNC_ROOT/platform/qca
$ git clone https://github.com/plume-design/opensync-vendor-qca-template.git OPENSYNC_ROOT/vendor/qca-template
$ mkdir -p OPENSYNC_ROOT/3rdparty
$ mkdir -p OPENSYNC_ROOT/service-provider
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

1. Go to OpenSync root directory
```
cd OPENSYNC_ROOT
```

2. Copy QCA SDK config file for `OS_GATEWAY_QCA53` or `OS_EXTENDER_QCA53` into
   `SDK_ROOT/qsdk/` dir as `.config` file

```
$ cp -fr vendor/qca-template/qca-sdk/qsdk-5.3/config_OS_[GATEWAY|EXTENDER]_QCA53* SDK_ROOT/qsdk/.config
```

3. Unpack OpenSync related QSDK overlays (package, dependencies, patches) to `SDK_ROOT/` dir.

```
$ tar xzvf opensync-sdk-qca53-*.tar.gz -C SDK_ROOT
```

Note that for this step the provided patches or overlays must match the QSDK
version you are using. If working with a different QSDK version, manual
modifications will probably be required.

4. Create a source link to OPENSYNC_ROOT

```
$ cd SDK_ROOT/qdsk/package/opensync/
$ ln -sf OPENSYNC_ROOT src
```

This step creates a symbolic link to the `OPENSYNC_ROOT` directory, which is
not located directly in the QSDK tree.

In case that you wish to keep OpenSync sources in QSDK tree, you may put
the source tree directly into `SDK_ROOT/qdsk/package/opensync/src`, and then
this will be your OPENSYNC_ROOT.

5. Prepare the SDK for build (as instructed in `SDK_ROOT/qsdk/README`):
```
$ cd SDK_ROOT/qsdk
$ ./scripts/feeds update -a
$ ./scripts/feeds install -a
```

NOTE: Provided information is based on QCA SDK version `5.3`. In case you are
using some other QCA SDK version, these steps can be used as a general guidance,
but may require some modifications.


Build environment
-----------------

For build environment requirements see `docker/Dockerfile`, which is used to
create the build environment and run builds in a docker container.

Note that the Dockerfile is tailored for QCA SDK 5.3 and may require some
modifications in case some other QCA SDK version is used.

The docker container can also be used interactively by running:
```
$ cd OPENSYNC_ROOT/vendor/qca-template/docker
$ ./dock-run bash
```

Build
-----

To build OpenSync as part of QSDK run the commands below.

Build full QSDK for target `OS_GATEWAY_QCA53`:

```
$ cp OPENSYNC_ROOT/vendor/qca-template/qca-sdk/qsdk-5.3/config-OS_GATEWAY_QCA53* SDK_ROOT/qsdk/.config
$ cd SDK_ROOT/qsdk
$ make defconfig
$ make
```

Build full QSDK for target `OS_EXTENDER_QCA53`:

```
$ cp OPENSYNC_ROOT/vendor/qca-template/qca-sdk/qsdk-5.3/config-OS_EXTENDER_QCA53* SDK_ROOT/qsdk/.config
$ cd SDK_ROOT/qsdk
$ make defconfig
$ make
```

Re-build only the OpenSync package:

```
$ cd SDK_ROOT/qsdk
$ make package/opensync/{clean,compile} V=s
```

Note that `TARGET` and some other build time variables are defined in the QSDK `.config` as:

```
CONFIG_PACKAGE_opensync=y
CONFIG_OPENSYNC_TARGET="OS_EXTENDER_QCA53"
CONFIG_OPENSYNC_ONBOARD_SSID="opensync.onboard"
CONFIG_OPENSYNC_ONBOARD_PSK="7eCyoqETHiJzKBBALPFP9X8mVy4dwCga"
```

For additional details see on `ONBOARD_SSID` and `ONBOARD_PSK` see `Makefile`.


Image install
-------------

#### Full image reflash

This is only applicable to reference device hardware.

```
$ cd /tmp
$ curl -O <image-url>
$ safeupdate -u <image-file>
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
./rootfs/kconfig/PLUME_HARDWARE/INSTALL_PREFIX/bin/watchdog-kick.sh
./rootfs/kconfig/PLUME_HARDWARE/INSTALL_PREFIX/bin/fan.sh
```

Non-OpenSync service startup scripts:

```
./rootfs/common/etc/init.d/syslog
./rootfs/common/etc/init.d/dropbear
./rootfs/common/etc/init.d/watchdog
./rootfs/common/etc/init.d/firewall
./rootfs/common/etc/init.d/debugnet
./rootfs/kconfig/PLUME_HARDWARE/etc/init.d/fan
./rootfs/kconfig/PLUME_HARDWARE/etc/init.d/bcreset
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
./rootfs/kconfig/PLUME_HARDWARE/lib/firmware/IPQ4019/hw.1/boarddata_0.bin
./rootfs/kconfig/PLUME_HARDWARE/lib/firmware/IPQ4019/hw.1/boarddata_1.bin
./rootfs/kconfig/PLUME_HARDWARE/lib/firmware/QCA9984/hw.1/boarddata_2.bin
./rootfs/kconfig/PLUME_HARDWARE/INSTALL_PREFIX/tools/bootconfig
./rootfs/kconfig/PLUME_HARDWARE/INSTALL_PERFIX/tools/safeupdate
```


OpenSync resources
------------------

For further information please visit: https://www.opensync.io/
