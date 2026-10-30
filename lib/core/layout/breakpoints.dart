import 'package:flutter/widgets.dart';

/// Classes de largeur (en dp). La decision se prend sur la largeur
/// disponible, jamais sur le type d'appareil.
enum WindowSize { compact, medium, expanded }

WindowSize windowSizeOf(double width) {
  if (width < 600) return WindowSize.compact;
  if (width < 840) return WindowSize.medium;
  return WindowSize.expanded;
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => windowSizeOf(MediaQuery.sizeOf(this).width);
  bool get isCompact => windowSize == WindowSize.compact;
}
