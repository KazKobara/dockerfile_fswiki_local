# This Dockerfile is to launch FSWiki that is used only from a local web
# browser. 
# Cf. https://github.com/KazKobara/dockerfile_fswiki_local
#
# CAUTION: 
# To expose it to the public network, additional security considerations
# would be necessary including https use, load-balancing, permissions
# and so on.
#
# Operation is checked:
#  for TAG_VERSION=0.0.2 at:
#   FROM httpd:2.4.52-alpine
#   perl v5.34.0
#  for TAG_VERSION=0.0.1 at:
#   FROM httpd:2.4.46-alpine
#   perl v5.30.3
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

FROM httpd:alpine

ARG tag_version
LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="${tag_version}"
LABEL description="FSWiki for local use only"

ARG owner_group
ARG require_ip
ARG fswiki_tmp_dir
ARG fswiki_version
ENV DEBCONF_NOWARNINGS yes
RUN apk update \
    && apk add \
        perl \
        perl-cgi-fast \
    && mv /usr/local/apache2/htdocs /usr/local/apache2/htdocs_org
# httpd runs its sub-processes as a 'www-data' user for 2.4.52
# (or a 'daemon' user for older ones).
# ADD/COPY --chown is available at Docker 17.09 and later.
COPY --chown=${owner_group} ${fswiki_tmp_dir}/wiki${fswiki_version} /usr/local/apache2/htdocs

# Edit ${require_ip} to allow access from other or all IP addresses where
# ${require_ip} is given by docker-compose.yml or docker_build.sh.
RUN sed -r -i.bk \
    "s/Require all granted/Require all denied\n    Require ip ${require_ip}/g; \
     s/#ServerName www.example.com/ServerName fswiki.local/g; \
     s/#LoadModule cgid_module/LoadModule cgid_module/g; \
     s/DirectoryIndex index.html/DirectoryIndex wiki.cgi/g; \
     s/Options Indexes FollowSymLinks/Options ExecCGI/g; \
     s/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/g" \
    /usr/local/apache2/conf/httpd.conf; \
    echo "Include conf/extra/httpd-security-fswiki-local.conf" >> /usr/local/apache2/conf/httpd.conf
# root:root 644
COPY ./data/httpd-security-fswiki-local.conf /usr/local/apache2/conf/extra/.

WORKDIR /usr/local/apache2/htdocs
# TODO: owner, group, and permissions should be harmonized with FSWiki setup.sh
#       and docker -v.
COPY --chown=${owner_group} ./data/favicon.ico .
COPY --chown=${owner_group} ./data/.htaccess .
# Due to "AllowOverride None", append copied .htaccess to httpd.conf.
RUN cat .htaccess >> /usr/local/apache2/conf/httpd.conf; \
    chmod 500 ./setup.sh; ./setup.sh; \
    rm -rf ./setup.sh ./release.sh .git/ .htaccess; \
    chmod -R o-rwx ./; \
    chmod 444 /usr/local/apache2/conf/extra/httpd-security-fswiki-local.conf; \
    chown -R ${owner_group} ./attach ./backup ./config ./data ./log ./pdf

