# Signed Referrer Demo

## Requirements

- Ruby
- Bundler
- Varnish
- https://github.com/varnish/libvmod-digest

## Getting started

```shell
bundle exec foreman start
```

This will start

- A Sinatra server listening on `localhost:4567`
- A Varnish server listening on `localhost:4566`
- `varnishlog`

## What it does

The Sinatra server serves:

- A CSS file at `/cdn/protected.css`
- A form at `/` that posts to `/signed_url` which lets you generate a signed url for that CSS file

The signed url contains two query parameters:

- `host`: The host to allow as a `Referer`
- `hmac`: An SHA256 HMAC of the `host`

Both these parameters are base64url-encoded (without padding).

The Varnish server proxies everything to the Sinatra server, except for paths that start with `/cdn`
in which case the following rules are applied:

1. Return a `406` unless both the `host` and `hmac` query parameters are present
2. Return a `406` unless the `hmac` is valid for that `host`
3. Return a `401` unless the `Referer` host matches the `host` query parameter
