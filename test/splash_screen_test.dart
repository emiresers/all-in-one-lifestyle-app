import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dummyproject/screens/splash/splash_screen.dart';

void main() {
  testWidgets('splash ekranı giriş ekranına otomatik geçer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.byKey(const Key('splash-background')), findsOneWidget);
    expect(find.text('Welcome Back,'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('splash-background')), findsNothing);
    expect(find.text('Welcome Back,'), findsOneWidget);
  });
}
