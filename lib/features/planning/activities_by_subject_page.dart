import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ring.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/pagination.dart';
import '../../domain/report_rules.dart';
import '../../domain/subject_group.dart';
import 'photo_sheet_page.dart';
import 'subject_labels.dart';

/// Liste des activites d'un type (visite, formation ou rencontre) : photo en
/// haut, feuille blanche. On choisit d'abord la section ; les sujets
/// (plantation, saigneur ou groupe) s'affichent ensuite avec recherche et
/// pagination, chacun avec ses activites dans une ligne repliable.
class ActivitiesBySubjectPage extends ConsumerStatefulWidget {
  const ActivitiesBySubjectPage({
    super.key,
    required this.title,
    required this.icon,
    required this.labels,
    required this.matches,
    required this.backPath,
    this.pageSize = 5,
  });

  final String title;
  final IconData icon;
  final SubjectLabels labels;

  /// Garde les activites du type affiche.
  final bool Function(Activity) matches;

  /// Ecran sur lequel le bouton retour ramene.
  final String backPath;

  /// Nombre de sujets par page.
  final int pageSize;

  @override
  ConsumerState<ActivitiesBySubjectPage> createState() => _ActivitiesBySubjectPageState();
}

class _ActivitiesBySubjectPageState extends ConsumerState<ActivitiesBySubjectPage> {
  final _search = TextEditingController();
  String? _section;
  int _page = 0;

  /// Plantations dont l'etat est inverse par rapport au defaut (la premiere
  /// de la page est depliee au depart).
  final Set<String> _toggled = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setSection(String? v) => setState(() {
        _section = v;
        _page = 0;
        _toggled.clear();
      });

  void _setQuery() => setState(() {
        _page = 0;
        _toggled.clear();
      });

  void _goTo(int page) => setState(() {
        _page = page;
        _toggled.clear();
      });

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final visits = [
      for (final a in ref.watch(activitiesProvider))
        if (widget.matches(a)) a,
    ];
    final section = _section;
    final slice = section == null
        ? null
        : paginate(
            groupBySubject(visits, section: section, query: _search.text),
            page: _page,
            pageSize: widget.pageSize,
          );

    return PhotoSheetPage(
      title: widget.title,
      fallbackIcon: widget.icon,
      backPath: widget.backPath,
      children: [
        _SectionField(
          value: section,
          options: distinctValues(visits.map((a) => a.section)),
          onChanged: _setSection,
        ),
        const SizedBox(height: 16),
        if (slice == null)
          _PickSectionHint(text: widget.labels.pickHint)
        else ...[
          _SearchField(
            hint: widget.labels.searchHint,
            controller: _search,
            onChanged: _setQuery,
          ),
          const SizedBox(height: 8),
          Text(
            widget.labels.count(slice.total),
            style: TextStyle(fontSize: 13, color: context.tokens.inkMuted),
          ),
          const SizedBox(height: 12),
          if (slice.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  widget.labels.empty,
                  style: TextStyle(color: context.tokens.inkMuted),
                ),
              ),
            )
          else
            for (var i = 0; i < slice.items.length; i++) ...[
              _SubjectTile(
                labels: widget.labels,
                group: slice.items[i],
                today: today,
                open: (i == 0) != _toggled.contains(slice.items[i].name),
                onToggle: () => setState(() {
                  final name = slice.items[i].name;
                  if (!_toggled.remove(name)) _toggled.add(name);
                }),
                onOpenVisit: (a) => context.push('/action/${a.id}'),
              ),
              const SizedBox(height: 14),
            ],
          if (slice.pageCount > 1)
            _PaginationBar(slice: slice, onGoTo: _goTo),
        ],
      ],
    );
  }
}

class _SectionField extends StatelessWidget {
  const _SectionField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
      child: Row(
        children: [
          const Text(S.sectionField, style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(S.chooseSection, style: TextStyle(color: t.inkMuted)),
              underline: const SizedBox.shrink(),
              items: [
                for (final o in options) DropdownMenuItem<String>(value: o, child: Text(o)),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickSectionHint extends StatelessWidget {
  const _PickSectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.park_outlined, size: 48, color: t.inkMuted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String hint;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: S.clearSearch,
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.slice, required this.onGoTo});

  final PageSlice<SubjectGroup> slice;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: slice.hasPrevious ? () => onGoTo(slice.page - 1) : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text(S.previous),
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        Expanded(
          child: Text(
            S.pageOf(slice.page + 1, slice.pageCount),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton(
          onPressed: slice.hasNext ? () => onGoTo(slice.page + 1) : null,
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text(S.next), Icon(Icons.chevron_right)],
          ),
        ),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.labels,
    required this.group,
    required this.today,
    required this.open,
    required this.onToggle,
    required this.onOpenVisit,
  });

  final SubjectLabels labels;
  final SubjectGroup group;
  final DateTime today;
  final bool open;
  final VoidCallback onToggle;
  final void Function(Activity) onOpenVisit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final percent = (group.rate * 100).round();
    final name = '${labels.prefix} ${group.name.toUpperCase()}'.trim();
    return SysCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Semantics(
              button: true,
              expanded: open,
              label: '$name, $percent % effectuées, ${open ? S.collapse : S.expand}',
              child: InkWell(
                onTap: onToggle,
                child: ExcludeSemantics(
                  child: Container(
                    color: t.neutralBg,
                    constraints: const BoxConstraints(minHeight: 72),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(width: 4, color: context.scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Center(
                            child: Ring(
                              value: group.rate,
                              color: context.scheme.primary,
                              track: t.line,
                              size: 52,
                              strokeWidth: 4,
                              child: Text(
                                '$percent%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Center(
                            child: Icon(
                              open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                              size: 40,
                              color: t.inkMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (open)
              for (final v in group.visits) ...[
                Divider(height: 1, color: t.line),
                _ActivityRow(labels: labels, visit: v, today: today, onTap: () => onOpenVisit(v)),
              ],
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.labels, required this.visit, required this.today, required this.onTap});

  final SubjectLabels labels;
  final Activity visit;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final done = visit.status == ActivityStatus.done;
    final late = isLate(done: done, plannedOn: visit.date, today: today);
    final (statusLabel, statusColor, statusIcon) = switch (visit.status) {
      ActivityStatus.done => (labels.doneLabel, t.okFg, Icons.check_circle_outline),
      ActivityStatus.inProgress => (S.statusInProgress, t.warnFg, Icons.timelapse),
      ActivityStatus.todo when late => (S.lateLabel, t.dangerFg, Icons.error_outline),
      ActivityStatus.todo => (S.statusTodo, t.inkMuted, Icons.schedule),
    };
    final end = visit.lastDay;
    return Semantics(
      button: true,
      label: '${labels.item(visit.rank ?? 1)}, $statusLabel',
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${visit.date.day}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                        Text(
                          formatMonthShort(visit.date),
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
                          labels.item(visit.rank ?? 1),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        if (end != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${S.endDate} : ${formatLongDate(end)}',
                            style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                          ),
                        ],
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
