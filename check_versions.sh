#!/usr/bin/env sh
#
# Usage:
#   check_versions $container_name
#
# Cf. https://github.com/KazKobara/dockerfile_fswiki_local

docker exec "$1" sh -c \
       "uname -r; \
        cat /etc/os-release | awk -F '\"' '/^PRETTY_NAME=/ {print \$2}'; \
        which busybox > /dev/null && { busybox | head -1 ;}; \
        httpd -v | awk '/Apache/ {print \$3}'; \
	perl -v  | awk '/^This is perl/ {print \$3 \$9}'; \
        ../text-markdown-discount/discount/markdown -version; \
       "
