/// Les quatre types de rencontre technique.
enum MeetingType {
  outreachGroup('vulgarisation'),
  conference('conference'),
  studyTrip('voyage'),
  fair('foire');

  const MeetingType(this.slug);

  /// Segment d'URL : `/activite/rencontre/slug`.
  final String slug;

  /// Vulgarisation, conference et
  /// voyage d'etude se font sans controle (presence puis rapport).
  bool get hasControl => this == MeetingType.fair;

  static MeetingType? fromSlug(String? slug) {
    for (final t in values) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
