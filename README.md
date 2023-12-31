# curl-chromium

A special build of curl that can impersonate the major browsers: Chrome, Edge, Safari. curl-impersonate is able to perform TLS and HTTP handshakes that are identical to that of a real browser.

## Basic usage

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
docker exec -it curl_chromium curl_edge_115 --version
#curl 7.88.1 (x86_64-pc-linux-musl) libcurl/7.88.1 BoringSSL zlib/1.2.13 brotli/1.0.9 nghttp2/1.54.0
```

## Using libcurl-impersonate in PHP scripts

### On Linux

First, patch libcurl-impersonate and change its SONAME:

```text
patchelf --set-soname libcurl.so.4 /path/to/libcurl-impersonate-chrome.so
```

Then replace at runtime with:

```text
LD_PRELOAD=/path/to/libcurl-impersonate-chrome.so CURL_IMPERSONATE=edge115 php -r 'print_r(curl_version());'
```

If successful you should see:

```text
[ssl_version] => BoringSSL
```

## fork by curl-impersonate

What's diffrent:
- Update curl, brotli & brotli-ssl
- Add support new version edge/chrome
- Base on alpine v3.18.2 (latest)

## Todo

Update to latest cURL 8.x