import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/designation/designation_datagrid.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DesignationFormScreen extends StatefulWidget {
  final bool showHeader;

  const DesignationFormScreen({super.key, this.showHeader = false});

  @override
  DesignationFormScreenState createState() => DesignationFormScreenState();
}

class DesignationFormScreenState extends State<DesignationFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmdesignationform',
        'frmdesignation',
        'designation',
        'designation master',
        'designation mst',
      ]);
  final DefaultController defaultController = Get.find<DefaultController>();
  final DataGridController _dataGridController = DataGridController();

  // Controllers
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sortIdController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _sortIdFocus = FocusNode();

  // State
  final RxInt _selectedDesignationCode = 0.obs;
  final RxInt _selectedDesignationMstID = 0.obs;
  final RxBool _isActive = true.obs;
  bool _isEnabled = false;
  bool _isFromEdit = false;
  bool _canEditOrDelete = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getDesignationData(
          companyCodeParam: defaultController.companyCode.value);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _sortIdController.dispose();
    _nameFocus.dispose();
    _sortIdFocus.dispose();
    super.dispose();
  }

  Future<void> _enableFields({bool needFocus = true}) async {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      _canEditOrDelete = true;
      _selectedDesignationCode.value = 0;
      _selectedDesignationMstID.value = 0;
      _codeController.text = '';
      _nameController.clear();
      _sortIdController.clear();
      _isActive.value = true;
    });

    try {
      final next = await defaultController.getNextDesignationCode();
      if (next != null && mounted) {
        final dynamic nextCode = next['DesiCode'] ??
            next['nextCode'] ??
            next['nextDesignationCode'] ??
            next['DesignationCode'] ??
            next['code'];
        final dynamic nextSort = next['SortNo'] ??
            next['nextSortID'] ??
            next['SortID'] ??
            next['sortId'];
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
      _canEditOrDelete = true;
      _selectedDesignationCode.value = 0;
      _selectedDesignationMstID.value = 0;
      _codeController.clear();
      _nameController.clear();
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
    if (_isFromEdit && !_canEditOrDelete) {
      infoDialog(
          messageText:
              'This record is locked and cannot be edited (EditDel is N).');
      return;
    }

    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      infoDialog(messageText: 'Please enter Designation Name');
      _nameFocus.requestFocus();
      return;
    }

    final int? sortId = int.tryParse(_sortIdController.text.trim());
    final int? code = int.tryParse(_codeController.text.trim());

    if (_isFromEdit) {
      final dynamic targetId = _selectedDesignationMstID.value != 0
          ? _selectedDesignationMstID.value
          : _selectedDesignationCode.value;

      if (targetId == 0 || targetId == null) {
        errorDialog(
            messageText: 'Unable to identify Designation record to update');
        return;
      }

      await defaultController.updateDesignationData(
        id: targetId,
        name: name,
        code: code,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    } else {
      await defaultController.addDesignationData(
        code: code,
        name: name,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    }
    await defaultController.getDesignationData(
        companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit) return;
    if (!_canEditOrDelete) {
      infoDialog(
          messageText:
              'This record is locked and cannot be deleted (EditDel is N).');
      return;
    }

    final dynamic targetId = _selectedDesignationMstID.value != 0
        ? _selectedDesignationMstID.value
        : _selectedDesignationCode.value;

    if (targetId == 0 || targetId == null) return;

    await defaultController.deleteDesignationData(
      id: targetId,
      companyCodeParam: defaultController.companyCode.value,
    );
    await defaultController.getDesignationData(
        companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  void _loadFromRow(DataGridRow row) {
    final codeCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'Code');
    final nameCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'Name');
    final sortCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'Sort ID');
    final activeCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'Active');
    final editDelCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'EditDel');
    final mstIdCell =
        row.getCells().firstWhereOrNull((c) => c.columnName == 'DesiMstID');

    final dynamic rawCode = codeCell?.value;
    final int code = (rawCode is int)
        ? rawCode
        : int.tryParse(rawCode?.toString() ?? '') ?? 0;

    final dynamic rawMstId = mstIdCell?.value;
    final int mstId = (rawMstId is int)
        ? rawMstId
        : int.tryParse(rawMstId?.toString() ?? '') ?? code;

    final String editDelVal =
        (editDelCell?.value?.toString() ?? 'Y').toUpperCase().trim();
    final bool isLocked = editDelVal == 'N';
    final bool canEditDel = !isLocked;

    if (code != 0 || mstId != 0) {
      _selectedDesignationCode.value = code;
      _selectedDesignationMstID.value = mstId != 0 ? mstId : code;
      _codeController.text = code.toString();
      _nameController.text = nameCell?.value?.toString() ?? '';
      _sortIdController.text =
          sortCell?.value != null ? sortCell!.value.toString() : '';
      _isActive.value = (activeCell?.value as bool?) ?? true;

      setState(() {
        _isFromEdit = true;
        _canEditOrDelete = canEditDel;
        _isEnabled = canEditDel; // Disabled if locked!
      });

      if (canEditDel) {
        _nameFocus.requestFocus();
      }
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
        onSave: (_isEnabled && _canEditOrDelete) ? _handleSave : null,
        onDelete: (_isFromEdit && _canEditOrDelete) ? _handleDelete : null,
        onCancel: (_isEnabled || _isFromEdit) ? _clearFormFields : null,
        onExit: _exitScreen,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader)
                const Header(title: 'Designation Master'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
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
              Icon(Icons.badge_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Designation Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_isFromEdit)
                if (!_canEditOrDelete)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            size: 11, color: AppColors.danger),
                        const SizedBox(width: 4),
                        Text(
                          'READ ONLY (CANNOT EDIT/DELETE)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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

          // Fields: Code, Name, Sort ID, Active
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 600;

              final codeWidget = SizedBox(
                width: isWide ? 100 : null,
                child: AppTextField(
                  label: 'Code',
                  controller: _codeController,
                  enabled: false,
                  hintText: 'Auto',
                ),
              );

              final nameWidget = AppTextField(
                label: 'Designation Name *',
                controller: _nameController,
                focusNode: _nameFocus,
                enabled: _isEnabled,
                hintText: 'e.g. Manager, Diamond Assorter, Accountant',
                onFieldSubmitted: (_) => _sortIdFocus.requestFocus(),
              );

              final sortIdWidget = SizedBox(
                width: isWide ? 130 : null,
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
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    codeWidget,
                    const SizedBox(width: 14),
                    Expanded(flex: 4, child: nameWidget),
                    const SizedBox(width: 14),
                    sortIdWidget,
                    const SizedBox(width: 14),
                    activeWidget,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 1, child: codeWidget),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: activeWidget),
                      ],
                    ),
                    const SizedBox(height: 12),
                    nameWidget,
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
          if (!_isEnabled && !_isFromEdit)
            AppButton(
              text: 'Add',
              icon: Icons.add_rounded,
              variant: AppButtonVariant.primary,
              onPressed: () => _enableFields(),
            ),
          const SizedBox(width: 8),
          if (_isFromEdit && !_canEditOrDelete) ...[
            AppButton(
              text: 'Add New',
              icon: Icons.add_rounded,
              variant: AppButtonVariant.primary,
              onPressed: () => _enableFields(),
            ),
            const SizedBox(width: 8),
          ],
          if (_isEnabled && _canEditOrDelete) ...[
            AppButton(
              text: _isFromEdit ? 'Update' : 'Save',
              icon: Icons.save_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _handleSave,
            ),
            const SizedBox(width: 8),
          ],
          if (_isFromEdit && _canEditOrDelete) ...[
            AppButton(
              text: 'Delete',
              icon: Icons.delete_outline_rounded,
              variant: AppButtonVariant.danger,
              onPressed: _handleDelete,
            ),
            const SizedBox(width: 8),
          ],
          if (_isEnabled || _isFromEdit) ...[
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
                  'Existing Designations',
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
                      'Total: ${defaultController.designationModelList.length}',
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
                source: DesignationDataGridSource(
                    defaultController.designationModelList),
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
                    width: 100,
                    label: _gridHeader('Code', alignment: Alignment.center),
                  ),
                  GridColumn(
                    columnName: 'Name',
                    label: _gridHeader('Designation Name',
                        alignment: Alignment.centerLeft),
                  ),
                  GridColumn(
                    columnName: 'Sort ID',
                    width: 120,
                    label: _gridHeader('Sort ID', alignment: Alignment.center),
                  ),
                  GridColumn(
                    columnName: 'Active',
                    width: 100,
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
