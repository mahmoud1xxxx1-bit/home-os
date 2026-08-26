import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_os/core/services/local_repositories.dart';
import 'package:home_os/features/documents/presentation/documents_screen.dart';
import 'package:home_os/features/expenses/presentation/expenses_screen.dart';
import 'package:home_os/features/maintenance/presentation/maintenance_screen.dart';
import 'package:home_os/features/warranties/presentation/warranties_screen.dart';
import 'package:home_os/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('maintenance opened from an asset shows only that asset records', (tester) async {
    await _pumpScreen(tester, const MaintenanceScreen(assetId: 'asset-ac'));

    expect(find.textContaining('مكيف المجلس'), findsWidgets);
    expect(find.textContaining('تنظيف فلاتر ومراجعة التبريد'), findsOneWidget);
    expect(find.textContaining('تغيير زيت وفلاتر'), findsNothing);
  });

  testWidgets('warranties opened from an asset show only that asset warranty', (tester) async {
    await _pumpScreen(tester, const WarrantiesScreen(assetId: 'asset-ac'));

    expect(find.textContaining('مكيف المجلس'), findsWidgets);
    expect(find.text('Gree'), findsOneWidget);
    expect(find.text('Samsung'), findsNothing);
  });

  testWidgets('documents opened from an asset show only documents for that asset', (tester) async {
    await _pumpScreen(tester, const DocumentsScreen(assetId: 'asset-ac'));

    expect(find.textContaining('مكيف المجلس'), findsWidgets);
    expect(find.text('فاتورة مكيف المجلس'), findsOneWidget);
    expect(find.text('وثيقة تأمين السيارة'), findsNothing);
  });

  testWidgets('expenses opened from an asset calculate and show only that asset costs', (tester) async {
    await _pumpScreen(tester, const ExpensesScreen(assetId: 'asset-ac'));

    expect(find.textContaining('مكيف المجلس'), findsWidgets);
    expect(find.text('تنظيف مكيف'), findsOneWidget);
    expect(find.text('صيانة السيارة'), findsNothing);
    expect(find.text('عامل الحديقة'), findsNothing);
    expect(find.text('180.00 SAR'), findsWidgets);
  });
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(LocalHomeStore()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
