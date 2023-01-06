# Change Log

<!-- markdownlint-disable MD024 no-duplicate-heading -->
<!-- ## [Unreleased 0.0.6] -->

## [Unreleased 0.0.6]

### Changed

- Commented out `theme/kati_dark` volume in docker-compose-multiple.yml.
- Added how to update `theme/kati_dark` in README.

## [0.0.5]

### Security

- Tested Alpine v3.17 due to the [vulnerabilities of BusyBox v1.35 and older](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=busybox).

### Added

- README-jp.md
- CONTAINER_CLI=nerdctl and COMPOSE="nerdctl compose" in .env

### Changed

- `check_versions.sh` to `check_ver_in_container.sh`
  - It shows the versions of os and busybox (if used) as well.

## [0.0.4]

### Added

- LaTeX and MathML rendering using MathJax.
- plugin/markdown/Markdown.pm and its security settings for Content Security Policy (CSP).
- Setting for sharing data volumes on multiple Operating Systems.

### Changed

- Text::Markdown::Discount to use latest discount markdown v2maint.
- `check_versions.sh` shows the version of markdown as well.
- Separated change_permissions.sh from get_fswiki.sh.
- `#!/bin/bash` to `#!/usr/bin/env bash`.

## [0.0.3]

### Security

- Enabled `diffview` securely with CSP (Content Security Policy) Hash in `httpd-security-fswiki-local.conf`, `plugin/core/Diff.pm` and `theme/resources/diff.js`.

## [0.0.2]

### Security

- Tested httpd 2.4.52 due to the [vulnerabilities of 2.4.51 and older](https://httpd.apache.org/security/vulnerabilities_24.html).
  - Added `OWNER_GROUP=www-data:www-data` in `.env`, and `${owner_group}` in `Dockerfile` `docker_build.sh` and `docker-compose.yml`, respectively, for owner and group of folders/files accessed by httpd sub-processes.
- Set more strict permissions in `httpd-security-fswiki-local.conf` and `Dockerfile`, then made `.htaccess` dummy.

### Changed

- jsdifflib to ver. 1.1.0 on github.
- For `volumes` (or `-v` option) in `docker-compose.yml` and `run_fswiki_local.sh`, removed `theme/` and `tmpl/`, and then added `theme/kati_dark` only
- Moved ./tmpl/ and ./theme/ (including ./theme/kati_dark) in the container since they (especially ./theme/resources) are maintained by FSWiki and may be updated later on.
- In `./test.sh`, what to test became selectable.

## [0.0.1]

### Changed

- `http:` to `https:` in `./get_fswiki.sh`.
- Made '[latest FSWiki](https://scm.osdn.net/gitroot/fswiki/fswiki.git)' (git pull) default.
- Made '[kati_dark theme](https://github.com/KazKobara/kati_dark)' default.

---
Return to [README](../README.md)

<!--
## Template
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
-->
