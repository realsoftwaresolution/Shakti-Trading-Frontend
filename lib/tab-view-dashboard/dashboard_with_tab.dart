import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/assort/rough_assort_form_screen.dart';
import 'package:real_web_rough_entry_system/common/components/app_sidebar.dart';
import 'package:real_web_rough_entry_system/common/components/theme_studio_dialog.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/party-ledger/party_ledger_form_screen.dart';
import 'package:real_web_rough_entry_system/payment/payment_form_screen.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_form_screen.dart';
import 'package:real_web_rough_entry_system/report/report_screen.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:real_web_rough_entry_system/sale/sale_form_screen.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/advanced_dashboard.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_item.dart';

class DashboardWithDynamicTabs extends StatelessWidget {
  const DashboardWithDynamicTabs({super.key});

  void _openTab(String label, IconData icon, Widget view) {
    tabController.isReportForm.value = false;
    tabController.addTab(
      TabItem(
        view: view,
        label: label,
        icon: Icon(icon, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.keyW, control: true): () {
        tabController.closeCurrentTab();
      },
      const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () {
        tabController.closeCurrentTab();
      },
      const SingleActivator(LogicalKeyboardKey.tab, control: true): () {
        tabController.nextTab();
      },
      const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true): () {
        tabController.previousTab();
      },
      const SingleActivator(LogicalKeyboardKey.pageDown, control: true): () {
        tabController.nextTab();
      },
      const SingleActivator(LogicalKeyboardKey.pageUp, control: true): () {
        tabController.previousTab();
      },
      const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
        tabController.toggleSidebar();
      },
      const SingleActivator(LogicalKeyboardKey.keyB, alt: true): () {
        tabController.toggleSidebar();
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            color: AppColors.background,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              drawer: Responsive.isMobile(context) ? _buildMobileDrawer(context) : null,
              body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Fixed Luxury Sidebar on Desktop & Tablet
              if (!Responsive.isMobile(context))
                Obx(
                  () => AppSidebar(
                    isCollapsed: tabController.isSidebarCollapsed.value,
                    onToggleCollapse: () => tabController.toggleSidebar(),
                    isDrawer: false,
                  ),
                ),

              // 2. Main Workspace
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Modern Clean Top Bar
                    _buildTopAppBar(context),

                    // Modern Tab Bar Strip
                Obx(() {
                  if (tabController.tabList.isEmpty) return const SizedBox.shrink();

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
                    ),
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                    child: Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          scrollController.jumpTo(
                            (scrollController.offset + pointerSignal.scrollDelta.dy).clamp(
                              0.0,
                              scrollController.position.maxScrollExtent,
                            ),
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            tabController.tabList.length,
                            (i) => Obx(() {
                              final isSelected = tabController.currentIndex.value == i;
                              final item = tabController.tabList[i];

                              return LongPressDraggable<int>(
                                data: i,
                                axis: Axis.horizontal,
                                onDragStarted: () => tabController.draggingIndex.value = i,
                                onDraggableCanceled: (_, __) => tabController.draggingIndex.value = -1,
                                onDragCompleted: () => tabController.draggingIndex.value = -1,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        item.icon,
                                        const SizedBox(width: 8),
                                        Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                child: DragTarget<int>(
                                  onWillAcceptWithDetails: (_) => true,
                                  onAcceptWithDetails: (details) {
                                    tabController.moveTab(details.data, i);
                                  },
                                  builder: (context, _, __) {
                                    return InkWell(
                                      onTap: () {
                                        tabController.currentIndex.value = i;
                                      },
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.only(right: 4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.surface : Colors.transparent,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                          border: isSelected
                                              ? Border.all(color: AppColors.borderLight, width: 1)
                                              : null,
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconTheme(
                                                    data: IconThemeData(
                                                      size: 15,
                                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                                    ),
                                                    child: item.icon,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    item.label,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  InkWell(
                                                    borderRadius: BorderRadius.circular(10),
                                                    onTap: () => tabController.removeTab(i),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(2.0),
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        size: 14,
                                                        color: isSelected ? AppColors.textSecondary : AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 2.5,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Active Tab Content or Dashboard
                Expanded(
                  child: Obx(() {
                    if (tabController.tabList.isNotEmpty) {
                      return IndexedStack(
                        key: const ValueKey('tab_stack'),
                        index: tabController.currentIndex.value,
                        children: tabController.tabList.map((tab) => tab.view).toList(),
                      );
                    }

                    if (defaultController.enabledAdvancedDashboard.value) {
                      return const AdvancedDashboard();
                    }

                    // Modern Welcome Empty State
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SvgPicture.asset(
                              "assets/images/logo.svg",
                              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Shakti Trading ERP',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select a module from the top navigation bar to begin data entry.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildQuickActionButton(
                                icon: Icons.shopping_bag_outlined,
                                label: 'Purchase Entry',
                                onTap: () => _openTab('Purchase', Icons.shopping_bag_rounded, const PurchaseFormScreen(showHeader: false)),
                              ),
                              _buildQuickActionButton(
                                icon: Icons.category_outlined,
                                label: 'Rough Assort',
                                onTap: () => _openTab('Rough Assort', Icons.category_rounded, const RoughAssortFormScreen(showHeader: false)),
                              ),
                              _buildQuickActionButton(
                                icon: Icons.sell_outlined,
                                label: 'Sale Entry',
                                onTap: () => _openTab('Sale', Icons.sell_rounded, const SaleFormScreen(showHeader: false)),
                              ),
                              _buildQuickActionButton(
                                icon: Icons.payment_outlined,
                                label: 'Payment Voucher',
                                onTap: () => _openTab('Payment', Icons.payment_rounded, const PaymentFormScreen(showHeader: false)),
                              ),
                              _buildQuickActionButton(
                                icon: Icons.account_balance_outlined,
                                label: 'Party Ledger',
                                onTap: () => _openTab('Party Ledger', Icons.account_balance_rounded, const PartyLedgerFormScreen(showHeader: false)),
                              ),
                              _buildQuickActionButton(
                                icon: Icons.receipt_long_outlined,
                                label: 'Reports',
                                onTap: () => _openTab('Reports', Icons.receipt_long_rounded, const ReportScreen(showHeader: false)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // Modern Sleek Status Bar
                _buildStatusBar(context),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
),
);
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.isInitialized ? ThemeController.to.isDarkMode.value : false;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Mobile Hamburger Button OR Desktop/Tablet Sidebar Toggle
          if (Responsive.isMobile(context))
            Builder(
              builder: (scaffoldContext) => IconButton(
                icon: Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                tooltip: 'Open Menu',
                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
              ),
            ),

          // Active Module / Tab Breadcrumb Badge
          Obx(() {
            final activeLabel = tabController.activeTabLabel;
            final isHome = tabController.tabList.isEmpty;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10),
                Obx(
                      () => Text(
                    '•  ${getCompanyName(defaultController.companyCode.value)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),

          const Spacer(),
          // Quick Light / Dark Mode Toggle Button
          Obx(() {
            final isDark = ThemeController.isInitialized
                ? ThemeController.to.isDarkMode.value
                : false;
            return Tooltip(
              message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              child: InkWell(
                onTap: () => ThemeController.to.toggleDarkMode(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                    size: 18,
                    color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
                  ),
                ),
              ),
            );
          }),

          // User Profile / Account Menu
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
            ),
            tooltip: 'Account & System Menu',
            onPressed: () => _showAccountMenu(context),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildStatusBar(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.isInitialized ? ThemeController.to.isDarkMode.value : false;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B1120) : const Color(0xFF0F172A),
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFF334155), width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 4),
              FutureBuilder<String?>(
                future: getUsername(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Admin',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ],
          ),
          if (!Responsive.isMobile(context)) ...[
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_done_outlined, color: Color(0xFF38BDF8), size: 14),
                const SizedBox(width: 4),
                Text(
                  defaultController.baseUrl.split('//').last.split('/').first,
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Shortcuts: Ctrl+B: Toggle Sidebar | Ctrl+W: Close Tab | Ctrl+Tab: Switch Tab',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            const Spacer(),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 12),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8), size: 12),
              const SizedBox(width: 4),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
    });
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppSidebar(
        isCollapsed: false,
        onToggleCollapse: _noopCollapse,
        isDrawer: true,
      ),
    );
  }

  static void _noopCollapse() {}

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.cardBg,
      side: BorderSide(color: AppColors.borderLight),
      onPressed: onTap,
    );
  }

  void _showProfileOptionsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppColors.isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.business_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getCompanyName(defaultController.companyCode.value),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getCompanyDetails(defaultController.companyCode.value).mobileno ?? '',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    getCompanyDetails(defaultController.companyCode.value).address ?? 'No Address',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                      onPressed: () {
                        if (tabController.tabList.isEmpty) {
                          _logout();
                          Get.back();
                        } else {
                          infoDialog(messageText: 'Please close all open tabs before logging out.');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    await defaultController.logout();
  }

  void _showAccountMenu(BuildContext context) async {
    final isDark = ThemeController.isInitialized
        ? ThemeController.to.isDarkMode.value
        : false;

    await showMenu(
      context: context,
      color: AppColors.cardBg,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.borderLight),
      ),
      position: const RelativeRect.fromLTRB(10, 50, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                defaultController.currentUserFullName.value.isNotEmpty
                    ? defaultController.currentUserFullName.value
                    : (defaultController.currentUserName.value.isNotEmpty
                        ? defaultController.currentUserName.value
                        : 'Admin'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                'Role: ${defaultController.currentUserGrp.value.isNotEmpty ? defaultController.currentUserGrp.value : "ADMIN"} • ${getCompanyName(defaultController.companyCode.value)}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.swap_horiz_rounded, size: 20),
            title: Text('Switch Company', style: TextStyle(fontSize: 13)),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showCompanySelectionDialog(isFromSwitchCompany: true);
            });
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_outline_rounded, size: 20),
            title: Text('Company Profile', style: TextStyle(fontSize: 13)),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                _showProfileOptionsDialog(context);
              }
            });
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.palette_outlined, size: 20),
            title: Text('Theme & Appearance', style: TextStyle(fontSize: 13)),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                showThemeStudioDialog(context);
              }
            });
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined, size: 20),
            title: Text('Settings', style: TextStyle(fontSize: 13)),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                showSettingsDialog(context);
              }
            });
          },
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
            title: Text('Log out', style: TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
          onTap: () {
            if (tabController.tabList.isEmpty) {
              _logout();
            } else {
              infoDialog(messageText: 'Please close all open tabs before logging out.');
            }
          },
        ),
      ],
    );
  }
}
