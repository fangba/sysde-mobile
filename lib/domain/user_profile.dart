/// Profil de la personne connectee sur l'appareil. Vient du serveur a la
/// connexion (compte cree par l'organisation) et reste lisible hors ligne.
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.firstName,
    required this.matricule,
    required this.role,
    required this.operatorName,
    required this.sector,
    required this.lot,
    required this.sections,
    required this.phone,
    required this.email,
  });

  final String fullName;
  final String firstName;

  /// « ACRONYME-NUMERO », ex. SAPH-00348 (identifiant de connexion).
  final String matricule;
  final String role;
  final String operatorName;
  final String sector;
  final String lot;
  final List<String> sections;
  final String phone;
  final String email;

  /// Initiales pour l'avatar : premiere lettre du premier et du dernier mot.
  String get initials {
    final words = fullName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
