# Change Log

<!-- markdownlint-disable MD024 no-duplicate-heading -->
<!-- ## [Unreleased] -->

## [Unreleased 0.0.2]

### Security

- Tested httpd 2.4.52 due to the [vulnerabilities of 2.4.51 and older](https://httpd.apache.org/security/vulnerabilities_24.html).
  - Added `OWNER_GROUP=www-data:www-data` in `.env`, and `${owner_group}` in `Dockerfile` `docker_build.sh` and `docker-compose.yml`, respectively, for owner and group of folders/files accessed by httpd sub-processes.
- Set more strict permissions in `Dockerfile` and `./data/.htaccess` that is appended to `httpd.conf`.

### Changed

- For `volumes` (or `-v` option) in `docker-compose.yml` and `run_fswiki_local.sh`, removed `theme/` and `tmpl/`, and then added `theme/kati_dark` only since `theme/` (especially `theme/resources`) and `tmpl/` are maintained by FSWiki and will be updated later on.
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
