import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/ring.dart';
import '../../../core/widgets/sys_widgets.dart';
import '../../../domain/activity.dart';

/// Onglets Formations / Rencontres / Visites, avec pour chacun les activites
/// en attente et terminees (compteur, anneau, part du total).
class CategoryPanel extends StatefulWidget {
  const CategoryPanel({super.key, required this.stats});

  final Map<ActivityCategory, CategoryStats> stats;

  @override
  State<CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<CategoryPanel> {
  ActivityCategory _selected = ActivityCategory.visit;

  static const _tabs = [
    (category: ActivityCategory.training, label: S.tabTraining, icon: Icons.school_outlined),
    (category: ActivityCategory.meeting, label: S.tabMeeting, icon: Icons.groups_outlined),
    (category: ActivityCategory.visit, label: S.tabVisit, icon: Icons.assignment_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final stats = widget.stats[_selected] ?? const CategoryStats(pending: 0, done: 0);

    return SysCard(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              for (final tab in _tabs)
                Expanded(
                  child: _TabButton(
                    label: tab.label,
                    icon: tab.icon,
                    selected: tab.category == _selected,
                    onTap: () => setState(() => _selected = tab.category),
                  ),
                ),
            ],
          ),
          Divider(height: 1, color: t.line),
          _StatRow(
            label: S.pendingUpper,
            count: stats.pending,
            share: stats.pendingShare,
            color: t.warnFg,
          ),
          Divider(height: 1, color: t.line),
          _StatRow(
            label: S.finishedUpper,
            count: stats.done,
            share: stats.doneShare,
            color: context.scheme.primary,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.scheme.primary : context.tokens.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? context.scheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: color,
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.count,
    required this.share,
    required this.color,
  });

  final String label;
  final int count;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final percent = (share * 100).round();
    return Semantics(
      label: '$label : $count, $percent %',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Ring(
                value: share,
                color: color,
                track: t.neutralBg,
                size: 56,
                strokeWidth: 8,
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '$percent %',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
