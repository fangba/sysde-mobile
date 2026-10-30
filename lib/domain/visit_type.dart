/// Les quatre types de visite.
enum VisitType {
  plantation('plantation'),
  intervention('intervention'),
  conformity('conformite'),
  orchard('verger');

  const VisitType(this.slug);

  /// Segment d'URL : `/activite/visite/slug`.
  final String slug;

  static VisitType? fromSlug(String? slug) {
    for (final t in values) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
