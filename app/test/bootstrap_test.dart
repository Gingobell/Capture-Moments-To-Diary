import 'package:capture_moment/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bootstrap mounts without backend configuration', (tester) async {
    await tester.pumpWidget(const CaptureMomentApp());
    expect(find.byType(CaptureMomentApp), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        const Color(0xFFFBFBF7));
  });
}
