import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/main/company_mst_model.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/dashboard_with_tab.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Test form widget with internal state to prove state is not destroyed on theme toggle
class _TestTabFormWidget extends StatefulWidget {
  final String title;
  const _TestTabFormWidget({required this.title});

  @override
  State<_TestTabFormWidget> createState() => _TestTabFormWidgetState();
}

class _TestTabFormWidgetState extends State<_TestTabFormWidget> {
  late final TextEditingController textController;
  int buildCount = 0;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: 'Initial Form Input');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tab: ${widget.title}'),
            TextField(controller: textController),
          ],
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'username': 'Darshanbhai',
      'companyCode': 3,
      'app_is_dark_mode': false,
    });
    Get.reset();
    Get.put(ThemeController());
    Get.put(TabControllerX());
    final defaultController = Get.put(DefaultController());
    defaultController.companyCode.value = 3;
    defaultController.companies.value = [];
  });

  testWidgets('Theme toggling does not dispose or recreate open tabs in IndexedStack',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final tabController = Get.find<TabControllerX>();
    final themeController = Get.find<ThemeController>();

    // Add a tab with a stateful form
    tabController.addTab(
      TabItem(
        view: const _TestTabFormWidget(title: 'Active Purchase Tab'),
        label: 'Purchase Entry',
        icon: const Icon(Icons.shopping_bag_rounded),
      ),
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardWithDynamicTabs(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab and input content
    expect(find.text('Tab: Active Purchase Tab'), findsOneWidget);
    expect(find.text('Initial Form Input'), findsOneWidget);
    expect(themeController.isDarkMode.value, isFalse);

    // Enter custom user input into form field
    await tester.enterText(find.byType(TextField), 'Modified User Typed Input 123');
    await tester.pumpAndSettle();
    expect(find.text('Modified User Typed Input 123'), findsOneWidget);

    // Toggle theme to Dark Mode
    await themeController.setDarkMode(true);
    await tester.pumpAndSettle();

    // Verify Dark Mode is active
    expect(themeController.isDarkMode.value, isTrue);

    // Crucial check: The user's input must NOT be reset or destroyed!
    expect(find.text('Modified User Typed Input 123'), findsOneWidget);

    // Verify IndexedStack is stable
    final indexedStackFinder = find.byKey(const ValueKey('tab_stack'));
    expect(indexedStackFinder, findsOneWidget);

    // Toggle theme back to Light Mode
    await themeController.setDarkMode(false);
    await tester.pumpAndSettle();

    // Verify Light Mode is active and input still preserved
    expect(themeController.isDarkMode.value, isFalse);
    expect(find.text('Modified User Typed Input 123'), findsOneWidget);
  });

  testWidgets('Quick theme toggle button in Top Bar switches theme smoothly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final themeController = Get.find<ThemeController>();
    expect(themeController.isDarkMode.value, isFalse);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardWithDynamicTabs(),
      ),
    );
    await tester.pumpAndSettle();

    // Find the quick theme toggle button by tooltip
    final toggleButton = find.byTooltip('Switch to Dark Mode');
    expect(toggleButton, findsOneWidget);

    // Tap quick toggle button
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    // Theme toggles to dark
    expect(themeController.isDarkMode.value, isTrue);
    expect(find.byTooltip('Switch to Light Mode'), findsOneWidget);

    // Tap again to switch back to light
    await tester.tap(find.byTooltip('Switch to Light Mode'));
    await tester.pumpAndSettle();

    expect(themeController.isDarkMode.value, isFalse);
    expect(find.byTooltip('Switch to Dark Mode'), findsOneWidget);
  });
}
