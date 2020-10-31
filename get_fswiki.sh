#!/bin/bash
# usage:
#   $ ./get_fswiki.sh [FSWIKI_VERSION [FSWIKI_TMP_DIR]]
#
#   where fefault FSWIKI_VERSION and FSWIKI_TMP_DIR are given in .env file.

source .env
echo "FSWIKI_VERSION: $FSWIKI_VERSION"
if [ "$1" != "" ];then
	FSWIKI_VERSION="$1"
	if [ "$2" != "" ];then
		FSWIKI_TMP_DIR="$2"
	fi
fi

##
FSWIKI_SOURCE_DIR="wiki${FSWIKI_VERSION}"
FSWIKI_ZIP="${FSWIKI_SOURCE_DIR}.zip"

echo "=== getting or updating fswiki ==="
if [ ! -d "${FSWIKI_TMP_DIR}" ]; then
	mkdir "${FSWIKI_TMP_DIR}"
fi
# pushd/popd is needed since this is sourced by ./docker_build.sh.
pushd "$(pwd)"
	cd "${FSWIKI_TMP_DIR}/" || (echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/'!!" ; exit 1)
	if [ "$FSWIKI_VERSION" == "latest" ]; then
		if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
			git clone https://scm.osdn.net/gitroot/fswiki/fswiki.git "${FSWIKI_SOURCE_DIR}"
		else
			(cd "${FSWIKI_SOURCE_DIR}" && git pull)
		fi
	else
		if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
			if [ ! -e "${FSWIKI_ZIP}" ]; then
				wget "https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}"
			fi
			unzip "./${FSWIKI_ZIP}"
		fi
	fi
popd