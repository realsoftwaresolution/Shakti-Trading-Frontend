import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/import_entry/import_api.dart';
import 'package:real_web_rough_entry_system/import_entry/import_datagrid.dart';
import 'package:real_web_rough_entry_system/import_entry/import_model.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Import entry (Transaction menu).
///
/// Main details : ID (auto), Date, Manager, Kapan No
/// Sub details  : Polish Type, Shape, Clarity, Charni, Color, Pcs, Wt,
///                Less Rate, Less Amount, Rate, Amount, Final Amount, Round Of
///
///   Less Amount  = Wt x Less Rate
///   Rate         = Less Rate
///   Amount       = Less Amount
///   Final Amount = Amount (can be changed to round it)
///   Round Of     = Amount - Final Amount
class ImportFormScreen extends StatefulWidget {
  final bool showHeader;

  const ImportFormScreen({super.key, required this.showHeader});

  @override
  ImportFormScreenState createState() => ImportFormScreenState();
}

class ImportFormScreenState extends State<ImportFormScreen> {
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmimportform',
        'frmimport',
        'import',
      ]);

  final DefaultController defaultController = Get.find<DefaultController>();
  final ImportApi api = ImportApi.to;

  // ==================== MAIN DETAILS ====================
  final TextEditingController idController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController kapanNoController = TextEditingController();
  final Rxn<int> _selectedManagerId = Rxn<int>();
  DateTime? selectedDate;

  // ==================== SUB DETAILS ====================
  final RxString _selectedPolishType = ''.obs;
  final RxString _selectedShape = ''.obs;
  final RxString _selectedClarity = ''.obs;
  final RxString _selectedCharni = ''.obs;
  final RxString _selectedColor = ''.obs;
  final TextEditingController pcsController = TextEditingController();
  final TextEditingController wtController = TextEditingController();
  final TextEditingController lessRateController = TextEditingController();
  final TextEditingController lessAmountController = TextEditingController(text: '0.00');
  final TextEditingController rateController = TextEditingController(text: '0.00');
  final TextEditingController amountController = TextEditingController(text: '0.00');
  final TextEditingController finalAmountController = TextEditingController(text: '0.00');
  final TextEditingController roundOfController = TextEditingController(text: '0.00');

  // ==================== FOCUS ====================
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _managerFocus = FocusNode();
  final FocusNode _kapanNoFocus = FocusNode();
  final FocusNode _polishTypeFocus = FocusNode();
  final FocusNode _shapeFocus = FocusNode();
  final FocusNode _clarityFocus = FocusNode();
  final FocusNode _charniFocus = FocusNode();
  final FocusNode _colorFocus = FocusNode();
  final FocusNode _pcsFocus = FocusNode();
  final FocusNode _wtFocus = FocusNode();
  final FocusNode _lessRateFocus = FocusNode();
  final FocusNode _finalAmountFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();
  final ScrollController _tableScroll = ScrollController();

  // Same breakpoints as Responsive (lib/responsive.dart), measured on the
  // space the tab really has (the sidebar takes part of the screen).
  static const double _mobileWidth = 700;
  static const double _tabletWidth = 1100;
  static const double _entryRowWidth = 1300; // sub details fit on one line

  /// Items on the screen. Each map keeps codes + values of one row.
  List<Map<String, dynamic>> entries = [];
  int? _editingEntryIndex;
  int _editMstId = 0;

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;
  bool _isLoadingRow = false;

  // Search filter
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final RxBool _isFiltered = false.obs;

  static final RegExp _dec3 = RegExp(r'^\d*\.?\d{0,3}');
  static final RegExp _dec2 = RegExp(r'^\d*\.?\d{0,2}');
  static final RegExp _signedDec2 = RegExp(r'^-?\d*\.?\d{0,2}');

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;

  // ==================== TOTALS ====================
  int get totalPcs => entries.fold(0, (p, e) => p + (int.tryParse(e['pcs']?.toString() ?? '0') ?? 0));
  double get totalWt => entries.fold(0.0, (p, e) => p + _num(e['wt']));
  double get totalLessAmount => entries.fold(0.0, (p, e) => p + _num(e['lessAmount']));
  double get totalAmount => entries.fold(0.0, (p, e) => p + _num(e['amount']));
  double get totalFinalAmount => entries.fold(0.0, (p, e) => p + _num(e['finalAmount']));
  double get totalRoundOf => entries.fold(0.0, (p, e) => p + _num(e['roundOf']));
  /// Average (weighted by Wt): Tot Less Amount / Tot Wt.
  double get avgLessRate => totalWt == 0 ? 0.0 : totalLessAmount / totalWt;

  /// Average (weighted by Wt): Tot Amount / Tot Wt.
  double get avgRate => totalWt == 0 ? 0.0 : totalAmount / totalWt;

  @override
  void initState() {
    super.initState();

    _dateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          (_isManagerEnabled ? _managerFocus : _kapanNoFocus).requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled) _openDatePicker();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (defaultController.userModelList.isEmpty) await defaultController.getUserData();
      if (defaultController.polishTypeModelList.isEmpty) defaultController.getPolishTypeData();
      if (defaultController.shapeModelList.isEmpty) defaultController.getShapeData();
      if (defaultController.clarityModelList.isEmpty) defaultController.getClarityData();
      if (defaultController.charniModelList.isEmpty) defaultController.getCharniData();
      if (defaultController.colorModelList.isEmpty) defaultController.getColorData();
      if (mounted) setState(_initManager);
    });
  }

  @override
  void dispose() {
    for (final c in [
      idController, dateController, kapanNoController, pcsController, wtController, lessRateController,
      lessAmountController, rateController, amountController, finalAmountController, roundOfController,
      fromDateController, toDateController,
    ]) {
      c.dispose();
    }
    _tableScroll.dispose();
    for (final f in [
      _dateFocus, _managerFocus, _kapanNoFocus, _polishTypeFocus, _shapeFocus, _clarityFocus, _charniFocus,
      _colorFocus, _pcsFocus, _wtFocus, _lessRateFocus, _finalAmountFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // ==================== MANAGER (same rule as Memo Issue / Sale) ====================
  bool get _isUserTypeUser {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'USER' || !defaultController.isAdmin;
  }

  /// A normal user can only enter for himself; admin picks a manager.
  bool get _isManagerEnabled => !_isUserTypeUser;

  List<UserModel> get _managerUsers {
    if (_isUserTypeUser) {
      final me = defaultController.currentUserId.value;
      return defaultController.userModelList.where((u) => u.counterMstId == me).toList();
    }
    final branch = defaultController.effectiveBranchCode;
    if (branch > 0) {
      return defaultController.userModelList.where((u) => u.branchCode == branch).toList();
    }
    return defaultController.userModelList;
  }

  String _userName(UserModel u) => (u.userName != null && u.userName!.trim().isNotEmpty)
      ? u.userName!.trim()
      : (u.loginName ?? 'User #${u.counterMstId}');

  String _managerName(int? id) {
    if (id == null || id == 0) return '';
    final u = defaultController.userModelList.firstWhereOrNull((x) => x.counterMstId == id);
    return u == null ? '#$id' : _userName(u);
  }

  void _initManager() {
    if (_isUserTypeUser) {
      final me = defaultController.currentUserId.value;
      _selectedManagerId.value = me > 0 ? me : null;
      return;
    }
    final list = _managerUsers;
    if (_selectedManagerId.value != null && !list.any((u) => u.counterMstId == _selectedManagerId.value)) {
      _selectedManagerId.value = null;
    }
    if (_selectedManagerId.value == null && list.isNotEmpty) {
      _selectedManagerId.value = list.first.counterMstId;
    }
  }

  List<DropdownMenuItem<int>> get _managerItems => _managerUsers
      .where((u) => u.counterMstId != null)
      .map((u) => DropdownMenuItem<int>(
            value: u.counterMstId,
            child: Text(_userName(u), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
          ))
      .toList();

  List<AppDropdownItem<int>> get _managerAppItems => _managerUsers
      .where((u) => u.counterMstId != null)
      .map((u) => AppDropdownItem<int>(
            value: u.counterMstId!,
            label: _userName(u),
            subtitle: (u.loginName?.isNotEmpty ?? false) ? 'Login: ${u.loginName}' : null,
          ))
      .toList();

  // ==================== MASTER DROPDOWNS (same as Polish Purchase) ====================
  TextStyle get _itemStyle => TextStyle(fontSize: 13, color: AppColors.textPrimary);

  List<DropdownMenuItem<String>> get _polishTypeItems => defaultController.polishTypeModelList
      .map((p) => DropdownMenuItem<String>(
            value: p.polishTypeCode?.toString() ?? p.polishTypeName ?? '',
            child: Text(p.polishTypeName ?? '', style: _itemStyle),
          ))
      .toList();

  List<DropdownMenuItem<String>> get _shapeItems => defaultController.shapeModelList
      .map((s) => DropdownMenuItem<String>(
            value: s.shapeCode?.toString() ?? s.shapeName ?? '',
            child: Text(s.shapeName ?? '', style: _itemStyle),
          ))
      .toList();

  List<DropdownMenuItem<String>> get _clarityItems => defaultController.clarityModelList
      .map((c) => DropdownMenuItem<String>(
            value: c.clarityMstID?.toString() ?? c.clarityName ?? '',
            child: Text(c.clarityName ?? '', style: _itemStyle),
          ))
      .toList();

  List<DropdownMenuItem<String>> get _charniItems => defaultController.charniModelList
      .map((c) => DropdownMenuItem<String>(
            value: c.charniCode?.toString() ?? c.charniName ?? '',
            child: Text(c.charniName ?? '', style: _itemStyle),
          ))
      .toList();

  List<DropdownMenuItem<String>> get _colorItems => defaultController.colorModelList
      .map((c) => DropdownMenuItem<String>(
            value: c.colorCode?.toString() ?? c.colorName ?? '',
            child: Text(c.colorName ?? '', style: _itemStyle),
          ))
      .toList();

  // ==================== DATE ====================
  Future<void> _openDatePicker() async {
    if (!_isEnabled) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
    (_isManagerEnabled ? _managerFocus : _kapanNoFocus).requestFocus();
  }

  // ==================== ITEM CALCULATION ====================
  /// Less Amount = Wt x Less Rate, Rate = Less Rate, Amount = Less Amount,
  /// Final Amount = Amount, Round Of = Amount - Final (0 until Final is changed).
  void _recalcItem({bool keepFinal = false}) {
    final double wt = _num(wtController.text);
    final double lessRate = _num(lessRateController.text);
    final double lessAmount = wt * lessRate;
    lessAmountController.text = lessAmount.toStringAsFixed(2);
    rateController.text = lessRate.toStringAsFixed(2);
    amountController.text = lessAmount.toStringAsFixed(2);
    if (!keepFinal) finalAmountController.text = lessAmount.toStringAsFixed(2);
    _recalcRoundOf();
  }

  void _recalcRoundOf() {
    final double amount = _num(amountController.text);
    final double finalAmount =
        finalAmountController.text.trim().isEmpty ? amount : _num(finalAmountController.text);
    roundOfController.text = (amount - finalAmount).toStringAsFixed(2);
  }

  void _clearEntryInputs() {
    _editingEntryIndex = null;
    _selectedPolishType.value = '';
    _selectedShape.value = '';
    _selectedClarity.value = '';
    _selectedCharni.value = '';
    _selectedColor.value = '';
    pcsController.clear();
    wtController.clear();
    lessRateController.clear();
    lessAmountController.text = '0.00';
    rateController.text = '0.00';
    amountController.text = '0.00';
    finalAmountController.text = '0.00';
    roundOfController.text = '0.00';
  }

  void _addEntry() {
    if (!_isEnabled) return;
    if (_selectedPolishType.value.trim().isEmpty) {
      infoDialog(messageText: 'Please select Polish Type');
      _polishTypeFocus.requestFocus();
      return;
    }
    // Wt and Less Rate can not be empty
    final double wt = _num(wtController.text);
    if (wtController.text.trim().isEmpty || wt <= 0) {
      infoDialog(messageText: 'Please enter Wt');
      _wtFocus.requestFocus();
      return;
    }
    final double lessRate = _num(lessRateController.text);
    if (lessRateController.text.trim().isEmpty || lessRate <= 0) {
      infoDialog(messageText: 'Please enter Less Rate');
      _lessRateFocus.requestFocus();
      return;
    }

    final double lessAmount = wt * lessRate;
    final double amount = lessAmount;
    final double finalAmount =
        finalAmountController.text.trim().isEmpty ? amount : _num(finalAmountController.text);

    final row = <String, dynamic>{
      if (_editingEntryIndex != null) ...entries[_editingEntryIndex!],
      'kapanNo': kapanNoController.text.trim(),
      'polishTypeCode': int.tryParse(_selectedPolishType.value),
      'shapeCode': int.tryParse(_selectedShape.value),
      'clarityCode': int.tryParse(_selectedClarity.value),
      'charniCode': int.tryParse(_selectedCharni.value),
      'colorCode': int.tryParse(_selectedColor.value),
      'pcs': int.tryParse(pcsController.text.trim()) ?? 0,
      'wt': wt.toStringAsFixed(3),
      'lessRate': lessRate.toStringAsFixed(2),
      'lessAmount': lessAmount.toStringAsFixed(2),
      'rate': lessRate.toStringAsFixed(2),
      'amount': amount.toStringAsFixed(2),
      'finalAmount': finalAmount.toStringAsFixed(2),
      'roundOf': (amount - finalAmount).toStringAsFixed(2),
    };

    setState(() {
      if (_editingEntryIndex != null) {
        entries[_editingEntryIndex!] = row;
      } else {
        entries.add(row);
      }
      _clearEntryInputs();
    });
    _polishTypeFocus.requestFocus();
  }

  void _loadEntryForEdit(int index) {
    if (!_isEnabled || index < 0 || index >= entries.length) return;
    final e = entries[index];
    setState(() {
      _editingEntryIndex = index;
      _selectedPolishType.value = e['polishTypeCode']?.toString() ?? '';
      _selectedShape.value = e['shapeCode']?.toString() ?? '';
      _selectedClarity.value = e['clarityCode']?.toString() ?? '';
      _selectedCharni.value = e['charniCode']?.toString() ?? '';
      _selectedColor.value = e['colorCode']?.toString() ?? '';
      pcsController.text = e['pcs']?.toString() ?? '0';
      wtController.text = e['wt']?.toString() ?? '';
      lessRateController.text = e['lessRate']?.toString() ?? '';
      finalAmountController.text = e['finalAmount']?.toString() ?? '';
      _recalcItem(keepFinal: true);
    });
    _polishTypeFocus.requestFocus();
  }

  void _removeEntry(int index) {
    if (!_isEnabled || index < 0 || index >= entries.length) return;
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to remove this item?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () {
        Get.back();
        // Only removed from the list; the database changes when the Import is saved.
        setState(() {
          entries.removeAt(index);
          if (_editingEntryIndex == index) {
            _clearEntryInputs();
          } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
            _editingEntryIndex = _editingEntryIndex! - 1;
          }
        });
      },
    );
  }

  /// Kapan No is shown on every row; keep the rows in line with the header.
  void _onKapanChanged(String value) {
    if (entries.isEmpty) return;
    setState(() {
      for (final e in entries) {
        e['kapanNo'] = value.trim();
      }
    });
  }

  // ==================== ADD / SAVE / DELETE / CANCEL ====================
  void _enableFields() {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    if (_isFromEdit) _resetForm();
    setState(() {
      _isEnabled = true;
      selectedDate ??= DateTime.now();
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      _initManager();
    });
    Future.delayed(const Duration(milliseconds: 100), () => _dateFocus.requestFocus());
  }

  void _enableEdit() {
    if (!_rights.canEdit) {
      infoDialog(messageText: 'You do not have permission to edit here.');
      return;
    }
    setState(() => _isEnabled = true);
  }

  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;
    if (selectedDate == null) {
      infoDialog(messageText: 'Please select Date');
      _dateFocus.requestFocus();
      return;
    }
    if (_selectedManagerId.value == null || _selectedManagerId.value == 0) {
      infoDialog(messageText: 'Please select Manager');
      _managerFocus.requestFocus();
      return;
    }
    if (kapanNoController.text.trim().isEmpty) {
      infoDialog(messageText: 'Please enter Kapan No');
      _kapanNoFocus.requestFocus();
      return;
    }
    if (entries.isEmpty) {
      infoDialog(messageText: 'Please add at least one item');
      _polishTypeFocus.requestFocus();
      return;
    }

    final kapan = kapanNoController.text.trim();
    final master = ImportMstModel(
      importMstID: _isFromEdit && _editMstId > 0 ? _editMstId : null,
      importDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
      managerId: _selectedManagerId.value,
      kapanNo: kapan,
      totPcs: totalPcs,
      totWt: totalWt,
      totLessRate: avgLessRate,
      totLessAmt: totalLessAmount,
      totRate: avgRate,
      totAmount: totalAmount,
      totFinalAmt: totalFinalAmount,
      totRoundOf: totalRoundOf,
    );
    final items = <ImportDetModel>[
      for (int i = 0; i < entries.length; i++)
        ImportDetModel(
          importDetID: entries[i]['importDetID'] as int?,
          srNo: i + 1,
          kapanNo: kapan,
          polishTypeCode: entries[i]['polishTypeCode'] as int?,
          shapeCode: entries[i]['shapeCode'] as int?,
          clarityCode: entries[i]['clarityCode'] as int?,
          charniCode: entries[i]['charniCode'] as int?,
          colorCode: entries[i]['colorCode'] as int?,
          pcs: int.tryParse(entries[i]['pcs']?.toString() ?? '0') ?? 0,
          wt: _num(entries[i]['wt']),
          lessRate: _num(entries[i]['lessRate']),
          lessAmount: _num(entries[i]['lessAmount']),
          rate: _num(entries[i]['rate']),
          amount: _num(entries[i]['amount']),
          finalAmount: _num(entries[i]['finalAmount']),
          roundOf: _num(entries[i]['roundOf']),
        ),
    ];

    final ok = await api.saveImport(master, items);
    if (ok) _resetForm();
  }

  void _handleDelete() {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit || _editMstId <= 0) return;
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this Import entry?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        Get.back();
        final ok = await api.deleteImport(_editMstId);
        if (ok) _resetForm();
      },
    );
  }

  void _handleCancel() {
    if (_editingEntryIndex != null) {
      setState(_clearEntryInputs);
      _polishTypeFocus.requestFocus();
      return;
    }
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      _editMstId = 0;
      entries.clear();
      _clearEntryInputs();
      idController.clear();
      kapanNoController.clear();
      dateController.clear();
      selectedDate = null;
      _initManager();
    });
  }

  // ==================== SEARCH ====================
  List<ImportMstModel> get _searchList {
    final list = api.importList.toList();
    if (!_isFiltered.value || fromDate == null || toDate == null) return list;
    final start = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
    final end = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
    return list.where((m) {
      final d = DateTime.tryParse(m.importDate ?? '');
      return d != null && !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  void _openSearch() {
    setState(() => _isSearch = true);
    _dataGridController.selectedRows.clear();
    api.getImportList(force: true);
  }

  Future<void> _loadForEdit(int id) async {
    if (_isLoadingRow) return;
    _isLoadingRow = true;
    try {
      final data = await api.getImportById(id);
      if (data == null || !mounted) return;
      final m = data.master;
      setState(() {
        _isSearch = false;
        _isFromEdit = true;
        _isEnabled = false;
        _editMstId = m.importMstID ?? id;
        idController.text = _editMstId.toString();
        selectedDate = DateTime.tryParse(m.importDate ?? '')?.toLocal();
        dateController.text = selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : '';
        _selectedManagerId.value = m.managerId;
        kapanNoController.text = m.kapanNo ?? '';
        _clearEntryInputs();
        entries = [
          for (final d in data.items)
            {
              'importDetID': d.importDetID,
              'kapanNo': d.kapanNo ?? m.kapanNo ?? '',
              'polishTypeCode': d.polishTypeCode,
              'shapeCode': d.shapeCode,
              'clarityCode': d.clarityCode,
              'charniCode': d.charniCode,
              'colorCode': d.colorCode,
              'pcs': d.pcs,
              'wt': d.wt.toStringAsFixed(3),
              'lessRate': d.lessRate.toStringAsFixed(2),
              'lessAmount': d.lessAmount.toStringAsFixed(2),
              'rate': d.rate.toStringAsFixed(2),
              'amount': d.amount.toStringAsFixed(2),
              'finalAmount': d.finalAmount.toStringAsFixed(2),
              'roundOf': d.roundOf.toStringAsFixed(2),
            },
        ];
      });
    } finally {
      _isLoadingRow = false;
      _dataGridController.selectedRows.clear();
    }
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Always read the loading flags so this Obx has something to listen to.
      api.isLoading.value;
      api.isDeleteLoading.value;
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? _enableFields : null,
        onEdit: (_isFromEdit && !_isEnabled) ? _enableEdit : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: _isSearch ? () => setState(() => _isSearch = false) : (_isEnabled ? _handleCancel : null),
        onExit: () => tabController.closeCurrentTab(),
        onSearch: () => _isSearch ? setState(() => _isSearch = false) : _openSearch(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) Header(title: _isSearch ? 'Import Search' : ':: Import Entry ::'),
              Expanded(child: _isSearch ? _buildSearchView() : _buildFormView()),
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionTitle(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      );

  Widget _buildFormView() {
    return LayoutBuilder(builder: (context, viewConstraints) {
      final bool isMobile = viewConstraints.maxWidth < _mobileWidth;
      final double cardPad = isMobile ? 10 : 16;
      final double gap = isMobile ? 10 : 16;
      return _formBody(isMobile ? 4 : 8, cardPad, gap);
    });
  }

  Widget _formBody(double outerPad, double cardPad, double gap) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(outerPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. MAIN DETAILS
          Card(
            child: Padding(
              padding: EdgeInsets.all(cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.diamond_outlined, 'MainDetails'),
                  const Divider(height: 20),
                  LayoutBuilder(builder: (context, constraints) {
                    final idField = AppTextField(
                      label: 'ID :',
                      controller: idController,
                      enabled: false,
                      readOnly: true,
                      hintText: 'Auto',
                    );
                    final dateField = AppTextField(
                      label: 'Date :',
                      controller: dateController,
                      focusNode: _dateFocus,
                      enabled: _isEnabled,
                      readOnly: true,
                      prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                      onTap: _isEnabled ? _openDatePicker : null,
                    );
                    final managerField = Obx(() => AppDropdown<int>(
                          label: 'Manager :',
                          value: _selectedManagerId.value,
                          items: _managerItems,
                          dropdownItems: _managerAppItems,
                          focusNode: _managerFocus,
                          nextFocusNode: _kapanNoFocus,
                          isEnabled: _isEnabled && _isManagerEnabled,
                          hintText: 'Select Manager',
                          searchHint: 'Search manager...',
                          prefixIcon: const Icon(Icons.person_rounded, size: 16),
                          onChanged: (val) => _selectedManagerId.value = val,
                        ));
                    final kapanField = AppTextField(
                      label: 'Kapan No :',
                      controller: kapanNoController,
                      focusNode: _kapanNoFocus,
                      nextFocusNode: _polishTypeFocus,
                      enabled: _isEnabled,
                      hintText: 'Kapan No',
                      onChanged: _onKapanChanged,
                      onFieldSubmitted: (_) => _polishTypeFocus.requestFocus(),
                    );
                    final double w = constraints.maxWidth;
                    if (w >= _tabletWidth) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: idField),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: dateField),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: managerField),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: kapanField),
                        ],
                      );
                    }
                    final idDate = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 2, child: idField),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: dateField),
                    ]);
                    if (w >= _mobileWidth) {
                      // tablet: 2 x 2
                      return Column(children: [
                        idDate,
                        const SizedBox(height: 10),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: managerField),
                          const SizedBox(width: 10),
                          Expanded(child: kapanField),
                        ]),
                      ]);
                    }
                    // mobile: ID + Date, then Manager, then Kapan No
                    return Column(children: [
                      idDate,
                      const SizedBox(height: 10),
                      managerField,
                      const SizedBox(height: 10),
                      kapanField,
                    ]);
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: gap),

          // 2. SUB DETAILS (quick entry)
          Card(
            child: Padding(
              padding: EdgeInsets.all(cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.list_alt_rounded, 'SubDetails'),
                  const Divider(height: 20),
                  Obx(() => _buildEntryRow()),
                ],
              ),
            ),
          ),
          SizedBox(height: gap),

          // 3. ITEMS TABLE
          Card(
            child: Padding(
              padding: EdgeInsets.all(cardPad),
              child: _buildEntriesTable(),
            ),
          ),
          SizedBox(height: gap),

          // 4. ACTIONS
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: cardPad, vertical: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!_isEnabled)
                    AppButton(text: 'Add', icon: Icons.add_circle_outline_rounded, onPressed: _enableFields),
                  if (_isFromEdit && !_isEnabled)
                    AppButton(
                      text: 'Edit',
                      variant: AppButtonVariant.outline,
                      icon: Icons.edit_note_rounded,
                      onPressed: _enableEdit,
                    ),
                  if (_isEnabled)
                    AppButton(
                      text: 'Save',
                      icon: Icons.save_rounded,
                      isLoading: api.isLoading.value,
                      onPressed: _handleSave,
                    ),
                  if (_isFromEdit)
                    AppButton(
                      text: 'Delete',
                      variant: AppButtonVariant.danger,
                      icon: Icons.delete_outline_rounded,
                      isLoading: api.isDeleteLoading.value,
                      onPressed: _isEnabled ? _handleDelete : null,
                    ),
                  if (_isEnabled)
                    AppButton(
                      text: 'Cancel',
                      variant: AppButtonVariant.outline,
                      icon: Icons.cancel_outlined,
                      onPressed: _handleCancel,
                    ),
                  AppButton(
                    text: 'Exit',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.exit_to_app_rounded,
                    onPressed: () => tabController.closeCurrentTab(),
                  ),
                  AppButton(
                    text: 'Search',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.search_rounded,
                    onPressed: _openSearch,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow() {
    Widget dropdown(String label, RxString value, List<DropdownMenuItem<String>> items, FocusNode focus,
        FocusNode next) {
      return AppDropdown<String>(
        label: label,
        focusNode: focus,
        nextFocusNode: next,
        isEnabled: _isEnabled,
        value: value.value.isEmpty ? null : value.value,
        items: items,
        hintText: label,
        onChanged: (val) => value.value = val ?? '',
      );
    }

    final polishType = dropdown('Polish Type', _selectedPolishType, _polishTypeItems, _polishTypeFocus, _shapeFocus);
    final shape = dropdown('Shape', _selectedShape, _shapeItems, _shapeFocus, _clarityFocus);
    final clarity = dropdown('Clarity', _selectedClarity, _clarityItems, _clarityFocus, _charniFocus);
    final charni = dropdown('Charni (+/-)', _selectedCharni, _charniItems, _charniFocus, _colorFocus);
    final color = dropdown('Color', _selectedColor, _colorItems, _colorFocus, _pcsFocus);

    final pcs = AppTextField(
      label: 'Pcs',
      controller: pcsController,
      focusNode: _pcsFocus,
      nextFocusNode: _wtFocus,
      enabled: _isEnabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      hintText: '0',
      onFieldSubmitted: (_) => _wtFocus.requestFocus(),
    );
    final wt = AppTextField(
      label: 'Wt *',
      controller: wtController,
      focusNode: _wtFocus,
      nextFocusNode: _lessRateFocus,
      enabled: _isEnabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(_dec3)],
      hintText: '0.000',
      onChanged: (_) => setState(() => _recalcItem()),
      onFieldSubmitted: (_) => _lessRateFocus.requestFocus(),
    );
    final lessRate = AppTextField(
      label: 'Less Rate *',
      controller: lessRateController,
      focusNode: _lessRateFocus,
      nextFocusNode: _finalAmountFocus,
      enabled: _isEnabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(_dec2)],
      hintText: '0.00',
      onChanged: (_) => setState(() => _recalcItem()),
      onFieldSubmitted: (_) => _finalAmountFocus.requestFocus(),
    );
    AppTextField readOnlyField(String label, TextEditingController c) =>
        AppTextField(label: label, controller: c, enabled: false, readOnly: true, hintText: '0.00');
    final finalAmount = AppTextField(
      label: 'Final Amount',
      controller: finalAmountController,
      focusNode: _finalAmountFocus,
      enabled: _isEnabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(_signedDec2)],
      hintText: '0.00',
      onChanged: (_) => setState(_recalcRoundOf),
      onFieldSubmitted: (_) => _addEntry(),
    );

    final isEditingItem = _editingEntryIndex != null;
    Widget addButton({double? width}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          width: width,
          text: isEditingItem ? 'Update' : (width != null ? 'Add' : ''),
          icon: isEditingItem ? Icons.check_rounded : Icons.add_rounded,
          // shortcutLabel: 'Enter',
          onPressed: _isEnabled ? _addEntry : null,
        ),
        if (isEditingItem) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            tooltip: 'Cancel',
            onPressed: _isEnabled ? () => setState(_clearEntryInputs) : null,
          ),
        ],
      ],
    );

    // widths: base width + share of any extra space (row scrolls when narrow)
    final fields = <_EntryField>[
      _EntryField(polishType, 125, 0.09),
      _EntryField(shape, 100, 0.08),
      _EntryField(clarity, 100, 0.08),
      _EntryField(charni, 100, 0.08),
      _EntryField(color, 85, 0.07),
      _EntryField(pcs, 45, 0.05),
      _EntryField(wt, 70, 0.07),
      _EntryField(lessRate, 70, 0.08),
      _EntryField(readOnlyField('Less Amount', lessAmountController), 80, 0.08),
      _EntryField(readOnlyField('Rate', rateController), 70, 0.07),
      _EntryField(readOnlyField('Amount', amountController), 80, 0.08),
      _EntryField(finalAmount, 80, 0.08),
      _EntryField(readOnlyField('Round Of', roundOfController), 70, 0.07),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final double avail = constraints.maxWidth.isFinite ? constraints.maxWidth : _entryRowWidth;

      // Wide desktop: everything on one line, as on Polish Purchase.
      if (avail >= _entryRowWidth) {
        final double extra = avail - _entryRowWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final f in fields) ...[
              SizedBox(width: f.width + extra * f.share, child: f.child),
              const SizedBox(width: 8),
            ],
            addButton(),
          ],
        );
      }

      // Small desktop / tablet / mobile: fields wrap into a grid.
      final int cols = avail >= 1000
          ? 7
          : avail >= _mobileWidth
              ? 5
              : avail >= 480
                  ? 3
                  : 2;
      const double spacing = 10;
      final double cellWidth = ((avail - spacing * (cols - 1)) / cols).floorToDouble();
      final bool fullWidthButton = avail < _mobileWidth;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final f in fields) SizedBox(width: cellWidth, child: f.child),
              if (!fullWidthButton) SizedBox(width: cellWidth, child: Align(alignment: Alignment.bottomLeft, child: addButton())),
            ],
          ),
          if (fullWidthButton) ...[
            const SizedBox(height: 12),
            addButton(width: isEditingItem ? avail - 52 : avail),
          ],
        ],
      );
    });
  }

  // ==================== ITEMS TABLE (all fields + Kapan No) ====================
  Widget _cell(String text, {bool header = false, TextAlign align = TextAlign.left}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          textAlign: align,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: header ? FontWeight.bold : FontWeight.normal,
            color: header ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      );

  String _name(String Function(dynamic) fn, dynamic code) {
    if (code == null || code.toString().isEmpty || code == 0) return '-';
    final n = fn(code);
    return n.trim().isEmpty ? code.toString() : n;
  }

  /// Items table on every screen size; when the screen is smaller than the
  /// table it scrolls sideways (with a visible scroll bar).
  Widget _buildEntriesTable() {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: Column(children: [
          Icon(Icons.diamond_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('No import items added yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
      );
    }

    const r = TextAlign.right;
    const c = TextAlign.center;
    final headerColor = AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final footerColor = AppColors.isDark ? const Color(0xFF0F172A) : const Color(0xFFEDF2F7);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(builder: (context, constraints) {
          const double minWidth = 1450;
          final double width = constraints.maxWidth.isFinite && constraints.maxWidth > minWidth
              ? constraints.maxWidth
              : minWidth;
          return Scrollbar(
            controller: _tableScroll,
            thumbVisibility: width > constraints.maxWidth,
            child: SingleChildScrollView(
            controller: _tableScroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: width > constraints.maxWidth ? 10 : 0),
            child: SizedBox(
              width: width,
              child: Table(
                border: TableBorder(horizontalInside: BorderSide(color: AppColors.borderLight, width: 1)),
                columnWidths: const {
                  0: FixedColumnWidth(48), // Srno
                  1: FlexColumnWidth(1.4), // Kapan No
                  2: FlexColumnWidth(1.6), // Polish Type
                  3: FlexColumnWidth(1.4), // Shape
                  4: FlexColumnWidth(1.4), // Clarity
                  5: FlexColumnWidth(1.4), // Charni
                  6: FlexColumnWidth(1.2), // Color
                  7: FixedColumnWidth(55), // Pcs
                  8: FixedColumnWidth(80), // Wt
                  9: FixedColumnWidth(85), // Less Rate
                  10: FixedColumnWidth(100), // Less Amount
                  11: FixedColumnWidth(80), // Rate
                  12: FixedColumnWidth(100), // Amount
                  13: FixedColumnWidth(105), // Final Amount
                  14: FixedColumnWidth(80), // Round Of
                  15: FixedColumnWidth(85), // Actions
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: headerColor),
                    children: [
                      _cell('Srno', header: true, align: c),
                      _cell('Kapan No', header: true),
                      _cell('Polish Type', header: true),
                      _cell('Shape', header: true),
                      _cell('Clarity', header: true),
                      _cell('Charni', header: true),
                      _cell('Color', header: true),
                      _cell('Pcs', header: true, align: r),
                      _cell('Wt', header: true, align: r),
                      _cell('Less Rate', header: true, align: r),
                      _cell('Less Amount', header: true, align: r),
                      _cell('Rate', header: true, align: r),
                      _cell('Amount', header: true, align: r),
                      _cell('Final Amount', header: true, align: r),
                      _cell('Round Of', header: true, align: r),
                      _cell('Actions', header: true, align: c),
                    ],
                  ),
                  for (int i = 0; i < entries.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: _editingEntryIndex == i
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : (i.isEven ? AppColors.surface : AppColors.tableRowAlt),
                      ),
                      children: [
                        _cell('${i + 1}', align: c),
                        _cell(entries[i]['kapanNo']?.toString() ?? ''),
                        _cell(_name(getPolishTypeName, entries[i]['polishTypeCode'])),
                        _cell(_name(getShapeName, entries[i]['shapeCode'])),
                        _cell(_name(getClarityName, entries[i]['clarityCode'])),
                        _cell(_name(getCharniName, entries[i]['charniCode'])),
                        _cell(_name(getColorName, entries[i]['colorCode'])),
                        _cell(entries[i]['pcs']?.toString() ?? '0', align: r),
                        _cell(entries[i]['wt']?.toString() ?? '0.000', align: r),
                        _cell(entries[i]['lessRate']?.toString() ?? '0.00', align: r),
                        _cell(entries[i]['lessAmount']?.toString() ?? '0.00', align: r),
                        _cell(entries[i]['rate']?.toString() ?? '0.00', align: r),
                        _cell(entries[i]['amount']?.toString() ?? '0.00', align: r),
                        _cell(entries[i]['finalAmount']?.toString() ?? '0.00', align: r),
                        _cell(entries[i]['roundOf']?.toString() ?? '0.00', align: r),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _editingEntryIndex == i ? Icons.edit : Icons.edit_outlined,
                                size: 16,
                                color: _isEnabled
                                    ? (_editingEntryIndex == i ? AppColors.primary : AppColors.textSecondary)
                                    : AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Edit Item',
                              onPressed: _isEnabled ? () => _loadEntryForEdit(i) : null,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: _isEnabled ? AppColors.danger : AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Delete Item',
                              onPressed: _isEnabled ? () => _removeEntry(i) : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  TableRow(
                    decoration: BoxDecoration(color: footerColor),
                    children: [
                      _cell('Total', header: true, align: c),
                      for (int k = 0; k < 6; k++) _cell('', header: true),
                      _cell('$totalPcs', header: true, align: r),
                      _cell(totalWt.toStringAsFixed(3), header: true, align: r),
                      _cell(avgLessRate.toStringAsFixed(2), header: true, align: r),
                      _cell(totalLessAmount.toStringAsFixed(2), header: true, align: r),
                      _cell(avgRate.toStringAsFixed(2), header: true, align: r),
                      _cell(totalAmount.toStringAsFixed(2), header: true, align: r),
                      _cell(totalFinalAmount.toStringAsFixed(2), header: true, align: r),
                      _cell(totalRoundOf.toStringAsFixed(2), header: true, align: r),
                      _cell('', header: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          );
        }),
      ),
    );
  }

  // ==================== SEARCH VIEW ====================
  GridColumn _col(String name, double width, {Alignment align = Alignment.centerRight}) => GridColumn(
        columnName: name,
        width: width,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: align,
          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      );

  Future<void> _pickFilterDate(bool from) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (from ? fromDate : toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        fromDate = picked;
        fromDateController.text = DateFormat('dd-MMM-yy').format(picked);
      } else {
        toDate = picked;
        toDateController.text = DateFormat('dd-MMM-yy').format(picked);
      }
    });
  }

  Widget _buildSearchView() {
    final fromField = AppTextField(
      label: 'From Date :',
      controller: fromDateController,
      readOnly: true,
      prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
      onTap: () => _pickFilterDate(true),
    );
    final toField = AppTextField(
      label: 'To :',
      controller: toDateController,
      readOnly: true,
      prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
      onTap: () => _pickFilterDate(false),
    );
    final buttons = <Widget>[
      AppButton(
        text: 'Show',
        icon: Icons.filter_alt_rounded,
        onPressed: () => setState(() => _isFiltered.value = fromDate != null && toDate != null),
      ),
      AppButton(
        text: 'Cancel',
        variant: AppButtonVariant.outline,
        icon: Icons.clear_all_rounded,
        onPressed: () => setState(() {
          fromDate = null;
          toDate = null;
          fromDateController.clear();
          toDateController.clear();
          _isFiltered.value = false;
          _isSearch = false;
        }),
      ),
      AppButton(
        text: 'Refresh',
        variant: AppButtonVariant.outline,
        icon: Icons.refresh_rounded,
        onPressed: () => api.getImportList(force: true),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter bar: full width, From / To share the free space.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final dates = Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: fromField),
                const SizedBox(width: 12),
                Expanded(child: toField),
              ],
            );
            if (constraints.maxWidth >= _mobileWidth) {
              // one line: dates fill the width, buttons on the right
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: dates),
                  for (final b in buttons) ...[const SizedBox(width: 12), b],
                ],
              );
            }
            // mobile: dates full width, buttons below
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                dates,
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: buttons),
              ],
            );
          }),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, gridConstraints) => Obx(() {
            final source = ImportDataGridSource(_searchList, managerName: _managerName);
            // Columns stretch to the full width (in proportion); on a smaller
            // screen they keep these widths and the grid scrolls sideways.
            const base = <String, double>{
              'ID': 60, 'Date': 95, 'Manager': 150, 'Kapan No': 120, 'Pcs': 70, 'Wt': 95,
              'Less Amount': 115, 'Amount': 115, 'Final Amount': 115, 'Round Of': 90,
            };
            final double baseTotal = base.values.fold(0.0, (a, b) => a + b);
            final double avail = gridConstraints.maxWidth.isFinite ? gridConstraints.maxWidth - 4 : baseTotal;
            final double scale = avail > baseTotal ? avail / baseTotal : 1.0;
            double w(String name) => (base[name]! * scale).floorToDouble();
            void open(RowColumnIndex rc) {
              final i = rc.rowIndex - 1;
              final rows = source.effectiveRows;
              if (i < 0 || i >= rows.length) return;
              final id = rows[i].getCells().first.value as int?;
              if (id != null && id > 0) _loadForEdit(id);
            }

            return AppDataGrid(
              controller: _dataGridController,
              source: source,
              allowSorting: true,
              allowFiltering: true,
              allowColumnsResizing: true,
              rowHeight: 30,
              headerRowHeight: 36,
              columnWidthMode: ColumnWidthMode.none,
              selectionMode: SelectionMode.single,
              columns: [
                _col('ID', w('ID'), align: Alignment.center),
                _col('Date', w('Date'), align: Alignment.center),
                _col('Manager', w('Manager'), align: Alignment.centerLeft),
                _col('Kapan No', w('Kapan No'), align: Alignment.centerLeft),
                _col('Pcs', w('Pcs')),
                _col('Wt', w('Wt')),
                _col('Less Amount', w('Less Amount')),
                _col('Amount', w('Amount')),
                _col('Final Amount', w('Final Amount')),
                _col('Round Of', w('Round Of')),
              ],
              tableSummaryRows: [
                GridTableSummaryRow(
                  showSummaryInRow: false,
                  position: GridTableSummaryRowPosition.bottom,
                  columns: const [
                    GridSummaryColumn(name: 'count', columnName: 'ID', summaryType: GridSummaryType.count),
                    GridSummaryColumn(name: 'Pcs', columnName: 'Pcs', summaryType: GridSummaryType.sum),
                    GridSummaryColumn(name: 'Wt', columnName: 'Wt', summaryType: GridSummaryType.sum),
                    GridSummaryColumn(name: 'Less Amount', columnName: 'Less Amount', summaryType: GridSummaryType.sum),
                    GridSummaryColumn(name: 'Amount', columnName: 'Amount', summaryType: GridSummaryType.sum),
                    GridSummaryColumn(name: 'Final Amount', columnName: 'Final Amount', summaryType: GridSummaryType.sum),
                    GridSummaryColumn(name: 'Round Of', columnName: 'Round Of', summaryType: GridSummaryType.sum),
                  ],
                ),
              ],
              onCellTap: (d) => open(d.rowColumnIndex),
              onCellDoubleTap: (d) => open(d.rowColumnIndex),
            );
          })),
        ),
      ],
    );
  }
}

/// One field of the sub-details row: base width + share of extra space.
class _EntryField {
  final Widget child;
  final double width;
  final double share;

  const _EntryField(this.child, this.width, this.share);
}
