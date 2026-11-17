import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/app.dart';
import 'package:tekki/core/constants/app_constants.dart';

void main() {
  testWidgets('TekkiApp renders home screen with app name', (tester) async {
    await tester.pumpWidget(const TekkiApp());

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(
      find.text('Gestion de caisse et passeport financier pour commercants'),
      findsOneWidget,
    );
  });
}
