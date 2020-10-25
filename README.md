# Dockerfile for local use FSWiki

[FSWiki (FreeStyleWiki)](https://fswiki.osdn.jp/cgi-bin/wiki.cgi) is a Wiki clone written in Perl.

> **CAUTION:** This Dockerfile is to launch FSWiki that is used only from a local web browser. Additional security considerations would be necessary to expose it to the public network, such as https use, load-balancing and so on.

## How to use

Run the following commands on a shell terminal.

### 1. Get Dockerfile

~~~shell
git clone https://github.com/KazKobara/dockerfile_fswiki_local.git .
~~~

### 2. Build image

~~~shell
cd dockerfile_fswiki_local
docker build -t fswiki_local:latest .
~~~

### 3. Run server for local use

1. Edit FSWIKI_DATA_ROOT in ./run_fswiki_local.sh so that it can be the parent directory of data/, attach/, config/ and log/ of FSWiki.
2. Run `./run_fswiki_local.sh`
3. Browser access to `http//localhost:8365/`

### Stop and remove the process

~~~shell
docker stop fswiki_local && docker rm fswiki_local
~~~

### Remove the image

~~~shell
docker rmi fswiki_local:latest
~~~

---
THIS FILE COMES WITH ABSOLUTELY NO WARRANTY.
