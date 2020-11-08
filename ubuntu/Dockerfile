# This Dockerfile is to launch FSWiki that is used only from a local web
# browser. 
#
# CAUTION: 
# To expose it to the public network, additional security considerations
# would be necessary including https use, load-balancing, permissions
# and so on.
#
# Operation is checked at:
#  FROM httpd:2.4.46, 2.4.43 
#  perl v5.28.1
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

FROM httpd:latest

ARG tag_version
LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="${tag_version}"
LABEL description="FSWiki for local use only"

ARG require_ip
ARG fswiki_tmp_dir
ARG fswiki_version
ENV DEBCONF_NOWARNINGS yes
# ca-certificates is for wget
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        perl \
        libcgi-session-perl \
        ca-certificates \
    && apt-get autoremove -y \
    && mv /usr/local/apache2/htdocs /usr/local/apache2/htdocs_org
# httpd runs its sub-processes as daemon user, and 
# ADD/COPY --chown is available at Docker 17.09 and later.
COPY --chown=daemon:daemon ${fswiki_tmp_dir}/wiki${fswiki_version} /usr/local/apache2/htdocs

# Edit ${require_ip} to allow access from other or all IP addresses where
# ${require_ip} is given by docker-compose.yml or docker_build.sh.
RUN sed -r -i.bk \
    "s/Require all granted/Require all denied\n    Require ip ${require_ip}/g; \
     s/#ServerName www.example.com/ServerName fswiki.local/g; \
     s/#LoadModule cgid_module/LoadModule cgid_module/g; \
     s/DirectoryIndex index.html/DirectoryIndex wiki.cgi/g; \
     s/Options Indexes FollowSymLinks/Options FollowSymLinks ExecCGI/g; \
     s/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/g" \
    /usr/local/apache2/conf/httpd.conf; \
    echo "Include conf/extra/httpd-security-fswiki-local.conf" >> /usr/local/apache2/conf/httpd.conf
COPY ./data/httpd-security-fswiki-local.conf /usr/local/apache2/conf/extra/.

WORKDIR /usr/local/apache2/htdocs
# TODO: owner, group and permissions should be harmonized with FSWiki setup.sh
#       and docker -v.
COPY --chown=daemon:daemon ./data/favicon.ico .
# To avoid abusing and/or downloading *.sh since .htaccess could not prevent it. 
RUN chmod 500 ./setup.sh; ./setup.sh; rm -f ./setup.sh
RUN chown -R daemon:daemon ./pdf ./backup ./data ./attach ./config ./log

COPY ./data/.htaccess .
# Due to "AllowOverride None", append .htaccess to httpd.conf.
RUN cat .htaccess >> /usr/local/apache2/conf/httpd.conf
