#!/bin/bash
# Usage:
#   check_versions $container_name

docker exec "$1" sh -c \
       "uname -r; \
        httpd -v | awk '/Apache/ {print \$3}'; \
	perl -v  | awk '/^This is perl/ {print \$3 \$9}'"
