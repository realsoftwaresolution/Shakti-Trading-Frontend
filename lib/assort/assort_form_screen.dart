import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/assort/assort_datagrid.dart';
import 'package:real_web_rough_entry_system/assort/assort_model.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AssortFormScreen extends StatefulWidget {
  final bool showHeader;

  const AssortFormScreen({super.key, required this.showHeader});

  @override
  AssortFormScreenState createState() => AssortFormScreenState();
}

class AssortFormScreenState extends State<AssortFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'assort master',
        'frmassortform',
      ]);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sortIdController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _groupFocusNode = FocusNode();
  final FocusNode _sortIdFocusNode = FocusNode();

  final DataGridController _dataGridController = DataGridController();

  final RxString _selectedTypeGroup = ''.obs;
  final RxInt selectedAssortMstID = 0.obs;

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;

  final DefaultController defaultController = Get.find<DefaultController>();
  final RxList<AssortMst> assortDataGridSource = <AssortMst>[].obs;
  Worker? _listWorker;

  @override
  void initState() {
    super.initState();
    assortDataGridSource.value = defaultController.assortMstList;

    _listWorker = ever(defaultController.assortMstList, (list) {
      if (mounted) {
        assortDataGridSource.value = list;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getAssortGroupData(force: true);
      defaultController.getAssortData(force: true);
    });
  }

  @override
  void dispose() {
    _listWorker?.dispose();
    nameController.dispose();
    sortIdController.dispose();
    searchController.dispose();
    _nameFocus.dispose();
    _groupFocusNode.dispose();
    _sortIdFocusNode.dispose();
    super.dispose();
  }

  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      nameController.clear();
      sortIdController.clear();
      _selectedTypeGroup.value = '';
    });
    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _nameFocus.requestFocus();
      });
    }
  }

  Future<void> _saveAssort() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;
    if (nameController.text.trim().isEmpty) {
      infoDialog(messageText: 'Please enter Assort Name');
      _nameFocus.requestFocus();
      return;
    }
    if (_selectedTypeGroup.value.isEmpty) {
      infoDialog(messageText: 'Please select Assort Group');
      _groupFocusNode.requestFocus();
      return;
    }

    if (_isFromEdit) {
      await defaultController.updateAssortData(
        id: selectedAssortMstID.value,
        name: nameController.text.trim(),
        sortId: sortIdController.text.trim(),
        group: _selectedTypeGroup.value,
      );
    } else {
      await defaultController.addAssortData(
        name: nameController.text.trim(),
        sortId: sortIdController.text.trim(),
        group: _selectedTypeGroup.value,
      );
    }

    await defaultController.getAssortData(force: true);
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      nameController.clear();
      sortIdController.clear();
      _selectedTypeGroup.value = '';
      assortDataGridSource.value = defaultController.assortMstList;
    });
  }

  Future<void> _deleteAssort() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit || selectedAssortMstID.value == 0) return;
    await defaultController.deleteAssortData(id: selectedAssortMstID.value);
    await defaultController.getAssortData(force: true);
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      nameController.clear();
      sortIdController.clear();
      _selectedTypeGroup.value = '';
      assortDataGridSource.value = defaultController.assortMstList;
    });
  }

  void _cancel() {
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      nameController.clear();
      sortIdController.clear();
      _selectedTypeGroup.value = '';
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (_isSearch) {
        assortDataGridSource.value = defaultController.assortMstList;
        searchController.clear();
      }
    });
  }

  void _filterSearch(String query) {
    if (query.trim().isEmpty) {
      assortDataGridSource.value = defaultController.assortMstList;
    } else {
      final q = query.toLowerCase();
      assortDataGridSource.value = defaultController.assortMstList.where((a) {
        final name = (a.name ?? '').toLowerCase();
        final group = (a.assortGroup ?? '').toLowerCase();
        return name.contains(q) || group.contains(q);
      }).toList();
    }
  }

  void _selectAssortFromRow(DataGridRow row) {
    final id = row.getCells().first.value as int?;
    if (id == null) return;

    final entry = defaultController.assortMstList.firstWhere(
      (e) => e.assortMstID == id,
      orElse: () => AssortMst(),
    );

    if (entry.assortMstID != null) {
      selectedAssortMstID.value = entry.assortMstID!;
      nameController.text = entry.name ?? '';
      sortIdController.text = entry.sortID?.toString() ?? '';
      _selectedTypeGroup.value = entry.assortGroup ?? '';
      setState(() {
        _isFromEdit = true;
        _isEnabled = true;
        _isSearch = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _nameFocus.requestFocus();
      });
    }
  }

  void _exitScreen() {
    tabController.removeTab(tabController.currentIndex.value);
  }

  List<DropdownMenuItem<String>> get dropdownItemsAssortGroup {
    return defaultController.assortGroupMstList
        .map((group) {
          return DropdownMenuItem<String>(
            value: group.name ?? '',
            child: Text(group.name ?? ''),
          );
        })
        .toList()
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = AppColors.isDark;
      return AppKeyboardShortcutHandler(
        onAdd: _enableFields,
        onSave: _saveAssort,
        onDelete: _isFromEdit ? _deleteAssort : null,
        onCancel: _cancel,
        onSearch: _toggleSearch,
        onExit: _exitScreen,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) Header(title: _isSearch ? 'Assort Directory Search' : 'Assort Master'),
              Expanded(
                child: _isSearch ? _buildSearchView() : _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(),
              const SizedBox(height: 12),
              _buildActionBar(),
              const SizedBox(height: 12),
              _buildQuickDirectoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Assort Master Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_isFromEdit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Text(
                    'EDIT MODE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 24, color: AppColors.borderLight),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: 'Assort Name *',
                  controller: nameController,
                  focusNode: _nameFocus,
                  enabled: _isEnabled,
                  hintText: 'e.g. 4-8, +11, MAKABLE',
                  onFieldSubmitted: (_) => _groupFocusNode.requestFocus(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Obx(
                  () => AppDropdown<String>(
                    key: ValueKey(_selectedTypeGroup.value),
                    label: 'Assort Group *',
                    value: _selectedTypeGroup.value.isEmpty ? null : _selectedTypeGroup.value,
                    focusNode: _groupFocusNode,
                    isEnabled: _isEnabled,
                    hintText: 'Select Group...',
                    items: dropdownItemsAssortGroup,
                    onChanged: (val) {
                      _selectedTypeGroup.value = val ?? '';
                      _sortIdFocusNode.requestFocus();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Sort ID',
                  controller: sortIdController,
                  focusNode: _sortIdFocusNode,
                  enabled: _isEnabled,
                  hintText: 'Order index',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (_) => _saveAssort(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (!_isEnabled)
            AppButton(
              text: 'Add',
              icon: Icons.add_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _enableFields,
            ),
          if (_isEnabled) ...[
            AppButton(
              text: _isFromEdit ? 'Update' : 'Save',
              icon: Icons.save_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _saveAssort,
            ),
            const SizedBox(width: 8),
            if (_isFromEdit) ...[
              AppButton(
                text: 'Delete',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                onPressed: _deleteAssort,
              ),
              const SizedBox(width: 8),
            ],
            AppButton(
              text: 'Cancel',
              icon: Icons.clear_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _cancel,
            ),
            const SizedBox(width: 8),
          ],
          AppButton(
            text: 'Search',
            icon: Icons.search_rounded,
            variant: AppButtonVariant.outline,
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Exit',
            icon: Icons.close_rounded,
            variant: AppButtonVariant.danger,
            onPressed: _exitScreen,
          ),
          const Spacer(),
          Obx(() {
            final isLoading = defaultController.isLoading.value || defaultController.isDeleteLoading.value;
            if (isLoading) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(radius: 8),
                  const SizedBox(width: 8),
                  Text('Processing...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildQuickDirectoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Existing Assort Items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    'Total: ${defaultController.assortMstList.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          SizedBox(
            height: 300,
            child: Obx(
              () => AppDataGrid(
                controller: _dataGridController,
                source: AssortDataGridSource(assortDataGridSource),
                columnWidthMode: ColumnWidthMode.fill,
                rowHeight: 28,
                headerRowHeight: 34,
                allowSorting: true,
                allowMultiColumnSorting: true,
                showSortNumbers: true,
                allowFiltering: true,
                allowColumnsResizing: true,
                selectionMode: SelectionMode.single,
                // Clicking the row that is already selected does not fire
                // onSelectionChanged, so load that row again here.
                onCellTap: (details) {
                  final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                  final selected = _dataGridController.selectedRow;
                  if (dataRowIndex >= 0 &&
                      selected != null &&
                      _dataGridController.selectedIndex == dataRowIndex) {
                    _selectAssortFromRow(selected);
                  }
                },
                onSelectionChanged: (addedRows, _) {
                  if (addedRows.isNotEmpty) {
                    _selectAssortFromRow(addedRows.first);
                  }
                },
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'ID',
                    visible: false,
                    label: _gridHeader('ID'),
                  ),
                  GridColumn(
                    columnName: 'Name',
                    label: _gridHeader('Assort Name', alignment: Alignment.centerLeft),
                  ),
                  GridColumn(
                    columnName: 'Group',
                    label: _gridHeader('Group', alignment: Alignment.centerLeft),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Search Assort Directory',
                    controller: searchController,
                    hintText: 'Type to filter by name or group...',
                    prefixIcon: Icon(Icons.search_rounded, size: 16, color: AppColors.textMuted),
                    onChanged: _filterSearch,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              searchController.clear();
                              _filterSearch('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  text: 'Back to Form',
                  icon: Icons.arrow_back_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: _toggleSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Obx(
                  () => AppDataGrid(
                    controller: _dataGridController,
                    source: AssortDataGridSource(assortDataGridSource),
                    columnWidthMode: ColumnWidthMode.fill,
                    rowHeight: 30,
                    headerRowHeight: 36,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    showSortNumbers: true,
                    allowFiltering: true,
                    allowColumnsResizing: true,
                    selectionMode: SelectionMode.single,
                    // Clicking the row that is already selected does not fire
                    // onSelectionChanged, so load that row again here.
                    onCellTap: (details) {
                      final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                      final selected = _dataGridController.selectedRow;
                      if (dataRowIndex >= 0 &&
                          selected != null &&
                          _dataGridController.selectedIndex == dataRowIndex) {
                        _selectAssortFromRow(selected);
                      }
                    },
                    onSelectionChanged: (addedRows, _) {
                      if (addedRows.isNotEmpty) {
                        _selectAssortFromRow(addedRows.first);
                      }
                    },
                    columns: <GridColumn>[
                      GridColumn(
                        columnName: 'ID',
                        visible: false,
                        label: _gridHeader('ID'),
                      ),
                      GridColumn(
                        columnName: 'Name',
                        label: _gridHeader('Assort Name', alignment: Alignment.centerLeft),
                      ),
                      GridColumn(
                        columnName: 'Group',
                        label: _gridHeader('Group', alignment: Alignment.centerLeft),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridHeader(String label, {Alignment alignment = Alignment.center}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      alignment: alignment,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
