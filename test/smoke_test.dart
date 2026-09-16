import 'package:flutter_test/flutter_test.dart';
import 'package:pdftoolkit/app.dart';

void main() {
  testWidgets('App initializes and renders Home tool grid properly', (WidgetTester tester) async {
    await tester.pumpWidget(const PdfToolkitApp());
    await tester.pumpAndSettle();

    expect(find.text('PDF Toolkit'), findsOneWidget);
    expect(find.text('Offline • Secure'), findsOneWidget);
    expect(find.text('Images → PDF'), findsOneWidget);
    expect(find.text('Merge PDF'), findsOneWidget);
    expect(find.text('Split PDF'), findsOneWidget);
    expect(find.text('PDF → Images'), findsOneWidget);
    expect(find.text('Compress PDF'), findsOneWidget);
    expect(find.text('Manage Pages'), findsOneWidget);

    // Verify switching bottom navigation tab
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Files Placeholder Screen'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings Placeholder Screen'), findsOneWidget);

    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.text('Images → PDF'), findsOneWidget);
  });
}
