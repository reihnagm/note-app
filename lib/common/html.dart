String removeHtmlTags(String html) {
  RegExp exp = RegExp(r'<[^>]*>');
  return html.replaceAll(exp, '');
}