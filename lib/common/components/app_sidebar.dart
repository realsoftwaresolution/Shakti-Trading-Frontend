import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/assort/assort_form_screen.dart';
import 'package:real_web_rough_entry_system/assort/rough_assort_form_screen.dart';
import 'package:real_web_rough_entry_system/common/components/diamond_logo.dart';
import 'package:real_web_rough_entry_system/common/components/placeholder_form_screen.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/controllers/menu_app_controller.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/main/menu_model.dart';
import 'package:real_web_rough_entry_system/memo%20issue/memoiss_form_screen.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memorec_form_screen.dart';
import 'package:real_web_rough_entry_system/party-ledger/party_ledger_form_screen.dart';
import 'package:real_web_rough_entry_system/party/party_form_screen.dart';
import 'package:real_web_rough_entry_system/payment/payment_form_screen.dart';
import 'package:real_web_rough_entry_system/charni/charni_form_screen.dart';
import 'package:real_web_rough_entry_system/clarity/clarity_form_screen.dart';
import 'package:real_web_rough_entry_system/color/color_form_screen.dart';
import 'package:real_web_rough_entry_system/designation/designation_form_screen.dart';
import 'package:real_web_rough_entry_system/branch_transfer/branch_transfer_form_screen.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_form_screen.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_form_screen.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer_confirm/internal_stock_transfer_confirm_form_screen.dart';
import 'package:real_web_rough_entry_system/polish_purchase/polish_purchase_form_screen.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_form_screen.dart';
import 'package:real_web_rough_entry_system/quality/quality_form_screen.dart';
import 'package:real_web_rough_entry_system/report/report_screen.dart';
import 'package:real_web_rough_entry_system/rough/rough_type_form_screen.dart';
import 'package:real_web_rough_entry_system/sale/sale_form_screen.dart';
import 'package:real_web_rough_entry_system/shape/shape_form_screen.dart';
import 'package:real_web_rough_entry_system/expense_group/expense_group_form_screen.dart';
import 'package:real_web_rough_entry_system/expense/expense_form_screen.dart';
import 'package:real_web_rough_entry_system/acc_type/acc_type_form_screen.dart';
import 'package:real_web_rough_entry_system/polish_type/polish_type_form_screen.dart';
import 'package:real_web_rough_entry_system/company/company_form_screen.dart';
import 'package:real_web_rough_entry_system/branch/branch_form_screen.dart';
import 'package:real_web_rough_entry_system/user/user_form_screen.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_item.dart';

/// Ultra-clean, modern left sidebar for Shakti Diamond ERP.
/// Supports dynamic menu API structure, collapsible accordion groups,
/// single-line submenus, smooth hover states, collapsed rail popups, and logout/exit actions.
class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final bool isDrawer;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.isDrawer = false,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late final TabControllerX _tabController;
  late final DefaultController _defaultController;
  late final MenuAppController _menuAppController;

  @override
  void initState() {
    super.initState();
    _tabController = Get.isRegistered<TabControllerX>()
        ? Get.find<TabControllerX>()
        : Get.put(TabControllerX());
    _defaultController = Get.isRegistered<DefaultController>()
        ? Get.find<DefaultController>()
        : Get.put(DefaultController());
    _menuAppController = Get.isRegistered<MenuAppController>()
        ? Get.find<MenuAppController>()
        : Get.put(MenuAppController());

    if (_defaultController.menuList.isEmpty) {
      _defaultController.getMenuList();
    }
  }

  void _openTab(String label, IconData icon, Widget view) {
    if (widget.isDrawer) {
      Navigator.of(context).pop();
    }
    _tabController.isReportForm.value = false;
    _tabController.addTab(
      TabItem(
        view: view,
        label: label,
        icon: Icon(icon, size: 16),
      ),
    );
  }

  void _openDashboard() {
    if (widget.isDrawer) {
      Navigator.of(context).pop();
    }
    _tabController.tabList.clear();
    _tabController.isReportForm.value = false;
    _defaultController.enabledAdvancedDashboard.value = true;
  }

  void _navigateToSubMenu(SubMenuModel sub) {
    if (!_defaultController.canViewMenu(sub.menuMstID)) {
      infoDialog(messageText: 'You do not have permission to access this module.');
      return;
    }

    final String name = (sub.menuName ?? '').trim();
    final String form = (sub.formName ?? '').trim();
    final IconData icon = getSubMenuIcon(name, formName: form);

    final String formLower = form.toLowerCase();
    final String nameLower = name.toLowerCase();

    // 1. Party Form
    if (formLower == 'frmpartyform' || nameLower == 'party') {
      _openTab(name, icon, const PartyFormScreen(showHeader: false));
      return;
    }

    // Rough Type Form
    if (formLower == 'frmroughtypeform' || nameLower == 'rough type') {
      _openTab(name, icon, const RoughTypeFormScreen(showHeader: false));
      return;
    }

    // Quality Form
    if (formLower == 'frmqualityform' || nameLower == 'quality') {
      _openTab(name, icon, const QualityFormScreen(showHeader: false));
      return;
    }

    // Charni Form
    if (formLower == 'frmcharniform' || nameLower == 'charni') {
      _openTab(name, icon, const CharniFormScreen(showHeader: false));
      return;
    }

    // Clarity Form
    if (formLower == 'frmclarityform' || nameLower == 'clarity') {
      _openTab(name, icon, const ClarityFormScreen(showHeader: false));
      return;
    }

    // Color Form
    if (formLower == 'frmcolorform' || nameLower == 'color') {
      _openTab(name, icon, const ColorFormScreen(showHeader: false));
      return;
    }

    // Designation Form
    if (formLower == 'frmdesignationform' ||
        formLower == 'frmdesignation' ||
        nameLower == 'designation' ||
        nameLower == 'designation master' ||
        nameLower == 'designation mst') {
      _openTab(name, icon, const DesignationFormScreen(showHeader: false));
      return;
    }

    // Shape Form
    if (formLower == 'frmshapeform' || nameLower == 'shape') {
      _openTab(name, icon, const ShapeFormScreen(showHeader: false));
      return;
    }

    // Expense Group Form
    if (formLower == 'frmexpensegroupform' ||
        nameLower == 'expense group' ||
        nameLower == 'expense group mst' ||
        nameLower == 'expense group master') {
      _openTab(name, icon, const ExpenseGroupFormScreen(showHeader: false));
      return;
    }

    // Expense Form
    if (formLower == 'frmexpenseform' ||
        nameLower == 'expense' ||
        nameLower == 'expense mst' ||
        nameLower == 'expense master') {
      _openTab(name, icon, const ExpenseFormScreen(showHeader: false));
      return;
    }

    // Acc Type / Type Master
    if (formLower == 'frmacctype' ||
        formLower == 'frmtype' ||
        nameLower == 'acc type' ||
        nameLower == 'acc type mst' ||
        nameLower == 'account type' ||
        nameLower == 'type mst') {
      _openTab(name, icon, const AccTypeFormScreen(showHeader: false));
      return;
    }

    // Polish Type Master
    if (formLower == 'frmpolishtype' ||
        nameLower == 'polish type' ||
        nameLower == 'polish type mst' ||
        nameLower == 'polish type master') {
      _openTab(name, icon, const PolishTypeFormScreen(showHeader: false));
      return;
    }

    // 2. Rough Purchase Form
    if (formLower == 'frmroughpurchaseform' || nameLower == 'rough purchase') {
      _openTab(name, icon, const PurchaseFormScreen(showHeader: false));
      return;
    }

    // 3. Polish Purchase Form
    if (formLower == 'frmpolishpurchaseform' || nameLower == 'polish purchase') {
      _openTab(name, icon, const PolishPurchaseFormScreen(showHeader: false));
      return;
    }

    // Branch Transfer Form
    if (formLower == 'frmbranchtransferform' ||
        formLower == 'frmbranchtransfer' ||
        formLower == 'frmstockissueform' ||
        formLower == 'frmstockissue' ||
        nameLower == 'branch transfer' ||
        nameLower == 'stock issue') {
      _openTab(name, icon, const BranchTransferFormScreen(showHeader: false));
      return;
    }

    // Branch Transfer Confirm Form
    if (formLower == 'frmbranchtransferconfirmform' ||
        formLower == 'frmbranchtransferconfirm' ||
        formLower == 'frmstockconfirmform' ||
        formLower == 'frmstockconfirm' ||
        nameLower == 'branch transfer confirm' ||
        nameLower == 'stock confirm') {
      _openTab(
        name,
        icon,
        const BranchTransferConfirmFormScreen(showHeader: false),
      );
      return;
    }

    // Internal Stock Transfer Form
    if (formLower == 'frminternalstocktransferform' ||
        formLower == 'frminternalstocktransfer' ||
        formLower == 'frminternaltransferform' ||
        formLower == 'frminternaltransfer' ||
        nameLower == 'internal stock transfer' ||
        nameLower == 'internal transfer') {
      _openTab(name, icon, const InternalStockTransferFormScreen(showHeader: false));
      return;
    }

    // Internal Stock Transfer Confirm Form
    if (formLower == 'frminternalstocktransferconfirmform' ||
        formLower == 'frminternalstocktransferconfirm' ||
        formLower == 'frminternaltransferconfirmform' ||
        formLower == 'frminternaltransferconfirm' ||
        nameLower == 'internal stock transfer confirm' ||
        nameLower == 'internal transfer confirm') {
      _openTab(
        name,
        icon,
        const InternalStockTransferConfirmFormScreen(showHeader: false),
      );
      return;
    }

    // 4. Polish Sale / Sale Form
    if (formLower == 'frmpolishsale' || nameLower == 'polish sale' || nameLower == 'sale') {
      _openTab(name, icon, const SaleFormScreen(showHeader: false));
      return;
    }

    // 5. Memo Issue Form
    if (formLower == 'frmmemoissueform' || nameLower == 'memo issue') {
      _openTab(name, icon, const MemoIssFormScreen(showHeader: false));
      return;
    }

    // 6. Memo Return / Memo Receive Form
    if (formLower == 'frmmemoreturnform' ||
        nameLower == 'memo return' ||
        nameLower == 'memo rec' ||
        nameLower == 'memo receive') {
      _openTab(name, icon, const MemoRecFormScreen(showHeader: false));
      return;
    }

    // 7. Payment Form
    if (formLower == 'frmpaymentform' || nameLower == 'payment') {
      _openTab(name, icon, const PaymentFormScreen(showHeader: false));
      return;
    }

    // 8. Company Master
    if (formLower == 'frmcompanyform' ||
        formLower == 'frmcompany' ||
        nameLower == 'company' ||
        nameLower == 'company master' ||
        nameLower == 'company mst') {
      _openTab(name, icon, const CompanyFormScreen(showHeader: false));
      return;
    }

    // 8.1 Branch Master
    if (formLower == 'frmbranchform' ||
        formLower == 'frmbranch' ||
        nameLower == 'branch' ||
        nameLower == 'branch master' ||
        nameLower == 'branch mst') {
      _openTab(name, icon, const BranchFormScreen(showHeader: false));
      return;
    }

    // 8.2 User Master
    if (formLower == 'frmuserform' ||
        formLower == 'frmuser' ||
        nameLower == 'user' ||
        nameLower == 'user master' ||
        nameLower == 'user mst') {
      _openTab(name, icon, const UserFormScreen(showHeader: false));
      return;
    }

    if (nameLower == 'switch company') {
      showCompanySelectionDialog(isFromSwitchCompany: true);
      return;
    }

    // 9. Assort Master
    if (nameLower == 'assort master' || formLower == 'frmassortform') {
      _openTab(name, icon, const AssortFormScreen(showHeader: false));
      return;
    }

    // 10. Rough Assort
    if (nameLower == 'rough assort' || formLower == 'frmroughassortform') {
      _openTab(name, icon, const RoughAssortFormScreen(showHeader: false));
      return;
    }

    // 11. Party Ledger
    if (nameLower == 'party ledger') {
      _openTab(name, icon, const PartyLedgerFormScreen(showHeader: false));
      return;
    }

    // 12. Reports
    if (nameLower.contains('report')) {
      _openTab(name, icon, const ReportScreen(showHeader: false));
      return;
    }

    // Default: Placeholder for unmapped master forms
    _openTab(
      name,
      icon,
      PlaceholderFormScreen(
        title: name,
        formName: form.isNotEmpty ? form : null,
        icon: icon,
      ),
    );
  }

  void _handleLogout() {
    if (_tabController.tabList.isNotEmpty) {
      infoDialog(messageText: 'Please close all open tabs before logging out.');
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppColors.isDark ? 0.6 : 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to end your session?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Get.back();
                        await _defaultController.logout();
                      },
                      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool collapsed = widget.isDrawer ? false : widget.isCollapsed;
    final double width = widget.isDrawer ? 280 : (collapsed ? 70 : 260);

    return Obx(() {
      final isDark = ThemeController.isInitialized
          ? ThemeController.to.isDarkMode.value
          : false;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1A262F),
          border: Border(
            right: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFF263544),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Clean Brand Header
            _buildBrandHeader(collapsed, isDark),

            Divider(
              height: 1,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFF263544),
            ),

            // 2. High-Contrast Dynamic Scrollable Navigation Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 8 : 10,
                  vertical: 10,
                ),
                child: Obx(() {
                  final currentLabel = _tabController.activeTabLabel;
                  final hasNoTabs = _tabController.tabList.isEmpty;
                  final isLoading = _defaultController.isLoadingMenuList.value;
                  // Register reactive dependency on user access permissions matrix
                  final _ = _defaultController.userAccessMap.length;

                  final List<MainMenuModel> displayMenus =
                  List<MainMenuModel>.from(_defaultController.menuList)
                    ..sort((a, b) =>
                        (a.mainMenuMstID ?? 0).compareTo(b.mainMenuMstID ?? 0));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section: DASHBOARD (Always accessible)
                      _buildMenuItem(
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        collapsed: collapsed,
                        isActive: hasNoTabs,
                        onTap: _openDashboard,
                        isDark: isDark,
                      ),

                      if (isLoading && _defaultController.menuList.isEmpty)
                        _buildLoadingSkeleton(isDark)
                      else ...[
                        const SizedBox(height: 6),

                        // Dynamic Menus from API
                        ...displayMenus.asMap().entries.map((entry) {
                          final int catIndex = entry.key;
                          final MainMenuModel mainMenu = entry.value;

                          if (mainMenu.valid == 0) return const SizedBox.shrink();

                          final String mainTitle = mainMenu.mainMenuName ?? '';
                          final String upperTitle = mainTitle.toUpperCase().trim();

                          // Exclude LOGOUT and EXIT from the navigation menu list
                          if (upperTitle == 'LOGOUT' || upperTitle == 'EXIT') {
                            return const SizedBox.shrink();
                          }

                          final IconData mainIcon = getMainMenuIcon(mainTitle);
                          final int menuId = mainMenu.mainMenuMstID ?? 0;
                          final List<SubMenuModel> validSubMenus = mainMenu.subMenus
                              .where((s) =>
                          s.valid != 0 &&
                              (s.menuName ?? '').toUpperCase().trim() != 'LOGOUT' &&
                              (s.menuName ?? '').toUpperCase().trim() != 'EXIT' &&
                              _defaultController.canViewMenu(
                                s.menuMstID,
                                categoryKey: catIndex,
                              ))
                              .toList()
                            ..sort((a, b) =>
                                (a.sortID ?? 0).compareTo(b.sortID ?? 0));

                          // CASE A: Menu has submenus (Accordion Category)
                          if (validSubMenus.isNotEmpty) {
                            if (collapsed) {
                              return _buildCollapsedGroupItem(
                                icon: mainIcon,
                                title: mainTitle,
                                subMenus: validSubMenus,
                                isDark: isDark,
                              );
                            }

                            final bool isExpanded = _menuAppController.isExpanded(menuId);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAccordionHeader(
                                  title: mainTitle,
                                  icon: mainIcon,
                                  itemCount: validSubMenus.length,
                                  isExpanded: isExpanded,
                                  onTap: () => _menuAppController.toggleExpand(menuId),
                                  isDark: isDark,
                                ),
                                if (isExpanded)
                                  ...validSubMenus.map((sub) {
                                    final String subTitle = sub.menuName ?? '';
                                    final IconData subIcon =
                                        getSubMenuIcon(subTitle, formName: sub.formName);
                                    final bool isSubActive =
                                        !hasNoTabs && currentLabel == subTitle;

                                    return _buildSubMenuItem(
                                      icon: subIcon,
                                      title: subTitle,
                                      isActive: isSubActive,
                                      onTap: () => _navigateToSubMenu(sub),
                                      isDark: isDark,
                                    );
                                  }),
                                const SizedBox(height: 6),
                              ],
                            );
                          }

                          // If category had submenus but none are permitted, hide it
                          if (mainMenu.subMenus.isNotEmpty) {
                            return const SizedBox.shrink();
                          }

                          // CASE B: Single menu item without submenus (e.g. REPORT, UTILITY)
                          if (!_defaultController.canViewMenu(menuId, categoryKey: catIndex)) {
                            return const SizedBox.shrink();
                          }

                          return _buildDirectMenuItem(
                            mainTitle: mainTitle,
                            mainIcon: mainIcon,
                            collapsed: collapsed,
                            hasNoTabs: hasNoTabs,
                            currentLabel: currentLabel,
                            isDark: isDark,
                          );
                        }),
                      ],
                    ],
                  );
                }),
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFF263544),
            ),

            // 3. Bottom Footer: User Profile & Logout
            _buildBottomSection(collapsed, isDark),
          ],
        ),
      );
    });
  }

  /// Builds direct single menu items like REPORT, LOGOUT, EXIT, UTILITY
  Widget _buildDirectMenuItem({
    required String mainTitle,
    required IconData mainIcon,
    required bool collapsed,
    required bool hasNoTabs,
    required String currentLabel,
    required bool isDark,
  }) {
    final upper = mainTitle.toUpperCase().trim();

    if (upper == 'LOGOUT' || upper == 'EXIT') {
      return const SizedBox.shrink();
    }

    if (upper == 'REPORT') {
      final bool isActive = !hasNoTabs && (currentLabel == 'Reports' || currentLabel == 'REPORT');
      return _buildMenuItem(
        icon: mainIcon,
        title: 'Reports',
        collapsed: collapsed,
        isActive: isActive,
        onTap: () => _openTab('Reports', mainIcon, const ReportScreen(showHeader: false)),
        isDark: isDark,
      );
    }

    if (upper == 'UTILITY') {
      final bool isActive = !hasNoTabs && currentLabel == 'Utility';
      return _buildMenuItem(
        icon: mainIcon,
        title: 'Utility',
        collapsed: collapsed,
        isActive: isActive,
        onTap: () => _openTab(
          'Utility',
          mainIcon,
          const PlaceholderFormScreen(
            title: 'Utility Tools',
            formName: 'FrmUtility',
            icon: Icons.build_circle_rounded,
          ),
        ),
        isDark: isDark,
      );
    }

    // Generic direct main item
    final bool isActive = !hasNoTabs && currentLabel == mainTitle;
    return _buildMenuItem(
      icon: mainIcon,
      title: mainTitle,
      collapsed: collapsed,
      isActive: isActive,
      onTap: () => _openTab(
        mainTitle,
        mainIcon,
        PlaceholderFormScreen(
          title: mainTitle,
          icon: mainIcon,
        ),
      ),
      isDark: isDark,
    );
  }

  /// Clean Brand Header with Diamond Logo & Collapse Toggle
  Widget _buildBrandHeader(bool collapsed, bool isDark) {
    final Color logoBg = isDark ? const Color(0xFF1E293B) : const Color(0xFF243340);
    final Color logoBorder = const Color(0xFF38BDF8).withValues(alpha: 0.35);

    if (collapsed) {
      return Container(
        height: 64,
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Expand Sidebar (Ctrl+B)',
          child: InkWell(
            onTap: widget.onToggleCollapse,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: logoBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: logoBorder,
                  width: 1.2,
                ),
              ),
              child: DiamondLogo.lightOnDark(size: 24),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Diamond Logo Badge
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: logoBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: logoBorder,
                width: 1.2,
              ),
            ),
            child: DiamondLogo.lightOnDark(size: 26),
          ),
          const SizedBox(width: 10),

          // Brand Typography
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shakti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'T R A D I N G',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Collapsible Accordion Header (MASTER, TRANSACTION, etc.)
  Widget _buildAccordionHeader({
    required String title,
    required IconData icon,
    required int itemCount,
    required bool isExpanded,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final Color badgeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFF243340);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (itemCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Clean Indented Submenu Item
  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 1.5),
      child: Material(
        color: isActive ? const Color(0xFF1D4ED8) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isActive
                      ? Colors.white
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : const Color(0xFFE2E8F0),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Floating Popup for Collapsed Rail Mode
  Widget _buildCollapsedGroupItem({
    required IconData icon,
    required String title,
    required List<SubMenuModel> subMenus,
    required bool isDark,
  }) {
    return PopupMenuButton<SubMenuModel>(
      tooltip: title,
      offset: const Offset(65, 0),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1A262F),
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFF263544),
        ),
      ),
      onSelected: (sub) => _navigateToSubMenu(sub),
      itemBuilder: (context) {
        return [
          PopupMenuItem<SubMenuModel>(
            enabled: false,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          ...subMenus.where((s) => s.valid != 0).map((sub) {
            final icon = getSubMenuIcon(sub.menuName, formName: sub.formName);
            return PopupMenuItem<SubMenuModel>(
              value: sub,
              height: 38,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    sub.menuName ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ];
      },
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(vertical: 2),
        alignment: Alignment.center,
        child:  Icon(
          icon,
          size: 20,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  /// Shimmer loading skeleton
  Widget _buildLoadingSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        6,
        (index) => Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Clean Single-Line Direct Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool collapsed,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    Color? customColor,
  }) {
    final Widget itemContent = Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1D4ED8) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
            ),
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: customColor ??
                      (isActive
                          ? Colors.white
                          : const Color(0xFF94A3B8)),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: customColor ??
                            (isActive
                                ? Colors.white
                                : const Color(0xFFE2E8F0)),
                        fontSize: 13.5,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF38BDF8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF38BDF8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: title,
        preferBelow: false,
        verticalOffset: 20,
        child: itemContent,
      );
    }

    return itemContent;
  }

  /// Clean Bottom Section
  Widget _buildBottomSection(bool collapsed, bool isDark) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Tooltip(
              message: 'Log Out',
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                onPressed: _handleLogout,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFF141F27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Profile Row
          Obx(() {
            final String name = _defaultController.currentUserFullName.value.isNotEmpty
                ? _defaultController.currentUserFullName.value
                : (_defaultController.currentUserName.value.isNotEmpty
                    ? _defaultController.currentUserName.value
                    : 'Admin');
            final String role = _defaultController.currentUserGrp.value.isNotEmpty
                ? _defaultController.currentUserGrp.value
                : 'ADMIN';
            final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

            return Row(
              children: [
                // User Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF0284C7)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Username & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Logout Button
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                  tooltip: 'Log Out',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: _handleLogout,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
