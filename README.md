<!-- markdownlint-disable MD024 no-duplicate-heading -->
# Dockerfile and docker-compose.yml for local use FSWiki

[日本語 <img src="https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/jp.svg" width="20" alt="Japanese" title="Japanese"/>](./README-jp.md)

[FSWiki (FreeStyleWiki)](https://fswiki.osdn.jp/cgi-bin/wiki.cgi) is a Wiki clone written in Perl (and JavaScript<!-- for diffview-->).

![screenshot](https://raw.githubusercontent.com/KazKobara/kati_dark/main/docs/screenshot.png "screenshot")

## Features

This Dockerfile is to launch FSWiki enabling:

- CSP (Content Security Policy) protected Markdown Plugin ([available Markdown syntax (in Japanese)](https://kazkobara.github.io/kati_dark/docs/markdown/Help_Markdown_for_FreeStyleWiki.htm)).
- LaTeX (and MathML) rendering using MathJax.
- Restriction of access only from localhost.

> **CAUTION:**
To expose it to the public network, additional security considerations
would be necessary including https use, load-balancing, permissions
and so on.

![markdown_screenshot](https://raw.githubusercontent.com/KazKobara/dockerfile_fswiki_local/main/data/markdown_screenshot.png "screenshot")

<!-- ![markdown_screenshot](./data/markdown_screenshot.png "screenshot") -->

The above is the screenshot of the following markdown document (in a markdown block of FSWiki
in the ['kati_dark' theme](https://github.com/KazKobara/kati_dark "https://github.com/KazKobara/kati_dark (in Japanese)") where other themes are available from [here](https://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=%A5%C6%A1%BC%A5%DE%B0%EC%CD%F7 "https://fswiki.osdn.jp/cgi-bin/wiki.cgi?page=%A5%C6%A1%BC%A5%DE%B0%EC%CD%F7 (in Japanese)").

<!--
Including "'markdown' in double curly braces", the tag to identify markdown blocks in FSWiki, here and below causes 
"Liquid Exception: Liquid syntax error (line 26): Variable" error in
"pages build and deployment pages build and deployment #6" for jekyll-theme-midnight.
 -->

~~~markdown
# Markdown Plugin with CSP

## Syntax

1. **Inline _scripts_** and _**unintended** inline styles_ are ~~allowed~~ blocked by CSP.
    - <span type="text/css" class="orange">Coloring</span> shall be realized using style-sheet defined {type, class} selectors.

### Definition List

CSP
: Content ___Security___ Policy

=FSWiki=
    A *Wiki* clone written in [Perl](https://www.perl.org/ "https://www.perl.org/") (and JavaScript).

### Table

<!-- Realizing 'text-align:' in a markdown table without using inline-style requires a tweak. -->

| text-align: left | text-align: center | text-align: right |
|:---------|:----------:|---------:|
| left     |   center   |    right |

### Fenced Code Block

```console
git clone https://github.com/KazKobara/dockerfile_fswiki_local.git
cd dockerfile_fswiki_local
```

### \\( \LaTeX \\) (and MathML) Using MathJax

<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>

It can show equations, and so on, beautifully, such as
\\( \sin^{2} \theta + \cos^{2} \theta = 1 \\),
\\( \tan \theta = \frac{\sin \theta}{\cos \theta} \\)  and below:
\\[ \lim_{h \to 0} \frac{f(x+h) - f(x)}{h} \\]

~~~

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

| Variable | Explanation |
|:---------|:----------|
| `FSWIKI_DATA_ROOT` | Set the root folder that includes FSWiki's `attach/ config/ data/ log/` to share them as the container's shared volumes.\*1 |
| `CONTAINER_CLI` | Set your container CLI, such as `docker` or `nerdctl`.
| `COMPOSE` | Set your container composer, such as `docker-compose` or `nerdctl compose`.

> - \*1 Edit `docker-compose.yml` or `run_fswiki_local.sh` you use to change the shared volumes.

#### 1.3 Download FSWiki under ./tmp/

~~~shell
./get_fswiki.sh
~~~

### 2. Build and run

In the following steps, you can choose either [2a. compose version](#2a-compose-version) (such as '[docker-compose](https://docs.docker.com/compose/reference/)', '[nerdctl](https://github.com/containerd/nerdctl#command-reference) compose') or [2b. shell script version](#2b-shell-script-version) depending on your environment.

If they pop up the following window on Windows OS, click the "cancel" button to block the access from outside your PC.

<img src="https://raw.githubusercontent.com/KazKobara/dockerfile_fswiki_local/main/data/warning.png" width="500" alt="cancel" title="Push the cancel button"/>
<!--
![cancel](./data/warning.png "Push the cancel button")
-->

### 2a Compose Version

#### 2a.1 Build image

~~~shell
nerdctl compose build
~~~

or

~~~shell
docker-compose build
~~~

> - On Windows OS, add `.exe` after the command.
> - Building the image on Alpine takes time in `git clone`, presumably to resolve FQDN.

#### 2a.2 Run

~~~shell
nerdctl compose up
~~~

or

~~~shell
docker-compose up
~~~

> To run it in the background, add `-d` option.

#### 2a.3 Browse

With your web browser, access `http//localhost:<FSWIKI_PORT>/`, such as `http//localhost:8366/`, where `FSWIKI_PORT` is specified in the `.env` file.

#### 2a.4 Stop and remove the process

~~~shell
nerdctl compose down
~~~

or

~~~shell
docker-compose down
~~~

### 2b. Shell Script Version

#### 2b.1 Build image

~~~shell
./docker_build.sh
~~~

> Building the image on Alpine takes time, similar to the compose version.

#### 2b.2 Run server for local use

~~~shell
./run_fswiki_local.sh
~~~

#### 2b.3 Browse

With your web browser, access `http//localhost:<FSWIKI_PORT>/`, such as `http//localhost:8366/`, where `FSWIKI_PORT` is specified in the .env file.

#### 2b.4 Stop and remove the process

~~~shell
nerdctl stop <container_name> && nerdctl rm <container_name>
~~~

or

~~~shell
docker stop <container_name> && docker rm <container_name>
~~~

where `<container_name>` is `fswiki_alpine_local` for Alpine image or   `fswiki_ubuntu_local` for Debian/Ubuntu image.

> `<container_name>` of the compose version ends with `_dc`.

#### 2b.5 Remove the image

~~~shell
nerdctl rmi <image_name>
~~~

or

~~~shell
docker rmi <image_name>
~~~

where `<image_name>` is `<container_name>:<fswiki_version>` and `<fswiki_version>` is `latest`, `3_8_5`, and os on.

### 3. Rebuild for update/upgrade

#### 3.1 Update httpd

 Depending on the base os of the docker container, run the following:

For Alpine image:

~~~shell
nerdctl pull httpd:alpine
~~~

or

~~~shell
docker pull httpd:alpine
~~~

For Debian/Ubuntu image:

~~~shell
nerdctl pull httpd:latest
~~~

or

~~~shell
docker pull httpd:latest
~~~

#### 3.2 Update kati_dark theme

For the latest FSWiki in the git repo:

~~~shell
(cd ./tmp/wikilatest/theme/kati_dark && git pull)
~~~

For FSWiki 3.5.6:

~~~shell
(cd ./tmp/wiki3_6_5/theme/kati_dark && git pull)
~~~

#### 3.3 Rebuild and run

Run [step 2](#2-build-and-run), depending on your environment.

<!--
~~~shell
nerdctl compose up --no-deps --build
~~~

or

~~~shell
docker-compose up --no-deps --build
~~~
-->

## To run multiple/additional services

There are two ways to realize this, one creates a [new folder](#method-1-new-folder), and the other utilizes an [existing folder](#method-2-existing-folder).

### Method 1: new folder

1. In [step 1.1](#11-git-clone-and-enter-the-folder), git clone to another folder.
1. In the new folder, edit variables according to the following section in [docker-compose.yml](https://github.com/KazKobara/dockerfile_fswiki_local/blob/main/docker-compose.yml).

    ~~~yaml
    ##### To launch multiple independent docker processes #####
    ~~~

1. Run [step 1.2](#12-edit-parameters-in-env-file) and later.

### Method 2: existing folder

Edit `FSWIKI_DATA_ROOT_PRIVATE` and `FSWIKI_PORT_PRIVATE` in `.env`, then

~~~shell
nerdctl compose -f docker-compose-multiple.yml up
~~~

or

~~~shell
docker-compose -f docker-compose-multiple.yml up
~~~

or

~~~shell
./run_fswiki_private.sh
~~~

## Differences between docker-compose and shell versions

- The differences are the network addresses to be assigned and IP addresses that can access the FSWiki server in the docker network.
  - docker-compose uses 10.0.0.0/24 and httpd accepts access only from 10.0.0.1.
  - shell version (docker build) uses 172.17.0.0/16 and httpd accepts access only from 172.17.0.1.
  - See [this page](https://github.com/KazKobara/tips-jp/blob/gh-pages/docker/subnet.md) as well (after translation from Japanese).

## Docker Image Sizes

|tag_version|fswiki|base|kernel|httpd|perl|Image Size[MB]|
| :---: | :---: | :--- | ---: | ---: | ---: | ---: |
|0.0.5|latest (4ba68e3)|Alpine 3.17 \*1|5.15.79.1|2.4.54 \*2|5.36.0|78.6|
|0.0.5|3_6_5|Alpine 3.17 \*1|5.15.79.1|2.4.54 \*2|5.36.0|73.5|
|0.0.5|latest (4ba68e3)|Debian 11|5.15.79.1|2.4.54 \*2|5.32.1|229|
|0.0.5|3_6_5|Debian 11|5.15.79.1|2.4.54 \*2|5.32.1|224|

> The following versions have vulnerabilities. To update, cf. the above [step 3](#3-rebuild-for-updateupgrade).
>
> - \*2 [httpd 2.4.54 and older](https://httpd.apache.org/security/vulnerabilities_24.html)
> - [busybox 1.35.0 and older](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=busybox)
>   - \*1 [Status in Alpine 3.17](https://security.alpinelinux.org/branch/3.17-main): [CVE-2022-28391](https://security.alpinelinux.org/vuln/CVE-2022-28391), [CVE-2022-30065](https://security.alpinelinux.org/vuln/CVE-2022-30065).

The following commands show the sizes:

~~~shell
nerdctl images | grep fswiki_
~~~

or

~~~shell
docker images | grep fswiki_
~~~

and versions:

~~~shell
./check_ver_in_container.sh <container_name>
~~~

or the following test can show them too.

## TEST

1. Edit the following parameters in `./test.sh`

    ~~~shell
    ## Uncomment one of them.
    TEST_PLATFORM="alpine ubuntu"
    # TEST_PLATFORM="alpine"
    # TEST_PLATFORM="ubuntu"

    ## Comment out if not to test
    TEST_COMPOSE_VER="Do"
    TEST_SHELL_VER="Do"
    ~~~

1. Set `FSWIKI_DATA_ROOT` in `.env` (as an absolute path to test shell version).
1. Run

    ~~~shell
    ./test.sh
    ~~~

## Settings

### Web Security Check

To allow access from other docker containers for web security check using OWASP ZAP, Nikto and so on, edit `FSWIKI_PORT` in `.env` and set their target IP addresses to any IP address assigned to the host OS.

<!--
### Help of Markdown Plugin with CSP, LaTeX and MathML rendering using MathJax

- On your web browser displaying FSWiki launched by this docker file, click and see `Help/Markdown` in the menu (after translation from Japanese).

Or

1. Get the HTML files:

    ~~~shell
    git clone https://github.com/KazKobara/kati_dark.git
    cd ./kati_dark/docs/markdown/
    ~~~

1. Open Help_Markdown_for_FreeStyleWiki.htm with your web browser
1. (Translate Japanese to your language).
-->

<!--
[Help/Markdown (FSWiki file)]: https://github.com/KazKobara/kati_dark/blob/main/docs/markdown/Help%252FMarkdown.wiki

[Help/Markdown (HTML file)]: https://github.com/KazKobara/kati_dark/blob/main/docs/markdown/Help_Markdown_for_FreeStyleWiki.htm

[Markdown Plugin]: https://github.com/KazKobara/kati_dark/blob/main/docs/markdown/markdown_plugin_for_fswiki.md
-->

### Permissions and group

Check and edit `FSWIKI_DATA_ROOT` in `.env`. Then in the same folder as `.env`, run

~~~console
./change_permissions.sh
~~~

Alternatively, set manually permissions and group of folders (and their files), which are under `FSWIKI_DATA_ROOT` folder set in `.env`, and where `docker-compose.yml` or `run_fswiki_local.sh` specifies.
If the folders are `attach/ config/ data/ log/`, the commands are as follows:

  ~~~console
  chmod -R a-rwx,ug+rwX attach/ config/ data/ log/
  chgrp -R <gid_of_httpd_sub-processes> attach/ config/ data/ log/
  ~~~

> FSWiki, however, changes the files' permission to 644 (regardless umask) and their owners to uid of httpd_sub-processes.

 <!--find . -type f -executable -print-->

where `<gid_of_httpd_sub-processes>` is

|<gid_of_httpd_sub-processes>|(uid_of_httpd_sub-processes)|group|base|httpd|
| :---: | :---: | :---: | :---: | :---: |
|33|(33)|www-data|Debian/Ubuntu|2.4.52|
|82|(82)|www-data|Alpine|2.4.52|
|1|(1)|daemon|Debian/Ubuntu|2.4.46|
|2|(2)|daemon|Alpine|2.4.46|

> **NOTE:** `gid` is needed since `gid` may differ between host and guest of the docker container. If you change it in the container, you can use `group` name instead of `gid`.

### Permission to share data volume with multiple OSes

On each container OS, add the username of the httpd_sub-process of the OS to the group corresponding to the other OS, e.g., to share Alpine folders on Debian/Ubuntu:

  ~~~console
  addgroup --gid 82 www-data-alpine
  adduser www-data www-data-alpine
  ~~~

and vice versa on Alpine:

  ~~~console
  adduser www-data xfs
  ~~~

where gid of xfs is 33 whose group is www-data on Debian/Ubuntu.

## Trouble-shooting

### 'Permission denied' or 'Lock is busy'

If your web browser displays any of the following errors, check and change file permissions and group as [above](#permissions-and-group).

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

### Software Error

If your web browser displays the following error, check or change `FSWIKI_DATA_ROOT` in .env file. Docker for Windows does not mount some folders to docker containers.

  ~~~text
  Software Error:
  HTML::Template->new() : Cannot open included file ./tmpl/site//. tmpl : file not found. at lib/HTML/Template.pm
  ~~~

### Can't locate CGI.pm

If the docker outputs the following log, install Perl CGI with `apt-get install -y libcgi-session-perl` for Debian/Ubuntu, `apk add -y perl-cgi-fast` for Alpine, and so on.

  ~~~text
  Can't locate CGI.pm in @INC (you may need to install the CGI module) (...) at lib/CGI2.pm line 7.
  BEGIN failed--compilation aborted at lib/CGI2.pm line 7.
  ~~~

<!--
From v0.0.3, 'diff view' is available using CSP Hash without relying on 'unsafe-inline' or 'unsafe-hashes'!!

### To show difference in "Difference" menu

If inline scripts are not threatening, let the corresponding part in /usr/local/apache2/conf/extra/[`httpd-security-fswiki-local.conf`](https://raw.githubusercontent.com/KazKobara/dockerfile_fswiki_local/main/data/httpd-security-fswiki-local.conf) as follows:

~~~apache
Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline';"
# Header always set Content-Security-Policy "default-src 'self';"
~~~

though CSP Hash or CSP Nonce is more ideal than 'unsafe-inline' after modification of scripts.
-->

## [CHANGELOG](./CHANGELOG.md)

## [LICENSE](./LICENSE)

---

- [https://github.com/KazKobara/](https://github.com/KazKobara/)
- [https://kazkobara.github.io/](https://kazkobara.github.io/)
