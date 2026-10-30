# mod_444

Apache HTTP Server module that drops the connection (NGINX 444 style).

## Requirements

```shell
apt-get install apache2-dev binutils
```

## Installation

Download the `.deb` for your Debian version (11, 12, or 13; amd64) from
GitHub Releases, then install and enable the module:

```shell
sudo apt install ./libapache2-mod-444_*.deb
sudo a2enmod 444
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### Build from source

```shell
install -d -m755 /usr/local/lib/apache2/modules
apxs -c -S LIBEXECDIR=/usr/local/lib/apache2/modules mod_444.c
apxs -i -S LIBEXECDIR=/usr/local/lib/apache2/modules mod_444.la
strip --strip-unneeded /usr/local/lib/apache2/modules/mod_444.so
```

## Configuration

For a source installation on Debian, create
`/etc/apache2/mods-available/444.load` with this content:

```apache
LoadModule fourfour_module /usr/local/lib/apache2/modules/mod_444.so
```

The `.deb` package creates this file automatically, using
`/usr/lib/apache2/modules/mod_444.so` as the module path.

Then enable the module, validate the configuration and reload Apache as root:

```shell
a2enmod 444
apache2ctl configtest
systemctl reload apache2
```

Run the reload only if the configuration check succeeds. If Apache is not
running yet, use `systemctl start apache2` instead of the reload.
For other Apache layouts, add the `LoadModule` line to the server configuration.

## Usage

```php
http_response_code(444);
exit;
```

## Debian package builds

GitHub Actions builds and verifies packages in Debian 11, 12, and 13 containers
on pushes to `master`, pull requests, and manual runs. Pushing a `v*` tag
(for example `v1.0.0`) also publishes the packages, build information, and
SHA-256 checksums to a GitHub Release.

To build locally on the target Debian version with the requirements installed:

```shell
DEB_MAINTAINER='Your Name <you@example.com>' sh packaging/build-deb.sh 1.0.0 13
```

Packages are written to `dist/`. Enable the module with `a2enmod 444` after
installation; installation does not automatically enable it or reload Apache.
