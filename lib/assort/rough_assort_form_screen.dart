import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/assort/rough_assort_datagrid.dart';
import 'package:real_web_rough_entry_system/assort/rough_assort_mst_model.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class RoughAssortFormScreen extends StatefulWidget {
  final bool showHeader;

  const RoughAssortFormScreen({super.key, required this.showHeader});

  @override
  RoughAssortFormScreenState createState() => RoughAssortFormScreenState();
}

class RoughAssortFormScreenState extends State<RoughAssortFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'rough assort',
        'frmroughassortform',
      ]);
  final TextEditingController wtController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode _partyFocNode = FocusNode();
  final FocusNode _roughFocNode = FocusNode();
  final FocusNode _wtFocus = FocusNode();
  final FocusNode _rateFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();

  final RxString _selectedType = ''.obs;
  final RxString _selectedTypeParty = ''.obs;
  final RxInt selectedRoughAssortMstID = 0.obs;
  final RxString selectedRoughId = ''.obs;

  List<Map<String, String>> entries = [];

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;

  final DefaultController defaultController = Get.find<DefaultController>();
  final RxList<RoughAssortMst> roughAssortMstDataGridSource = <RoughAssortMst>[].obs;
  Worker? _listWorker;

  double get assortWt => entries.fold(0.0, (prev, e) => prev + (double.tryParse(e['wt'] ?? '0') ?? 0.0));

  double get totalAmount => entries.fold(0.0, (prev, e) => prev + (double.tryParse(e['amount'] ?? '0') ?? 0.0));

  double get totalRate => assortWt == 0 ? 0.0 : totalAmount / assortWt;

  double get totalAssWt {
    if (_selectedTypeParty.value.isEmpty) return 0.0;
    final prevAssort = getTotalAssortWt(_selectedTypeParty.value, _isFromEdit, selectedRoughAssortMstID.value);
    return prevAssort + (_isFromEdit ? 0.0 : assortWt);
  }

  double get parcelTotalWeight {
    if (_selectedTypeParty.value.isEmpty) return 0.0;
    final wt = getTotalWeight(_selectedTypeParty.value);
    if (wt is num) return wt.toDouble();
    return double.tryParse(wt.toString()) ?? 0.0;
  }

  double get pendingWt {
    if (_selectedTypeParty.value.isEmpty) return 0.0;
    return parcelTotalWeight - totalAssWt - (_isFromEdit ? assortWt : 0.0);
  }

  @override
  void initState() {
    super.initState();
    wtController.addListener(_updateAmount);
    rateController.addListener(_updateAmount);
    roughAssortMstDataGridSource.value = defaultController.roughAssortMstList;

    _listWorker = ever(defaultController.roughAssortMstList, (list) {
      if (mounted) {
        roughAssortMstDataGridSource.value = list;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getRoughAssortData(force: true);
      defaultController.getRoughAssortDetailsData(force: true);
      defaultController.getPartyData(force: true);
      defaultController.getRoughData(force: true);
    });
  }

  @override
  void dispose() {
    _listWorker?.dispose();
    wtController.dispose();
    rateController.dispose();
    amountController.dispose();
    searchController.dispose();
    _partyFocNode.dispose();
    _roughFocNode.dispose();
    _wtFocus.dispose();
    _rateFocus.dispose();
    super.dispose();
  }

  void _updateAmount() {
    final double wt = double.tryParse(wtController.text) ?? 0.0;
    final double rate = double.tryParse(rateController.text) ?? 0.0;
    amountController.text = (wt * rate).toStringAsFixed(2);
  }

  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      entries.clear();
      _selectedTypeParty.value = '';
      _selectedType.value = '';
      wtController.clear();
      rateController.clear();
      amountController.clear();
    });
    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _partyFocNode.requestFocus();
      });
    }
  }

  void addEntry() {
    final double wt = double.tryParse(wtController.text) ?? 0.0;
    final double rate = double.tryParse(rateController.text) ?? 0.0;

    if (_selectedType.value.isEmpty) {
      infoDialog(messageText: 'Please select Assort Type');
      _roughFocNode.requestFocus();
      return;
    }
    if (wt <= 0) {
      infoDialog(messageText: 'Please enter valid Weight');
      _wtFocus.requestFocus();
      return;
    }
    if (rate <= 0) {
      infoDialog(messageText: 'Please enter valid Rate');
      _rateFocus.requestFocus();
      return;
    }

    setState(() {
      entries.add({
        if (selectedRoughId.value.isNotEmpty) 'id': selectedRoughId.value,
        'assort': _selectedType.value,
        'wt': wt.toStringAsFixed(2),
        'rate': rate.toStringAsFixed(2),
        'amount': (wt * rate).toStringAsFixed(2),
      });

      _selectedType.value = '';
      wtController.clear();
      rateController.clear();
      amountController.clear();
      selectedRoughId.value = '';
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _roughFocNode.requestFocus();
    });
  }

  Future<void> _saveVoucher() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;
    if (_selectedTypeParty.value.isEmpty) {
      infoDialog(messageText: 'Please select an Invoice / Parcel');
      _partyFocNode.requestFocus();
      return;
    }
    if (entries.isEmpty) {
      infoDialog(messageText: 'Please add at least one Rough Assort line item');
      _roughFocNode.requestFocus();
      return;
    }

    if (_isFromEdit) {
      await defaultController.updateRoughAssortData(
        id: selectedRoughAssortMstID.value,
        invoiceNo: _selectedTypeParty.value,
        wt: getTotalWeight(_selectedTypeParty.value),
        assWt: assortWt.toStringAsFixed(2),
        penWt: pendingWt.toStringAsFixed(2),
        entries: entries,
      );
    } else {
      await defaultController.addRoughAssortData(
        invoiceNo: _selectedTypeParty.value,
        wt: getTotalWeight(_selectedTypeParty.value),
        assWt: assortWt.toStringAsFixed(2),
        penWt: pendingWt.toStringAsFixed(2),
        entries: entries,
      );
    }

    await defaultController.getRoughAssortData(force: true);
    await defaultController.getRoughAssortDetailsData(force: true);
    setState(() {
      entries.clear();
      _selectedTypeParty.value = '';
      _selectedType.value = '';
      _isEnabled = false;
      _isFromEdit = false;
    });
  }

  Future<void> _deleteVoucher() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit || selectedRoughAssortMstID.value == 0) return;
    await defaultController.deleteRoughAssortData(
      id: selectedRoughAssortMstID.value,
      entries: entries,
    );
    await defaultController.getRoughAssortData(force: true);
    await defaultController.getRoughAssortDetailsData(force: true);
    setState(() {
      entries.clear();
      _selectedTypeParty.value = '';
      _selectedType.value = '';
      _isEnabled = false;
      _isFromEdit = false;
    });
  }

  void _cancel() {
    setState(() {
      entries.clear();
      _selectedTypeParty.value = '';
      _selectedType.value = '';
      _isEnabled = false;
      _isFromEdit = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (_isSearch) {
        roughAssortMstDataGridSource.value = defaultController.roughAssortMstList;
        searchController.clear();
      }
    });
  }

  void _filterSearch(String query) {
    if (query.trim().isEmpty) {
      roughAssortMstDataGridSource.value = defaultController.roughAssortMstList;
    } else {
      final q = query.toLowerCase();
      roughAssortMstDataGridSource.value = defaultController.roughAssortMstList.where((voucher) {
        final inv = (voucher.invoiceNo ?? '').toLowerCase();
        return inv.contains(q);
      }).toList();
    }
  }

  void _selectVoucherFromRow(DataGridRow row) {
    final mstId = row.getCells()[0].value as int?;
    if (mstId == null) return;

    final entry = defaultController.roughAssortMstList.firstWhereOrNull(
      (e) => e.roughAssortMstID == mstId,
    );
    if (entry == null) return;
    final roughEntries = defaultController.roughAssortMstDetList
        .where((e) => e.roughAssortMstID == mstId)
        .toList();

    selectedRoughAssortMstID.value = mstId;
    _selectedTypeParty.value = entry.invoiceNo ?? '';

    setState(() {
      entries.clear();
      for (var r in roughEntries) {
        final wt = r.wt ?? 0.0;
        final rate = r.rate ?? 0.0;
        entries.add({
          'id': r.roughAssortDetMstID.toString(),
          'assort': r.assortName.toString(),
          'wt': wt.toStringAsFixed(2),
          'rate': rate.toStringAsFixed(2),
          'amount': (wt * rate).toStringAsFixed(2),
        });
      }
      _isFromEdit = true;
      _isEnabled = true;
      _isSearch = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _roughFocNode.requestFocus();
    });
  }

  void _exitScreen() {
    tabController.removeTab(tabController.currentIndex.value);
  }

  List<DropdownMenuItem<String>> get dropdownItemsInvoiceNo {
    return defaultController.purchaseDataList
        .where((p) => p.companyCode == defaultController.companyCode.value)
        .map((p) {
      final transactions = defaultController.roughAssortMstList
          .where((trn) => trn.invoiceNo == p.invoiceNo)
          .toList();
      final double totalAssort = transactions.fold(0.0, (prev, trn) => prev + (trn.assortWt ?? 0));
      final double totalPending = (p.tWeight ?? 0) - totalAssort;

      return DropdownMenuItem<String>(
        value: p.invoiceNo ?? '',
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                p.invoiceNo ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tot: ${(p.tWeight ?? 0).toStringAsFixed(2)} Ct',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: totalPending > 0 ? AppColors.warningBg : AppColors.successBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Pen: ${totalPending.toStringAsFixed(2)} Ct',
                style: TextStyle(
                  fontSize: 11,
                  color: totalPending > 0 ? AppColors.warning : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsAssort {
    return defaultController.assortMstList
        .where((e) => e.name != null && !entries.any((entry) => entry["assort"] == e.name))
        .map((assort) {
      return DropdownMenuItem<String>(
        value: assort.name ?? '',
        child: Text(assort.name ?? '', style: const TextStyle(fontSize: 13)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = AppColors.isDark;
      return AppKeyboardShortcutHandler(
        onAdd: _enableFields,
        onSave: _saveVoucher,
        onDelete: _isFromEdit ? _deleteVoucher : null,
        onCancel: _cancel,
        onSearch: _toggleSearch,
        onExit: _exitScreen,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) Header(title: _isSearch ? 'Rough Assort Search' : 'Rough Assort Entry'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildParcelCard(),
          const SizedBox(height: 12),
          _buildItemInputCard(),
          const SizedBox(height: 12),
          _buildItemsTableCard(),
          const SizedBox(height: 12),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildParcelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Parcel Identification & Real-Time Balances',
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
          Divider(height: 20, color: AppColors.borderLight),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Obx(
                  () => AppDropdown<String>(
                    key: ValueKey(_selectedTypeParty.value),
                    label: 'Select Parcel (Invoice No) *',
                    value: _selectedTypeParty.value.isEmpty ? null : _selectedTypeParty.value,
                    focusNode: _partyFocNode,
                    isEnabled: _isEnabled,
                    hintText: 'Select Purchase Invoice...',
                    items: dropdownItemsInvoiceNo,
                    onChanged: (val) {
                      _selectedTypeParty.value = val ?? '';
                      _roughFocNode.requestFocus();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 6,
                child: Obx(
                  () => Row(
                    children: [
                      _buildMetricStatPill(
                        label: 'TOTAL WT',
                        value: '${parcelTotalWeight.toStringAsFixed(2)} Ct',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricStatPill(
                        label: 'ASSORTED WT',
                        value: '${totalAssWt.toStringAsFixed(2)} Ct',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricStatPill(
                        label: 'PENDING WT',
                        value: '${pendingWt.toStringAsFixed(2)} Ct',
                        color: pendingWt > 0 ? AppColors.warning : AppColors.success,
                        bgColor: pendingWt > 0 ? AppColors.warningBg : AppColors.successBg,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStatPill({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_shopping_cart_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Add Assort Item Entry',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Press Enter on Rate to add row',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Obx(
                  () => AppDropdown<String>(
                    key: ValueKey(_selectedType.value),
                    label: 'Assort Type *',
                    value: _selectedType.value.isEmpty ? null : _selectedType.value,
                    focusNode: _roughFocNode,
                    isEnabled: _isEnabled && _selectedTypeParty.isNotEmpty,
                    hintText: 'Select Assort...',
                    items: dropdownItemsAssort,
                    onChanged: (val) {
                      _selectedType.value = val ?? '';
                      _wtFocus.requestFocus();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Weight (Ct) *',
                  controller: wtController,
                  focusNode: _wtFocus,
                  enabled: _isEnabled && _selectedTypeParty.isNotEmpty,
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))],
                  onFieldSubmitted: (_) => _rateFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Rate (₹) *',
                  controller: rateController,
                  focusNode: _rateFocus,
                  enabled: _isEnabled && _selectedTypeParty.isNotEmpty,
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  onFieldSubmitted: (_) => addEntry(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Amount (₹)',
                  controller: amountController,
                  enabled: false,
                  hintText: '0.00',
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Add Item',
                icon: Icons.add_circle_outline_rounded,
                variant: AppButtonVariant.primary,
                height: 40,
                onPressed: _isEnabled && _selectedTypeParty.isNotEmpty ? addEntry : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTableCard() {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.table_chart_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Assorted Items Register',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tableRowAlt,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Lines: ${entries.length}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, size: 40, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'No assort items added yet',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: AppColors.borderLight, width: 1),
              ),
              columnWidths: const {
                0: FixedColumnWidth(60),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
                5: FixedColumnWidth(80),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                  children: [
                    _tableHeaderCell('Sr.', alignment: Alignment.center),
                    _tableHeaderCell('Assort Name', alignment: Alignment.centerLeft),
                    _tableHeaderCell('Weight (Ct)', alignment: Alignment.centerRight),
                    _tableHeaderCell('Rate (₹)', alignment: Alignment.centerRight),
                    _tableHeaderCell('Amount (₹)', alignment: Alignment.centerRight),
                    _tableHeaderCell('Actions', alignment: Alignment.center),
                  ],
                ),
                for (int i = 0; i < entries.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? AppColors.surface : AppColors.tableRowAlt,
                    ),
                    children: [
                      _tableDataCell('${i + 1}', alignment: Alignment.center),
                      _tableDataCell(entries[i]['assort'] ?? '', alignment: Alignment.centerLeft, isBold: true),
                      _tableDataCell(entries[i]['wt'] ?? '0.00', alignment: Alignment.centerRight),
                      _tableDataCell(entries[i]['rate'] ?? '0.00', alignment: Alignment.centerRight),
                      _tableDataCell(entries[i]['amount'] ?? '0.00', alignment: Alignment.centerRight),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                              tooltip: 'Edit Row',
                              onPressed: () {
                                if (_isFromEdit) {
                                  selectedRoughId.value = entries[i]['id'] ?? '';
                                }
                                _selectedType.value = entries[i]['assort'] ?? '';
                                wtController.text = entries[i]['wt'] ?? '';
                                rateController.text = entries[i]['rate'] ?? '';
                                setState(() {
                                  entries.removeAt(i);
                                });
                                _roughFocNode.requestFocus();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                              tooltip: 'Delete Row',
                              onPressed: () {
                                if (_isFromEdit) {
                                  if (entries.length == 1) {
                                    infoDialog(messageText: 'Cannot delete single rough entry');
                                    return;
                                  }
                                  defaultController
                                      .deleteRoughAssortDetData(id: int.parse(entries[i]['id']!))
                                      .then((_) {
                                    setState(() {
                                      entries.removeAt(i);
                                    });
                                  });
                                } else {
                                  setState(() {
                                    entries.removeAt(i);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    border: Border(top: BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                  children: [
                    _tableDataCell('', alignment: Alignment.center),
                    _tableDataCell('TOTAL', alignment: Alignment.centerLeft, isBold: true),
                    _tableDataCell('${assortWt.toStringAsFixed(2)} Ct', alignment: Alignment.centerRight, isBold: true),
                    _tableDataCell('Avg: ${totalRate.toStringAsFixed(2)}', alignment: Alignment.centerRight, isBold: true),
                    _tableDataCell('₹ ${totalAmount.toStringAsFixed(2)}', alignment: Alignment.centerRight, isBold: true),
                    _tableDataCell('', alignment: Alignment.center),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String label, {Alignment alignment = Alignment.center}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _tableDataCell(String text, {Alignment alignment = Alignment.center, bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: alignment,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
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
              text: 'Add Voucher',
              icon: Icons.add_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _enableFields,
            ),
          if (_isEnabled) ...[
            AppButton(
              text: _isFromEdit ? 'Update Voucher' : 'Save Voucher',
              icon: Icons.save_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _saveVoucher,
            ),
            const SizedBox(width: 8),
            if (_isFromEdit) ...[
              AppButton(
                text: 'Delete Voucher',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                onPressed: _deleteVoucher,
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
                  Text('Saving...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
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
                    label: 'Search Rough Assort Register',
                    controller: searchController,
                    hintText: 'Filter by invoice number...',
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
                  text: 'Back to Voucher',
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
                    source: RoughAssortDataGridSource(roughAssortMstDataGridSource),
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
                        _selectVoucherFromRow(selected);
                      }
                    },
                    onSelectionChanged: (addedRows, _) {
                      if (addedRows.isNotEmpty) {
                        _selectVoucherFromRow(addedRows.first);
                      }
                    },
                    columns: <GridColumn>[
                      GridColumn(
                        columnName: 'ID',
                        visible: false,
                        label: _tableHeaderCell('ID'),
                      ),
                      GridColumn(
                        columnName: 'Invoice No',
                        label: _tableHeaderCell('Invoice No', alignment: Alignment.centerLeft),
                      ),
                      GridColumn(
                        columnName: 'Assort Wt',
                        label: _tableHeaderCell('Assort Wt (Ct)', alignment: Alignment.centerRight),
                      ),
                      GridColumn(
                        columnName: 'Amount',
                        label: _tableHeaderCell('Total Amount (₹)', alignment: Alignment.centerRight),
                      ),
                    ],
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        title: 'Total ${roughAssortMstDataGridSource.length} Vouchers',
                        showSummaryInRow: false,
                        titleColumnSpan: 2,
                        columns: const <GridSummaryColumn>[
                          GridSummaryColumn(
                            name: 'Tot Assort Wt',
                            columnName: 'Assort Wt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'Tot Amount',
                            columnName: 'Amount',
                            summaryType: GridSummaryType.sum,
                          ),
                        ],
                        position: GridTableSummaryRowPosition.bottom,
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
}
