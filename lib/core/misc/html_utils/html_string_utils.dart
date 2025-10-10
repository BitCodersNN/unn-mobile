String removeHtmlComments(String html) {
  return html.replaceAllMapped(
    RegExp(r'<!--.*?-->', multiLine: true, dotAll: true),
    (match) => '',
  );
}
