/// Les quatre types de formation a la saignee.
enum TrainingType {
  initial('initiale'),
  inSitu('perfectionnement'),
  postControl('controle'),
  recycling('recyclage');

  const TrainingType(this.slug);

  /// Segment d'URL : `/activite/formation/slug`.
  final String slug;

  static TrainingType? fromSlug(String? slug) {
    for (final t in values) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
