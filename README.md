# curl-impersonate

A special build of curl that can impersonate the four major browsers: Chrome, Edge, Safari. curl-impersonate is able to perform TLS and HTTP handshakes that are identical to that of a real browser.

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