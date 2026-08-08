/// Cross-origin Flutter web cannot read the API host's `XSRF-TOKEN` cookie.
/// Mobile uses [PersistCookieJar] instead. Return null here so callers fall
/// back to the cookie jar path (no-op on web until a same-site proxy exists).
String? readCsrfCookieFromDocument() => null;
