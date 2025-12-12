import 'dart:math';
import 'package:flutter/material.dart';

/// Generates a pleasant random color using HSL color space.
Color generatePleasantColor() {
  final random = Random();

  // 1. Hue
  final double hue = random.nextDouble() * 360.0;

  // 2. Saturation 50-85%
  final double saturation = 0.5 + random.nextDouble() * 0.35;

  // 3. Lightness 35-50%
  final double lightness = 0.35 + random.nextDouble() * 0.25;

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}
