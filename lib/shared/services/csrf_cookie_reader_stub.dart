/// Web-only: read the readable `XSRF-TOKEN` cookie from `document.cookie`.
/// Returns null on native / when the cookie is not same-site readable.
String? readCsrfCookieFromDocument() => null;
