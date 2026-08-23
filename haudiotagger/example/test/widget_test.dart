import 'package:flutter_test/flutter_test.dart';
import 'package:haudiotagger/haudiotagger.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    // Just verify the library imports resolve
    expect(Tag, isNotNull);
    expect(Picture, isNotNull);
    expect(Haudiotagger, isNotNull);
  });
}
