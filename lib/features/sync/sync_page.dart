import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/sync_state.dart';

enum SyncState { pending, review, sent }

class _SyncItem {
  const _SyncItem(this.title, this.detail, this.state);

  final String title;
  final String detail;
  final SyncState state;
}

const _queue = [
  _SyncItem('Visite · Plantation 4417', '3 photos · terminée à l\'instant', SyncState.pending),
  _SyncItem('Rencontre · Groupe Espoir', '2 photos · terminée', SyncState.pending),
  _SyncItem('Visite · Plantation 4398', 'Position hors secteur', SyncState.review),
  _SyncItem('Visite · Plantation 4391', 'Envoyée hier à 17:42', SyncState.sent),
];

/// File d'envoi (demonstration). Elle sera alimentee par l'outbox locale.
class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final wide = !context.isCompact;
    final now = ref.watch(clockProvider)();
    final lastSync = ref.watch(lastSyncProvider);
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.syncSubtitle, style: TextStyle(fontSize: 13, color: t.inkMuted)),
                const SizedBox(height: 18),
                SysCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OfflineChip(label: '${S.offline} · ${formatLastSync(lastSync, now)}'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _Count(value: '4', label: S.toSend.toLowerCase(), bg: t.brandSoft, fg: context.scheme.primary)),
                          const SizedBox(width: 8),
                          Expanded(child: _Count(value: '9', label: 'photos', bg: t.brandSoft, fg: context.scheme.primary)),
                          const SizedBox(width: 8),
                          Expanded(child: _Count(value: '1', label: S.toCheck, bg: t.warnBg, fg: t.warnFg)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  S.syncQueue,
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final item in _queue) ...[
                  _QueueTile(item: item),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(S.noNetwork)),
                  ),
                  child: const Text(S.syncNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, required this.bg, required this.fg});

  final String value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.item});

  final _SyncItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, bg, fg) = switch (item.state) {
      SyncState.pending => (S.syncPending, t.neutralBg, t.neutralFg),
      SyncState.review => (S.syncReview, t.warnBg, t.warnFg),
      SyncState.sent => (S.syncSent, t.okBg, t.okFg),
    };
    return SysCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  item.detail,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: item.state == SyncState.review ? t.warnFg : t.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusPill(label: label, background: bg, foreground: fg),
        ],
      ),
    );
  }
}
