import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';

/// Formulaire de connexion par matricule (dans la feuille de l'ecran
/// d'accueil). En demonstration : aucun appel reseau.
///
/// [reveal] (0 a 1) fait apparaitre les blocs l'un apres l'autre quand la
/// feuille monte.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.reveal = 1});

  final double reveal;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _matricule = TextEditingController(text: 'SAPH-00348');
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _matricule.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Apparition decalee : le bloc `i` demarre un peu apres le precedent.
  Widget _step(int i, Widget child) {
    final o = ((widget.reveal - 0.1 * i) / 0.5).clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(o);
    return Opacity(
      opacity: eased,
      child: Transform.translate(offset: Offset(0, 18 * (1 - eased)), child: child),
    );
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    final t = context.tokens;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.line),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: t.inkMuted),
      filled: true,
      fillColor: context.scheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.scheme.primary, width: 1.5),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _step(
          0,
          Text(
            S.loginTitle,
            textAlign: TextAlign.center,
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 22),
        _step(
          1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(S.matricule, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _matricule,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: _decoration(S.matriculeHint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _step(
          2,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(S.password, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
                obscureText: _hidden,
                autofillHints: const [AutofillHints.password],
                decoration: _decoration(
                  S.passwordHint,
                  suffix: IconButton(
                    tooltip: _hidden ? S.showPassword : S.hidePassword,
                    icon: Icon(
                      _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  ),
                ),
              ),
            ],
          ),
        ),
        _step(
          3,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(S.forgotPassword, style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _step(
          4,
          FilledButton(
            onPressed: () => context.go('/accueil'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: const Text(S.signIn),
          ),
        ),
        const SizedBox(height: 18),
        _step(
          5,
          Text(
            S.noSignup,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: t.inkMuted),
          ),
        ),
      ],
    );
  }
}
