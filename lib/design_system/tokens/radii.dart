import 'package:flutter/widgets.dart';

/// Corner radius tokens for the Gateway UI.
abstract final class AppRadiiTokens {
  /// Small radius.
  static const double sm = 8;

  /// Medium radius.
  static const double md = 12;

  /// Large radius.
  static const double lg = 16;

  /// Extra-large radius.
  static const double xl = 24;

  /// Card border radius.
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// Chip border radius.
  static const BorderRadius chip = BorderRadius.all(Radius.circular(sm));
}
