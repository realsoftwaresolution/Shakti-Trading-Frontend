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
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/quality/quality_datagrid.dart';
import 'package:real_web_rough_entry_system/quality/quality_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class QualityFormScreen extends StatefulWidget {
  final bool showHeader;

  const QualityFormScreen({super.key, this.showHeader = false});

  @override
  QualityFormScreenState createState() => QualityFormScreenState();
}

class QualityFormScreenState extends State<QualityFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmqualityform',
        'quality',
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
  final RxInt _selectedQualityCode = 0.obs;
  final RxInt _selectedQualityMstID = 0.obs;
  final RxBool _isActive = true.obs;
  bool _isEnabled = false;
  bool _isFromEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getQualityData(companyCodeParam: defaultController.companyCode.value);
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
      _selectedQualityCode.value = 0;
      _selectedQualityMstID.value = 0;
      _codeController.text = '';
      _nameController.clear();
      _sortIdController.clear();
      _isActive.value = true;
    });

    try {
      final next = await defaultController.getNextQualityCode();
      if (next != null && mounted) {
        final dynamic nextCode =
            next['nextQualityCode'] ?? next['QualityCode'] ?? next['code'];
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
      _selectedQualityCode.value = 0;
      _selectedQualityMstID.value = 0;
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

    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      infoDialog(messageText: 'Please enter Quality Name');
      _nameFocus.requestFocus();
      return;
    }

    final int? sortId = int.tryParse(_sortIdController.text.trim());

    if (_isFromEdit) {
      final dynamic targetId = _selectedQualityCode.value != 0
          ? _selectedQualityCode.value
          : _selectedQualityMstID.value;

      if (targetId == 0 || targetId == null) {
        errorDialog(messageText: 'Unable to identify Quality record to update');
        return;
      }

      await defaultController.updateQualityData(
        id: targetId,
        name: name,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    } else {
      await defaultController.addQualityData(
        name: name,
        sortId: sortId,
        active: _isActive.value,
        companyCodeParam: defaultController.companyCode.value,
      );
    }
    await defaultController.getQualityData(companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit) return;

    final dynamic targetId = _selectedQualityCode.value != 0
        ? _selectedQualityCode.value
        : _selectedQualityMstID.value;

    if (targetId == 0 || targetId == null) return;

    await defaultController.deleteQualityData(
      id: targetId,
      companyCodeParam: defaultController.companyCode.value,
    );
    await defaultController.getQualityData(companyCodeParam: defaultController.companyCode.value);
    _clearFormFields();
  }

  void _loadFromRow(DataGridRow row) {
    final dynamic cellVal = row.getCells()[0].value;
    final item = defaultController.qualityModelList.firstWhere(
      (entry) =>
          entry.qualityCode == cellVal || entry.qualityMstID == cellVal,
      orElse: () => QualityModel(),
    );

    final int code = item.qualityCode ??
        item.qualityMstID ??
        (cellVal is int ? cellVal : 0);
    if (code != 0) {
      _selectedQualityCode.value = item.qualityCode ?? code;
      _selectedQualityMstID.value = item.qualityMstID ?? code;
      _codeController.text = code.toString();
      _nameController.text = item.qualityName ?? '';
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
              if (widget.showHeader) const Header(title: 'Quality Master'),
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
              Icon(Icons.workspace_premium_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Quality Details',
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
                label: 'Quality Name *',
                controller: _nameController,
                focusNode: _nameFocus,
                enabled: _isEnabled,
                hintText: 'e.g. G VS2 +, OVAL',
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
                  'Existing Qualities',
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
                      'Total: ${defaultController.qualityModelList.length}',
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
                source:
                    QualityDataGridSource(defaultController.qualityModelList),
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
                    label: _gridHeader('Quality Name',
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
