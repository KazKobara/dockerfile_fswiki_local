# This Dockerfile is to launch FSWiki that is used only from a local web
# browser. 
#
# CAUTION: 
# To expose it to the public network, additional security considerations
# would be necessary including https use, load-balancing, permissions
# and so on.
#
# Operation is checked at:
#  FROM httpd:2.4.43
#  perl v5.28.1
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

FROM httpd:latest

ARG tag_version
LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="${tag_version}"
LABEL description="FSWiki for local use only"

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
# httpd subprocesses are run as daemon user, so 
# ADD/COPY --chown is available at Docker 17.09 and later.
COPY --chown=daemon:daemon ${fswiki_tmp_dir}/wiki${fswiki_version} /usr/local/apache2/htdocs

# Edit here to allow access from other or all IP addresses.
# Below only allows from 172.17.0.1 assigned to the docker default gateway.
RUN sed -r -i.bk \
    's/Require all granted/Require all denied\n    Require ip 172.17.0.1/g; \
     s/#LoadModule cgid_module/LoadModule cgid_module/g; \
     s/DirectoryIndex index.html/DirectoryIndex wiki.cgi/g; \
     s/Options Indexes FollowSymLinks/Options FollowSymLinks ExecCGI/g; \
     s/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/g' \
    /usr/local/apache2/conf/httpd.conf

WORKDIR /usr/local/apache2/htdocs
COPY --chown=daemon:daemon ./favicon.ico .
RUN ./setup.sh
# TODO: owner, group and permissions should be harmonized with FSWiki setup.sh
#       and docker -v.
RUN chown -R daemon:daemon ./pdf ./backup ./data ./attach ./config ./log

# Due to "AllowOverride None", append .htaccess to httpd.conf.
RUN cat .htaccess >> /usr/local/apache2/conf/httpd.conf
