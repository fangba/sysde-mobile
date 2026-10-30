import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';

/// Parametres : compte, acces a la synchronisation, deconnexion.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final wide = !context.isCompact;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.settings,
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                SysCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: t.okBg,
                        child: Icon(Icons.person_outline, color: context.scheme.primary),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yao',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Contrôleur de saignée · SAPH-00348',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/parametres/synchro'),
                    child: SysCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: t.warnBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.sync, color: t.warnFg),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  S.sync,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  S.syncPendingSummary,
                                  style: TextStyle(fontSize: 13, color: t.inkMuted),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: t.inkMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.go('/connexion'),
                  icon: const Icon(Icons.logout),
                  label: const Text(S.signOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.dangerFg,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: t.dangerFg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    S.appVersion,
                    style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
