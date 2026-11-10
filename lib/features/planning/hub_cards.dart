import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/activity.dart';
import 'activity_labels.dart';

/// Carte « Programme » du menu Activite : grande carte verte en vedette.
class ProgramHubCard extends StatelessWidget {
  const ProgramHubCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return Semantics(
      button: true,
      label: '${S.sectionProgram}. ${S.sectionProgramDesc}',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: brandGradient(context, radius: radius).copyWith(
            boxShadow: [
              BoxShadow(
                color: context.tokens.deep.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: context.scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.sectionProgram.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                S.sectionProgramDesc,
                                style: TextStyle(color: Colors.white, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte d'une categorie (formations, visites, rencontres) : tuile coloree,
/// titre, pastilles « en attente » / « terminees » et barre d'avancement.
class CategoryHubCard extends StatelessWidget {
  const CategoryHubCard({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ActivityCategory category;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = category.color(t);
    final radius = BorderRadius.circular(22);
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: context.scheme.surface,
            borderRadius: radius,
            border: Border.all(color: t.line),
            boxShadow: [
              BoxShadow(
                color: t.deep.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(category.icon, size: 30, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(fontSize: 13, color: t.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: t.inkMuted),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
