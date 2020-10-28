#!/bin/bash

## Choose FSWIKI_PLATFORM and edit FSWIKI_VERSION.
FSWIKI_PLATFORM=alpine
# FSWIKI_PLATFORM=ubuntu
FSWIKI_VERSION=3_6_5

##
TAG_VERSION=0.0.0
FSWIKI_TMP_DIR=tmp  # path from ../.
FSWIKI_SOURCE_DIR="wiki${FSWIKI_VERSION}"
FSWIKI_ZIP="${FSWIKI_SOURCE_DIR}.zip"

if [ ! -d ${FSWIKI_TMP_DIR} ]; then
	mkdir ${FSWIKI_TMP_DIR}
fi
pushd `pwd`
	cd ${FSWIKI_TMP_DIR}/
	if [ ! -e ${FSWIKI_SOURCE_DIR} ]; then
		if [ ! -e ${FSWIKI_ZIP} ]; then
			wget https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}
		fi
		unzip ./${FSWIKI_ZIP} 
	fi
popd
echo "=== docker building ==="
pwd
docker build -f ./${FSWIKI_PLATFORM}/Dockerfile -t fswiki_${FSWIKI_PLATFORM}_local:latest . \
       	--build-arg tag_version="${TAG_VERSION}" \
	--build-arg fswiki_version="${FSWIKI_VERSION}" \
	--build-arg fswiki_tmp_dir="${FSWIKI_TMP_DIR}"
