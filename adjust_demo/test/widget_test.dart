import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adjust_demo/models/user.dart';
import 'package:adjust_demo/utils/validators.dart';
import 'package:adjust_demo/widgets/brand_logo.dart';

void main() {
  group('Validators', () {
    test('email rejects malformed and accepts valid addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('ada@nova.com'), isNull);
    });

    test('password enforces a minimum length', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('secret1'), isNull);
    });

    test('confirmPassword must match the original', () {
      expect(Validators.confirmPassword('abc', 'abcd'), isNotNull);
      expect(Validators.confirmPassword('abcd', 'abcd'), isNull);
    });
  });

  group('User', () {
    test('derives initials from the name', () {
      const user = User(id: '1', name: 'Ada Lovelace', email: 'a@b.com');
      expect(user.initials, 'AL');
    });

    test('round-trips through JSON', () {
      const user = User(id: '1', name: 'Ada Lovelace', email: 'a@b.com');
      final restored = User.fromJson(user.toJson());
      expect(restored, user);
    });
  });

  testWidgets('BrandLogo renders the wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrandLogo())),
    );
    expect(find.text('Nova Store'), findsOneWidget);
  });
}
