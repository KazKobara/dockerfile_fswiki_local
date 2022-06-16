#!/usr/bin/env sh
#
# Usage:
#   check_versions $container_name
#
# Cf. https://github.com/KazKobara/dockerfile_fswiki_local

docker exec "$1" sh -c \
       "uname -r; \
        httpd -v | awk '/Apache/ {print \$3}'; \
	perl -v  | awk '/^This is perl/ {print \$3 \$9}'; \
        ../text-markdown-discount/discount/markdown -version; \
       "
