import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_datagrid.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_item_model.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_mst_model.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BranchTransferConfirmFormScreen extends StatefulWidget {
  final bool showHeader;

  const BranchTransferConfirmFormScreen({super.key, this.showHeader = false});

  @override
  BranchTransferConfirmFormScreenState createState() =>
      BranchTransferConfirmFormScreenState();
}

class BranchTransferConfirmFormScreenState
    extends State<BranchTransferConfirmFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmbranchtransferconfirmform',
        'frmbranchtransferconfirm',
        'frmstockconfirmform',
        'frmstockconfirm',
        'branch transfer confirm',
        'stock confirm',
      ]);
  final DefaultController defaultController = Get.find<DefaultController>();
  final TabControllerX _tabController = Get.isRegistered<TabControllerX>()
      ? Get.find<TabControllerX>()
      : Get.put(TabControllerX());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchFromDateController =
      TextEditingController();
  final TextEditingController _searchToDateController =
      TextEditingController();

  DateTime? _searchFromDate;
  DateTime? _searchToDate;
  final RxBool _isDateFiltered = false.obs;

  // Search view toggle
  bool _isSearch = false;

  // Focus Nodes
  final FocusNode _toManagerFocus = FocusNode();
  final FocusNode _addFocus = FocusNode();
  final FocusNode _saveFocus = FocusNode();

  // Selected State
  final Rx<int?> _selectedToManagerId = Rx<int?>(null);
  int? get selectedToManagerId => _selectedToManagerId.value;

  // Form State
  bool _isEnabled = false;
  bool _isFromView = false;
  bool get isEnabled => _isEnabled;
  bool get isFromView => _isFromView;

  final RxBool _isLoadingUsers = false.obs;

  // Table items & DataGridSource
  final List<BranchTransferConfirmItemModel> _allItems = [];
  final List<BranchTransferConfirmItemModel> _displayItems = [];
  late BranchTransferConfirmDataGridSource _gridSource;
  final DataGridController _dataGridController = DataGridController();

  bool get isCurrentUserTypeUser {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'USER' || !defaultController.isAdmin;
  }

  bool get isCurrentUserTypeAdmin {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'ADMIN' || grp == 'SUPERADMIN' || defaultController.isAdmin;
  }

  @override
  void initState() {
    super.initState();

    _gridSource = BranchTransferConfirmDataGridSource(
      initialItems: _displayItems,
      isEnabled: _isEnabled,
      showCheckbox: true,
      onRowChanged: (_) {
        if (mounted) setState(() {});
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadMasterData();

      if (defaultController.userModelList.isEmpty) {
        _isLoadingUsers.value = true;
        await defaultController.getUserData();
        _isLoadingUsers.value = false;
      }
    });
  }

  void _loadMasterData() {
    if (defaultController.roughModel.isEmpty) {
      defaultController.getRoughData();
    }
    if (defaultController.polishTypeModelList.isEmpty) {
      defaultController.getPolishTypeData();
    }
    if (defaultController.qualityModelList.isEmpty) {
      defaultController.getQualityData();
    }
    if (defaultController.charniModelList.isEmpty) {
      defaultController.getCharniData();
    }
    if (defaultController.shapeModelList.isEmpty) {
      defaultController.getShapeData();
    }
    if (defaultController.colorModelList.isEmpty) {
      defaultController.getColorData();
    }
    if (defaultController.clarityModelList.isEmpty) {
      defaultController.getClarityData();
    }
  }

  void _clearTableItems() {
    _allItems.clear();
    _applyTableFilter();
  }

  /// Fetch pending transfer details for the selected manager via GET /branch-transfer/details/<toCrId>
  Future<void> _loadDetailsForManager(dynamic toCrId) async {
    if (toCrId == null || toCrId == 0) {
      _clearTableItems();
      return;
    }
    final list =
        await defaultController.getBranchTransferConfirmDetails(toCrId);
    _allItems.clear();
    if (list.isNotEmpty) {
      for (var item in list) {
        item.isSelected = false;
      }
      _allItems.addAll(list);
    }
    _applyTableFilter();
  }

  void _applyTableFilter() {
    final query = _searchController.text.trim().toLowerCase();
    _displayItems.clear();
    if (query.isEmpty) {
      _displayItems.addAll(_allItems);
    } else {
      _displayItems.addAll(
        _allItems.where((item) {
          final type = item.resolveTypeName().toLowerCase();
          final inv = (item.invoiceNo ?? '').toLowerCase();
          final src = item.source.toLowerCase();
          final quality = item.resolveQualityName().toLowerCase();
          final charni = item.resolveCharniName().toLowerCase();
          final shape = item.resolveShapeName().toLowerCase();
          final color = item.resolveColorName().toLowerCase();
          final clarity = item.resolveClarityName().toLowerCase();

          return type.contains(query) ||
              inv.contains(query) ||
              src.contains(query) ||
              quality.contains(query) ||
              charni.contains(query) ||
              shape.contains(query) ||
              color.contains(query) ||
              clarity.contains(query);
        }),
      );
    }
    if (mounted) {
      _gridSource.updateItems(_displayItems);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFromDateController.dispose();
    _searchToDateController.dispose();
    _toManagerFocus.dispose();
    _addFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  List<UserModel> get toManagerUsers {
    List<UserModel> list = [];
    if (isCurrentUserTypeUser && !_isFromView) {
      final currentUserId = defaultController.currentUserId.value;
      list = defaultController.userModelList
          .where((u) => u.counterMstId == currentUserId)
          .toList();
      if (list.isEmpty) list = List.from(defaultController.userModelList);
    } else {
      final adminBranch = defaultController.effectiveBranchCode;
      if (adminBranch > 0 && !_isFromView) {
        list = defaultController.userModelList
            .where((u) => u.branchCode == adminBranch)
            .toList();
        if (list.isEmpty) list = List.from(defaultController.userModelList);
      } else {
        list = List.from(defaultController.userModelList);
      }
    }

    final selectedId = _selectedToManagerId.value;
    if (selectedId != null && !list.any((u) => u.counterMstId == selectedId)) {
      final existing = defaultController.userModelList
          .firstWhereOrNull((u) => u.counterMstId == selectedId);
      if (existing != null) {
        list.add(existing);
      } else {
        list.add(UserModel(
            counterMstId: selectedId, userName: 'Manager #$selectedId'));
      }
    }
    return list;
  }

  List<DropdownMenuItem<int>> _buildToManagerDropdownItems() {
    return toManagerUsers.where((u) => u.counterMstId != null).map((u) {
      final name = (u.userName != null && u.userName!.trim().isNotEmpty)
          ? u.userName!.trim()
          : (u.loginName ?? 'User #${u.counterMstId}');
      return DropdownMenuItem<int>(
        value: u.counterMstId,
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      );
    }).toList();
  }

  List<AppDropdownItem<int>> _buildToManagerAppDropdownItems() {
    return toManagerUsers.where((u) => u.counterMstId != null).map((u) {
      final name = (u.userName != null && u.userName!.trim().isNotEmpty)
          ? u.userName!.trim()
          : (u.loginName ?? 'User #${u.counterMstId}');
      final subtitle = (u.loginName != null &&
              u.loginName!.isNotEmpty &&
              u.userName != null &&
              u.userName!.isNotEmpty)
          ? 'Login: ${u.loginName}'
          : null;
      return AppDropdownItem<int>(
        value: u.counterMstId!,
        label: name,
        subtitle: subtitle,
        icon: const Icon(Icons.person_pin_rounded, size: 16),
      );
    }).toList();
  }

  /// Action button: Add
  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    setState(() {
      _isEnabled = true;
      _isFromView = false;
      _isSearch = false;
      _selectedToManagerId.value = null;
      _clearTableItems();
    });

    _gridSource.setShowCheckbox(true);
    _gridSource.setEnabled(true);

    // If logged-in user is a normal user, auto-select their ID and fetch
    if (isCurrentUserTypeUser) {
      final currentUserId = defaultController.currentUserId.value;
      if (currentUserId > 0) {
        _selectedToManagerId.value = currentUserId;
        _loadDetailsForManager(currentUserId);
      }
    }

    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _toManagerFocus.requestFocus();
        }
      });
    }
  }

  /// Action button: Cancel
  void _handleCancel() {
    setState(() {
      _isEnabled = false;
      _isFromView = false;
      _isSearch = false;
      _selectedToManagerId.value = null;
      _clearTableItems();
    });
    _gridSource.setShowCheckbox(true);
    _gridSource.setEnabled(false);
    _gridSource.toggleSelectAll(false);
  }

  /// Load a confirmed transfer by its ID from search list
  /// Load a confirmed transfer by its ID from search list via GET /branch-transfer/confirm/details/<confirmMstId>
  Future<void> _loadConfirmedTransferById(dynamic confirmMstId) async {
    if (confirmMstId == null || confirmMstId.toString().trim().isEmpty) return;

    final cleanId = confirmMstId.toString().trim();
    final BranchTransferConfirmMstModel? mst =
        defaultController.branchTransferConfirmList.firstWhereOrNull(
      (m) =>
          m.branchTransferConfirmMstID?.toString() == cleanId,
    );

    final details =
        await defaultController.getBranchTransferConfirmDetailsById(
      cleanId,
      toCrId: mst?.toCrId,
    );

    setState(() {
      _isSearch = false;
      _isFromView = true;
      _isEnabled = false;
      _selectedToManagerId.value = mst?.toCrId ??
          (details.isNotEmpty ? details.first.toCrId : null);

      _allItems.clear();
      _displayItems.clear();
      _allItems.addAll(details);
      _displayItems.addAll(details);

      _gridSource.setShowCheckbox(false);
      _gridSource.setEnabled(false);
      _gridSource.updateItems(_displayItems);
    });
  }

  /// Action button: Save
  Future<void> _handleSave() async {
    if (!_rights.canSave(false)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;

    if (_selectedToManagerId.value == null) {
      infoDialog(messageText: 'Please select To Manager');
      return;
    }

    final selectedItems = _allItems.where((i) => i.isSelected).toList();
    if (selectedItems.isEmpty) {
      infoDialog(
        messageText: 'Please select at least one item to confirm transfer.',
      );
      return;
    }

    final detailIds = selectedItems
        .map((i) => i.branchTransferDetID)
        .whereType<int>()
        .toList();

    if (detailIds.isEmpty) {
      infoDialog(
        messageText:
            'Selected items have no valid detail ID to confirm. Please check records.',
      );
      return;
    }

    final success = await defaultController.saveBranchTransferConfirm(
      managerId: _selectedToManagerId.value!,
      detailIds: detailIds,
    );

    if (success) {
      setState(() {
        _isEnabled = false;
        _isFromView = false;
        _selectedToManagerId.value = null;
        _clearTableItems();
      });
      _gridSource.setShowCheckbox(true);
      _gridSource.setEnabled(false);
      _gridSource.toggleSelectAll(false);
    }
  }

  void _exitScreen() {
    _tabController.closeCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (widget.showHeader)
            Header(
              title: _isSearch
                  ? 'Branch Transfer Confirm Search'
                  : 'Branch Transfer Confirm',
            ),
          Expanded(
            child: _isSearch ? _buildSearchView() : _buildFormView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 10 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Form Card with only one field: To Manager
            _buildFormCard(),
            const SizedBox(height: 10),

            // DataTable Card
            Expanded(
              child: _buildDataTableCard(),
            ),
            const SizedBox(height: 10),

            // Action buttons row at the bottom
            _buildActionButtonsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'BRANCH TRANSFER CONFIRM INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 768;

                final toManagerField = Obx(
                  () => AppDropdown<int>(
                    label: 'To Manager',
                    value: _selectedToManagerId.value,
                    items: _buildToManagerDropdownItems(),
                    dropdownItems: _buildToManagerAppDropdownItems(),
                    focusNode: _toManagerFocus,
                    isEnabled: _isEnabled && !_isFromView,
                    hintText: 'Select To Manager',
                    searchHint: 'Search manager...',
                    prefixIcon:
                        const Icon(Icons.person_pin_rounded, size: 16),
                    onChanged: (val) {
                      _selectedToManagerId.value = val;
                      if (val != null && val > 0) {
                        _loadDetailsForManager(val);
                      } else {
                        _clearTableItems();
                      }
                    },
                  ),
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 320,
                        child: toManagerField,
                      ),
                    ],
                  );
                } else {
                  return toManagerField;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!_isEnabled)
              AppButton(
                text: 'Add',
                icon: Icons.add_circle_outline_rounded,
                focusNode: _addFocus,
                onPressed: () => _enableFields(),
              ),
            if (_isEnabled)
              Obx(
                () => AppButton(
                  text: 'Save',
                  icon: Icons.save_rounded,
                  focusNode: _saveFocus,
                  isLoading:
                      defaultController.isSavingBranchTransferConfirm.value,
                  onPressed: _handleSave,
                ),
              ),
            if (_isEnabled || _isFromView)
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.outline,
                icon: Icons.cancel_outlined,
                onPressed: _handleCancel,
              ),
            AppButton(
              text: 'Search',
              variant: AppButtonVariant.secondary,
              icon: Icons.search_rounded,
              onPressed: () {
                setState(() {
                  _isSearch = true;
                });
                defaultController.getBranchTransferConfirmList(force: true);
              },
            ),
            AppButton(
              text: 'Exit',
              variant: AppButtonVariant.secondary,
              icon: Icons.exit_to_app_rounded,
              onPressed: _exitScreen,
            ),
          ],
        ),
      ),
    );
  }

  List<GridColumn> _buildGridColumns() {
    return [
      // 1. Checkbox Select Column
      if (_gridSource.showCheckbox)
        GridColumn(
          columnName: 'select',
          width: 48,
          allowSorting: false,
          allowFiltering: false,
          label: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _gridSource.isAllSelected
                    ? true
                    : (_gridSource.hasSomeSelected ? null : false),
                tristate: true,
                activeColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
                onChanged: _isEnabled
                    ? (val) {
                        _gridSource.toggleSelectAll(val ?? false);
                        setState(() {});
                      }
                    : null,
              ),
            ),
          ),
        ),

      // 2. Source (Rough / Polish)
      AppDataGrid.buildColumn(
        columnName: 'source',
        labelText: 'Source',
        width: 75,
        alignment: Alignment.center,
      ),

      // 3. Type
      AppDataGrid.buildColumn(
        columnName: 'type',
        labelText: 'Type',
        width: 130,
        alignment: Alignment.centerLeft,
      ),

      // 4. Inv No
      AppDataGrid.buildColumn(
        columnName: 'invoiceNo',
        labelText: 'Inv No',
        width: 85,
        alignment: Alignment.centerLeft,
      ),

      // 5. Quality
      AppDataGrid.buildColumn(
        columnName: 'quality',
        labelText: 'Quality',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 6. Charni
      AppDataGrid.buildColumn(
        columnName: 'charni',
        labelText: 'Charni',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 7. Shape
      AppDataGrid.buildColumn(
        columnName: 'shape',
        labelText: 'Shape',
        width: 90,
        alignment: Alignment.centerLeft,
      ),

      // 8. Color
      AppDataGrid.buildColumn(
        columnName: 'color',
        labelText: 'Color',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 9. Clarity
      AppDataGrid.buildColumn(
        columnName: 'clarity',
        labelText: 'Clarity',
        alignment: Alignment.centerLeft,
      ),

      // 10. Rate $
      AppDataGrid.buildColumn(
        columnName: 'rateDollar',
        labelText: 'Rate \$',
        width: 90,
        alignment: Alignment.centerRight,
      ),

      // 11. Rate Rs
      AppDataGrid.buildColumn(
        columnName: 'rateRs',
        labelText: 'Rate ₹',
        alignment: Alignment.centerRight,
      ),

      // 12. Amount $
      AppDataGrid.buildColumn(
        columnName: 'amtDollar',
        labelText: 'Amount \$',
        alignment: Alignment.centerRight,
      ),

      // 13. Amount Rs
      AppDataGrid.buildColumn(
        columnName: 'amtRs',
        labelText: 'Amount ₹',
        alignment: Alignment.centerRight,
      ),

      // 14. Stock Pc
      AppDataGrid.buildColumn(
        columnName: 'stockPc',
        labelText: 'Stock Pc',
        width: 100,
        alignment: Alignment.centerRight,
      ),

      // 15. Stock Wt
      AppDataGrid.buildColumn(
        columnName: 'stockWt',
        labelText: 'Stock Wt',
        width: 100,
        alignment: Alignment.centerRight,
      ),

      // 16. Iss Pc
      AppDataGrid.buildColumn(
        columnName: 'issuePc',
        labelText: 'Iss Pc',
        width: 80,
        alignment: Alignment.centerRight,
      ),

      // 17. Iss Wt
      AppDataGrid.buildColumn(
        columnName: 'issueWt',
        labelText: 'Iss Wt',
        width: 90,
        alignment: Alignment.centerRight,
      ),

      // 18. Iss Rate
      AppDataGrid.buildColumn(
        columnName: 'issueRate',
        labelText: 'Iss Rate',
        alignment: Alignment.centerRight,
      ),

      // 19. Iss Amt
      AppDataGrid.buildColumn(
        columnName: 'issueAmt',
        labelText: 'Iss Amt',
        alignment: Alignment.centerRight,
      ),

      // 20. Diff Wt
      AppDataGrid.buildColumn(
        columnName: 'diffWt',
        labelText: 'Diff Wt',
        width: 85,
        alignment: Alignment.centerRight,
      ),

      // 21. Diff Rate
      AppDataGrid.buildColumn(
        columnName: 'diffRate',
        labelText: 'Diff Rate',
        width: 95,
        alignment: Alignment.centerRight,
      ),

      // 22. Diff Amt
      AppDataGrid.buildColumn(
        columnName: 'diffAmt',
        labelText: 'Diff Amt',
        width: 95,
        alignment: Alignment.centerRight,
      ),
    ];
  }

  Widget _buildDataTableCard() {
    final selectedCount = _allItems.where((i) => i.isSelected).length;
    final totalStockPc = _allItems.fold(0, (sum, i) => sum + i.stockPc);
    final totalStockWt = _allItems.fold(0.0, (sum, i) => sum + i.stockWt);
    final totalIssuePc = _allItems.fold(0, (sum, i) => sum + i.issuePc);
    final totalIssueWt = _allItems.fold(0.0, (sum, i) => sum + i.issueWt);
    final totalIssueAmt = _allItems.fold(0.0, (sum, i) => sum + i.issueAmt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Controls Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TRANSFER DETAILS TO CONFIRM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_displayItems.length} items',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Search Filter Box
                        SizedBox(
                          width: isCompact ? 160 : 220,
                          height: 32,
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search items...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 16),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        _searchController.clear();
                                        _applyTableFilter();
                                      },
                                      child: const Icon(Icons.clear, size: 14),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.primary),
                              ),
                            ),
                            onChanged: (_) => _applyTableFilter(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Refresh button
                        InkWell(
                          onTap: () {
                            if (_selectedToManagerId.value != null &&
                                _selectedToManagerId.value! > 0) {
                              _loadDetailsForManager(
                                _selectedToManagerId.value,
                              );
                            } else {
                              infoDialog(
                                messageText:
                                    'Please select To Manager first to load items',
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 15,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reload',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),

          // The Data Grid Table
          Expanded(
            child: Obx(() {
              final isLoading = defaultController
                  .isLoadingBranchTransferConfirmDetails.value;
              final hasManager = _selectedToManagerId.value != null &&
                  _selectedToManagerId.value! > 0;

              return Stack(
                children: [
                  AppDataGrid(
                    controller: _dataGridController,
                    source: _gridSource,
                    columns: _buildGridColumns(),
                    rowHeight: 25,
                    headerRowHeight: 25,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    showSortNumbers: false,
                    allowFiltering: true,
                    allowColumnsResizing: true,
                    selectionMode: SelectionMode.none,
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        showSummaryInRow: false,
                        position: GridTableSummaryRowPosition.bottom,
                        columns: const <GridSummaryColumn>[
                          GridSummaryColumn(
                            name: 'total_title',
                            columnName: 'source',
                            summaryType: GridSummaryType.count,
                          ),
                          GridSummaryColumn(
                            name: 'stockPc_sum',
                            columnName: 'stockPc',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'stockWt_sum',
                            columnName: 'stockWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'amtDollar_sum',
                            columnName: 'amtDollar',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'amtRs_sum',
                            columnName: 'amtRs',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issuePc_sum',
                            columnName: 'issuePc',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issueWt_sum',
                            columnName: 'issueWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issueAmt_sum',
                            columnName: 'issueAmt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'diffWt_sum',
                            columnName: 'diffWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'diffAmt_sum',
                            columnName: 'diffAmt',
                            summaryType: GridSummaryType.sum,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.white.withValues(alpha: 0.65),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Loading transfer details...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!hasManager)
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 48,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Select "To Manager" to load transfer records',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_displayItems.isEmpty)
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No transfer records found for selected manager',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),

          // Bottom Summary Stat Bar
          Divider(height: 1, color: AppColors.borderLight),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: selectedCount > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Selected: $selectedCount of ${_allItems.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedCount > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildQuickStat(
                      'Stock',
                      '$totalStockPc Pc | ${totalStockWt.toStringAsFixed(3)} Wt',
                    ),
                    _buildQuickStat(
                      'Issue',
                      '$totalIssuePc Pc | ${totalIssueWt.toStringAsFixed(3)} Wt',
                      highlight: true,
                    ),
                    _buildQuickStat(
                      'Issue Amt',
                      '₹${NumberFormat('#,##0.00').format(totalIssueAmt)}',
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value,
      {bool highlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        // Top Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: AppTextField(
                  label: 'From Date :',
                  controller: _searchFromDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchFromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _searchFromDate = picked;
                        _searchFromDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: AppTextField(
                  label: 'To :',
                  controller: _searchToDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchToDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _searchToDate = picked;
                        _searchToDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Show',
                icon: Icons.filter_alt_rounded,
                onPressed: () {
                  setState(() {
                    _isDateFiltered.value = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Clear Filter',
                variant: AppButtonVariant.outline,
                icon: Icons.clear_all_rounded,
                onPressed: () {
                  setState(() {
                    _searchFromDate = null;
                    _searchToDate = null;
                    _searchFromDateController.clear();
                    _searchToDateController.clear();
                    _isDateFiltered.value = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Refresh',
                variant: AppButtonVariant.outline,
                icon: Icons.refresh_rounded,
                onPressed: () => defaultController
                    .getBranchTransferConfirmList(force: true),
              ),
              const Spacer(),
              AppButton(
                text: 'Back to Form',
                variant: AppButtonVariant.secondary,
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  setState(() {
                    _isSearch = false;
                  });
                },
              ),
            ],
          ),
        ),

        // Search Data Grid
        Expanded(
          child: Obx(() {
            if (defaultController.isLoadingBranchTransferConfirmList.value) {
              return const Center(child: CircularProgressIndicator());
            }

            var list = defaultController.branchTransferConfirmList;
            if (_isDateFiltered.value) {
              list = list.where((item) {
                if (item.createdAt == null) return false;
                final dt = DateTime.tryParse(item.createdAt!);
                if (dt == null) return true;
                if (_searchFromDate != null &&
                    dt.isBefore(_searchFromDate!)) {
                  return false;
                }
                if (_searchToDate != null &&
                    dt.isAfter(
                        _searchToDate!.add(const Duration(days: 1)))) {
                  return false;
                }
                return true;
              }).toList().obs;
            }

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'No branch transfer confirm records found.',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            final searchSource = BranchTransferConfirmSearchDataGridSource(
              list: list,
              onSelect: (item) => _loadConfirmedTransferById(
                  item.branchTransferConfirmMstID),
              onDoubleTap: (item) => _loadConfirmedTransferById(
                  item.branchTransferConfirmMstID),
            );

            return AppDataGrid(
              source: searchSource,
              columns: _buildSearchGridColumns(),
              allowSorting: true,
              allowFiltering: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              onCellDoubleTap: (details) {
                if (details.rowColumnIndex.rowIndex <= 0) return;
                final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                final rows = searchSource.effectiveRows;
                if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                  final row = rows[dataRowIndex];
                  final idCell = row
                      .getCells()
                      .firstWhereOrNull((c) => c.columnName == 'ID');
                  if (idCell?.value != null) {
                    _loadConfirmedTransferById(idCell!.value);
                  }
                }
              },
            );
          }),
        ),
      ],
    );
  }

  List<GridColumn> _buildSearchGridColumns() {
    return [
      GridColumn(
        columnName: 'ID',
        width: 100,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'Date',
        width: 160,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Created Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'ManagerName',
        width: 220,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('To Manager',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'ToCrId',
        width: 120,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Manager ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    ];
  }
}
