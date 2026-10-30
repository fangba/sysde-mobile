import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/sys_widgets.dart';
import '../../../domain/attention.dart';
import '../../planning/activity_labels.dart';

/// Taches du jour : activites en retard et activites prevues aujourd'hui.
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.items, required this.onOpen});

  final List<AttentionItem> items;
  final void Function(String activityId) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SysCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  S.toHandle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(S.nothingToHandle, style: TextStyle(color: t.inkMuted)),
            )
          else
            for (final item in items) ...[
              Divider(height: 1, color: t.line),
              _Row(item: item, onTap: () => onOpen(item.activity.id)),
            ],
        ],
      ),
    );
  }
}

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
    final detail = isLate
        ? '${a.category.label} · ${S.plannedOn} ${formatDay(a.date)}'
        : a.category.label;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${a.title.split(' ').first} · $plantation',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 12.5, color: t.inkMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusPill(
              label: isLate ? S.lateLabel : S.today,
              background: isLate ? t.warnBg : t.brandSoft,
              foreground: isLate ? t.warnFg : context.scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
