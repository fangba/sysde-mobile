/// Les quatre types de rencontre technique.
enum MeetingType {
  outreachGroup('vulgarisation'),
  conference('conference'),
  studyTrip('voyage'),
  fair('foire');

  const MeetingType(this.slug);

  /// Segment d'URL : `/activite/rencontre/slug`.
  final String slug;

  static MeetingType? fromSlug(String? slug) {
    for (final t in values) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
