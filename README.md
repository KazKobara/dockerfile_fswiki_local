# Dockerfile and docker-compose.yml for local use FSWiki

[FSWiki (FreeStyleWiki)](https://fswiki.osdn.jp/cgi-bin/wiki.cgi) is a Wiki clone written in Perl.

This Dockerfile is to launch FSWiki that is used only from a local web browser.

![screenshot](https://raw.githubusercontent.com/KazKobara/kati_dark/main/docs/screenshot.png)
<!--
![](https://fswiki.osdn.jp/cgi-bin/wiki.cgi?action=ATTACH&page=BugTrack%2Dtheme%2F30&file=screenshot%5Fsmall%2Epng)
-->

> **CAUTION:**
To expose it to the public network, additional security considerations
would be necessary including https use, load-balancing, permissions
and so on.

## How to use

Run the following commands on a shell terminal.

### 1. Get Dockerfile etc and enter the folder

~~~shell
git clone https://github.com/KazKobara/dockerfile_fswiki_local.git .
~~~

~~~shell
cd dockerfile_fswiki_local
~~~

Edit parameters in the `.env` file.

~~~shell
vim .env
~~~

For the following steps, either docker-compose or shell scripts can be used.

If they pop up the following window on Windows, click the "cancel" button to block the access from outside your PC.

![cancel](./data/warning.png)

### 2. When using docker-compose

Download FSWiki under ./tmp/ with:

~~~shell
./get_fswiki.sh
~~~

Run,

~~~shell
docker-compose up
~~~

or on Windows,

~~~shell
docker-compose.exe up
~~~

If the log messages on the terminal are not necessary, add `-d` option to them.

Then access `http//localhost:<FSWIKI_PORT specified in the .env file>/` such as `http//localhost:8365/` with a web browser.

To stop,

~~~shell
docker-compose down
~~~

or on Windows,

~~~shell
docker-compose.exe down
~~~

For more options, cf. [reference of docker-compose](https://docs.docker.com/compose/reference/down/).

### 2. When using shell scripts

#### 2.1 Build image

~~~shell
./docker_build.sh
~~~

#### 2.2 Run server for local use

~~~shell
./run_fswiki_local.sh
~~~

Then access `http//localhost:<FSWIKI_PORT specified in the .env file>/` such as `http//localhost:8365/` with a web browser.

#### Stop and remove the process

~~~shell
docker stop <container_name> && docker rm <container_name>
~~~

where `<container_name>` is `fswiki_alpine_local_dc` or   `fswiki_ubuntu_local_dc` for docker-compose versions, and `fswiki_alpine_local` or   `fswiki_ubuntu_local` for shell script versions.

#### Remove the image

~~~shell
docker rmi <image_name>
~~~

where `<image_name>` is `<container_name>:<fswiki_version>` and `<fswiki_version>` is `latest`, `3_8_5`, and os on.

## Differences between docker-compose and shell versions

- The differences are the network addresses to be assigned and IP addresses that can access the fswiki server in the docker network.
  - docker-compose uses 10.0.0.0/24 and httpd accepts access only from 10.0.0.1.
  - shell version (docker build) uses 172.17.0.0/16 and httpd accepts access only from 172.17.0.1.
  - See [this page](https://github.com/KazKobara/tips-jp/blob/gh-pages/docker/subnet.md) as well (after translating it from Japanese).

## Docker Image Sizes

|fswiki|base|kernel|httpd|perl|Image Size[MB]|
| ---: | :--- | ---: | ---: | ---: | ---: |
|3_6_5|alpine|4.19.76|2.4.46|5.30.3|62.1|
|3_6_5|ubuntu|4.19.76|2.4.46|5.28.1|209.0|

These info can be obtained respectively by:

~~~shell
docker images | grep fswiki_
~~~

and

~~~shell
./check_versions.sh <container_name>
~~~

## TEST

~~~shell
./test.sh
~~~

## Setting for Web Security Check

To allow access from other docker containers for web security check using OWASP ZAP, Nikto and so on, edit `FSWIKI_PORT` in `.env` and set their target IP addresses to any IP address assigned to the host OS.

## Trouble-shooting

### Software Error

If your web browser displays the following error, check or change `FSWIKI_DATA_ROOT` in .env file. Docker for Windows does not mount some folders to docker containers.

  ~~~text
  Software Error:
  HTML::Template->new() : Cannot open included file ./tmpl/site//. tmpl : file not found. at lib/HTML/Template.pm
  ~~~

### Lock is busy

If your web browser displays the following error,

  ~~~text
  Lock is busy. at plugin/core/ShowPage.pm line 69. at lib/Util.pm line 743.
  ~~~

check and change file permissions as follows where `2` is GID of daemon in the docker container.

  ~~~console
  chgrp -R 2     attach/ config/ data/ log/ resources/ theme/ tmpl/
  chmod g+w   -R attach/ config/ data/ log/ resources/ theme/ tmpl/
  chmod o+rwx -R attach/ config/ data/ log/ resources/ theme/ tmpl/
  ~~~

## [CHANGELOG](./CHANGELOG.md)

## [LICENSE](./LICENSE)
