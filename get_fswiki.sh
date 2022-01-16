#!/bin/bash
# usage:
#   $ ./get_fswiki.sh [FSWIKI_VERSION [FSWIKI_TMP_DIR]]
#
#   where default FSWIKI_VERSION and FSWIKI_TMP_DIR are given in .env file.
#   Cf. https://github.com/KazKobara/dockerfile_fswiki_local

source .env
echo "FSWIKI_VERSION: $FSWIKI_VERSION"
if [ "$1" != "" ];then
    FSWIKI_VERSION="$1"
    if [ "$2" != "" ];then
        FSWIKI_TMP_DIR="$2"
    fi
fi

##
if [ "${FSWIKI_PLATFORM}" == "alpine" ];then
    ## for httpd 2.5.52 (or newer)
    GID_OF_HTTPD_SUB_PROCESSES=82
    ## for httpd 2.4.46 (or older than 2.5.52)
    # GID_OF_HTTPD_SUB_PROCESSES=2
elif [ "${FSWIKI_PLATFORM}" == "ubuntu" ];then
    ## for httpd 2.5.52 (or newer)
    GID_OF_HTTPD_SUB_PROCESSES=33
    ## for httpd 2.4.46 (or older than 2.5.52)
    # GID_OF_HTTPD_SUB_PROCESSES=1
else
    echo "ERROR: unknown FSWIKI_PLATFORM=${FSWIKI_PLATFORM}"
fi
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
    ## Add customized files.
    # Menu.wiki
    if [ ! -e "./data/Menu.wiki" ]; then
        cp -p ../../data/Menu.wiki data/.
    fi
    # favicon.ico
    if [ ! -e "./favicon.ico" ]; then
        # curl -o favicon.ico "http://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=BBS%2D%BB%A8%C3%CC%B7%C7%BC%A8%C8%C4%2F131&action=ATTACH&file=aki2%2Eico"
        cp -p ../../data/favicon.ico .
    fi
    # .htaccess
    if [ -e "../../data/.htaccess" ]; then
        # mv .htaccess if different
        if [ -e "./.htaccess" ]; then
            cmp -s ./.htaccess ../../data/.htaccess
            ret=$?
            if [ "$ret" == "1" ]; then
                # different
                mv ./.htaccess ./.htaccess_org
            elif [ "$ret" == "2" ]; then
                echo "Error in cmp!!"
                exit 1
            fi
        fi
        if [ ! -e "./.htaccess" ]; then
            cp -p ../../data/.htaccess .
        fi
    fi
}

echo
echo "=== getting or updating fswiki ==="
mkdir -p "${FSWIKI_TMP_DIR}"
# pushd/popd is needed since this is sourced by ./docker_build.sh.
pushd "$(pwd)" || exit 2
cd "${FSWIKI_TMP_DIR}/" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/'!!"; exit 1; }
if [ "$FSWIKI_VERSION" == "latest" ]; then
    if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
	    git clone --depth 1 https://scm.osdn.net/gitroot/fswiki/fswiki.git "${FSWIKI_SOURCE_DIR}"
	    (cd "${FSWIKI_SOURCE_DIR}" && apply_patches)
    else
	    (cd "${FSWIKI_SOURCE_DIR}" && git pull --depth 1)
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
    # mkdir -p "${FSWIKI_SOURCE_DIR}/theme"
    cd "${FSWIKI_SOURCE_DIR}/theme" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/wiki${FSWIKI_VERSION}/theme/'!!"; exit 1; }
    if [ ! -e "${FSWIKI_THEME}" ]; then
        # git clone --depth 1 git@github.com:KazKobara/kati_dark.git
        git clone --depth 1 https://github.com/KazKobara/kati_dark.git
    else
        (cd "kati_dark" && git pull --depth 1)
    fi
    popd || exit 2
fi

# Get jsdifflib
echo
echo "=== git clone or pull 'jsdifflib' ==="
# pushd/popd is needed since this is sourced by ./docker_build.sh.
pushd "$(pwd)" || exit 2
cd "${FSWIKI_SOURCE_DIR}/theme/resources/" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/wiki${FSWIKI_VERSION}/theme/resources/'!!"; exit 1; }
# `git -C ./jsdifflib/ rev-parse 2>/dev/null` does not work since it is under another git repo.
TESTED_JSDIFFLIB=f728d45e5ccb798f35696f2ac6b763fbfc7682d0
if [ ! -d "jsdifflib/.git" ]; then
    if [ -d "jsdifflib" ]; then
        mv jsdifflib jsdifflib_org 
    fi
    git clone https://github.com/cemerick/jsdifflib.git
    (cd jsdifflib && \
    git reset --hard "${TESTED_JSDIFFLIB}" && \
    $PATCH_COMMAND ../../../../../data/diffview_to_both_white_and_black_text.patch)
else
    # (cd "jsdifflib" && git pull --depth 1)
    pushd "$(pwd)" || exit 2
        cd "jsdifflib" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/wiki${FSWIKI_VERSION}/theme/resources/jsdifflib/'!!"; exit 1; }
        REMOTE=$(git rev-parse @\{u\})
        LOCAL=$(git rev-parse @\{0\})
        MERGE_BASE=$(git merge-base @\{0\} @\{u\})
        if [ "$REMOTE" == "$LOCAL" ]; then
            echo "jsdifflib is up-to-date"
        elif [ "$MERGE_BASE" == "$LOCAL" ]; then
            echo "========================================================="
            echo " Updated jsdifflib is available, git pull; and test it!! "
            echo " If test is passed, update TESTED_JSDIFFLIB in this file."
            echo "========================================================="
        fi
    popd || exit 2
fi

popd || exit 2

## Change group and permissions
# Cf. https://github.com/KazKobara/dockerfile_fswiki_local
echo
echo "=== Changing group and permissions of ./attach/ ./backup/ ./log/ ./pdf/ ==="
echo "=== under ${FSWIKI_SOURCE_DIR} . ==="
pushd "$(pwd)" || exit 2
cd "${FSWIKI_SOURCE_DIR}" || { echo "ERROR: could not 'cd ${FSWIKI_SOURCE_DIR}'!!"; exit 1; }
# To avoid that fswiki newly creates the following folders as root.
mkdir -p ./attach/ ./backup/ ./log/ ./pdf/
# Change group and permissions of files/folders corresponding to
# `Volumes:` in docker-compose.yml or `-v` in ./run_fswiki_local.sh .
# 'sudo' is needed if FSWiki changed the owner of the files after its access to them.
sudo chgrp -R "${GID_OF_HTTPD_SUB_PROCESSES}" attach/ config/ data/ log/
sudo chmod -R a=rX,ug+w attach/ config/ data/ log/
popd || exit 2

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
