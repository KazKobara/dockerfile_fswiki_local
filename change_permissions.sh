#!/usr/bin/env bash
# This file is a part of https://github.com/KazKobara/dockerfile_fswiki_local
# and called from ./get_fswiki.sh .
#
# Usage:
# - Run this in the git clone folder after setting
#   FSWIKI_PLATFORM and FSWIKI_DATA_ROOT in '.env'.
#
#   $ bash ./change_permissions.sh

echo
echo "=== Changing group and permissions of ./attach/ ./backup/ ./log/ ./pdf/ ==="
if [ -z "${FSWIKI_PLATFORM+x}" ] && [ -z "${FSWIKI_DATA_ROOT+x}" ];then
    # Not called by ./get_fswiki.sh, so
    source .env
fi
if [ -z "${FSWIKI_PLATFORM+x}" ];then
    echo
    echo "ERROR: FSWIKI_PLATFORM is not set in '.env'!!"
    echo
    exit 3
elif [ -z "${FSWIKI_DATA_ROOT+x}" ];then
    echo
    echo "ERROR: FSWIKI_DATA_ROOT is not set in '.env'!!"
    echo
    exit 3
fi
echo "FSWIKI_PLATFORM: ${FSWIKI_PLATFORM}"
echo "FSWIKI_DATA_ROOT: ${FSWIKI_DATA_ROOT}"
echo
if [ "${FSWIKI_PLATFORM}" == "alpine" ];then
    ## for httpd 2.5.52 (or newer)
    GID_OF_HTTPD_SUB_PROCESSES=82
    ## for httpd 2.4.46 (or older than 2.5.52)
    # GID_OF_HTTPD_SUB_PROCESSES=2
elif [ "${FSWIKI_PLATFORM}" == "ubuntu" ];then
    ## for httpd 2.5.52 (or newer)
    GID_OF_HTTPD_SUB_PROCESSES=33
    ## for httpd 2.4.46 (or older than 2.5.52)
    # GID_OF_HTTPD_SUB_PROCESSES=1
else
    echo "ERROR: unknown FSWIKI_PLATFORM=${FSWIKI_PLATFORM}"
    exit 3
fi

# pushd "$(pwd)" || exit 2
echo
echo "The following 'chgrp' and 'chmod' require 'sudo' "
echo "since FSWiki changes the owner of the files after its access to them."
echo
set -x
cd "${FSWIKI_DATA_ROOT}" || { echo "ERROR: could not 'cd ${FSWIKI_DATA_ROOT}'!!"; exit 1; }
# To avoid that fswiki newly creates the following folders as root.
mkdir -p ./attach/ ./backup/ ./log/ ./pdf/
# Change group and permissions of files/folders corresponding to
# `Volumes:` in docker-compose.yml or `-v` in ./run_fswiki_local.sh .
# 'sudo' is needed if FSWiki changed the owner of the files after its access to them.
sudo chgrp -R "${GID_OF_HTTPD_SUB_PROCESSES}" attach/ config/ data/ log/
#sudo chmod -R a=rX,ug+w,o-rwx attach/ config/ data/ log/
sudo chmod -R a-rwx,ug+rwX attach/ config/ data/ log/
set +x
#popd || exit 2

exit 0
