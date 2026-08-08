import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrovision/app/app.dart';
import 'package:agrovision/core/storage/secure_storage.dart';
import 'package:agrovision/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AgroVision app boots successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const AgroVisionApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AgroVisionApp), findsOneWidget);
  });
}
