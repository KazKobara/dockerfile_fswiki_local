# Image sizes of tested versions

|tag_version|fswiki|base|kernel|httpd|perl|markdown (discount)|Image Size[MB]|
| :---: | :---: | :--- | ---: | ---: | ---: | ---: | ---: |
|0.0.6|latest (89bf198)|Alpine 3.21 (BusyBox v1.37.0)|5.15.167.4-microsoft-standard-WSL2|2.4.63|5.40.1|2.2.7d|121|
|0.0.6|3_6_5           |Alpine 3.21 (BusyBox v1.37.0)|5.15.167.4-microsoft-standard-WSL2|2.4.63|5.40.1|2.2.7d|118|
|0.0.6|latest (89bf198)|Debian 12                    |5.15.167.4-microsoft-standard-WSL2|2.4.63|5.36.0|2.2.7d|234|
|0.0.6|3_6_5           |Debian 12                    |5.15.167.4-microsoft-standard-WSL2|2.4.63|5.36.0|2.2.7d|231|

<!--
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


> 以下のバージョンには脆弱性があります。アップデート方法は上記の [3. アップデート/アップグレードのためのリビルド](#3-アップデートアップグレードのためのリビルド)をご参照下さい。
>
> - \*2 [httpd 2.4.54 以前](https://httpd.apache.org/security/vulnerabilities_24.html)
> - [busybox 1.35 以前](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=busybox)
>   - \*1 [Alpine 3.17 での状況](https://security.alpinelinux.org/branch/3.17-main): [CVE-2022-28391](https://security.alpinelinux.org/vuln/CVE-2022-28391), [CVE-2022-30065](https://security.alpinelinux.org/vuln/CVE-2022-30065)
-->
