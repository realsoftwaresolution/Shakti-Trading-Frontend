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
import 'package:real_web_rough_entry_system/polish_purchase/polish_purchase_datagrid.dart';
import 'package:real_web_rough_entry_system/polish_purchase/polish_purchase_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PolishPurchaseFormScreen extends StatefulWidget {
  final bool showHeader;

  const PolishPurchaseFormScreen({super.key, required this.showHeader});

  @override
  PolishPurchaseFormScreenState createState() =>
      PolishPurchaseFormScreenState();
}

class PolishPurchaseFormScreenState extends State<PolishPurchaseFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmpolishpurchaseform',
        'polish purchase',
      ]);
  // ==================== MASTER HEADER CONTROLLERS ====================
  final TextEditingController idController = TextEditingController();
  final TextEditingController crIdController = TextEditingController();
  final TextEditingController invNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final RxString _selectedTypeParty = ''.obs;
  final RxString _selectedTypeBroker = ''.obs;
  final TextEditingController dueDaysController =
      TextEditingController(text: '0');
  final TextEditingController dueDateController = TextEditingController();
  final RxString _selectedCurrency = 'RS'.obs;
  final TextEditingController dollarRateController =
      TextEditingController(text: '71.000');
  final RxString _selectedType = 'LOOSE'.obs;

  // ==================== SUB-DETAILS (POLISH ITEM) CONTROLLERS ====================
  final RxString _selectedPolishType = ''.obs;
  final RxString _selectedShape = ''.obs;
  final RxString _selectedClarity = ''.obs;
  final RxString _selectedCharni = ''.obs;
  final RxString _selectedColor = ''.obs;
  final TextEditingController pcsController = TextEditingController();
  final TextEditingController wtController = TextEditingController();
  final TextEditingController rateRsController = TextEditingController();
  final TextEditingController amountRsController =
      TextEditingController(text: '0.000');
  final TextEditingController rateDollarController = TextEditingController();
  final TextEditingController amountDollarController =
      TextEditingController(text: '0.000');

  // ==================== BOTTOM SECTION: CALCULATIONS ====================
  final RxBool _chkBro = false.obs;
  final TextEditingController broPerController = TextEditingController();
  final TextEditingController broFixDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController broRsController =
      TextEditingController(text: '0.000');

  final RxBool _chkAdd = false.obs;
  final TextEditingController addPerController = TextEditingController();
  final TextEditingController addFixDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController addFixRsController =
      TextEditingController(text: '0.000');

  final RxBool _chkLess = false.obs;
  final TextEditingController lessPerController = TextEditingController();
  final TextEditingController lessFixDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController lessFixRsController =
      TextEditingController(text: '0.000');

  final TextEditingController remarksController = TextEditingController();

  final TextEditingController netAmtDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController netAmtRsController =
      TextEditingController(text: '0.000');

  final TextEditingController roundOfDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController roundOfRsController =
      TextEditingController(text: '0.000');

  final TextEditingController finalAmtDollarController =
      TextEditingController(text: '0.000');
  final TextEditingController finalAmtRsController =
      TextEditingController(text: '0.000');

  // ==================== FOCUS NODES ====================
  final FocusNode _invNoFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _partyFocus = FocusNode();
  final FocusNode _brokerFocus = FocusNode();
  final FocusNode _dueDaysFocus = FocusNode();
  final FocusNode _dueDateFocus = FocusNode();
  final FocusNode _currencyFocus = FocusNode();
  final FocusNode _dollarRateFocus = FocusNode();
  final FocusNode _typeFocus = FocusNode();

  final FocusNode _polishTypeFocus = FocusNode();
  final FocusNode _shapeFocus = FocusNode();
  final FocusNode _clarityFocus = FocusNode();
  final FocusNode _charniFocus = FocusNode();
  final FocusNode _colorFocus = FocusNode();
  final FocusNode _pcsFocus = FocusNode();
  final FocusNode _wtFocus = FocusNode();
  final FocusNode _rateRsFocus = FocusNode();
  final FocusNode _rateDollarFocus = FocusNode();
  final FocusNode _remarksFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();
  final DefaultController defaultController = Get.find<DefaultController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> entries = [];
  final RxInt selectedPolishPurMstID = 0.obs;
  int? _editingEntryIndex;

  DateTime? selectedDate;
  String? dueDate;

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;
  bool _isConvertingRate = false;
  final RxBool _isFiltered = false.obs;

  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  RxList<PolishPurchaseModel> polishPurchaseGridSource =
      <PolishPurchaseModel>[].obs;
  RxList<PolishPurchaseModel> filteredDataGridSource =
      <PolishPurchaseModel>[].obs;
  Worker? _listWorker;

  // ==================== ITEM TOTAL COMPUTATIONS ====================
  bool get isUsd =>
      _selectedCurrency.value == 'USD' || _selectedCurrency.value == '\$';

  int get totalPc => entries.fold(
      0, (prev, e) => prev + (int.tryParse(e['pcs']?.toString() ?? '0') ?? 0));

  double get totalWt => entries.fold(0.0,
      (prev, e) => prev + (double.tryParse(e['wt']?.toString() ?? '0') ?? 0.0));

  double get totalAmountRs => entries.fold(
      0.0,
      (prev, e) =>
          prev + (double.tryParse(e['amountRs']?.toString() ?? '0') ?? 0.0));

  double get totalAmountDollar => entries.fold(
      0.0,
      (prev, e) =>
          prev +
          (double.tryParse(e['amountDollar']?.toString() ?? '0') ?? 0.0));

  double get avgRateRs => totalWt == 0 ? 0.0 : totalAmountRs / totalWt;

  double get avgRateDollar => totalWt == 0 ? 0.0 : totalAmountDollar / totalWt;

  @override
  void initState() {
    super.initState();
    crIdController.text = defaultController.effectiveCrId;
    wtController.addListener(_updateItemAmount);

    _dateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _partyFocus.requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled) _openDatePicker();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _dueDateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _currencyFocus.requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled) _openDueDatePicker();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    polishPurchaseGridSource.value =
        List<PolishPurchaseModel>.from(defaultController.polishPurchaseList);

    _listWorker = ever(defaultController.polishPurchaseList, (list) {
      if (mounted) {
        if (_isFiltered.value) {
          _applyDateFilter();
        } else {
          polishPurchaseGridSource.value = List<PolishPurchaseModel>.from(list);
        }
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultController.polishPurchaseList.isEmpty) {
        defaultController.getPolishPurchaseData();
      }
      if (defaultController.partyMstList.isEmpty) {
        defaultController.getPartyData();
      }
      if (defaultController.polishTypeModelList.isEmpty) {
        defaultController.getPolishTypeData();
      }
      if (defaultController.shapeModelList.isEmpty) {
        defaultController.getShapeData();
      }
      if (defaultController.clarityModelList.isEmpty) {
        defaultController.getClarityData();
      }
      if (defaultController.charniModelList.isEmpty) {
        defaultController.getCharniData();
      }
      if (defaultController.colorModelList.isEmpty) {
        defaultController.getColorData();
      }
    });
  }

  @override
  void dispose() {
    _listWorker?.dispose();

    idController.dispose();
    crIdController.dispose();
    invNoController.dispose();
    dateController.dispose();
    dueDaysController.dispose();
    dueDateController.dispose();
    dollarRateController.dispose();

    pcsController.dispose();
    wtController.dispose();
    rateRsController.dispose();
    amountRsController.dispose();
    rateDollarController.dispose();
    amountDollarController.dispose();

    broPerController.dispose();
    broFixDollarController.dispose();
    broRsController.dispose();
    addPerController.dispose();
    addFixDollarController.dispose();
    addFixRsController.dispose();
    lessPerController.dispose();
    lessFixDollarController.dispose();
    lessFixRsController.dispose();
    remarksController.dispose();

    netAmtDollarController.dispose();
    netAmtRsController.dispose();
    roundOfDollarController.dispose();
    roundOfRsController.dispose();
    finalAmtDollarController.dispose();
    finalAmtRsController.dispose();

    fromDateController.dispose();
    toDateController.dispose();

    _invNoFocus.dispose();
    _dateFocus.dispose();
    _partyFocus.dispose();
    _brokerFocus.dispose();
    _dueDaysFocus.dispose();
    _dueDateFocus.dispose();
    _currencyFocus.dispose();
    _dollarRateFocus.dispose();
    _typeFocus.dispose();

    _polishTypeFocus.dispose();
    _shapeFocus.dispose();
    _clarityFocus.dispose();
    _charniFocus.dispose();
    _colorFocus.dispose();
    _pcsFocus.dispose();
    _wtFocus.dispose();
    _rateRsFocus.dispose();
    _rateDollarFocus.dispose();
    _remarksFocus.dispose();

    super.dispose();
  }

  // ==================== DATE PICKERS ====================
  Future<void> _openDatePicker() async {
    if (!_isEnabled) return;
    final DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd-MM-yyyy').format(picked);
        _recalculateDueDate();
      });
    }
    _partyFocus.requestFocus();
  }

  Future<void> _openDueDatePicker() async {
    if (!_isEnabled) return;
    final DateTime initial = selectedDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked.toIso8601String();
        dueDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        if (selectedDate != null) {
          final diff = picked.difference(selectedDate!).inDays;
          dueDaysController.text = diff > 0 ? diff.toString() : '0';
        }
      });
    }
    _currencyFocus.requestFocus();
  }

  void _recalculateDueDate() {
    if (selectedDate != null) {
      final days = int.tryParse(dueDaysController.text.trim()) ?? 0;
      final calcDue = selectedDate!.add(Duration(days: days));
      dueDate = calcDue.toIso8601String();
      dueDateController.text = DateFormat('dd-MM-yyyy').format(calcDue);
    }
  }

  // ==================== DROPDOWNS ====================
  List<DropdownMenuItem<String>> get dropdownItemsParty {
    final list = defaultController.partyMstList
        .where((p) {
          final isPurParty = p.typeCode == 1 ||
              p.typeCode == 0 ||
              (p.partyType?.toUpperCase() == 'PARTY');
          final matchesComp = defaultController.companyCode.value == 0 ||
              p.companyCode == defaultController.companyCode.value;
          return isPurParty && matchesComp;
        })
        .map((p) => DropdownMenuItem<String>(
              value: p.partyCode.toString(),
              child: Text(p.partyName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();

    if (list.isEmpty) {
      return defaultController.partyMstList
          .map((p) => DropdownMenuItem<String>(
                value: p.partyCode.toString(),
                child: Text(p.partyName ?? '',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ))
          .toList();
    }
    return list;
  }

  List<DropdownMenuItem<String>> get dropdownItemsBroker {
    final list = defaultController.partyMstList
        .where((p) {
          final isBroker = (p.partyType != null &&
                  p.partyType!.trim().toUpperCase() == 'BROKER') ||
              p.typeCode == 5;
          final matchesComp = defaultController.companyCode.value == 0 ||
              p.companyCode == defaultController.companyCode.value;
          return isBroker && matchesComp;
        })
        .map((p) => DropdownMenuItem<String>(
              value: p.partyCode.toString(),
              child: Text(p.partyName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();

    return list;
  }

  List<DropdownMenuItem<String>> get dropdownItemsPolishType {
    if (defaultController.polishTypeModelList.isEmpty) {
      return const [
        DropdownMenuItem(value: 'CVD', child: Text('CVD')),
        DropdownMenuItem(value: 'HPHT', child: Text('HPHT')),
        DropdownMenuItem(value: 'NATURAL', child: Text('NATURAL')),
      ];
    }
    return defaultController.polishTypeModelList
        .map((p) => DropdownMenuItem<String>(
              value: p.polishTypeCode?.toString() ?? p.polishTypeName ?? '',
              child: Text(p.polishTypeName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsShape {
    if (defaultController.shapeModelList.isEmpty) {
      return const [
        DropdownMenuItem(value: 'MIX', child: Text('MIX')),
        DropdownMenuItem(value: 'ROUND', child: Text('ROUND')),
        DropdownMenuItem(value: 'PEAR', child: Text('PEAR')),
        DropdownMenuItem(value: 'MARQUISE', child: Text('MARQUISE')),
        DropdownMenuItem(value: 'OVAL', child: Text('OVAL')),
      ];
    }
    return defaultController.shapeModelList
        .map((s) => DropdownMenuItem<String>(
              value: s.shapeCode?.toString() ?? s.shapeName ?? '',
              child: Text(s.shapeName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsClarity {
    if (defaultController.clarityModelList.isEmpty) {
      return const [
        DropdownMenuItem(value: 'MIX', child: Text('MIX')),
        DropdownMenuItem(value: 'VVS1', child: Text('VVS1')),
        DropdownMenuItem(value: 'VS1', child: Text('VS1')),
        DropdownMenuItem(value: 'SI1', child: Text('SI1')),
      ];
    }
    return defaultController.clarityModelList
        .map((c) => DropdownMenuItem<String>(
              value: c.clarityMstID?.toString() ?? c.clarityName ?? '',
              child: Text(c.clarityName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsCharni {
    if (defaultController.charniModelList.isEmpty) {
      return const [
        DropdownMenuItem(value: 'MIX', child: Text('MIX')),
        DropdownMenuItem(value: '+2', child: Text('+2')),
        DropdownMenuItem(value: '-2', child: Text('-2')),
        DropdownMenuItem(value: '+11', child: Text('+11')),
      ];
    }
    return defaultController.charniModelList
        .map((c) => DropdownMenuItem<String>(
              value: c.charniCode?.toString() ?? c.charniName ?? '',
              child: Text(c.charniName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsColor {
    if (defaultController.colorModelList.isEmpty) {
      return const [
        DropdownMenuItem(value: 'MIX', child: Text('MIX')),
        DropdownMenuItem(value: 'D', child: Text('D')),
        DropdownMenuItem(value: 'E', child: Text('E')),
        DropdownMenuItem(value: 'F', child: Text('F')),
        DropdownMenuItem(value: 'G', child: Text('G')),
        DropdownMenuItem(value: 'H', child: Text('H')),
        DropdownMenuItem(value: 'I', child: Text('I')),
        DropdownMenuItem(value: 'J', child: Text('J')),
      ];
    }
    return defaultController.colorModelList
        .map((c) => DropdownMenuItem<String>(
              value: c.colorCode?.toString() ?? c.colorName ?? '',
              child: Text(c.colorName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsCurrency => const [
        DropdownMenuItem(
            value: 'USD',
            child: Text('USD (\$)', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(
            value: 'RS', child: Text('RS (₹)', style: TextStyle(fontSize: 13))),
      ];

  List<DropdownMenuItem<String>> get dropdownItemsType => const [
        DropdownMenuItem(value: 'LOOSE', child: Text('LOOSE')),
        DropdownMenuItem(value: 'SINGLE', child: Text('SINGLE')),
      ];

  // ==================== ITEM CALCULATIONS ====================
  void _updateItemAmount() {
    final double wt = double.tryParse(wtController.text) ?? 0.0;
    final double rateRs = double.tryParse(rateRsController.text) ?? 0.0;
    final double rateDollar = double.tryParse(rateDollarController.text) ?? 0.0;

    amountRsController.text = (wt * rateRs).toStringAsFixed(3);
    amountDollarController.text = (wt * rateDollar).toStringAsFixed(3);
  }

  void _onRateRsChanged(String val) {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    final double rateRs = double.tryParse(val) ?? 0.0;
    final double dollarRate =
        double.tryParse(dollarRateController.text) ?? 100.0;
    if (dollarRate > 0) {
      rateDollarController.text = (rateRs / dollarRate).toStringAsFixed(3);
    }
    _updateItemAmount();
    _isConvertingRate = false;
  }

  void _onRateDollarChanged(String val) {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    final double rateDollar = double.tryParse(val) ?? 0.0;
    final double dollarRate =
        double.tryParse(dollarRateController.text) ?? 100.0;
    rateRsController.text = (rateDollar * dollarRate).toStringAsFixed(3);
    _updateItemAmount();
    _isConvertingRate = false;
  }

  void _recalculateEntriesForExchangeRate() {
    final double dollarRate =
        double.tryParse(dollarRateController.text) ?? 100.0;
    final bool isUsdMode = isUsd;

    for (var entry in entries) {
      if (isUsdMode) {
        final double rD =
            double.tryParse(entry['rateDollar']?.toString() ?? '0') ?? 0.0;
        final double rRs = rD * dollarRate;
        final double wt =
            double.tryParse(entry['wt']?.toString() ?? '0') ?? 0.0;
        entry['rateRs'] = rRs.toStringAsFixed(3);
        entry['amountRs'] = (wt * rRs).toStringAsFixed(3);
      } else {
        final double rRs =
            double.tryParse(entry['rateRs']?.toString() ?? '0') ?? 0.0;
        final double rD = dollarRate > 0 ? rRs / dollarRate : 0.0;
        final double wt =
            double.tryParse(entry['wt']?.toString() ?? '0') ?? 0.0;
        entry['rateDollar'] = rD.toStringAsFixed(3);
        entry['amountDollar'] = (wt * rD).toStringAsFixed(3);
      }
    }
    _updateCalculations();
  }

  // ==================== BOTTOM EXPENSE & FINAL CALCULATIONS ====================
  void _updateCalculations() {
    final double dollarRate =
        double.tryParse(dollarRateController.text) ?? 100.0;
    final bool isUsdMode = isUsd;
    final double gridAmtD = totalAmountDollar;
    final double gridAmtRs = totalAmountRs;

    (double, double, double) calcRow({
      required bool isFix,
      required TextEditingController perCtrl,
      required TextEditingController fixDCtrl,
      required TextEditingController fixRCtrl,
      required double baseAmtD,
      required double baseAmtRs,
    }) {
      double p = double.tryParse(perCtrl.text) ?? 0.0;
      double d = 0.0;
      double r = 0.0;
      if (isFix) {
        if (isUsdMode) {
          d = double.tryParse(fixDCtrl.text) ?? 0.0;
          r = dollarRate > 0 ? d * dollarRate : 0.0;
          fixRCtrl.text = r.toStringAsFixed(3);
          p = (baseAmtD > 0 && d > 0) ? (d / baseAmtD) * 100 : 0.0;
        } else {
          r = double.tryParse(fixRCtrl.text) ?? 0.0;
          d = dollarRate > 0 ? r / dollarRate : 0.0;
          fixDCtrl.text = d.toStringAsFixed(3);
          p = (baseAmtRs > 0 && r > 0) ? (r / baseAmtRs) * 100 : 0.0;
        }
        perCtrl.text = p.toStringAsFixed(4);
      } else {
        if (p > 0) {
          d = baseAmtD * p / 100;
          r = baseAmtRs * p / 100;
          fixDCtrl.text = d.toStringAsFixed(3);
          fixRCtrl.text = r.toStringAsFixed(3);
        } else {
          fixDCtrl.text = '0.000';
          fixRCtrl.text = '0.000';
        }
      }
      return (p, d, r);
    }

    final (_, broD, broR) = calcRow(
      isFix: _chkBro.value,
      perCtrl: broPerController,
      fixDCtrl: broFixDollarController,
      fixRCtrl: broRsController,
      baseAmtD: gridAmtD,
      baseAmtRs: gridAmtRs,
    );

    final (_, addD, addR) = calcRow(
      isFix: _chkAdd.value,
      perCtrl: addPerController,
      fixDCtrl: addFixDollarController,
      fixRCtrl: addFixRsController,
      baseAmtD: gridAmtD,
      baseAmtRs: gridAmtRs,
    );

    final (_, lessD, lessR) = calcRow(
      isFix: _chkLess.value,
      perCtrl: lessPerController,
      fixDCtrl: lessFixDollarController,
      fixRCtrl: lessFixRsController,
      baseAmtD: gridAmtD,
      baseAmtRs: gridAmtRs,
    );

    // Final Amount = Total Grid Amount
    final double finD = gridAmtD;
    final double finR = gridAmtRs;
    finalAmtDollarController.text = finD.toStringAsFixed(3);
    finalAmtRsController.text = finR.toStringAsFixed(3);

    // Round Off
    double rndD = 0.0;
    double rndR = 0.0;
    if (isUsdMode) {
      rndD = double.tryParse(roundOfDollarController.text) ?? 0.0;
      rndR = dollarRate > 0 ? rndD * dollarRate : 0.0;
      roundOfRsController.text = rndR.toStringAsFixed(3);
    } else {
      rndR = double.tryParse(roundOfRsController.text) ?? 0.0;
      rndD = 0.0;
      roundOfDollarController.text = '0.000';
    }

    // Net Amount = Final Amount + Add - Less - Brokerage - Round Of
    final double netD = finD + addD - lessD - broD - rndD;
    final double netR = finR + addR - lessR - broR - rndR;
    netAmtDollarController.text = netD.toStringAsFixed(3);
    netAmtRsController.text = netR.toStringAsFixed(3);

    if (mounted) setState(() {});
  }

  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    if (_isFromEdit) {
      _handleCancel();
    }
    crIdController.text = defaultController.effectiveCrId;
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText:
            'Cannot add entry: Only users with a branch and designation code 4 are permitted to add entries.',
      );
      return;
    }
    setState(() {
      _isEnabled = true;
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        dateController.text = DateFormat('dd-MMM-yy').format(selectedDate!);
      }
      _recalculateDueDate();
    });
    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _invNoFocus.requestFocus();
      });
    }
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
    rateRsController.clear();
    amountRsController.text = '0.000';
    rateDollarController.clear();
    amountDollarController.text = '0.000';
  }

  void _addEntry() {
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText:
            'Cannot add entry: Only users with a branch and designation code 4 are permitted to add entries.',
      );
      return;
    }
    final polishType = _selectedPolishType.value.trim();
    if (polishType.isEmpty) {
      infoDialog(messageText: 'Please select Polish Type');
      _polishTypeFocus.requestFocus();
      return;
    }
    final double wt = double.tryParse(wtController.text.trim()) ?? 0.0;
    if (wt <= 0) {
      infoDialog(messageText: 'Please enter valid Weight');
      _wtFocus.requestFocus();
      return;
    }

    final double rateRs = double.tryParse(rateRsController.text.trim()) ?? 0.0;
    final double rateD =
        double.tryParse(rateDollarController.text.trim()) ?? 0.0;

    final entryData = {
      if (_editingEntryIndex != null) ...entries[_editingEntryIndex!],
      'srNo': _editingEntryIndex != null
          ? entries[_editingEntryIndex!]['srNo']
          : (entries.length + 1),
      // Name and code fields
      'polishType': polishType,
      'polishTypeCode': int.tryParse(_selectedPolishType.value) ?? 0,
      'shape': _selectedShape.value.isEmpty ? 'MIX' : _selectedShape.value,
      'shapeCode': int.tryParse(_selectedShape.value) ?? 0,
      'clarity': _selectedClarity.value.isEmpty ? 'MIX' : _selectedClarity.value,
      'clarityCode': int.tryParse(_selectedClarity.value) ?? 0,
      'charni': _selectedCharni.value.isEmpty ? 'MIX' : _selectedCharni.value,
      'charniCode': int.tryParse(_selectedCharni.value) ?? 0,
      'color': _selectedColor.value.isEmpty ? 'MIX' : _selectedColor.value,
      'colorCode': int.tryParse(_selectedColor.value) ??
          _resolveColorCode(_selectedColor.value),
      'pcs': int.tryParse(pcsController.text.trim()) ?? 0,
      'wt': wt.toStringAsFixed(3),
      'rateRs': rateRs.toStringAsFixed(3),
      'amountRs': (wt * rateRs).toStringAsFixed(3),
      'rateDollar': rateD.toStringAsFixed(3),
      'amountDollar': (wt * rateD).toStringAsFixed(3),
    };

    setState(() {
      if (_editingEntryIndex != null) {
        entries[_editingEntryIndex!] = entryData;
      } else {
        entries.add(entryData);
      }
      _clearEntryInputs();
      _updateCalculations();
    });

    _polishTypeFocus.requestFocus();
  }

  void _loadEntryForEdit(int index) {
    if (!_isEnabled) return;
    final item = entries[index];
    setState(() {
      _editingEntryIndex = index;
      _selectedPolishType.value = (item['polishTypeCode']?.toString() ?? item['polishType']?.toString() ?? '');
      _selectedShape.value = (item['shapeCode']?.toString() ?? item['shape']?.toString() ?? '');
      _selectedClarity.value = (item['clarityCode']?.toString() ?? item['clarity']?.toString() ?? '');
      _selectedCharni.value = (item['charniCode']?.toString() ?? item['charni']?.toString() ?? '');
      _selectedColor.value = (item['colorCode']?.toString() ?? item['color']?.toString() ?? '');
      pcsController.text = item['pcs']?.toString() ?? '0';
      wtController.text = item['wt']?.toString() ?? '';
      rateRsController.text = item['rateRs']?.toString() ?? '';
      amountRsController.text = item['amountRs']?.toString() ?? '0.000';
      rateDollarController.text = item['rateDollar']?.toString() ?? '';
      amountDollarController.text = item['amountDollar']?.toString() ?? '0.000';
    });
    _polishTypeFocus.requestFocus();
  }

  Future<void> _removeEntry(int index) async {
    if (!_isEnabled) return;
    if (index < 0 || index >= entries.length) return;

    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this polish item?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        Get.back();
        // Only removed from the list here. When editing, the database is
        // changed when the purchase is saved (all together), so Cancel keeps it.
        setState(() {
          entries.removeAt(index);
          for (int i = 0; i < entries.length; i++) {
            entries[i]['srNo'] = i + 1;
          }
          if (_editingEntryIndex == index) {
            _clearEntryInputs();
          } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
            _editingEntryIndex = _editingEntryIndex! - 1;
          }
          _updateCalculations();
        });
      },
    );
  }

  int _resolvePolishTypeCode(String? name) {
    if (name == null || name.isEmpty) return 0;
    final match = defaultController.polishTypeModelList.firstWhereOrNull(
      (m) =>
          m.polishTypeName?.toLowerCase().trim() == name.toLowerCase().trim(),
    );
    return match?.polishTypeCode ?? match?.polishTypeMstId ?? 0;
  }

  int _resolveShapeCode(String? name) {
    if (name == null || name.isEmpty) return 0;
    final match = defaultController.shapeModelList.firstWhereOrNull(
      (m) => m.shapeName?.toLowerCase().trim() == name.toLowerCase().trim(),
    );
    return match?.shapeCode ?? match?.shapeMstId ?? 0;
  }

  int _resolveClarityCode(String? name) {
    if (name == null || name.isEmpty) return 0;
    final match = defaultController.clarityModelList.firstWhereOrNull(
      (m) => m.clarityName?.toLowerCase().trim() == name.toLowerCase().trim(),
    );
    return match?.clarityMstID ?? 0;
  }

  int _resolveCharniCode(String? name) {
    if (name == null || name.isEmpty) return 0;
    final match = defaultController.charniModelList.firstWhereOrNull(
      (m) => m.charniName?.toLowerCase().trim() == name.toLowerCase().trim(),
    );
    return match?.charniCode ?? match?.charniMstID ?? 0;
  }

  int _resolveColorCode(String? name) {
    if (name == null || name.isEmpty) return 0;
    final match = defaultController.colorModelList.firstWhereOrNull(
      (m) =>
          m.colorName?.toLowerCase().trim() == name.toLowerCase().trim() ||
          m.colorCode?.toString() == name ||
          m.colorMstID?.toString() == name,
    );
    return match?.colorCode ?? match?.colorMstID ?? 0;
  }

  // ==================== SAVE / DELETE / CANCEL ====================
  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText:
            'Cannot save: Only users with a branch and designation code 4 are permitted to add/save entries.',
      );
      return;
    }
    if (_selectedTypeParty.value.isEmpty) {
      infoDialog(messageText: 'Please Select Party');
      _partyFocus.requestFocus();
      return;
    }
    if (entries.isEmpty) {
      infoDialog(messageText: 'Please Add at least one Polish Item');
      _polishTypeFocus.requestFocus();
      return;
    }

    final double dollarRate =
        double.tryParse(dollarRateController.text) ?? 100.0;
    final partyName = getPartyName(int.tryParse(_selectedTypeParty.value));
    final brokerName = _selectedTypeBroker.value.isNotEmpty
        ? getPartyName(int.tryParse(_selectedTypeBroker.value))
        : '';

    final invDateStr = selectedDate != null
        ? selectedDate!.toUtc().toIso8601String()
        : DateTime.now().toUtc().toIso8601String();
    final dueDateStr =
        (dueDate != null && dueDate!.isNotEmpty) ? dueDate! : invDateStr;

    final header = PolishPurchaseModel(
      polishPurMstID: selectedPolishPurMstID.value > 0
          ? selectedPolishPurMstID.value
          : null,
      crId: int.tryParse(crIdController.text.trim()),
      invoiceNo: invNoController.text.trim(),
      invoiceDate: invDateStr,
      partyCode: int.tryParse(_selectedTypeParty.value),
      partyName: partyName,
      brokerCode: int.tryParse(_selectedTypeBroker.value),
      brokerName: brokerName,
      dueDay: int.tryParse(dueDaysController.text.trim()) ?? 0,
      dueDate: dueDateStr,
      rdType: _selectedCurrency.value,
      exchange: dollarRate,
      type: _selectedType.value,
      totPcs: totalPc,
      totWt: totalWt,
      rateRs: avgRateRs,
      totAmtRs: totalAmountRs,
      rateDollar: avgRateDollar,
      totAmtDollar: totalAmountDollar,
      netAmtDollar: double.tryParse(netAmtDollarController.text) ?? 0.0,
      netAmtRs: double.tryParse(netAmtRsController.text) ?? 0.0,
      remarks: remarksController.text.trim(),
      finalAmtRs: double.tryParse(finalAmtRsController.text) ?? 0.0,
      finalAmtD: double.tryParse(finalAmtDollarController.text) ?? 0.0,
      roundOfRs: double.tryParse(roundOfRsController.text) ?? 0.0,
      roundOfD: double.tryParse(roundOfDollarController.text) ?? 0.0,
      chkBroker: _chkBro.value,
      brokerPer: double.tryParse(broPerController.text) ?? 0.0,
      brokerFixDollar: double.tryParse(broFixDollarController.text) ?? 0.0,
      brokerFixRs: double.tryParse(broRsController.text) ?? 0.0,
      chkAdd: _chkAdd.value,
      addPer: double.tryParse(addPerController.text) ?? 0.0,
      addFixDollar: double.tryParse(addFixDollarController.text) ?? 0.0,
      addFixRs: double.tryParse(addFixRsController.text) ?? 0.0,
      chkLess: _chkLess.value,
      lessPer: double.tryParse(lessPerController.text) ?? 0.0,
      lessFixDollar: double.tryParse(lessFixDollarController.text) ?? 0.0,
      lessFixRs: double.tryParse(lessFixRsController.text) ?? 0.0,
    );

    final details = entries.map((e) {
      final pType = e['polishType']?.toString(); 
      final shp = e['shape']?.toString();
      final clr = e['clarity']?.toString();
      final chr = e['charni']?.toString();
      final clrCol = e['color']?.toString();
      final colorCodeVal = (e['colorCode'] is int)
          ? e['colorCode'] as int
          : (int.tryParse(e['colorCode']?.toString() ?? '') ??
              _resolveColorCode(clrCol));
      final wtVal = double.tryParse(e['wt']?.toString() ?? '0.0') ?? 0.0;
      final rateRsVal =
          double.tryParse(e['rateRs']?.toString() ?? '0.0') ?? 0.0;
      final amtRsVal =
          double.tryParse(e['amountRs']?.toString() ?? '0.0') ?? 0.0;
      final rateDVal =
          double.tryParse(e['rateDollar']?.toString() ?? '0.0') ?? 0.0;
      final amtDVal =
          double.tryParse(e['amountDollar']?.toString() ?? '0.0') ?? 0.0;

      return PolishPurchaseDetailModel(
        polishPurDetID: e['polishPurDetID'] as int?,
        polishPurMstID: selectedPolishPurMstID.value > 0
            ? selectedPolishPurMstID.value
            : (e['polishPurMstID'] as int?),
        srNo: e['srNo'] as int?,
        polishTypeCode:
            e['polishTypeCode'] as int? ?? _resolvePolishTypeCode(pType),
        polishType: pType,
        shapeCode: e['shapeCode'] as int? ?? _resolveShapeCode(shp),
        shape: shp,
        clarityCode: e['clarityCode'] as int? ?? _resolveClarityCode(clr),
        clarity: clr,
        charniCode: e['charniCode'] as int? ?? _resolveCharniCode(chr),
        charni: chr,
        pcs: int.tryParse(e['pcs']?.toString() ?? '0'),
        wt: wtVal,
        rateRs: rateRsVal,
        amountRs: amtRsVal,
        rateDollar: rateDVal,
        amountDollar: amtDVal,
        packetID: e['packetID'] as int?,
        packetNo: e['packetNo']?.toString(),
        colorCode: colorCodeVal,
        cutCode: e['cutCode'],
        polishCode: e['polishCode'],
        symmetryCode: e['symmetryCode'],
        fluoCode: e['fluoCode'],
        diaMinW: e['diaMinW'],
        diaMaxL: e['diaMaxL'],
        diaHeightD: e['diaHeightD'],
        tableMM: e['tableMM'],
        tableDepth: e['tableDepth'],
        ca: e['ca'],
        ch: e['ch'],
        pa: e['pa'],
        ph: e['ph'],
        girdlePer: e['girdlePer'],
        girdle: e['girdle']?.toString(),
        gia: e['gia']?.toString(),
        igi: e['igi']?.toString(),
        ha: e['ha']?.toString(),
        ratio: e['ratio'],
        remarks: e['remarks']?.toString(),
        rs: e['rs'],
        disc: e['disc'],
        amount: e['amount'] ?? amtRsVal,
        nattsDisc: e['nattsDisc'],
        netAmount: e['netAmount'] ?? amtRsVal,
        rapaportMstID: e['rapaportMstID'],
        discountMstID: e['discountMstID'],
        rate: e['rate'] ?? rateRsVal,
        kno: e['kno']?.toString(),
      );
    }).toList();

    final bool ok;
    if (_isFromEdit) {
      ok = await defaultController.updatePolishPurchaseData(
          header: header, details: details);
    } else {
      ok = await defaultController.addPolishPurchaseData(
          header: header, details: details);
    }

    if (ok == true) {
      await defaultController.getPolishPurchaseData(force: true); // reload grid
      if (_isFiltered.value) {
        _applyDateFilter();
      } else {
        polishPurchaseGridSource.value =
            List<PolishPurchaseModel>.from(defaultController.polishPurchaseList);
      }
      _handleCancel();
    } else {
      // Show API error message if available
      infoDialog(messageText: 'Failed to save Polish Purchase.');
    }
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit || selectedPolishPurMstID.value <= 0) return;
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this Polish Purchase entry?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        Get.back();
        final ok = await defaultController
            .deletePolishPurchaseData(selectedPolishPurMstID.value);
        if (ok == true) {
          await defaultController.getPolishPurchaseData(force: true); // reload list
          if (_isFiltered.value) {
            _applyDateFilter();
          } else {
            polishPurchaseGridSource.value =
                List<PolishPurchaseModel>.from(defaultController.polishPurchaseList);
          }
          _handleCancel();
        } else {
          infoDialog(messageText: 'Failed to delete Polish Purchase.');
        }
      },
    );
  }

  void _handleCancel() {
    if (_editingEntryIndex != null) {
      setState(() {
        _clearEntryInputs();
      });
      _polishTypeFocus.requestFocus();
      return;
    }
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      selectedPolishPurMstID.value = 0;
      entries.clear();
      _clearEntryInputs();

      idController.clear();
      crIdController.text = defaultController.effectiveCrId;
      invNoController.clear();
      dateController.clear();
      _selectedTypeParty.value = '';
      _selectedTypeBroker.value = '';
      dueDaysController.text = '0';
      dueDateController.clear();
      _selectedCurrency.value = 'RS';
      dollarRateController.text = '71.000';
      _selectedType.value = 'LOOSE';

      _chkBro.value = false;
      broPerController.clear();
      broFixDollarController.text = '0.000';
      broRsController.text = '0.000';

      _chkAdd.value = false;
      addPerController.clear();
      addFixDollarController.text = '0.000';
      addFixRsController.text = '0.000';

      _chkLess.value = false;
      lessPerController.clear();
      lessFixDollarController.text = '0.000';
      lessFixRsController.text = '0.000';

      remarksController.clear();

      netAmtDollarController.text = '0.000';
      netAmtRsController.text = '0.000';
      roundOfDollarController.text = '0.000';
      roundOfRsController.text = '0.000';
      finalAmtDollarController.text = '0.000';
      finalAmtRsController.text = '0.000';

      selectedDate = null;
      dueDate = null;
    });
  }

  void _applyDateFilter() {
    if (fromDate == null || toDate == null) {
      polishPurchaseGridSource.value =
          List<PolishPurchaseModel>.from(defaultController.polishPurchaseList);
      _isFiltered.value = false;
      return;
    }

    final filtered = defaultController.polishPurchaseList.where((p) {
      if (p.invoiceDate == null) return false;
      final parsed = DateTime.tryParse(p.invoiceDate!);
      if (parsed == null) return false;
      final start = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
      final end =
          DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
      return parsed.isAfter(start.subtract(const Duration(seconds: 1))) &&
          parsed.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    filteredDataGridSource.value = filtered;
    polishPurchaseGridSource.value = filtered;
    _isFiltered.value = true;
  }

  void _removeDateFilter() {
    fromDate = null;
    toDate = null;
    fromDateController.clear();
    toDateController.clear();
    _isFiltered.value = false;
    polishPurchaseGridSource.value =
        List<PolishPurchaseModel>.from(defaultController.polishPurchaseList);
  }

  bool _isLoadingRow = false;
  void _clearGridSelection() {
    _dataGridController.selectedRow = null;
    _dataGridController.selectedRows.clear();
  }

  Future<void> _loadSelectedRowForEdit(DataGridRow row) async {
    if (_isLoadingRow) return;
    _isLoadingRow = true;
    try {
      final id = row.getCells()[0].value;
      if (id == null) return;
      final int mstId = id as int;

      setState(() {
        _isSearch = false;
        _isFromEdit = true;
        _isEnabled = false;
        selectedPolishPurMstID.value = mstId;
        entries.clear();
        _clearEntryInputs();
      });

      // Fetch fresh single Polish Purchase (master + details) from API 4
      final apiData = await defaultController.getPolishPurchaseById(mstId);
      final item =
          (apiData != null ? apiData['master'] as PolishPurchaseModel? : null) ??
              defaultController.polishPurchaseList
                  .firstWhereOrNull((p) => p.polishPurMstID == mstId);
      if (item == null) return;

      final List<PolishPurchaseDetailModel> itemDetails = (apiData != null
              ? (apiData['details'] as List<PolishPurchaseDetailModel>?)
              : null) ??
          defaultController.polishPurchaseDetailList
              .where((d) => d.polishPurMstID == mstId)
              .toList();

      setState(() {
        _isSearch = false;
        _isFromEdit = true;
        _isEnabled = false;
        selectedPolishPurMstID.value = mstId;

        idController.text = item.polishPurMstID?.toString() ?? '';
        crIdController.text = (item.crId != null && item.crId != 0)
            ? item.crId.toString()
            : defaultController.effectiveCrId;
        invNoController.text = item.invoiceNo ?? '';
        if (item.invoiceDate != null && item.invoiceDate!.isNotEmpty) {
          final parsed = DateTime.tryParse(item.invoiceDate!);
          if (parsed != null) {
            selectedDate = parsed;
            dateController.text = DateFormat('dd-MMM-yy').format(parsed);
          }
        }
        if (item.partyCode != null && item.partyCode! > 0) {
          _selectedTypeParty.value = item.partyCode!.toString();
        } else if (item.partyName != null && item.partyName!.isNotEmpty) {
          final match = defaultController.partyMstList.firstWhereOrNull(
            (p) =>
                p.partyName?.toLowerCase().trim() ==
                item.partyName!.toLowerCase().trim(),
          );
          if (match != null) {
            _selectedTypeParty.value =
                (match.partyCode ?? match.partyMstID)?.toString() ?? '';
          }
        } else {
          _selectedTypeParty.value = '';
        }

        if (item.brokerCode != null && item.brokerCode! > 0) {
          _selectedTypeBroker.value = item.brokerCode!.toString();
        } else if (item.brokerName != null && item.brokerName!.isNotEmpty) {
          final match = defaultController.partyMstList.firstWhereOrNull(
            (p) =>
                p.partyName?.toLowerCase().trim() ==
                item.brokerName!.toLowerCase().trim(),
          );
          if (match != null) {
            _selectedTypeBroker.value =
                (match.partyCode ?? match.partyMstID)?.toString() ?? '';
          }
        } else {
          _selectedTypeBroker.value = '';
        }

        dueDaysController.text = item.dueDay?.toString() ?? '0';
        if (item.dueDate != null && item.dueDate!.isNotEmpty) {
          final parsed = DateTime.tryParse(item.dueDate!);
          if (parsed != null) {
            dueDateController.text = DateFormat('dd-MM-yyyy').format(parsed);
            dueDate = item.dueDate;
          }
        }
        final rdt = item.rdType?.trim().toUpperCase();
        _selectedCurrency.value = (rdt == '\$' || rdt == 'USD') ? 'USD' : 'RS';
        dollarRateController.text = (item.exchange != null && item.exchange > 0)
            ? item.exchange.toString()
            : '71.000';
        final t = item.type?.trim().toUpperCase();
        _selectedType.value = (t == 'SINGLE') ? 'SINGLE' : 'LOOSE';

        _chkBro.value = item.chkBroker ?? false;
        broPerController.text = item.brokerPer != null && item.brokerPer != 0
            ? item.brokerPer.toString()
            : '';
        broFixDollarController.text = item.brokerFixDollar?.toString() ?? '0.000';
        broRsController.text = item.brokerFixRs?.toString() ?? '0.000';

        _chkAdd.value = item.chkAdd ?? false;
        addPerController.text =
            item.addPer != null && item.addPer != 0 ? item.addPer.toString() : '';
        addFixDollarController.text = item.addFixDollar?.toString() ?? '0.000';
        addFixRsController.text = item.addFixRs?.toString() ?? '0.000';

        _chkLess.value = item.chkLess ?? false;
        lessPerController.text = item.lessPer != null && item.lessPer != 0
            ? item.lessPer.toString()
            : '';
        lessFixDollarController.text = item.lessFixDollar?.toString() ?? '0.000';
        lessFixRsController.text = item.lessFixRs?.toString() ?? '0.000';

        remarksController.text = item.remarks ?? '';

        roundOfDollarController.text =
            item.roundOfD != null ? item.roundOfD!.toStringAsFixed(3) : '0.000';
        roundOfRsController.text = item.roundOfRs != null
            ? item.roundOfRs!.toStringAsFixed(3)
            : '0.000';

        entries.clear();
        for (var d in itemDetails) {
          entries.add({
            'polishPurDetID': d.polishPurDetID,
            'polishPurMstID': d.polishPurMstID,
            'srNo': d.srNo ?? (entries.length + 1),
            'polishTypeCode': d.polishTypeCode,
            'polishType': d.polishType ?? 'CVD',
            'shapeCode': d.shapeCode,
            'shape': d.shape ?? 'MIX',
            'clarityCode': d.clarityCode,
            'clarity': d.clarity ?? 'MIX',
            'charniCode': d.charniCode,
            'charni': d.charni ?? 'MIX',
            'pcs': d.pcs ?? 0,
            'wt': d.wt?.toString() ?? '0.000',
            'rateRs': d.rateRs?.toString() ?? '0.00',
            'amountRs': d.amountRs?.toString() ?? '0.00',
            'rateDollar': d.rateDollar?.toString() ?? '0.00',
            'amountDollar': d.amountDollar?.toString() ?? '0.00',
            'packetID': d.packetID,
            'packetNo': d.packetNo,
            'colorCode': d.colorCode,
            'color': getColorName(d.colorCode),
            'cutCode': d.cutCode,
            'polishCode': d.polishCode,
            'symmetryCode': d.symmetryCode,
            'fluoCode': d.fluoCode,
            'diaMinW': d.diaMinW,
            'diaMaxL': d.diaMaxL,
            'diaHeightD': d.diaHeightD,
            'tableMM': d.tableMM,
            'tableDepth': d.tableDepth,
            'ca': d.ca,
            'ch': d.ch,
            'pa': d.pa,
            'ph': d.ph,
            'girdlePer': d.girdlePer,
            'girdle': d.girdle,
            'gia': d.gia,
            'igi': d.igi,
            'ha': d.ha,
            'ratio': d.ratio,
            'remarks': d.remarks,
            'rs': d.rs,
            'disc': d.disc,
            'amount': d.amount,
            'nattsDisc': d.nattsDisc,
            'netAmount': d.netAmount,
            'rapaportMstID': d.rapaportMstID,
            'discountMstID': d.discountMstID,
            'rate': d.rate,
            'kno': d.kno,
          });
        }

        _updateCalculations();
      });
    } finally {
      _isLoadingRow = false;
      _clearGridSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onEdit: (_isFromEdit && !_isEnabled)
            ? () => setState(() => _isEnabled = true)
            : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: _isSearch
            ? () => setState(() => _isSearch = false)
            : (_isEnabled ? _handleCancel : null),
        onExit: () => tabController.closeCurrentTab(),
        onSearch: () {
          setState(() {
            _isSearch = !_isSearch;
          });
          if (_isSearch) {
            _clearGridSelection();
            defaultController.getPolishPurchaseData(force: true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader)
                Header(
                    title: _isSearch
                        ? 'Polish Purchase Search'
                        : ':: Polish Purchase Entry ::'),
              Expanded(
                child: _isSearch ? _buildSearchView() : _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== SEARCH VIEW (IMAGE 2) ====================
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
            children: [
              SizedBox(
                width: 150,
                child: AppTextField(
                  label: 'From Date :',
                  controller: fromDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        fromDate = picked;
                        fromDateController.text =
                            DateFormat('dd-MMM-yy').format(picked);
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
                  controller: toDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: toDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        toDate = picked;
                        toDateController.text =
                            DateFormat('dd-MMM-yy').format(picked);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Show',
                icon: Icons.filter_alt_rounded,
                onPressed: _applyDateFilter,
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.outline,
                icon: Icons.clear_all_rounded,
                onPressed: () {
                  _removeDateFilter();
                  setState(() {
                    _isSearch = false;
                  });
                  _clearGridSelection();
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Refresh',
                variant: AppButtonVariant.outline,
                icon: Icons.refresh_rounded,
                onPressed: () async {
                  await defaultController.getPolishPurchaseData(force: true);
                  if (_isFiltered.value) {
                    _applyDateFilter();
                  } else {
                    polishPurchaseGridSource.value =
                        List<PolishPurchaseModel>.from(
                            defaultController.polishPurchaseList);
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),

        // 19-Column Data Grid
        Expanded(
          child: Obx(() {
            final searchSource =
                PolishPurchaseDataGridSource(polishPurchaseGridSource);
            return AppDataGrid(
              controller: _dataGridController,
              source: searchSource,
            allowSorting: true,
            allowMultiColumnSorting: true,
            showSortNumbers: true,
            allowFiltering: true,
            allowColumnsResizing: true,
            rowHeight: 30,
            headerRowHeight: 36,
            columnWidthMode: ColumnWidthMode.none,
            selectionMode: SelectionMode.single,
            columns: <GridColumn>[
              GridColumn(
                columnName: 'ID',
                width: 55,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: const Text('ID',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'CrId',
                width: 60,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: const Text('CrId',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'InvoiceDate',
                width: 95,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: const Text('InvoiceDate',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Invoice No',
                width: 90,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Invoice No',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Party',
                width: 160,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Party',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Broker',
                width: 150,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Broker',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Rs / \$',
                width: 65,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: const Text('Rs / \$',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Exchange',
                width: 80,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Exchange',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Tot Wt',
                width: 95,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Tot Wt',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Rate Rs',
                width: 85,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Rate Rs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Tot Amt Rs',
                width: 105,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Tot Amt Rs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Rate (\$)',
                width: 85,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Rate (\$)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Tot Amt (\$)',
                width: 100,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Tot Amt (\$)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Net Amt Dollar',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Net Amt Dollar',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Net Amt Rs',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Net Amt Rs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Remarks',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Remarks',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Final Amt Rs',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Final Amt Rs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Final Amt \$',
                width: 100,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Final Amt \$',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Round Of Rs',
                width: 90,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Round Of Rs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              GridColumn(
                columnName: 'Round Of \$',
                width: 90,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Round Of \$',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
            tableSummaryRows: [
              GridTableSummaryRow(
                showSummaryInRow: false,
                columns: const <GridSummaryColumn>[
                  GridSummaryColumn(
                    name: 'ID_count',
                    columnName: 'ID',
                    summaryType: GridSummaryType.count,
                  ),
                  GridSummaryColumn(
                    name: 'Tot Wt',
                    columnName: 'Tot Wt',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Tot Amt Rs',
                    columnName: 'Tot Amt Rs',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Tot Amt (\$)',
                    columnName: 'Tot Amt (\$)',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Net Amt Dollar',
                    columnName: 'Net Amt Dollar',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Net Amt Rs',
                    columnName: 'Net Amt Rs',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Final Amt Rs',
                    columnName: 'Final Amt Rs',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Final Amt \$',
                    columnName: 'Final Amt \$',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Round Of Rs',
                    columnName: 'Round Of Rs',
                    summaryType: GridSummaryType.sum,
                  ),
                  GridSummaryColumn(
                    name: 'Round Of \$',
                    columnName: 'Round Of \$',
                    summaryType: GridSummaryType.sum,
                  ),
                ],
                position: GridTableSummaryRowPosition.bottom,
              ),
            ],
            onCellTap: (details) {
              if (details.rowColumnIndex.rowIndex <= 0) return;
              final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
              final rows = searchSource.effectiveRows;
              if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                _loadSelectedRowForEdit(rows[dataRowIndex]);
              }
            },
            onCellDoubleTap: (details) {
              if (details.rowColumnIndex.rowIndex <= 0) return;
              final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
              final rows = searchSource.effectiveRows;
              if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                _loadSelectedRowForEdit(rows[dataRowIndex]);
              }
            },
          );
        }),
      ),
      ],
    );
  }

  // ==================== FORM VIEW (IMAGE 1) ====================
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP MASTER HEADER CARD (MainDetails)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.diamond_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'MainDetails',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final idField = AppTextField(
                          label: 'ID :',
                          controller: idController,
                          enabled: false,
                          readOnly: true,
                          hintText: 'Auto',
                        );

                        final crIdField = AppTextField(
                          label: 'CrId :',
                          controller: crIdController,
                          enabled: false,
                          readOnly: true,
                          hintText: '',
                        );

                        final invoiceNoField = AppTextField(
                          label: 'Inv No :',
                          controller: invNoController,
                          focusNode: _invNoFocus,
                          nextFocusNode: _dateFocus,
                          enabled: _isEnabled,
                          hintText: 'e.g. HH03H01',
                          onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                        );

                        final dateField = AppTextField(
                          label: 'Inv Date :',
                          controller: dateController,
                          focusNode: _dateFocus,
                          nextFocusNode: _partyFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          onTap: _isEnabled ? _openDatePicker : null,
                          onFieldSubmitted: (_) => _partyFocus.requestFocus(),
                        );

                        final partyField = Obx(
                          () => AppDropdown<String>(
                            label: 'Party :',
                            focusNode: _partyFocus,
                            nextFocusNode: _brokerFocus,
                            isEnabled: _isEnabled,
                            value: _selectedTypeParty.value.isEmpty
                                ? null
                                : _selectedTypeParty.value,
                            items: dropdownItemsParty,
                            hintText: 'Select Party',
                            onChanged: (val) {
                              _selectedTypeParty.value = val ?? '';
                            },
                          ),
                        );

                        final brokerField = Obx(
                          () => AppDropdown<String>(
                            label: 'Broker :',
                            focusNode: _brokerFocus,
                            nextFocusNode: _dueDaysFocus,
                            isEnabled: _isEnabled,
                            value: _selectedTypeBroker.value.isEmpty
                                ? null
                                : _selectedTypeBroker.value,
                            items: dropdownItemsBroker,
                            hintText: 'Select Broker',
                            onChanged: (val) {
                              _selectedTypeBroker.value = val ?? '';
                            },
                          ),
                        );

                        final dueDaysField = AppTextField(
                          label: 'Due Day :',
                          controller: dueDaysController,
                          focusNode: _dueDaysFocus,
                          nextFocusNode: _currencyFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            _recalculateDueDate();
                          },
                          onFieldSubmitted: (_) =>
                              _currencyFocus.requestFocus(),
                        );

                        final dueDateField = AppTextField(
                          label: 'Due Date :',
                          controller: dueDateController,
                          focusNode: _dueDateFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          hintText: 'dd-MM-yyyy',
                          onTap: _isEnabled ? _openDueDatePicker : null,
                          onFieldSubmitted: (_) =>
                              _currencyFocus.requestFocus(),
                        );

                        final currencyField = Obx(
                          () => AppDropdown<String>(
                            label: 'Rs / \$ :',
                            focusNode: _currencyFocus,
                            nextFocusNode: _dollarRateFocus,
                            isEnabled: _isEnabled,
                            value: _selectedCurrency.value,
                            items: dropdownItemsCurrency,
                            onChanged: (val) {
                              _selectedCurrency.value = val ?? 'RS';
                              if (_selectedCurrency.value == 'RS') {
                                roundOfDollarController.text = '0.000';
                              } else {
                                final double dollarRate = double.tryParse(
                                        dollarRateController.text) ??
                                    100.0;
                                final double r =
                                    double.tryParse(roundOfRsController.text) ??
                                        0.0;
                                if (dollarRate > 0 && r > 0) {
                                  roundOfDollarController.text =
                                      (r / dollarRate).toStringAsFixed(3);
                                }
                              }
                              _recalculateEntriesForExchangeRate();
                            },
                          ),
                        );

                        final dollarRateField = AppTextField(
                          label: '\$ Rate :',
                          controller: dollarRateController,
                          focusNode: _dollarRateFocus,
                          nextFocusNode: _polishTypeFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          hintText: '71.000',
                          onChanged: (_) {
                            _recalculateEntriesForExchangeRate();
                          },
                          onFieldSubmitted: (_) =>
                              _polishTypeFocus.requestFocus(),
                        );

                        if (constraints.maxWidth >= 1000) {
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: idField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: crIdField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 3, child: invoiceNoField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 3, child: dateField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 4, child: partyField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 4, child: brokerField),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: dueDaysField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 3, child: dueDateField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: currencyField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: dollarRateField),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: idField),
                                  const SizedBox(width: 10),
                                  Expanded(child: crIdField),
                                  const SizedBox(width: 10),
                                  Expanded(child: invoiceNoField),
                                  const SizedBox(width: 10),
                                  Expanded(child: dateField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: partyField),
                                  const SizedBox(width: 10),
                                  Expanded(child: brokerField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: dueDaysField),
                                  const SizedBox(width: 10),
                                  Expanded(child: dueDateField),
                                  const SizedBox(width: 10),
                                  Expanded(child: currencyField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: dollarRateField),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. SUB-DETAILS INPUT ROW
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'SubDetails',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Obx(() {
                      final isUsdMode = isUsd;

                      final polishTypeField = AppDropdown<String>(
                        label: 'Polish Type',
                        focusNode: _polishTypeFocus,
                        nextFocusNode: _shapeFocus,
                        isEnabled: _isEnabled,
                        value: _selectedPolishType.value.isEmpty
                            ? null
                            : _selectedPolishType.value,
                        items: dropdownItemsPolishType,
                        hintText: 'Polish Type',
                        onChanged: (val) {
                          _selectedPolishType.value = val ?? '';
                        },
                      );

                      final shapeField = AppDropdown<String>(
                        label: 'Shape',
                        focusNode: _shapeFocus,
                        nextFocusNode: _clarityFocus,
                        isEnabled: _isEnabled,
                        value: _selectedShape.value.isEmpty
                            ? null
                            : _selectedShape.value,
                        items: dropdownItemsShape,
                        hintText: 'Shape',
                        onChanged: (val) {
                          _selectedShape.value = val ?? '';
                        },
                      );

                      final clarityField = AppDropdown<String>(
                        label: 'Clarity',
                        focusNode: _clarityFocus,
                        nextFocusNode: _charniFocus,
                        isEnabled: _isEnabled,
                        value: _selectedClarity.value.isEmpty
                            ? null
                            : _selectedClarity.value,
                        items: dropdownItemsClarity,
                        hintText: 'Clarity',
                        onChanged: (val) {
                          _selectedClarity.value = val ?? '';
                        },
                      );

                      final charniField = AppDropdown<String>(
                        label: 'Charni (+/-)',
                        focusNode: _charniFocus,
                        nextFocusNode: _colorFocus,
                        isEnabled: _isEnabled,
                        value: _selectedCharni.value.isEmpty
                            ? null
                            : _selectedCharni.value,
                        items: dropdownItemsCharni,
                        hintText: 'Charni',
                        onChanged: (val) {
                          _selectedCharni.value = val ?? '';
                        },
                      );

                      final colorField = AppDropdown<String>(
                        label: 'Color',
                        focusNode: _colorFocus,
                        nextFocusNode: _pcsFocus,
                        isEnabled: _isEnabled,
                        value: _selectedColor.value.isEmpty
                            ? null
                            : _selectedColor.value,
                        items: dropdownItemsColor,
                        hintText: 'Color',
                        onChanged: (val) {
                          _selectedColor.value = val ?? '';
                        },
                      );

                      final pcsField = AppTextField(
                        label: 'Pcs',
                        controller: pcsController,
                        focusNode: _pcsFocus,
                        nextFocusNode: _wtFocus,
                        enabled: _isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: '0',
                        onFieldSubmitted: (_) => _wtFocus.requestFocus(),
                      );

                      final wtField = AppTextField(
                        label: 'Wt',
                        controller: wtController,
                        focusNode: _wtFocus,
                        nextFocusNode:
                            isUsdMode ? _rateDollarFocus : _rateRsFocus,
                        enabled: _isEnabled,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        hintText: '0.000',
                        onChanged: (_) => _updateItemAmount(),
                        onFieldSubmitted: (_) =>
                            (isUsdMode ? _rateDollarFocus : _rateRsFocus)
                                .requestFocus(),
                      );

                      final rateRsField = AppTextField(
                        label: 'Rate (Rs)',
                        controller: rateRsController,
                        focusNode: _rateRsFocus,
                        nextFocusNode: isUsdMode ? _rateDollarFocus : null,
                        enabled: _isEnabled && !isUsdMode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        hintText: '0.000',
                        onChanged: _onRateRsChanged,
                        onFieldSubmitted:
                            !isUsdMode ? (_) => _addEntry() : null,
                      );

                      final amountRsField = AppTextField(
                        label: 'Amount (Rs)',
                        controller: amountRsController,
                        enabled: false,
                        hintText: '0.000',
                      );

                      final rateDollarField = AppTextField(
                        label: 'Rate (\$)',
                        controller: rateDollarController,
                        focusNode: _rateDollarFocus,
                        enabled: _isEnabled && isUsdMode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        hintText: '0.000',
                        onChanged: _onRateDollarChanged,
                        onFieldSubmitted: isUsdMode ? (_) => _addEntry() : null,
                      );

                      final amountDollarField = AppTextField(
                        label: 'Amount (\$)',
                        controller: amountDollarController,
                        enabled: false,
                        hintText: '0.000',
                      );

                      final isEditingItem = _editingEntryIndex != null;
                      final addButton = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            text: isEditingItem ? 'Update' : '',
                            icon: isEditingItem
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            shortcutLabel: 'Enter',
                            onPressed: _isEnabled ? _addEntry : null,
                          ),
                          if (isEditingItem) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              tooltip: 'Cancel Edit',
                              onPressed: _isEnabled
                                  ? () {
                                      setState(() {
                                        _clearEntryInputs();
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ],
                      );

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final double availWidth =
                              constraints.maxWidth.isFinite
                                  ? constraints.maxWidth
                                  : 1300.0;
                          final double totalWidth =
                              availWidth > 1300.0 ? availWidth : 1300.0;
                          final double extra = totalWidth - 1300.0;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 130 + (extra * 0.10),
                                    child: polishTypeField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 105 + (extra * 0.09),
                                    child: shapeField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 105 + (extra * 0.09),
                                    child: clarityField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 105 + (extra * 0.09),
                                    child: charniField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 105 + (extra * 0.09),
                                    child: colorField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 60 + (extra * 0.05),
                                    child: pcsField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 60 + (extra * 0.07), child: wtField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 85 + (extra * 0.09),
                                    child: rateRsField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 95 + (extra * 0.11),
                                    child: amountRsField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 95 + (extra * 0.10),
                                    child: rateDollarField),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 95 + (extra * 0.12),
                                    child: amountDollarField),
                                const SizedBox(width: 8),
                                addButton,
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. SUBDETAILS ITEMS TABLE CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEntriesTable(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. BOTTOM CALCULATIONS SECTION
            _buildCalculationsSection(),
            const SizedBox(height: 20),

            // 5. ACTION TOOLBAR BAR (Add, Edit, Save, Delete, Cancel, Exit, Search)
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!_isEnabled)
                      AppButton(
                        text: 'Add',
                        icon: Icons.add_circle_outline_rounded,
                        onPressed: () => _enableFields(),
                      ),
                    if (_isFromEdit && !_isEnabled)
                      AppButton(
                        text: 'Edit',
                        variant: AppButtonVariant.outline,
                        icon: Icons.edit_note_rounded,
                        onPressed: () => setState(() => _isEnabled = true),
                      ),
                    if (_isEnabled)
                      AppButton(
                        text: 'Save',
                        icon: Icons.save_rounded,
                        isLoading: defaultController.isLoading.value,
                        onPressed: _handleSave,
                      ),
                    if (_isFromEdit)
                      AppButton(
                        text: 'Delete',
                        variant: AppButtonVariant.danger,
                        icon: Icons.delete_outline_rounded,
                        isLoading: defaultController.isDeleteLoading.value,
                        onPressed: _handleDelete,
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
                      onPressed: () {
                        setState(() {
                          _isSearch = true;
                        });
                        _clearGridSelection();
                        defaultController.getPolishPurchaseData(force: true);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SUBDETAILS TABLE ====================
  Widget _buildEntriesTable() {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.diamond_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              'No polish items added yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 1080.0;
            final double tableWidth = availWidth > 1080.0 ? availWidth : 1080.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(48), // Srno
                    1: FlexColumnWidth(2.0), // Polish Type
                    2: FlexColumnWidth(1.8), // Shape
                    3: FlexColumnWidth(1.8), // Clarity
                    4: FlexColumnWidth(1.8), // Charni
                    5: FlexColumnWidth(1.8), // Color
                    6: FixedColumnWidth(60), // Pc
                    7: FixedColumnWidth(85), // Wt
                    8: FixedColumnWidth(95), // Rate Rs
                    9: FixedColumnWidth(105), // Amount Rs
                    10: FixedColumnWidth(95), // Rate Dollar
                    11: FixedColumnWidth(105), // Amount Dollar
                    12: FixedColumnWidth(85), // Actions
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8FAFC),
                      ),
                      children: [
                        _buildTableCell('Srno',
                            isHeader: true, align: TextAlign.center),
                        _buildTableCell('Polish Type', isHeader: true),
                        _buildTableCell('Shape', isHeader: true),
                        _buildTableCell('Clarity', isHeader: true),
                        _buildTableCell('Charni', isHeader: true),
                        _buildTableCell('Color', isHeader: true),
                        _buildTableCell('Pc',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Wt',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Rate Rs',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Amount Rs',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Rate Dollar',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Amount Dollar',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('Actions',
                            isHeader: true, align: TextAlign.center),
                      ],
                    ),

                    // Table Rows
                    for (int i = 0; i < entries.length; i++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: _editingEntryIndex == i
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (i.isEven
                                  ? AppColors.surface
                                  : AppColors.tableRowAlt),
                        ),
                        children: [
                          _buildTableCell('${i + 1}', align: TextAlign.center),
                          _buildTableCell(
                              getPolishTypeName(entries[i]['polishType'])),
                          _buildTableCell(getShapeName(entries[i]['shape'])),
                          _buildTableCell(
                              getClarityName(entries[i]['clarity'])),
                          _buildTableCell(getCharniName(entries[i]['charni'])),
                          _buildTableCell(getColorName(entries[i]['color'] ??
                              entries[i]['colorCode'])),
                          _buildTableCell(entries[i]['pcs']?.toString() ?? '0',
                              align: TextAlign.right),
                          _buildTableCell(
                              entries[i]['wt']?.toString() ?? '0.000',
                              align: TextAlign.right),
                          _buildTableCell(
                              entries[i]['rateRs']?.toString() ?? '0.000',
                              align: TextAlign.right),
                          _buildTableCell(
                              entries[i]['amountRs']?.toString() ?? '0.000',
                              align: TextAlign.right),
                          _buildTableCell(
                              entries[i]['rateDollar']?.toString() ?? '0.000',
                              align: TextAlign.right),
                          _buildTableCell(
                              entries[i]['amountDollar']?.toString() ?? '0.000',
                              align: TextAlign.right),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _editingEntryIndex == i
                                        ? Icons.edit
                                        : Icons.edit_outlined,
                                    size: 16,
                                    color: _isEnabled
                                        ? (_editingEntryIndex == i
                                            ? AppColors.primary
                                            : AppColors.textSecondary)
                                        : AppColors.textSecondary
                                            .withValues(alpha: 0.5),
                                  ),
                                  tooltip: 'Edit Item',
                                  onPressed: _isEnabled
                                      ? () => _loadEntryForEdit(i)
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: _isEnabled
                                        ? AppColors.danger
                                        : AppColors.textSecondary
                                            .withValues(alpha: 0.5),
                                  ),
                                  tooltip: 'Delete Item',
                                  onPressed: _isEnabled
                                      ? () => _removeEntry(i)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    // Total Footer Row (Image 1 totals)
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFEDF2F7),
                      ),
                      children: [
                        _buildTableCell('Total',
                            isHeader: true, align: TextAlign.center),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell('$totalPc',
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell(totalWt.toStringAsFixed(4),
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell(avgRateRs.toStringAsFixed(3),
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell(totalAmountRs.toStringAsFixed(3),
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell(avgRateDollar.toStringAsFixed(3),
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell(totalAmountDollar.toStringAsFixed(3),
                            isHeader: true, align: TextAlign.right),
                        _buildTableCell('', isHeader: true),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  // ==================== CALCULATIONS SECTION ====================
  Widget _buildCalculationsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;

        // Left Card: Brokerage, Add (+), Less (-), Remark
        final leftCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 158),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Per',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Fix (\$)',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Fix Rs',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Brokerage Row
                _buildCalcInputRow(
                  title: 'Brokerage :',
                  isFixChecked: _chkBro,
                  perController: broPerController,
                  fixDollarController: broFixDollarController,
                  fixRsController: broRsController,
                  onChanged: (_) => _updateCalculations(),
                ),

                // Add (+) Row
                _buildCalcInputRow(
                  title: 'Add (+) :',
                  isFixChecked: _chkAdd,
                  perController: addPerController,
                  fixDollarController: addFixDollarController,
                  fixRsController: addFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),

                // Less (-) Row
                _buildCalcInputRow(
                  title: 'Less (-) :',
                  isFixChecked: _chkLess,
                  perController: lessPerController,
                  fixDollarController: lessFixDollarController,
                  fixRsController: lessFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),

                const SizedBox(height: 8),

                // Remark Row
                Row(
                  children: [
                    const SizedBox(
                      width: 158,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('Remark :',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: remarksController,
                        focusNode: _remarksFocus,
                        enabled: _isEnabled,
                        hintText: 'Enter remarks',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        onFieldSubmitted: (_) => _handleSave(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        // Right Card: Net Amt, Round Of, Final Amt
        final rightCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryAmountRow(
                  labelDollar: 'Net Amt (\$) :',
                  ctrlDollar: netAmtDollarController,
                  labelRs: 'Rs',
                  ctrlRs: netAmtRsController,
                ),
                const SizedBox(height: 8),
                _buildRoundOfRow(),
                const SizedBox(height: 8),
                _buildSummaryAmountRow(
                  labelDollar: 'Final Amt (\$) :',
                  ctrlDollar: finalAmtDollarController,
                  labelRs: 'Rs',
                  ctrlRs: finalAmtRsController,
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: leftCard),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: rightCard),
            ],
          );
        } else {
          return Column(
            children: [
              leftCard,
              const SizedBox(height: 16),
              rightCard,
            ],
          );
        }
      },
    );
  }

  Widget _buildCalcInputRow({
    required String title,
    required RxBool isFixChecked,
    required TextEditingController perController,
    required TextEditingController fixDollarController,
    required TextEditingController fixRsController,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Obx(() {
        final bool isUsdMode = isUsd;
        final bool isFix = isFixChecked.value;

        return Row(
          children: [
            SizedBox(
              width: 58,
              child: InkWell(
                onTap: _isEnabled
                    ? () {
                        isFixChecked.value = !isFixChecked.value;
                        _updateCalculations();
                      }
                    : null,
                child: Row(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: isFix,
                        onChanged: _isEnabled
                            ? (val) {
                                isFixChecked.value = val ?? false;
                                _updateCalculations();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(isFix ? 'Fix' : 'Per',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: perController,
                enabled: _isEnabled && !isFix,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: fixDollarController,
                enabled: _isEnabled && isFix && isUsdMode,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: fixRsController,
                enabled: _isEnabled && isFix && !isUsdMode,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRoundOfRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Obx(() {
        final bool isUsdMode = isUsd;

        return Row(
          children: [
            const SizedBox(
              width: 110,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Round Of (\$) :',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: roundOfDollarController,
                enabled: _isEnabled && isUsdMode,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                onChanged: (_) => _updateCalculations(),
              ),
            ),
            const SizedBox(width: 12),
            const SizedBox(
              width: 30,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Text(
                    'Rs',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: roundOfRsController,
                enabled: _isEnabled && !isUsdMode,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                onChanged: (_) => _updateCalculations(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryAmountRow({
    required String labelDollar,
    required TextEditingController ctrlDollar,
    required String labelRs,
    required TextEditingController ctrlRs,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                labelDollar,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          child: AppTextField(
            controller: ctrlDollar,
            enabled: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                labelRs,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          child: AppTextField(
            controller: ctrlRs,
            enabled: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }
}
