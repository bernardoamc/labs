vcl 4.0;

import digest;

sub vcl_recv {
  if (req.url !~ "^/cdn.*") {
    return(pass);
  }

  if (req.url ~ "^.+\?.*hmac=([^&]+).*$") {
    set req.http.x-hmac = regsub(req.url, "^.+\?.*hmac=([^&]+).*$", "\1");
  } else {
    return (synth(406, "Missing or malformed 'hmac' query string parameter"));
  }

  if (req.url ~ "^.+\?.*host=([^&]+).*$") {
    set req.http.x-host = digest.base64url_nopad_decode(regsub(req.url, "^.+\?.*host=([^&]+).*$", "\1"));
  } else {
    return (synth(406, "Missing or malformed 'host' query string parameter"));
  }

  set req.http.x-expected-hmac = digest.base64url_nopad_hex(
    digest.hmac_sha256(
      "s3cr3t",
      req.http.x-host
    )
  );

  if (req.http.x-hmac != req.http.x-expected-hmac) {
    return (synth(406, "Invalid 'hmac' query string parameter"));
  }

  if (req.http.referer ~ "^https?://([^/]+).*$") {
    set req.http.x-referer-host = regsub(req.http.referer, "^https?://([^/]+).*$", "\1");
  } else {
    return (synth(401, "Missing or malformed 'Referer' header"));
  }

  if (req.http.x-referer-host != req.http.x-host) {
    return (synth(401, "Unauthorized referrer"));
  }
}
