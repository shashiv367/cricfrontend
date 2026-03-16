// Unit tests for API service (no network calls).
// Run: flutter test test/unit/api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sportbet/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('baseUrl contains /api', () {
      expect(ApiService.baseUrl.contains('/api'), isTrue);
    });

    test('baseUrl is non-empty', () {
      expect(ApiService.baseUrl.isNotEmpty, isTrue);
    });
  });
}
