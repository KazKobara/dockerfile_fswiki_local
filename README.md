# Dockerfile for local use FSWiki

[FSWiki (FreeStyleWiki)](https://fswiki.osdn.jp/cgi-bin/wiki.cgi) is a Wiki clone written in Perl.

This Dockerfile is to launch FSWiki that is used only from a local web browser.

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

For the following steps, either docker-compose or shell scripts can be used.

### 2. When using docker-compose

Edit `VOLUNE_*` and so on in docker-compose.yml, then run:

~~~shell
docker-compose up
~~~

Access `http//localhost:8365/` with a web browser.

To stop,

~~~shell
docker-compose down
~~~

or [see](https://docs.docker.com/compose/reference/down/).

### 2. When using shell scripts

#### 2.1 Build image

If necessary, edit `FSWIKI_PLATFORM` and `FSWIKI_VERSION` in `./docker_build.sh`, then run:

~~~shell
./docker_build.sh
~~~

#### 2.2 Run server for local use

Edit `FSWIKI_DATA_ROOT` in ./run_fswiki_local.sh so that it can be the parent directory of `data/`, `attach/`, `config/` and `log/` of FSWiki, then run:

~~~shell
./run_fswiki_local.sh
~~~

Access `http//localhost:8365/` with a web browser.

#### Stop and remove the process

~~~shell
docker stop fswiki_alpine_local && docker rm fswiki_alpine_local
~~~

or change `alpine` according to `FSWIKI_PLATFORM` in `./docker_build.sh`.

#### Remove the image

~~~shell
docker rmi fswiki_alpine_local:latest
~~~

or change `alpine` according to `FSWIKI_PLATFORM` in `./docker_build.sh`.

## Docker Image Sizes

|FSWIKI_PLATFORM|kernel|httpd|perl|Image Size[MB]|
| :--- | ---: | ---: | ---: | ---: |
|alpine|4.19.76|2.4.46|5.30.3|62.1|
|ubuntu|4.19.76|2.4.43|5.28.1|243.0|
---

These info can be obtained by:

~~~shell
docker images | grep fswiki_
docker exec <container_name> sh -c "uname -r; httpd -v; perl -v"
~~~

where <container_name> is `fswiki_alpine_local_dc` or   `fswiki_ubuntu_local_dc` for docker-compose versions, and `fswiki_alpine_local` or   `fswiki_ubuntu_local` for shell script versions.

## CHANGELOG

## [LICENSE](./LICENSE)
