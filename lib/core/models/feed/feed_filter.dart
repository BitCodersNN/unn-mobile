enum FeedFilter {
  all('Все'),
  pinned('Закреплённые'),
  important('Важные');

  final String caption;

  const FeedFilter(this.caption);
}
