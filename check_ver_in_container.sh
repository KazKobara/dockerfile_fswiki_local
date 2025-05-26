#!/usr/bin/env bash
# .env uses array that does not work on sh.
#
# Script to check versions in a container
# (maintained at https://github.com/KazKobara/dockerfile_fswiki_local )

### Params ###
if [ -e .env ]; then
    # Use TAG_VERSION and CONTAINER_CLI in .env
    . ./.env
else
    TAG_VERSION=0.0.5
    CONTAINER_CLI=docker
    # CONTAINER_CLI=nerdctl
fi

usage () {
    COMMAND=$(basename "$0")
    echo "Check versions in a container ${TAG_VERSION}"
    echo "Usage:"
    echo
    echo "  ./${COMMAND} <container_name>"
    echo
    echo "  or if either only one container runs or"
    echo "  to list up all the running containers"
    echo
    echo "  ./${COMMAND}"
}

container_exec () {
    ${CONTAINER_CLI} exec "$1" sh -c \
       "uname -r; \
        cat /etc/os-release | awk -F '\"' '/^PRETTY_NAME=/ {print \$2}'; \
        which busybox > /dev/null && { busybox | head -1 ;}; \
        httpd -v | awk '/Apache/ {print \$3}'; \
	    perl -v  | awk '/^This is perl/ {print \$3 \$9}'; \
        ../text-markdown-discount/discount/markdown -version; \
       "
}

### Body ###

# Setup and check
if [ "$#" -ge 2 ]; then
    usage
    exit 1
elif [ "$1" != "" ]; then
    CONTAINER_NAME=$1
else
    CONTAINER_NAME=$(${CONTAINER_CLI} ps --format "{{.Names}}")
    PS_NUM=$(echo "${CONTAINER_NAME}" | wc -l)
    if [ "${PS_NUM}" != "1" ]; then
        echo "------ Running Containers ------"
        echo "${CONTAINER_NAME}"
        echo "--------------------------------"
        exit 0
    fi
fi

container_exec "${CONTAINER_NAME}"
exit 0
