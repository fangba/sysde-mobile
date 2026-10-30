import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/activity.dart';
import 'activity_labels.dart';

/// Fiche d'une activite : position, photos, observations.
/// Partagee entre l'ecran plein (telephone) et le volet de detail (tablette).
class ActivityDetail extends StatelessWidget {
  const ActivityDetail({super.key, required this.activity, this.onFinish});

  final Activity activity;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ActivityStatusPill(status: activity.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(activity.place, style: TextStyle(fontSize: 13.5, color: t.inkMuted)),
          const SizedBox(height: 20),
          SysCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.okBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.place_outlined, color: context.scheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        S.positionSaved,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Précision ±6 m · dans le secteur',
                        style: TextStyle(fontSize: 13, color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
                StatusPill(label: 'OK', background: t.okBg, foreground: t.okFg),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '${S.photos} · 2 sur 3',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PhotoSlot(label: 'Panneau', color: t.visit),
              _PhotoSlot(label: 'Saignée', color: t.training),
              const _AddPhotoSlot(),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            S.observations,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const _ObservationsField(),
          const SizedBox(height: 20),
          Text(S.savedLocally, style: TextStyle(fontSize: 13, color: t.neutralFg)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onFinish, child: const Text(S.finishActivity)),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Photo : $label',
      child: Container(
        width: 112,
        height: 96,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AddPhotoSlot extends StatelessWidget {
  const _AddPhotoSlot();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: S.addPhoto,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          width: 112,
          height: 96,
          decoration: BoxDecoration(
            color: context.scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.inkMuted),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera_outlined, color: context.scheme.primary),
              const SizedBox(height: 6),
              Text(
                'Ajouter',
                style: TextStyle(
                  color: context.scheme.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObservationsField extends StatefulWidget {
  const _ObservationsField();

  @override
  State<_ObservationsField> createState() => _ObservationsFieldState();
}

class _ObservationsFieldState extends State<_ObservationsField> {
  final _controller = TextEditingController(
    text: "Panneau d'identification en place. Saignées conformes sur 12 arbres contrôlés.",
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.tokens.line),
        ),
      ),
    );
  }
}
