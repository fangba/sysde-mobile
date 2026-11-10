/// Nature d'un changement apporte au planning par le serveur.
enum PlanningChangeKind { added, changed, removed }

/// Un changement recu lors d'une mise a jour du planning.
class PlanningChange {
  const PlanningChange({required this.kind, required this.title, required this.detail});

  final PlanningChangeKind kind;
  final String title;
  final String detail;
}
