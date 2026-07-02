import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lectra/app.dart';

void main() {
  testWidgets('App boots and shows Dashboard as the initial screen',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LectraApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}