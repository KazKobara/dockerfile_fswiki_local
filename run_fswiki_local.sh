#!/bin/bash
## Choose FSWIKI_PLATFORM and edit FSWIKI_PORT.
FSWIKI_PLATFORM=alpine
# FSWIKI_PLATFORM=ubuntu
FSWIKI_PORT=8365

## Edit USER_NAME, FSWIKI_DATA_DIR and FSWIKI_DATA_ROOT 
FSWIKI_DATA_DIR=share/wikilocal
## Example for Windows (WSL):
FSWIKI_DATA_ROOT="c:\Users/$USER/${FSWIKI_DATA_DIR}"
## Example for Linux/MacOS:
# FSWIKI_DATA_ROOT="/home/$USER/$FSWIKI_DATA_DIR"

docker run --restart always \
       -d -p ${FSWIKI_PORT}:80 \
       -v "${FSWIKI_DATA_ROOT}/data":/usr/local/apache2/htdocs/data \
       -v "${FSWIKI_DATA_ROOT}/attach":/usr/local/apache2/htdocs/attach \
       -v "${FSWIKI_DATA_ROOT}/config":/usr/local/apache2/htdocs/config \
       -v "${FSWIKI_DATA_ROOT}/log":/usr/local/apache2/htdocs/log \
       --name fswiki_${FSWIKI_PLATFORM}_local \
       fswiki_${FSWIKI_PLATFORM}_local:latest

# Which folders to be backuped is explained in Japanese at:
# https://fswiki.osdn.jp/cgi-bin/wiki.cgi/docs?page=readme#p6
