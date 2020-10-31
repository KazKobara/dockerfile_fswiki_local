#!/bin/bash

# IP or network addresses to be accessed from:
# docker build assigns 172.17.0.x to its bridge network.
REQUIRE_IP=172.17.0.1

source ./get_fswiki.sh 

echo "=== docker building ==="
docker build -f "./${FSWIKI_PLATFORM}/Dockerfile" \
	-t "fswiki_${FSWIKI_PLATFORM}_local:${FSWIKI_VERSION}" . \
    --build-arg tag_version="${TAG_VERSION}" \
	--build-arg fswiki_version="${FSWIKI_VERSION}" \
	--build-arg fswiki_tmp_dir="${FSWIKI_TMP_DIR}" \
	--build-arg require_ip="${REQUIRE_IP}"
