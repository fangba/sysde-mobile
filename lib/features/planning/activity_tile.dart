import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/activity.dart';
import 'activity_labels.dart';

/// Carte d'une activite : barre de categorie, titre, lieu, etat. Zone
/// tactile >= 48 dp.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.selected = false,
  });

  final Activity activity;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = activity.category.color(t);
    final statusColor = switch (activity.status) {
      ActivityStatus.todo => context.scheme.primary,
      ActivityStatus.inProgress => t.warnFg,
      ActivityStatus.done => t.okFg,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: '${activity.title}, ${activity.place}, ${activity.status.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: ExcludeSemantics(
          child: SysCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: selected ? t.brandSoft : null,
            borderColor: selected ? context.scheme.primary : null,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        activity.place,
                        style: TextStyle(fontSize: 13, color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  activity.status.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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
