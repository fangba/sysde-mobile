import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';

/// Grande carte verte de menu : icone dans une tuile blanche, titre,
/// description facultative, chevron. Zone tactile bien au-dela de 48 dp.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.description,
    this.uppercase = true,
  });

  final IconData icon;
  final String title;
  final String? description;
  final bool uppercase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    final desc = description;
    return Semantics(
      button: true,
      label: desc == null ? title : '$title. $desc',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: brandGradient(context, radius: radius),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, size: 34, color: context.scheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uppercase ? title.toUpperCase() : title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (desc != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
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
