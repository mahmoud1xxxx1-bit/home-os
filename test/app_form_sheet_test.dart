import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_os/core/widgets/app_form_sheet.dart';

void main() {
  testWidgets('form sheet remains usable on a narrow screen with keyboard inset', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showAppFormSheet<void>(
                  context: context,
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Form title'),
                      for (var i = 0; i < 8; i++) ...[
                        const SizedBox(height: 12),
                        TextField(key: ValueKey('field-$i')),
                      ],
                      const SizedBox(height: 16),
                      const FilledButton(onPressed: null, child: Text('Save')),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Form title'), findsOneWidget);
    expect(find.byKey(const ValueKey('field-0')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('field-0')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
