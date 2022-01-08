#!/bin/bash
# usage:
#   $ ./get_fswiki.sh [FSWIKI_VERSION [FSWIKI_TMP_DIR]]
#
#   where default FSWIKI_VERSION and FSWIKI_TMP_DIR are given in .env file.

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
PATCH_COMMAND="git --git-dir= apply"
## Below requires file name to patch
# PATCH_COMMAND="eval patch <"

apply_patches () {
 	mkdir -p ../patches
    ## Check 'search in content' check box with config/config.dat.
    ## https://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=BugTrack%2Drequest%2F109
    if [ ! -e ../patches/search_in_content_control_in_config_dat.patch ]; then
	    curl -o ../patches/search_in_content_control_in_config_dat.patch "https://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=BugTrack%2Drequest%2F109&file=search%5Fin%5Fcontent%5Fcontrol%5Fin%5Fconfig%5Fdat%2Epatch&action=ATTACH"
    fi
    $PATCH_COMMAND ../patches/search_in_content_control_in_config_dat.patch
    ## Patch for 'value or values' warning.
    ## https://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=BBS%2D%A5%B5%A5%DD%A1%BC%A5%C8%B7%C7%BC%A8%C8%C4%2F997
    if [ ! -e ../patches/value_or_values_in_lib_CGI2_pm.patch ]; then
	    curl -o ../patches/value_or_values_in_lib_CGI2_pm.patch "https://fswiki.osdn.jp/cgi-bin/wiki.cgi?action=ATTACH&file=value%5For%5Fvalues%5Fin%5Flib%5FCGI2%5Fpm%2Epatch&page=BBS%2D%A5%B5%A5%DD%A1%BC%A5%C8%B7%C7%BC%A8%C8%C4%2F997"
    fi
    $PATCH_COMMAND ../patches/value_or_values_in_lib_CGI2_pm.patch
    ## Add Menu.wiki
    cp -p ../../data/Menu.wiki data/.
}

echo
echo "=== getting or updating fswiki ==="
mkdir -p "${FSWIKI_TMP_DIR}"
# pushd/popd is needed since this is sourced by ./docker_build.sh.
pushd "$(pwd)" || exit 2
cd "${FSWIKI_TMP_DIR}/" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/'!!"; exit 1; }
if [ "$FSWIKI_VERSION" == "latest" ]; then
    if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
	    git clone https://scm.osdn.net/gitroot/fswiki/fswiki.git "${FSWIKI_SOURCE_DIR}"
	    (cd "${FSWIKI_SOURCE_DIR}" && apply_patches)
    else
	    (cd "${FSWIKI_SOURCE_DIR}" && git pull)
    fi
else
    if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
    	if [ ! -e "${FSWIKI_ZIP}" ]; then
	        curl -OL "https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}"
            # wget "https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}"
	    fi
	    unzip "./${FSWIKI_ZIP}"
	    (cd "${FSWIKI_SOURCE_DIR}" && apply_patches)
    fi
fi

# Get new theme
if [ "${FSWIKI_THEME}" == "kati_dark" ]; then
    echo
    echo "=== git clone or pull 'kati_dark' theme ==="
    # pushd/popd is needed since this is sourced by ./docker_build.sh.
    pushd "$(pwd)" || exit 2
    mkdir -p "${FSWIKI_SOURCE_DIR}/theme"
    cd "${FSWIKI_SOURCE_DIR}/theme" || { echo "ERROR: could not 'cd ${FSWIKI_SOURCE_DIR}/wiki${FSWIKI_VERSION}/theme/'!!"; exit 1; }
    if [ ! -e "${FSWIKI_THEME}" ]; then
        git clone git@github.com:KazKobara/kati_dark.git
    else
        (cd "kati_dark" && git pull)
    fi
    popd || exit 2
fi

# Change theme of FSWiki
grep -qE "^theme=${FSWIKI_THEME}$|^theme=${FSWIKI_THEME} " "${FSWIKI_SOURCE_DIR}"/config/config.dat
if [ "$?" == "1" ]; then
    # not exist
    sed -r -i.bk \
        "/^theme=/d" \
        wiki"${FSWIKI_VERSION}"/config/config.dat
    echo "theme=${FSWIKI_THEME}" >> wiki"${FSWIKI_VERSION}"/config/config.dat
    echo
    echo "FSWiki's theme was changed to:"
    echo "------------------------------"
    grep -E "^theme=" "${FSWIKI_SOURCE_DIR}"/config/config.dat
    echo "------------------------------"
fi

popd || exit 2
