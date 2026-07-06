import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:admin_luxora/core/admin_data_store.dart';
import 'package:admin_luxora/core/theme_provider.dart';
import 'package:admin_luxora/main.dart';

void main() {
  testWidgets('App shows splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AdminDataStore()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    expect(find.text('LUXORA'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
