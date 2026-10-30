import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/components/app_sidebar.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/main/company_mst_model.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/dashboard_with_tab.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'username': 'Darshanbhai',
      'companyCode': 3,
    });
    Get.reset();
    Get.put(ThemeController());
    Get.put(TabControllerX());
    final defaultController = Get.put(DefaultController());
    defaultController.companyCode.value = 3;
    defaultController.companies.value = [];
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('AppSidebar renders all navigation modules and brand header in expanded mode',
      (WidgetTester tester) async {
    bool toggled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AppSidebar(
            isCollapsed: false,
            onToggleCollapse: () => toggled = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand Header
    expect(find.text('Shakti'), findsOneWidget);
    expect(find.text('D I A M O N D'), findsOneWidget);

    // Verify Category Headers
    expect(find.text('MAIN'), findsOneWidget);
    expect(find.text('OPERATIONS'), findsOneWidget);
    expect(find.text('REPORTS & MASTERS'), findsOneWidget);

    // Verify Modules from User Image & System
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('Memo Issue'), findsOneWidget);
    expect(find.text('Memo Rec'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Party Ledger'), findsOneWidget);
    expect(find.text('Assort Master'), findsOneWidget);
    expect(find.text('Rough Assort'), findsOneWidget);

    // Verify User Profile in Footer
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

  });

  testWidgets('AppSidebar can trigger onToggleCollapse when collapsed logo tapped',
      (WidgetTester tester) async {
    bool toggled = false;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AppSidebar(
            isCollapsed: true,
            onToggleCollapse: () {
              toggled = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand Sidebar (Ctrl+B)'));
    expect(toggled, isTrue);
  });

  testWidgets('AppSidebar opens tabs dynamically and highlights active item',
      (WidgetTester tester) async {
    final tabController = Get.find<TabControllerX>();
    expect(tabController.tabList.isEmpty, isTrue);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AppSidebar(
            isCollapsed: false,
            onToggleCollapse: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially Dashboard is active when no tabs
    expect(tabController.activeTabLabel, 'Dashboard');

    // Tap Purchase
    await tester.tap(find.text('Purchase'));
    await tester.pumpAndSettle();

    // Tab was added
    expect(tabController.tabList.length, 1);
    expect(tabController.tabList.first.label, 'Purchase');
    expect(tabController.activeTabLabel, 'Purchase');

    // Tap Sale
    await tester.tap(find.text('Sale'));
    await tester.pumpAndSettle();

    // Second tab was added
    expect(tabController.tabList.length, 2);
    expect(tabController.tabList[1].label, 'Sale');
    expect(tabController.activeTabLabel, 'Sale');
  });

  testWidgets('DashboardWithDynamicTabs renders clean top bar without old horizontal buttons and shows fixed sidebar on desktop',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardWithDynamicTabs(),
      ),
    );
    await tester.pumpAndSettle();

    // Fixed sidebar is rendered on the left
    expect(find.byType(AppSidebar), findsOneWidget);

    // Sidebar items are present inside AppSidebar
    expect(find.descendant(of: find.byType(AppSidebar), matching: find.text('Purchase')), findsOneWidget);
    expect(find.descendant(of: find.byType(AppSidebar), matching: find.text('Memo Issue')), findsOneWidget);
    expect(find.descendant(of: find.byType(AppSidebar), matching: find.text('Memo Rec')), findsOneWidget);
    expect(find.descendant(of: find.byType(AppSidebar), matching: find.text('Payment')), findsOneWidget);

    // Top Bar shows breadcrumb badge and sidebar toggle
    expect(find.byIcon(Icons.menu_open_rounded), findsWidgets);
    expect(find.text('Shortcuts: Ctrl+B: Toggle Sidebar | Ctrl+W: Close Tab | Ctrl+Tab: Switch Tab'), findsOneWidget);
  });
}
