#!/usr/bin/env bash
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

GIT_PULL="git pull --depth 1"
# GIT_PULL="git pull --unshallow"
FSWIKI_SOURCE_DIR="wiki${FSWIKI_VERSION}"
FSWIKI_ZIP="${FSWIKI_SOURCE_DIR}.zip"
PATCH_COMMAND="git --git-dir= apply"
## Below requires file name to patch
# PATCH_COMMAND="eval patch <"

# Patches to FSWiki 3.6.5
# TODO: '../../' assumes and depends on "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}/".
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
    # rsync -c -b --suffix=_org ../../data/.htaccess ./.htaccess
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
    ## Diff.pm and diff.js for CSP Hash
    $PATCH_COMMAND ../../data/Diff.pm.patch
    if [ ! -e "./theme/resources/diff.js" ]; then
        cp -p ../../data/diff.js ./theme/resources/diff.js
    fi
    ##### Plugin #####
    ## Default Off
    #for p in markdown rename; do
    #    sed -E -i "/^$p *\$/d" ./config/plugin.dat
    #done
    ## Default On
    for p in markdown rename; do
        grep -qE "^$p *\$"  ./config/plugin.dat || sed -E -i "\$i$p" ./config/plugin.dat
        # grep -qE "^$p *\$"  ./config/plugin.dat || sed -E -i "\$a$p" ./config/plugin.dat
        ## Following does not work since the file does not end with a new line.
        # grep -qE "^$p *\$"  ./config/plugin.dat || echo "$p" >> ./config/plugin.dat
    done
    echo
    echo "---- ./config/plugin.dat -----"
    cat ./config/plugin.dat
    echo "------------------------------"
    echo
}

echo
echo "=== getting or updating fswiki ==="
mkdir -p "${FSWIKI_TMP_DIR}"
# pushd/popd are needed since this is sourced by ./docker_build.sh.
pushd "$(pwd)" || exit 2
cd "${FSWIKI_TMP_DIR}/" || { echo "ERROR: could not 'cd ${FSWIKI_TMP_DIR}/'!!"; exit 1; }
if [ ! -e "${FSWIKI_SOURCE_DIR}" ]; then
    if [ "$FSWIKI_VERSION" == "latest" ]; then
	    git clone --depth 1 https://scm.osdn.net/gitroot/fswiki/fswiki.git "${FSWIKI_SOURCE_DIR}"
    else
        if [ ! -e "${FSWIKI_ZIP}" ]; then
            curl -OL "https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}"
            # wget "https://ja.osdn.net/projects/fswiki/downloads/69263/${FSWIKI_ZIP}"
        fi
        unzip "./${FSWIKI_ZIP}"
    fi
    (cd "${FSWIKI_SOURCE_DIR}" && apply_patches)
elif [ ! -d "${FSWIKI_SOURCE_DIR}" ]; then
    echo "WARNING: ${FSWIKI_SOURCE_DIR} exists but not a folder!!"
else
    # The holder exists.
    if [ "$FSWIKI_VERSION" == "latest" ]; then
	    (cd "${FSWIKI_SOURCE_DIR}" && ${GIT_PULL})
    fi
fi

# in "./${FSWIKI_TMP_DIR}"
echo
echo "=== setting in ${FSWIKI_SOURCE_DIR} ==="
pushd "$(pwd)" || exit 2
cd "./${FSWIKI_SOURCE_DIR}/" || { echo "ERROR: could not 'cd ./${FSWIKI_SOURCE_DIR}/'!!" ; exit 1; }

# Get new theme
# in "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}/"
if [ "${FSWIKI_THEME}" == "kati_dark" ]; then
    echo
    echo "=== git clone or pull 'kati_dark' theme ==="
    pushd "$(pwd)" || exit 2
        # mkdir -p "$./theme"
        cd "./theme" || { echo "ERROR: could not 'cd ./theme/'!!"; exit 1; }
        if [ ! -e "${FSWIKI_THEME}" ]; then
            # git clone --depth 1 git@github.com:KazKobara/kati_dark.git
            git clone --depth 1 https://github.com/KazKobara/kati_dark.git
        elif [ ! -d "${FSWIKI_THEME}" ]; then
            echo "WARNING: ${FSWIKI_THEME} exists but not a folder!!"
        else
            (cd "kati_dark" && ${GIT_PULL})
        fi
        # Hard link if not exists to maintain consistency between them.
        # TODO: On WSL1/2, becomes a copy after edit.
        if [ ! -e "../data/Help%2FMarkdown.wiki" ]; then
            ln kati_dark/docs/markdown/Help%2FMarkdown.wiki ../data/Help%2FMarkdown.wiki 
        fi
    popd || exit 2
fi

# Get jsdifflib
# in "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}/"
echo
echo "=== git clone or pull 'jsdifflib' ==="
pushd "$(pwd)" || exit 2
    cd "./theme/resources/" || { echo "ERROR: could not 'cd ./theme/resources/'!!"; exit 1; }
    # `git -C ./jsdifflib/ rev-parse 2>/dev/null` does not work since it is under another git repo.
    TESTED_JSDIFFLIB=f728d45e5ccb798f35696f2ac6b763fbfc7682d0
    if [ ! -e "jsdifflib/.git" ]; then
        if [ -d "jsdifflib" ]; then
            mv jsdifflib jsdifflib_org
        fi
        git clone https://github.com/cemerick/jsdifflib.git
        # TODO: patch dir depends on "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}/".
        (cd jsdifflib && \
        git reset --hard "${TESTED_JSDIFFLIB}" && \
        $PATCH_COMMAND ../../../../../data/diffview_to_both_white_and_black_text.patch)
    elif [ ! -d "jsdifflib/.git" ]; then
        echo "WARNING: jsdifflib/.git exists but not a folder!!"
    else
        # (cd "jsdifflib" && ${GIT_PULL})
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
# Now in "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}"

# Get markdown plugin
# in "${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}"
# cf. https://github.com/KazKobara/kati_dark/docs/markdown/markdown_plugin_for_fswiki.md
MARKDOWN_ZIP=markdown_20120714.zip
echo
echo "=== Downloading markdown_20120714.zip ==="
echo "pwd: $(pwd)"
pushd "$(pwd)" || exit 2
    cd "./plugin/" || { echo "ERROR: could not 'cd ./plugin/'!!"; exit 1; }
    if [ ! -e "./markdown" ]; then
        if [ ! -e "${MARKDOWN_ZIP}" ]; then
            curl -o "${MARKDOWN_ZIP}" "https://fswiki.osdn.jp/cgi-bin/wiki.cgi?file=markdown%5F20120714%2Ezip&page=BugTrack%2Dplugin%2F417&action=ATTACH"
        fi
        unzip "./${MARKDOWN_ZIP}"
        # Apply a patch for Discount
        sed -i.bk \
            "s/^use Text::Markdown /use Text::Markdown::Discount /; " \
            ./markdown/Markdown.pm
    elif [ ! -d "./markdown" ]; then
       echo "WARNING: ./markdown exists but not a folder!!"
    fi
popd || exit 2
# Now in "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}"

# echo "=== Downloading Text::Markdown ==="
#    mkdir -p ./lib/Text/
#    if [ ! -e "./lib/Text/Markdown.pm" ]; then
#        # https://cpan.metacpan.org/authors/id/B/BO/BOBTFISH/Text-Markdown-1.000031.tar.gz
#        curl -o ./lib/Text/Markdown.pm -L https://raw.githubusercontent.com/bobtfish/text-markdown/master/lib/Text/Markdown.pm
#    fi

popd || exit 2
# Now in "./${FSWIKI_TMP_DIR}/"
popd || exit 2
# Now in "./dockerfile_fswiki_local"

# Change theme of FSWiki
# in ./dockerfile_fswiki_local
pushd "$(pwd)" || exit 2
    cd "./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}" || { echo "ERROR: could not 'cd ./${FSWIKI_TMP_DIR}/${FSWIKI_SOURCE_DIR}'!!"; exit 1; }
    grep -qE "^theme=${FSWIKI_THEME}$|^theme=${FSWIKI_THEME} " ./config/config.dat
    if [ "$?" == "1" ]; then
        # not exist
        sed -E -i.bk \
            "/^theme=/d" \
            ./config/config.dat
        echo "theme=${FSWIKI_THEME}" >> ./config/config.dat
        echo
        echo "FSWiki's theme was changed to:"
        echo "------------------------------"
        grep -E "^theme=" ./config/config.dat
        echo "------------------------------"
    fi
popd || exit 2
# Now in "./dockerfile_fswiki_local"
# pushd/popd are needed since this is sourced by ./docker_build.sh.

## Change group and permissions
# in ./dockerfile_fswiki_local
bash ./change_permissions.sh || { echo "ERROR: ./change_permissions.sh failed!!"; exit 3;}
## This group/permissions change must come last.
