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
#   FROM httpd:2.4.52
#   perl v5.32.1
# for TAG_VERSION=0.0.1 at:
#  FROM httpd:2.4.46, 2.4.43 
#  perl v5.28.1
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

FROM httpd:latest

ARG tag_version
LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="${tag_version}"
LABEL description="FSWiki for local use only"

ARG owner_group
ARG require_ip
ARG fswiki_tmp_dir
ARG fswiki_version
# ENV DEBCONF_NOWARNINGS yes  # LegacyKeyValueFormat
ENV DEBCONF_NOWARNINGS=yes
# ca-certificates is for git (and curl/wget).
# libtext-markdown-perl is for Text::Markdown
#   (1.000031 as of Jan, 2022).
# libtext-markdown-discount-perl is for Text::Markdown::Discount
#   (0.12+b1 and Discount 2.2.6-1 as of Jan, 2022).
# `&& git make gcc libperl-dev \` are for Text::Markdown::Discount 0.13 or later
# `&& git cherry-pick b002a5a \` is to fix https://github.com/Orc/discount/issues/189 
#   for Text::Markdown::Discount 0.13.
# `&& git clone https://github.com/KazKobara/text-markdown-discount.git -b discount-2.2.7 --depth 1 \`
#   is tentative until 
#   both https://github.com/sekimura/text-markdown-discount/pull/25
#   and  https://github.com/adamatousek/text-markdown-discount/pull/1 are accepted.
# `&& addgroup --gid 82 www-data-alpine \`
# `&& adduser www-data www-data-alpine \`
#   are to share the data volume with Alpine.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        perl \
        ca-certificates \
        libcgi-session-perl \
        git make gcc libperl-dev\
    && addgroup --gid 82 www-data-alpine \
    && adduser www-data www-data-alpine \
    && mv /usr/local/apache2/htdocs /usr/local/apache2/htdocs_org \
    && git clone https://github.com/KazKobara/text-markdown-discount.git -b discount-2.2.7 --depth 1 \
    && (cd text-markdown-discount \
    && perl Makefile.PL && make && make install) \
    && apt-get purge -y git make gcc libperl-dev \
    && apt-get autoremove -y
#
#    && git clone https://github.com/sekimura/text-markdown-discount.git -b 0.13 --depth 1 \
#    && (cd text-markdown-discount \
#    && git remote add -t v2maint discount https://github.com/Orc/discount.git \
#    && git fetch --depth 400 -n discount \
#    && git cherry-pick -n b002a5a \
#
#    && rm -rf text-markdown-discount \
#
# httpd runs its sub-processes as daemon user, and 
# ADD/COPY --chown is available at Docker 17.09 and later.
COPY --chown=${owner_group} ${fswiki_tmp_dir}/wiki${fswiki_version} /usr/local/apache2/htdocs

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
# root:root 644
COPY ./data/httpd-security-fswiki-local.conf /usr/local/apache2/conf/extra/.

WORKDIR /usr/local/apache2/htdocs
# TODO: owner, group, and permissions should be harmonized with FSWiki setup.sh
#       and docker -v.
# Due to "AllowOverride None", append .htaccess to httpd.conf.
RUN sh ./setup.sh; \
    rm -rf ./setup.sh ./release.sh .git/ ./theme/kati_dark/.git/ ./theme/resources/jsdifflib/.git/; \
    chown -R ${owner_group} attach/ config/ data/ log/ backup/ pdf/; \
    chmod -R o-rwx ./; \
    chmod 444 /usr/local/apache2/conf/extra/httpd-security-fswiki-local.conf
# Despite `COPY --chown`, ./setup.sh creates missing folders as root.
