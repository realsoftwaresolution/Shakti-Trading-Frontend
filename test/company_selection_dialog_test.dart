import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/company_select_dialog.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/main/company_mst_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(ThemeController());
    Get.put(DefaultController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CompanySelectionDialog displays fallback company when list is empty',
      (WidgetTester tester) async {
    final controller = Get.find<DefaultController>();
    controller.companies.clear();

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: CompanySelectionDialog(isSwitchCompany: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify dialog header
    expect(find.text('Select Company'), findsOneWidget);
    expect(find.text('Choose the operating company branch'), findsOneWidget);

    // Verify company name is displayed in the dropdown
    expect(find.text('Shakti Diamond'), findsOneWidget);

    // Verify company details (mobile & address) are displayed
    expect(find.text('8898999999'), findsOneWidget);
    expect(find.text('Minibazar, Surat'), findsOneWidget);

    // Verify proceed button is present
    expect(find.text('Proceed to ERP'), findsOneWidget);
  });

  testWidgets('CompanySelectionDialog renders loaded companies list properly',
      (WidgetTester tester) async {
    final controller = Get.find<DefaultController>();
    controller.companies.value = [];
    controller.companyCode.value = 3;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: CompanySelectionDialog(isSwitchCompany: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify switch header
    expect(find.text('Switch Company'), findsOneWidget);
    expect(find.text('Choose the operating company branch'), findsOneWidget);

    // Verify company name from API is displayed
    expect(find.text('Shakti Diamond - Surat'), findsOneWidget);
    expect(find.text('8898999999'), findsOneWidget);
    expect(find.text('Minibazar, Surat'), findsOneWidget);

    // Verify Confirm Switch button
    expect(find.text('Confirm Switch'), findsOneWidget);

    // Tap Confirm Switch
    await tester.tap(find.text('Confirm Switch'));
    await tester.pumpAndSettle();

    // Verify companyCode was set
    expect(controller.companyCode.value, 3);
  });

  testWidgets('CompanySelectionDialog renders left hero panel on wide screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = Get.find<DefaultController>();
    controller.companies.clear();

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: CompanySelectionDialog(isSwitchCompany: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Left hero panel elements
    expect(find.text('Shakti'), findsWidgets);
    expect(find.text('D I A M O N D'), findsWidgets);
    expect(find.text('Operating Branches'), findsOneWidget);
    expect(find.text('Branch Control'), findsOneWidget);
    expect(find.text('Multi-Location Operations'), findsOneWidget);
    expect(find.text('Secure Session'), findsOneWidget);

    // Right panel elements
    expect(find.text('Select Company'), findsOneWidget);
    expect(find.text('Proceed to ERP'), findsOneWidget);
  });
}
