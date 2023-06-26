# curl-impersonate

A special build of curl that can impersonate the four major browsers: Chrome, Edge, Safari. curl-impersonate is able to perform TLS and HTTP handshakes that are identical to that of a real browser.

## Basic usage

```shell
curl_edge_115 https://www.ozon.ru/
```

## fork by curl-impersonate

What's diffrent:
- Update curl, brotli & brotli-ssl
- Add support new version edge/chrome
- Base on alpine v3.18.2 (latest)

## Todo

Update to latest cURL 8.x