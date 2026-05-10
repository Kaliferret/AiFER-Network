import 'package:flutter/material.dart';
import 'color_polyfill.dart';

/// Polyfill for `Color.withValues` which was added in Flutter 3.27 (Dart 3.6).
///
/// The fernetwork codebase targets Flutter 3.27+ where `withValues` is
/// native. When building with Flutter 3.24 (e.g. a sandbox dry-run), this
/// extension fills the gap so static analysis and debug builds pass.
///
/// NOTE: Official builds on Flutter 3.27+ will ignore this file — Dart's
/// native `Color.withValues` takes precedence over extension methods.
extension ColorValuesPolyfill on Color {
  Color withValues({
    double? alpha,
    double? red,
    double? green,
    double? blue,
    Object? colorSpace, // accepted but ignored on Flutter <3.27
  }) {
    return Color.fromARGB(
      ((alpha ?? (this.alpha / 255.0)) * 255).round().clamp(0, 255),
      ((red ?? (this.red / 255.0)) * 255).round().clamp(0, 255),
      ((green ?? (this.green / 255.0)) * 255).round().clamp(0, 255),
      ((blue ?? (this.blue / 255.0)) * 255).round().clamp(0, 255),
    );
  }
}
