import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_profile.dart';
import '../features/planning/control_provider.dart';

/// Profil de la personne connectee (demonstration). Avec le back, il viendra
/// de la connexion et sera garde dans la base locale.
final profileProvider = Provider<UserProfile>(
  (ref) => const UserProfile(
    fullName: 'Yao Serge KOFFI',
    firstName: 'Yao',
    matricule: 'SAPH-00348',
    role: 'Contrôleur de saignée',
    operatorName: 'SAPH',
    sector: 'Bonoua',
    lot: 'Lot 2',
    sections: ['Nord', 'Sud'],
    phone: '07 48 12 36 59',
    email: 'yao.koffi@saph.example',
  ),
);

/// Desactive le compte sur cet appareil : efface ce que ce profil a saisi en
/// local. La session (jeton) et la base locale seront aussi effacees ici une
/// fois en place, pour qu'un autre profil puisse se connecter sur l'appareil.
void deactivateLocalAccount(WidgetRef ref) {
  ref.invalidate(controlsProvider);
}
