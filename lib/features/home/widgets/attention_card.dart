import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/sys_widgets.dart';
import '../../../domain/attention.dart';

/// Taches du jour : activites en retard et activites prevues aujourd'hui.
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.items, required this.onOpen});

  final List<AttentionItem> items;
  final void Function(String activityId) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SysCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau colore : icone, titre et compteur centres verticalement.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: context.scheme.primary.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.task_alt_outlined, size: 22, color: context.scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.toHandle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: context.scheme.primary,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  StatusPill(
                    label: '${items.length}',
                    background: t.warnBg,
                    foreground: t.warnFg,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(S.nothingToHandle, style: TextStyle(color: t.inkMuted)),
                  )
                else
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: t.line),
                    _Row(item: items[i], onTap: () => onOpen(items[i].activity.id)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Une tache : date (jour + mois), filet vertical, titre et statut avec
/// icone (meme style que les lignes de date des pages d'activites).
class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});

  final AttentionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final a = item.activity;
    final isLate = item.kind == AttentionKind.late;
    final plantation = a.place.split(' · ').last;
    final (statusLabel, statusColor, statusIcon) = isLate
        ? (S.lateLabel, t.dangerFg, Icons.error_outline)
        : (S.today, context.scheme.primary, Icons.schedule);
    return Semantics(
      button: true,
      label: '${a.title}, $plantation, $statusLabel',
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${a.date.day}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          formatMonthShort(a.date),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  VerticalDivider(width: 2, thickness: 2, color: t.inkMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${a.title.split(' ').first} · $plantation',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
