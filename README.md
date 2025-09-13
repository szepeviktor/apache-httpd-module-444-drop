# mod_444

Apache HTTP Server module that drops the connection (NGINX 444 style).

## Requirements

```shell
apt-get install apache2-dev binutils
```

## Installation

```shell
install -d -m755 /usr/local/lib/apache2/modules
apxs -c -S LIBEXECDIR=/usr/local/lib/apache2/modules mod_444.c
apxs -i -S LIBEXECDIR=/usr/local/lib/apache2/modules mod_444.la
strip --strip-unneeded /usr/local/lib/apache2/modules/mod_444.so
```

## Configuration

```apache
LoadModule mod_444_module /usr/local/lib/apache2/modules/mod_444.so
```

## Usage

```php
http_response_code(444);
exit;
```
