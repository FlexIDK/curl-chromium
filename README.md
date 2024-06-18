# curl-chromium

A special build of curl that can impersonate the major browsers: Chrome, Edge, Safari. curl-impersonate is able to perform TLS and HTTP handshakes that are identical to that of a real browser.

## Emulated Browsers

- Chrome 99
- Chrome 100
- Chrome 101
- Chrome 104
- Chrome 107
- Chrome 110
- Chrome 114
- Chrome 116
- Chrome 126
- Chrome 99 Android
- Edge 99
- Edge 101
- Edge 115
- Edge 126
- Safari 15.3
- Safari 15.5

## Basic usage

```shell
CURL_BROWSER_VERSION=126
curl_edge_${CURL_BROWSER_VERSION} -v -L https://www.ozon.ru/

CURL_BROWSER_VERSION=126
curl_chrome_${CURL_BROWSER_VERSION} -v -L https://www.ozon.ru/

CURL_BROWSER_VERSION=15_5
curl_safari_${CURL_BROWSER_VERSION} -v -L https://www.ozon.ru/

CURL_BROWSER_VERSION=99
curl_chrome_${CURL_BROWSER_VERSION}_android -v -L https://www.ozon.ru/
```

```shell
curl_edge_115 -v -L https://www.ozon.ru/
curl_chrome_99 -v -L https://www.ozon.ru/
curl_chrome_99_android -v -L https://www.ozon.ru/
curl_chrome_100 -v -L https://www.ozon.ru/
curl_chrome_101 -v -L https://www.ozon.ru/
curl_chrome_104 -v -L https://www.ozon.ru/
curl_chrome_107 -v -L https://www.ozon.ru/
curl_chrome_110 -v -L https://www.ozon.ru/
curl_chrome_114 -v -L https://www.ozon.ru/
curl_edge_99 -v -L https://www.ozon.ru/
curl_edge_101 -v -L https://www.ozon.ru/
curl_edge_115 -v -L https://www.ozon.ru/
curl_safari_15_3 -v -L https://www.ozon.ru/
curl_safari_15_5 -v -L https://www.ozon.ru/
```

### Docker

```shell
docker build --tag curl_chromium ./
docker run --name curl_chromium -td curl_chromium
docker exec -it curl_chromium curl_edge_126 --version
#curl 8.1.2 (x86_64-pc-linux-musl) libcurl/8.1.2 BoringSSL zlib/1.3.1 brotli/1.0.9 nghttp2/1.62.1

docker cp curl_chromium:/usr/local/lib/libcurl-impersonate-chrome.so.4.8.0 ~/
docker cp curl_chromium:/usr/local/bin/curl-chromium ~/
```

## Using libcurl-impersonate in PHP scripts

### On Linux

First, patch libcurl-impersonate and change its SONAME:

```text
apt-get install musl-dev
ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1

# Patch libcurl-impersonate-chrome.so

patchelf --set-soname libcurl.so.4 /path/to/libcurl-impersonate-chrome.so
```

Then replace at runtime with:

```text
LD_PRELOAD=/path/to/libcurl-impersonate-chrome.so CURL_IMPERSONATE=edge126 php -r 'print_r(curl_version());'
```

If successful you should see:

```text
[ssl_version] => BoringSSL
```

## fork by [curl-impersonate](https://github.com/lwthiker/curl-impersonate)

What's diffrent:
- Update curl v8.1.2
- Update brotli v1.0.9 
- Update brotli-ssl #1b7fdbd9101dedc3e0aa3fcf4ff74eacddb34ecc
- Update nghttp2 v1.62.1
- Add support new version edge/chrome (126)
- Base on alpine v3.20.0 (latest)

