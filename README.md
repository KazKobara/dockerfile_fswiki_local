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

Then access `http//localhost:8365/` with a web browser.

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

Then access `http//localhost:8365/` with a web browser.

#### Stop and remove the process

~~~shell
docker stop <container_name> && docker rm <container_name>
~~~

where `<container_name>` is `fswiki_alpine_local_dc` or   `fswiki_ubuntu_local_dc` for docker-compose versions, and `fswiki_alpine_local` or   `fswiki_ubuntu_local` for shell script versions.

#### Remove the image

~~~shell
docker rmi <image_name>
~~~

where `<image_name>` is `<container_name>:<fswiki_version>` and `<fswiki_version>` `latest`, `3_8_5`, and os on.

## Docker Image Sizes

|fswiki|base|kernel|httpd|perl|Image Size[MB]|
| ---: | :--- | ---: | ---: | ---: | ---: |
|3_6_5|alpine|4.19.76|2.4.46|5.30.3|62.1|
|3_6_5|ubuntu|4.19.76|2.4.46|5.28.1|209.0|
---

These info can be obtained by:

~~~shell
docker images | grep fswiki_
./check_versions.sh <container_name>
~~~

## Test

~~~shell
./test.sh
~~~

## CHANGELOG

## [LICENSE](./LICENSE)
