FROM httpd:latest

LABEL maintainer="Kaz KOBARA <M-kaz-ml@aist.go.jp>"
LABEL version="0.0.0"
LABEL description="FSWiki for local use only"

# CAUTION: 
# This Dockerfile is to launch FSWiki that is used only from a local web browser. Additional security considerations would be necessary to expose it to the public network, such as https use, load-balancing and so on.
# ---
# THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.

ENV DEBCONF_NOWARNINGS yes
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install perl -y
RUN apt-get install libcgi-session-perl -y
RUN apt-get install wget -y
RUN apt-get install unzip -y
RUN apt-get autoremove -y
RUN mv /usr/local/apache2/htdocs /usr/local/apache2/htdocs_org
RUN wget https://ja.osdn.net/projects/fswiki/downloads/69263/wiki3_6_5.zip
RUN unzip ./wiki3_6_5.zip && mv wiki3_6_5 /usr/local/apache2/htdocs

RUN sed -r -i.bk 's/#LoadModule cgid_module/LoadModule cgid_module/g; \
             s/DirectoryIndex index.html/DirectoryIndex wiki.cgi/g; \
             s/Options Indexes FollowSymLinks/Options FollowSymLinks ExecCGI/g; \
             s/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/g' /usr/local/apache2/conf/httpd.conf

WORKDIR /usr/local/apache2/htdocs
COPY favicon.ico .
RUN ./setup.sh
# httpd subprocesses are run as daemon user, so 
RUN usermod -aG root daemon
RUN chmod -R g+wx lib backup pdf

# COPY .htaccess /usr/local/apache2/htdocs/.
# Due to "AllowOverride None", append .htaccess to httpd.conf.
RUN cat .htaccess >> /usr/local/apache2/conf/httpd.conf
