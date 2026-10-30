/// Role d'un participant a un controle.
enum ParticipantRole {
  tapper('Saigneur'),
  planter('Planteur');

  const ParticipantRole(this.label);
  final String label;
}

/// Personne rencontree lors d'une activite (saigneur, planteur).
class Participant {
  const Participant({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  final String id;
  final String name;
  final ParticipantRole role;

  /// Telephone au format « 78-85-55-58 ».
  final String phone;
}
