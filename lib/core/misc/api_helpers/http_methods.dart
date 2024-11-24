enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options,
}

extension HttpMethodExtension on HttpMethod {
  String get asString => name.toUpperCase();
}
