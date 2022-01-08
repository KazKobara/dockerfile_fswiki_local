#!/bin/bash

source .env
docker run --restart always \
       -d -p ${FSWIKI_PORT}:80 \
       -v "${FSWIKI_DATA_ROOT}/data":/usr/local/apache2/htdocs/data \
       -v "${FSWIKI_DATA_ROOT}/attach":/usr/local/apache2/htdocs/attach \
       -v "${FSWIKI_DATA_ROOT}/config":/usr/local/apache2/htdocs/config \
       -v "${FSWIKI_DATA_ROOT}/log":/usr/local/apache2/htdocs/log \
       -v "${FSWIKI_DATA_ROOT}/theme/kati_dark":/usr/local/apache2/htdocs/theme/kati_dark \
       --name fswiki_${FSWIKI_PLATFORM}_local_${FSWIKI_VERSION} \
       fswiki_${FSWIKI_PLATFORM}_local:${FSWIKI_VERSION}
 
#       -v "${FSWIKI_DATA_ROOT}/theme":/usr/local/apache2/htdocs/theme \
