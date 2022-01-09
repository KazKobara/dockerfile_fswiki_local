<!-- markdownlint-disable MD024 no-duplicate-heading -->
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

### 1. Get Dockerfile etc

#### 1.1 git clone and enter the folder

~~~shell
git clone https://github.com/KazKobara/dockerfile_fswiki_local.git
~~~

~~~shell
cd dockerfile_fswiki_local
~~~

#### 1.2 Edit parameters in `.env` file

~~~shell
vim .env
~~~

#### 1.3 Set permissions and group

Set permissions and group of folders (and their files), which are under `FSWIKI_DATA_ROOT` folder (set in `.env`) and where `docker-compose.yml` or `run_fswiki_local.sh` specifies, say `attach/ config/ data/ log/`, as follows:

  ~~~console
  chgrp -R <gid_of_httpd_sub-processes> attach/ config/ data/ log/
  chmod g+rw  -R attach/ config/ data/ log/
  chmod o-rwx -R attach/ config/ data/ log/
  ~~~

where `<gid_of_httpd_sub-processes>` is

|<gid_of_httpd_sub-processes>|(uid_of_httpd_subprocesses)|group|base|httpd|
| :---: | :---: | :---: | :---: | :---: |
|33|(33)|www-data|ubuntu|2.4.52|
|82|(82)|www-data|alpine|2.4.52|
|1|(1)|daemon|ubuntu|2.4.46|
|2|(2)|daemon|alpine|2.4.46|

Note that `gid` is needed since `gid` may differ between host and guest of the docker container. If you change it in the container, you can use `group` name instead of `gid`.

#### 1.4 Download FSWiki under ./tmp/

~~~shell
./get_fswiki.sh
~~~

For the following steps, you can use docker-compose or shell scripts depending on your environment.

If they pop up the following window on Windows, click the "cancel" button to block the access from outside your PC.

![cancel](./data/warning.png)

### 2. Build and run using docker-compose

#### 2.1 Build image and run server for local use

~~~shell
docker-compose up
~~~

or on Windows add `.exe` after docker-compose, such as

~~~shell
docker-compose.exe up
~~~

If the log messages on the terminal are not necessary, add `-d` option to them.

Then access `http//localhost:<FSWIKI_PORT specified in the .env file>/` such as `http//localhost:8365/` with a web browser.

#### Stop and remove the process

~~~shell
docker-compose down
~~~

For more options, cf. [reference of docker-compose](https://docs.docker.com/compose/reference/).

### 2. Build and run using shell scripts

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

### 3. Rebuild for update/upgrade

#### 3.1 Update httpd

 Depending on the base os of the docker container, run the following:

For alpine:

~~~shell
docker pull httpd:alpine
~~~

For ubuntu:

~~~shell
docker pull httpd:latest
~~~

#### 3.2 Rebuild and run

Run step 2.

<!--
~~~shell
docker-compose up --no-deps --build
~~~
-->

## To run multiple/additional services

Edit `FSWIKI_DATA_ROOT_PRIVATE` and `FSWIKI_PORT_PRIVATE` in `.env`, then

~~~shell
docker-compose -f docker-compose-multiple.yml up
~~~

or

~~~shell
./run_fswiki_private.sh
~~~

## Differences between docker-compose and shell versions

- The differences are the network addresses to be assigned and IP addresses that can access the fswiki server in the docker network.
  - docker-compose uses 10.0.0.0/24 and httpd accepts access only from 10.0.0.1.
  - shell version (docker build) uses 172.17.0.0/16 and httpd accepts access only from 172.17.0.1.
  - See [this page](https://github.com/KazKobara/tips-jp/blob/gh-pages/docker/subnet.md) as well (after translating it from Japanese).

## Docker Image Sizes

|tag_version|fswiki|base|kernel|httpd|perl|Image Size[MB]|
| :---: | :---: | :--- | ---: | ---: | ---: | ---: |
|0.0.2|latest (4ba68e3)|alpine|5.10.60.1, 4.19.76|2.4.52|5.34.0|72.2|
|0.0.2|3_6_5|alpine|5.10.60.1, 4.19.76|2.4.52|5.34.0|70.2|
|0.0.1|3_6_5|alpine|4.19.76|2.4.46 *1|5.30.3|62.1|
|0.0.2|latest (4ba68e3)|ubuntu|5.10.60.1|2.4.52|5.32.1|222|
|0.0.2|3_6_5|ubuntu|5.10.60.1|2.4.52|5.32.1|220|
|0.0.1|3_6_5|ubuntu|4.19.76|2.4.46 *1|5.28.1|209|

*1 httpd 2.4.51 and earlier have [vulnerabilities](https://httpd.apache.org/security/vulnerabilities_24.html), cf. step 3 to update httpd.

The following commands show the sizes and versions:

~~~shell
docker images | grep fswiki_
~~~

and

~~~shell
./check_versions.sh <container_name>
~~~

or the following test can show them too.

## TEST

Set `FSWIKI_DATA_ROOT` in `.env` as an absolute path to test shell version.

Edit the following parameters in `./test.sh`

~~~shell
## Edit here
# TEST_PLATFORM="alpine ubuntu"
TEST_PLATFORM="alpine"

## Comment out if not to test
TEST_DOCKER_COMPOSE="Do"
# TEST_SHELL_VERSION="Do"
~~~

then

~~~shell
./test.sh
~~~

## Setting for Web Security Check

To allow access from other docker containers for web security check using OWASP ZAP, Nikto and so on, edit `FSWIKI_PORT` in `.env` and set their target IP addresses to any IP address assigned to the host OS.

## Trouble-shooting

### 'Permission denied' or 'Lock is busy'

If your web browser displays any of the following errors,

  ~~~text
  Permission denied at lib/Wiki/DefaultStorage.pm line 114. 
  ~~~

  ~~~text
  Permission denied: ./log at lib/CGI2.pm line 34. 
  ~~~

  ~~~text
  You don't have permission to access this resource.
  ~~~

  ~~~text
  Lock is busy. at plugin/core/ShowPage.pm line 69. at lib/Util.pm line 743.
  ~~~

check and change file permissions and group according to the above step 1.3.

### Software Error

If your web browser displays the following error, check or change `FSWIKI_DATA_ROOT` in .env file. Docker for Windows does not mount some folders to docker containers.

  ~~~text
  Software Error:
  HTML::Template->new() : Cannot open included file ./tmpl/site//. tmpl : file not found. at lib/HTML/Template.pm
  ~~~

## [CHANGELOG](./CHANGELOG.md)

## [LICENSE](./LICENSE)

---

- [https://github.com/KazKobara/](https://github.com/KazKobara/)
- [https://kazkobara.github.io/ (mostly in Japanese)](https://kazkobara.github.io/)
