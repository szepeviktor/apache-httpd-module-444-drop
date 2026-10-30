#!/bin/sh
set -eu

version=${1:?Usage: build-deb.sh VERSION DEBIAN_VERSION}
debian_version=${2:?Usage: build-deb.sh VERSION DEBIAN_VERSION}
dpkg --validate-version "$version"
case "$debian_version" in
    11|12|13) ;;
    *) echo "Unsupported Debian version: $debian_version" >&2; exit 1 ;;
esac

package=libapache2-mod-444
architecture=$(dpkg --print-architecture)
package_version="${version}+deb${debian_version}"
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
chmod 755 "$stage"

apxs -c mod_444.c
install -D -m 644 .libs/mod_444.so "$stage/usr/lib/apache2/modules/mod_444.so"
strip --strip-unneeded "$stage/usr/lib/apache2/modules/mod_444.so"
install -d "$stage/etc/apache2/mods-available" "$stage/DEBIAN"
printf '%s\n' 'LoadModule fourfour_module /usr/lib/apache2/modules/mod_444.so' \
    > "$stage/etc/apache2/mods-available/444.load"
printf '%s\n' '/etc/apache2/mods-available/444.load' > "$stage/DEBIAN/conffiles"
api=$(sed -n 's/^#define MODULE_MAGIC_NUMBER_MAJOR[[:space:]]*\([0-9]*\).*/\1/p' \
    "$(apxs -q INCLUDEDIR)/ap_mmn.h")
test -n "$api"
cat > "$stage/DEBIAN/control" <<EOF
Package: $package
Version: $package_version
Section: httpd
Priority: optional
Architecture: $architecture
Maintainer: $DEB_MAINTAINER
Depends: apache2-api-$api, apache2-bin, libc6
Description: Apache module that drops connections for HTTP status 444
 Closes the connection without sending an HTTP response when a request
 produces status 444.
EOF
install -D -m 644 LICENSE "$stage/usr/share/doc/$package/copyright"
mkdir -p dist
dpkg-deb --root-owner-group --build "$stage" \
    "dist/${package}_${package_version}_${architecture}.deb"
