#!/usr/bin/env bash
# Cf. https://github.com/KazKobara/dockerfile_fswiki_local

# IP or network addresses to be accessed from:
# docker build assigns 172.17.0.0/16 to its docker bridge network.
REQUIRE_IP=172.17.0.1

source ./get_fswiki.sh 

echo "=== docker building ==="
# docker build -f "./${FSWIKI_PLATFORM}/Dockerfile" \
"${CONTAINER_CLI}" build -f "./${FSWIKI_PLATFORM}/Dockerfile" \
	-t "fswiki_${FSWIKI_PLATFORM}_local:${FSWIKI_VERSION}" . \
	--build-arg tag_version="${TAG_VERSION}" \
	--build-arg fswiki_version="${FSWIKI_VERSION}" \
	--build-arg fswiki_tmp_dir="${FSWIKI_TMP_DIR}" \
	--build-arg require_ip="${REQUIRE_IP}" \
	--build-arg owner_group="${OWNER_GROUP}"
