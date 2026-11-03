import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/charni/charni_datagrid.dart';
import 'package:real_web_rough_entry_system/charni/charni_model.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CharniFormScreen extends StatefulWidget {
  final bool showHeader;

  const CharniFormScreen({super.key, this.showHeader = false});

  @override
  CharniFormScreenState createState() => CharniFormScreenState();
}

class CharniFormScreenState extends State<CharniFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmcharniform',
        'charni',
      ]);
  final DefaultController defaultController = Get.find<DefaultController>();
  final DataGridController _dataGridController = DataGridController();

  // Controllers
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fromSizeController = TextEditingController();
  final TextEditingController _toSizeController = TextEditingController();
  final TextEditingController _sortIdController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _rptGroupFocus = FocusNode();
  final FocusNode _fromSizeFocus = FocusNode();
  final FocusNode _toSizeFocus = FocusNode();
  final FocusNode _sortIdFocus = FocusNode();

  // State
  final RxInt _selectedCharniCode = 0.obs;
  final RxInt _selectedCharniMstID = 0.obs;
  final Rx<int?> _selectedRptGroup = Rx<int?>(null);
  final RxBool _isActive = true.obs;
  bool _isEnabled = false;
  bool _isFromEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getCharniRptGroups();
      defaultController.getCharniData(companyCodeParam: defaultController.companyCode.value);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _fromSizeController.dispose();
    _toSizeController.dispose();
    _sortIdController.dispose();
    _nameFocus.dispose();
    _rptGroupFocus.dispose();
    _fromSizeFocus.dispose();
    _toSizeFocus.dispose();
    _sortIdFocus.dispose();
    super.dispose();
  }

  Future<void> _enableFields({bool needFocus = true}) async {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    int? defaultGroup;
    if (defaultController.charniRptGroupList.isNotEmpty) {
      defaultGroup = defaultController.charniRptGroupList.first.charniRptGroupCode ??
          defaultController.charniRptGroupList.first.charniRptGroupMstID;
    }

    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      _selectedCharniCode.value = 0;
      _selectedCharniMstID.value = 0;
      _selectedRptGroup.value = defaultGroup;
      _codeController.text = '';
      _nameController.clear();
      _fromSizeController.text = '0.000';
      _toSizeController.text = '0.000';
      _sortIdController.clear();
      _isActive.value = true;
    });

    try {
      final next = await defaultController.getNextCharniCode();
      if (next != null && mounted) {
        final dynamic nextCode =
            next['nextCharniCode'] ?? next['CharniCode'] ?? next['code'];
        final dynamic nextSort =
            next['nextSortID'] ?? next['SortID'] ?? next['sortId'];
        if (nextCode != null) {
          _codeController.text = nextCode.toString();
        }
        if (nextSort != null) {
          _sortIdController.text = nextSort.toString();
        }
      }
    } catch (_) {}

    if (needFocus && mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _nameFocus.requestFocus();
      });
    }
  }

  void _clearFormFields() {
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      _selectedCharniCode.value = 0;
      _selectedCharniMstID.value = 0;
      _selectedRptGroup.value = null;
      _codeController.clear();
      _nameController.clear();
      _fromSizeController.clear();
      _toSizeController.clear();
      _sortIdController.clear();
      _isActive.value = true;
    });
  }

  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;

    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      infoDialog(messageText: 'Please enter Charni Name');
      _nameFocus.requestFocus();
      return;
    }

    final double? fromSize = double.tryParse(_fromSizeController.text.trim());
    final double? toSize = double.tryParse(_toSizeController.text.trim());
    final int? sortId = int.tryParse(_sortIdController.text.trim());

    if (_isFromEdit) {
      final dynamic targetId = _selectedCharniCode.value != 0
          ? _selectedCharniCode.value
          : _selectedCharniMstID.value;

      if (targetId == 0 || targetId == null) {
        errorDialog(messageText: 'Unable to identify Charni record to update');
        return;
      }

      await defaultController.updateCharniData(
        id: targetId,
        name: name,
        rptGroup: _selectedRptGroup.value,
        fromSize: fromSize,
        toSize: toSize,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    } else {
      await defaultController.addCharniData(
        name: name,
        rptGroup: _selectedRptGroup.value,
        fromSize: fromSize,
        toSize: toSize,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    }
    await defaultController.getCharniData(companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit) return;

    final dynamic targetId = _selectedCharniCode.value != 0
        ? _selectedCharniCode.value
        : _selectedCharniMstID.value;

    if (targetId == 0 || targetId == null) return;

    await defaultController.deleteCharniData(
      id: targetId,
      companyCodeParam: defaultController.companyCode.value,
    );
    await defaultController.getCharniData(companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  void _loadFromRow(DataGridRow row) {
    final dynamic cellVal = row.getCells()[0].value;
    final item = defaultController.charniModelList.firstWhere(
      (entry) =>
          entry.charniCode == cellVal || entry.charniMstID == cellVal,
      orElse: () => CharniModel(),
    );

    final int code = item.charniCode ??
        item.charniMstID ??
        (cellVal is int ? cellVal : 0);
    if (code != 0) {
      _selectedCharniCode.value = item.charniCode ?? code;
      _selectedCharniMstID.value = item.charniMstID ?? code;
      _codeController.text = code.toString();
      _nameController.text = item.charniName ?? '';
      _selectedRptGroup.value = item.charniRptGroupCode ??
          item.rptGroup?.charniRptGroupCode ??
          item.rptGroup?.charniRptGroupMstID;
      _fromSizeController.text = item.fromSize != null
          ? item.fromSize!.toStringAsFixed(3)
          : '0.000';
      _toSizeController.text =
          item.toSize != null ? item.toSize!.toStringAsFixed(3) : '0.000';
      _sortIdController.text =
          item.sortID != null ? item.sortID.toString() : '';
      _isActive.value = item.active ?? true;

      setState(() {
        _isFromEdit = true;
        _isEnabled = true;
      });

      _nameFocus.requestFocus();
    }
  }

  void _exitScreen() {
    tabController.closeCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = AppColors.isDark;

      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: (_isEnabled || _isFromEdit) ? _clearFormFields : null,
        onExit: _exitScreen,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) const Header(title: 'Charni Master'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormCard(isDark),
                          const SizedBox(height: 12),
                          _buildActionBar(isDark),
                          const SizedBox(height: 14),
                          _buildDirectoryCard(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFormCard(bool isDark) {
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
              Icon(Icons.filter_vintage_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Charni Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_isFromEdit)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 700;

              // Widgets
              final codeWidget = SizedBox(
                width: isWide ? 90 : null,
                child: AppTextField(
                  label: 'Code',
                  controller: _codeController,
                  enabled: false,
                  hintText: 'Auto',
                ),
              );

              final nameWidget = AppTextField(
                label: 'Charni Name *',
                controller: _nameController,
                focusNode: _nameFocus,
                enabled: _isEnabled,
                hintText: 'e.g. 1 TO 2 CT, MIX',
                onFieldSubmitted: (_) => _rptGroupFocus.requestFocus(),
              );

              final rptGroupWidget = Obx(
                () => AppDropdown<int?>(
                  label: 'Rpt Group',
                  value: _selectedRptGroup.value,
                  focusNode: _rptGroupFocus,
                  isEnabled: _isEnabled,
                  hintText: 'Select Rpt Group...',
                  dropdownItems: defaultController.charniRptGroupList.map((g) {
                    final int? code =
                        g.charniRptGroupCode ?? g.charniRptGroupMstID;
                    final String name = g.charniRptGroupName ?? (code?.toString() ?? '-');
                    return AppDropdownItem<int?>(
                      value: code,
                      label: name,
                    );
                  }).toList(),
                  onChanged: (val) {
                    _selectedRptGroup.value = val;
                    _fromSizeFocus.requestFocus();
                  },
                ),
              );

              final fromSizeWidget = AppTextField(
                label: 'From Size',
                controller: _fromSizeController,
                focusNode: _fromSizeFocus,
                enabled: _isEnabled,
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onFieldSubmitted: (_) => _toSizeFocus.requestFocus(),
              );

              final toSizeWidget = AppTextField(
                label: 'To Size',
                controller: _toSizeController,
                focusNode: _toSizeFocus,
                enabled: _isEnabled,
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onFieldSubmitted: (_) => _sortIdFocus.requestFocus(),
              );

              final sortIdWidget = SizedBox(
                width: isWide ? 110 : null,
                child: AppTextField(
                  label: 'Sort ID',
                  controller: _sortIdController,
                  focusNode: _sortIdFocus,
                  enabled: _isEnabled,
                  hintText: 'e.g. 1',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (_) => _handleSave(),
                ),
              );

              final activeWidget = Obx(
                () => InkWell(
                  onTap: _isEnabled
                      ? () => _isActive.value = !_isActive.value
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isActive.value
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _isActive.value,
                          onChanged: _isEnabled
                              ? (val) => _isActive.value = val ?? true
                              : null,
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isEnabled
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (isWide) {
                return Column(
                  children: [
                    // Row 1: Code, Name, Rpt Group
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        codeWidget,
                        const SizedBox(width: 14),
                        Expanded(flex: 4, child: nameWidget),
                        const SizedBox(width: 14),
                        Expanded(flex: 3, child: rptGroupWidget),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Row 2: From Size, To Size, Sort ID, Active
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(flex: 2, child: fromSizeWidget),
                        const SizedBox(width: 14),
                        Expanded(flex: 2, child: toSizeWidget),
                        const SizedBox(width: 14),
                        sortIdWidget,
                        const SizedBox(width: 14),
                        activeWidget,
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: codeWidget),
                        const SizedBox(width: 10),
                        Expanded(child: activeWidget),
                      ],
                    ),
                    const SizedBox(height: 12),
                    nameWidget,
                    const SizedBox(height: 12),
                    rptGroupWidget,
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: fromSizeWidget),
                        const SizedBox(width: 10),
                        Expanded(child: toSizeWidget),
                      ],
                    ),
                    const SizedBox(height: 12),
                    sortIdWidget,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
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
              onPressed: () => _enableFields(),
            ),
          const SizedBox(width: 8),
          if (_isEnabled) ...[
            AppButton(
              text: _isFromEdit ? 'Update' : 'Save',
              icon: Icons.save_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _handleSave,
            ),
            const SizedBox(width: 8),
            if (_isFromEdit) ...[
              AppButton(
                text: 'Delete',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                onPressed: _handleDelete,
              ),
              const SizedBox(width: 8),
            ],
            AppButton(
              text: 'Cancel',
              icon: Icons.clear_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _clearFormFields,
            ),
            const SizedBox(width: 8),
          ],
          AppButton(
            text: 'Exit',
            icon: Icons.close_rounded,
            variant: AppButtonVariant.danger,
            onPressed: _exitScreen,
          ),
          const Spacer(),
          Obx(() {
            final isLoading = defaultController.isLoading.value ||
                defaultController.isDeleteLoading.value;
            if (isLoading) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(radius: 8),
                  const SizedBox(width: 8),
                  Text(
                    'Processing...',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDirectoryCard(bool isDark) {
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
                Icon(Icons.list_alt_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Existing Charni Records',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Total: ${defaultController.charniModelList.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          SizedBox(
            height: 380,
            child: Obx(
              () => AppDataGrid(
                controller: _dataGridController,
                source: CharniDataGridSource(defaultController.charniModelList),
                columnWidthMode: ColumnWidthMode.fill,
                rowHeight: 30,
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
                    _loadFromRow(selected);
                  }
                },
                onSelectionChanged: (addedRows, _) {
                  if (addedRows.isNotEmpty) {
                    _loadFromRow(addedRows.first);
                  }
                },
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'Code',
                    width: 90,
                    label: _gridHeader('Code', alignment: Alignment.center),
                  ),
                  GridColumn(
                    columnName: 'Name',
                    label: _gridHeader('Charni Name',
                        alignment: Alignment.centerLeft),
                  ),
                  GridColumn(
                    columnName: 'Rpt Group',
                    width: 120,
                    label: _gridHeader('Rpt Group', alignment: Alignment.center),
                  ),
                  GridColumn(
                    columnName: 'From Size',
                    width: 100,
                    label: _gridHeader('From Size',
                        alignment: Alignment.centerRight),
                  ),
                  GridColumn(
                    columnName: 'To Size',
                    width: 100,
                    label: _gridHeader('To Size',
                        alignment: Alignment.centerRight),
                  ),
                  GridColumn(
                    columnName: 'Sort ID',
                    width: 90,
                    label: _gridHeader('Sort ID', alignment: Alignment.center),
                  ),
                  GridColumn(
                    columnName: 'Active',
                    width: 80,
                    label: _gridHeader('Active', alignment: Alignment.center),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridHeader(String text, {Alignment alignment = Alignment.center}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
