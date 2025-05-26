#!/usr/bin/env bash
# This file is a part of
# https://github.com/KazKobara/dockerfile_fswiki_local

source .env

## Replace './' with $PWD to deal with the following error:
##   docker: Error response from daemon: create ./xxx: "./xxx" includes invalid characters for a local volume name, only "[a-zA-Z0-9][a-zA-Z0-9_.-]" are allowed. If you intended to pass a host directory, use absolute path.
##   See 'docker run --help'.
##
## For linux docker:
# FSWIKI_DATA_ROOT="${FSWIKI_DATA_ROOT/.\//$(pwd)/}"
FSWIKI_DATA_ROOT="${FSWIKI_DATA_ROOT/.\//${PWD}/}"
## For windows docker, ${PWD} must be a windows path like 'c:\..'. 

echo "FSWIKI_DATA_ROOT: ${FSWIKI_DATA_ROOT}"

# docker run --restart always \
"${CONTAINER_CLI}" run --restart always \
       -d -p "${FSWIKI_PORT_PRIVATE}:80" \
       -v "${FSWIKI_DATA_ROOT}/data":/usr/local/apache2/htdocs/data \
       -v "${FSWIKI_DATA_ROOT}/attach":/usr/local/apache2/htdocs/attach \
       -v "${FSWIKI_DATA_ROOT}/config":/usr/local/apache2/htdocs/config \
       -v "${FSWIKI_DATA_ROOT}/log":/usr/local/apache2/htdocs/log \
       --name "fswiki_${FSWIKI_PLATFORM}_private_${FSWIKI_VERSION}" \
       "fswiki_${FSWIKI_PLATFORM}_local:${FSWIKI_VERSION}"
