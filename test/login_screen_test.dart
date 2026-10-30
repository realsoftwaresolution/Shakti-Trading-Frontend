import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/login_dialog.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    final controller = Get.put(DefaultController());
    controller.isLoading.value = false;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LoginDialog renders split brand hero and sign-in form on wide desktop', (WidgetTester tester) async {
    // Set a desktop resolution (1200 x 800)
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: LoginDialog(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Brand Headers
    expect(find.text('Shakti'), findsWidgets);
    expect(find.text('D I A M O N D'), findsWidgets);
    expect(find.text('ERP System'), findsWidgets);
    expect(find.text('Realsoft Solutions'), findsWidgets);
    expect(find.text('Software For Your Business'), findsWidgets);
    expect(find.text('Presents'), findsWidgets);

    // Verify Custom Left-Panel Features for Shakti Diamond ERP
    expect(find.text('Streamline Operations'), findsOneWidget);
    expect(find.text('Increase Efficiency'), findsOneWidget);
    expect(find.text('Secure & Reliable'), findsOneWidget);
    expect(find.text('Purchase, Rough Entry, Polish Sales & Invoicing'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('For Shakti Diamond'), findsOneWidget);
  });

  testWidgets('LoginDialog renders clean compact view on mobile screens', (WidgetTester tester) async {
    // Set a mobile resolution (400 x 750)
    tester.view.physicalSize = const Size(400, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: LoginDialog(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify compact view displays primary sign-in form and brand header
    expect(find.text('Realsoft Solutions'), findsOneWidget);
    expect(find.text('Shakti'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Validation errors appear if Username or Password are empty', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: LoginDialog(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Clear the default text
    final usernameFields = find.byType(TextFormField);
    expect(usernameFields, findsNWidgets(2)); // Username & Password fields

    await tester.enterText(usernameFields.first, '');
    await tester.enterText(usernameFields.last, '');

    Get.find<DefaultController>().isLoading.value = false;
    await tester.pump();

    // Tap Sign In button
    final signInButton = find.text('Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
