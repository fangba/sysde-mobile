import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/calendar.dart';
import '../../domain/plan_status.dart';
import '../../domain/report_rules.dart';
import 'activity_detail.dart';
import 'activity_labels.dart';
import 'activity_tile.dart';

/// Planning annuel : calendrier du mois (points par categorie), puis les
/// activites du jour choisi. Telephone : une colonne, la fiche s'ouvre en
/// plein ecran. Tablette (>= 600 dp) : calendrier a gauche, fiche a droite.
class PlanningPage extends ConsumerStatefulWidget {
  const PlanningPage({super.key});

  @override
  ConsumerState<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends ConsumerState<PlanningPage> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = ref.read(todayProvider);
    _selected = DateTime(today.year, today.month, today.day);
    _month = DateTime(today.year, today.month);
  }

  void _shiftMonth(int delta) => setState(() {
        _month = DateTime(_month.year, _month.month + delta);
        // Dans le mois en cours on revient sur aujourd'hui, sinon sur le 1er.
        final today = ref.read(todayProvider);
        final isCurrent = today.year == _month.year && today.month == _month.month;
        _selected = isCurrent ? DateTime(today.year, today.month, today.day) : _month;
      });

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activitiesProvider);
    final today = ref.watch(todayProvider);
    final status = ref.watch(planStatusProvider);
    final selectedId = ref.watch(selectedActivityProvider);

    final ofDay = [
      for (final a in activities)
        if (isSameDay(a.date, _selected)) a,
    ];

    void open(Activity a) {
      if (context.isCompact) {
        context.push('/fiche/${a.id}');
      } else {
        ref.read(selectedActivityProvider.notifier).select(a.id);
      }
    }

    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(year: today.year, status: status),
        const SizedBox(height: 16),
        _CalendarCard(
          month: _month,
          selected: _selected,
          today: today,
          activities: activities,
          onSelect: (d) => setState(() => _selected = d),
          onShiftMonth: _shiftMonth,
        ),
        const SizedBox(height: 20),
        Text(
          formatDayLong(_selected),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (ofDay.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(S.noActivityThatDay, style: TextStyle(color: context.tokens.inkMuted)),
          )
        else
          for (final a in ofDay)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ActivityTile(
                activity: a,
                selected: !context.isCompact && a.id == selectedId,
                onTap: () => open(a),
              ),
            ),
      ],
    );

    final body = context.isCompact
        ? list
        : Row(
            children: [
              SizedBox(width: 440, child: list),
              VerticalDivider(width: 1, color: context.tokens.line),
              Expanded(child: _Detail(activities: activities, selectedId: selectedId)),
            ],
          );
    return Scaffold(body: body);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.activities, required this.selectedId});

  final List<Activity> activities;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final selected = activities.where((a) => a.id == selectedId);
    if (selected.isEmpty) {
      return Center(
        child: Text(S.noActivitySelected, style: TextStyle(color: context.tokens.inkMuted)),
      );
    }
    return ActivityDetail(activity: selected.first);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.year, required this.status});

  final int year;
  final PlanStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, bg, fg) = switch (status) {
      PlanStatus.validated => (S.planValidated, t.okBg, t.okFg),
      PlanStatus.submitted => (S.planSubmitted, t.warnBg, t.warnFg),
      PlanStatus.rejected => (S.planRejected, t.dangerBg, t.dangerFg),
      PlanStatus.draft => (S.planDraft, t.neutralBg, t.neutralFg),
    };
    return Row(
      children: [
        IconButton(
          tooltip: S.back,
          iconSize: 30,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => context.go('/activite'),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.planningTitle,
                style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(S.planningYear(year), style: TextStyle(fontSize: 13, color: t.inkMuted)),
            ],
          ),
        ),
        StatusPill(label: label, background: bg, foreground: fg),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.selected,
    required this.today,
    required this.activities,
    required this.onSelect,
    required this.onShiftMonth,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final List<Activity> activities;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShiftMonth;

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cells = monthCells(month);
    return SysCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: S.previousMonth,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => onShiftMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  formatMonthYear(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: S.nextMonth,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => onShiftMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.inkMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 0; row < cells.length ~/ 7; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: cells[row * 7 + col],
                      month: month,
                      selected: selected,
                      activities: activities,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final c in ActivityCategory.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(color: c.color(t)),
                    const SizedBox(width: 6),
                    Text(c.label, style: TextStyle(fontSize: 12.5, color: t.inkMuted)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.month,
    required this.selected,
    required this.activities,
    required this.onSelect,
  });

  final DateTime? day;
  final DateTime month;
  final DateTime selected;
  final List<Activity> activities;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final d = day;
    if (d == null) return const SizedBox(height: 52);

    final t = context.tokens;
    final inMonth = d.month == month.month;
    final isSelected = isSameDay(d, selected);
    final categories = inMonth ? categoriesOnDay(activities, d) : const <ActivityCategory>[];

    final number = Text(
      '${d.day}',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isSelected
            ? Colors.white
            : inMonth
                ? context.scheme.onSurface
                : t.inkMuted.withValues(alpha: 0.6),
      ),
    );
    final dots = SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: _Dot(color: isSelected ? Colors.white : c.color(t)),
            ),
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${formatDay(d)}, ${activities.where((a) => isSameDay(a.date, d)).length} activité(s)',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: isSelected ? context.scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: inMonth ? () => onSelect(d) : null,
              child: SizedBox(
                height: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [number, const SizedBox(height: 3), dots],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
