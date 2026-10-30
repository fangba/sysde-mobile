import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Horloge de l'appareil. Remplacee en test pour figer la date.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
