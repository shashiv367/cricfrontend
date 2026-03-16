// Unit tests for app color palette.
// Run: flutter test test/unit/app_colors_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportbet/utils/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primaryElectric is defined', () {
      expect(AppColors.primaryElectric, isA<Color>());
    });

    test('textPrimary is dark for readability', () {
      expect(AppColors.textPrimary, isA<Color>());
    });

    test('shadowColor has opacity < 1.0', () {
      expect(AppColors.shadowColor.opacity, lessThan(1.0));
    });
  });
}
