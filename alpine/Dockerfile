# This Dockerfile is to launch FSWiki that is used only from a local web
# browser. 
#
# CAUTION: 
# To expose it to the public network, additional security considerations
# would be necessary including https use, load-balancing, permissions
# and so on.
#
# Operation is checked at:
#  FROM httpd:2.4.46-alpine
#  perl v5.30.3
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

FROM httpd:alpine

ARG tag_version
LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="${tag_version}"
LABEL description="FSWiki for local use only"

ARG fswiki_tmp_dir
ARG fswiki_version
ENV DEBCONF_NOWARNINGS yes
# shadow is for usermod
RUN apk update \
    && apk add \
        perl \
        perl-cgi-fast \
        shadow \
    && mv /usr/local/apache2/htdocs /usr/local/apache2/htdocs_org
COPY ${fswiki_tmp_dir}/wiki${fswiki_version} /usr/local/apache2/htdocs

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
COPY ./favicon.ico .
RUN ./setup.sh
# httpd subprocesses are run as daemon user, so 
RUN usermod -aG root daemon && chmod -R g+wx lib backup pdf

# Due to "AllowOverride None", append .htaccess to httpd.conf.
RUN cat .htaccess >> /usr/local/apache2/conf/httpd.conf
