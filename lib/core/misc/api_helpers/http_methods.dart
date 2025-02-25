enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options;

  String get asString => name.toUpperCase();
}
