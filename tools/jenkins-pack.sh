#!/bin/sh
#
# Pack helpers for Jenkins job
#

TARGET="$2"
BUILD_NO="$3"

VERSION="${TARGET}-$(cat vendor/qca-template/.version)-${BUILD_NO}"
DST_DIR="$(pwd)/images"

flt()
{
    echo "$1" | egrep -v "$2"
}

gitinfo()
{
    local repo="$1"
    local name="$(basename $(git -C ${repo} remote -v | head -n 1 | awk '{ print $2 }'))"
    local commit=$(git -C ${repo} log --oneline -n 1 | awk '{print $1}')

    printf "%-34s : %s\n" "${name}" "${commit}"
}

gitarchive()
{
    local repo="$1"
    local name="$2"

    git -C ${repo} archive --format tar.gz -o ${DST_DIR}/${name}-${VERSION}.tar.gz HEAD
}

##
# Packs QCA SDK 5.3 overlay that was used with stock SDK to build this
# image.
#
pack_sdk_overlay()
{
    local sdk="../sdk/qsdk53"
    local fname="${DST_DIR}/opensync-qsdk53-overlay-${VERSION}.tgz"
    local rname="${DST_DIR}/opensync-qsdk53-overlay-${VERSION}-removed.list"

    echo "# Packing added/updated SDK files"

    # Create a list of relevant files that were added or updated
    files=$(git -C ${sdk} diff --name-status origin/qsdk_clean.. | egrep "^A|^M")
    files=$(echo "${files}" | awk '{ print $2 }' | egrep "^qsdk/")
    files=$(flt "${files}" "^qsdk/\.")
    files=$(flt "${files}" "^qsdk/dl/")
    files=$(flt "${files}" "^qsdk/include/")
    files=$(flt "${files}" "^qsdk/target/linux/")
    files=$(flt "${files}" "^qsdk/package/kernel/bt-ath3k/")
    files=$(flt "${files}" "^qsdk/package/system/procd/")
    files=$(flt "${files}" "^qsdk/package/system/mtd/")
    files=$(flt "${files}" "^qsdk/package/boot/")
    files=$(flt "${files}" "^qsdk/package/base-files/")
    files=$(flt "${files}" "^qsdk/qca/feeds/art2/")
    files=$(flt "${files}" "^qsdk/qca/feeds/packages/btconfig/")
    files=$(flt "${files}" "^qsdk/qca/feeds/packages/utils/")
    files=$(flt "${files}" "^qsdk/qca/feeds/nss/qca-nss-fw2-retail/")
    files=$(flt "${files}" "^qsdk/qca/feeds/qca/net/qca-wifi-fw-")
    files=$(flt "${files}" "^qsdk/qca/src/linux-4.4/")
    files=$(flt "${files}" "^qsdk/qca/src/uboot-1.0/")
    files=$(flt "${files}" "^qsdk/qca/src/qca-wifi/cmn_dev/")
    files=$(flt "${files}" "^qsdk/qca/src/qca-wifi/offload/os/linux/tools/athdiag/")
    files=$(flt "${files}" "^qsdk/qca/feeds/qca/net/qca-wifi/patches/107-build-enable-athdiag.patch")

    (cd ${sdk}; echo "${files}" | tar czvf ${fname} -T -)

    echo "# Listing removed SDK files"

    # Create a list of relevant files that were removed
    removed=$(git -C ${sdk} diff --name-status origin/qsdk_clean.. | egrep "^D")
    removed=$(echo "${removed}" | awk '{ print $2 }' | egrep "^qsdk/")
    removed=$(flt "${removed}" "^qsdk/dl/")
    removed=$(flt "${removed}" "^qsdk/qca/src/qca-wifi/cmn_dev/")

    echo "$removed" > ${rname}
    echo "$removed"
}

##
# Packs files required for OpenSync QCA application development.
#
# For more details see device-vendor-qca-apps.
#
pack_app_artifacts()
{
    local name="${DST_DIR}/opensync-app-artifacts-${VERSION}.tgz"
    local path="work/${TARGET}/"

    echo "# Packing application artifacts"

    tar czvf ${name} \
        ${path}rootfs/usr/opensync/lib/libopensync.so \
        ${path}obj/src.lib.schema/schema_pre.h \
        ${path}obj/src.lib.schema/schema_gen.h
}

##
# Here we are are packing git commit hashes and archive of used repos.
#
pack_opensync_repos()
{
    local name="${DST_DIR}/opensync-repos-${VERSION}.list"

    echo "# Listing git repos"

    gitinfo .                     >  ${name}
    gitinfo platform/qca          >> ${name}
    gitinfo vendor/qca-template   >> ${name}
    gitinfo ../sdk/qsdk53         >> ${name}
    cat ${name}

    echo "# Packing git repos"

    gitarchive .                     opensync-core
    gitarchive platform/qca          opensync-platform-qca
    gitarchive vendor/qca-template   opensync-vendor-qca
}

##
# Main
#
case $1 in
    sdk-overlay)
        pack_sdk_overlay
        ;;
    app-artifacts)
        pack_app_artifacts
        ;;
    opensync-repos)
        pack_opensync_repos
        ;;
    all)
        pack_sdk_overlay
        pack_app_artifacts
        pack_opensync_repos
        ;;
esac
