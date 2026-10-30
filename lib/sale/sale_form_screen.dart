import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/sale/sale_datagrid.dart';
import 'package:real_web_rough_entry_system/sale/sale_details_model.dart';
import 'package:real_web_rough_entry_system/sale/sale_model.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';

class SaleFormScreen extends StatefulWidget {
  final bool showHeader;
  const SaleFormScreen({super.key, required this.showHeader});

  @override
  SaleFormScreenState createState() => SaleFormScreenState();
}

class SaleFormScreenState extends State<SaleFormScreen> {
  // Master Header Controllers
  final TextEditingController idController = TextEditingController(text: '0');
  final TextEditingController dateController = TextEditingController();
  final TextEditingController invoiceNoController = TextEditingController();
  final TextEditingController invDateController = TextEditingController();
  final TextEditingController termsController = TextEditingController(text: '0');
  final TextEditingController dueDateController = TextEditingController();

  // Broker & Party Info Controllers
  final TextEditingController brokerMobileController = TextEditingController();
  final TextEditingController partyContactController = TextEditingController();
  final TextEditingController partyAddressController = TextEditingController();
  final TextEditingController partyLocationController = TextEditingController();
  final TextEditingController partyMobileController = TextEditingController();
  final TextEditingController dollarRateController = TextEditingController(text: '100.00');

  // GST / Net / Round / Brokerage / Final summary (saved to PolishSaleLooseMst)
  final TextEditingController sgstPerController = TextEditingController(text: '0.000');
  final TextEditingController cgstPerController = TextEditingController(text: '0.000');
  final TextEditingController igstPerController = TextEditingController(text: '0.000');
  final TextEditingController netRsController = TextEditingController(text: '0.00');
  final TextEditingController broPerController = TextEditingController();

  // Quick Entry Controllers
  final TextEditingController invNoItemController = TextEditingController();
  final TextEditingController pcsController = TextEditingController(text: '1');
  final TextEditingController wtController = TextEditingController();
  final TextEditingController rateRsController = TextEditingController();
  final TextEditingController amountRsController = TextEditingController(text: '0.0000');
  final TextEditingController rateDollarController = TextEditingController(text: '0.0000');
  final TextEditingController amountDollarController = TextEditingController(text: '0.0000');
  final TextEditingController penWtController = TextEditingController();
  final TextEditingController descripController = TextEditingController();

  // Search Filter Controllers
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Focus Nodes
  final FocusNode _idFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _invoiceNoFocus = FocusNode();
  final FocusNode _invDateFocus = FocusNode();
  final FocusNode _termsFocus = FocusNode();
  final FocusNode _dueDateFocus = FocusNode();
  final FocusNode _fromManagerFocus = FocusNode();
  final FocusNode _brokerFocus = FocusNode();
  final FocusNode _partyFocus = FocusNode();
  final FocusNode _currencyFocus = FocusNode();
  final FocusNode _dollarRateFocus = FocusNode();

  final FocusNode _typeFocus = FocusNode();
  final FocusNode _itemInvFocus = FocusNode();
  final FocusNode _qualityFocus = FocusNode();
  final FocusNode _shapeFocus = FocusNode();
  final FocusNode _colorFocus = FocusNode();
  final FocusNode _clarityFocus = FocusNode();
  final FocusNode _charniFocus = FocusNode();
  final FocusNode _pcsFocus = FocusNode();
  final FocusNode _wtFocus = FocusNode();
  final FocusNode _rateRsFocus = FocusNode();
  final FocusNode _rateDollarFocus = FocusNode();
  final FocusNode _penWtFocus = FocusNode();
  final FocusNode _searchKeyBoardFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();

  // State Variables
  List<Map<String, dynamic>> entries = [];
  final Rxn<int> _selectedFromManagerId = Rxn<int>();
  final RxString _selectedTypeBroker = '22'.obs;
  final RxString _selectedTypeParty = ''.obs;
  final RxString _selectedCurrency = 'RS'.obs;

  // Item Quick Entry Observables
  final RxString _selectedItemType = 'ROUGH'.obs;
  final RxString _selectedItemInvNo = ''.obs;
  final RxString _selectedQuality = ''.obs;
  final RxString _selectedShape = ''.obs;
  final RxString _selectedColor = ''.obs;
  final RxString _selectedClarity = ''.obs;
  final RxString _selectedCharni = ''.obs;
  final RxInt selectedPolishSaleMstID = 0.obs;
  final RxString selectedItemDetId = ''.obs;
  int? _editingEntryIndex;

  DateTime? selectedDate;
  DateTime? selectedInvDate;
  String? dueDate;
  DateTime? fromDate;
  DateTime? toDate;

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;
  bool _isConvertingRate = false;
  final RxBool _isFiltered = false.obs;
  final RxBool _chkPrint = false.obs;
  final RxBool _chkPreview = true.obs;
  final _formKey = GlobalKey<FormState>();

  final DefaultController defaultController = Get.find<DefaultController>();

  RxList<PolishSaleModel> saleDataGridSource = <PolishSaleModel>[].obs;
  RxList<PolishSaleModel> filteredDataGridSource = <PolishSaleModel>[].obs;
  Worker? _listWorker;
  Worker? _userListWorker;

  // ==================== MANAGER ROLE LOGIC (Same as Branch Transfer) ====================
  bool get isCurrentUserTypeUser {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'USER' || !defaultController.isAdmin;
  }

  bool get _isFromManagerEnabled {
    if (isCurrentUserTypeUser) {
      return false;
    }
    return true;
  }

  void _initFromManager() {
    if (isCurrentUserTypeUser) {
      final currentUserId = defaultController.currentUserId.value;
      _selectedFromManagerId.value = currentUserId > 0 ? currentUserId : null;
    } else {
      final adminBranch = defaultController.effectiveBranchCode;
      if (adminBranch > 0 && _selectedFromManagerId.value != null) {
        final inBranch = defaultController.userModelList.any(
          (u) =>
              u.counterMstId == _selectedFromManagerId.value &&
              u.branchCode == adminBranch,
        );
        if (!inBranch) {
          _selectedFromManagerId.value = null;
        }
      }
      if (_selectedFromManagerId.value == null && fromManagerUsers.isNotEmpty) {
        _selectedFromManagerId.value = fromManagerUsers.first.counterMstId;
      }
    }
  }

  List<UserModel> get fromManagerUsers {
    if (isCurrentUserTypeUser) {
      final currentUserId = defaultController.currentUserId.value;
      return defaultController.userModelList
          .where((u) => u.counterMstId == currentUserId)
          .toList();
    }

    final adminBranch = defaultController.effectiveBranchCode;
    if (adminBranch > 0) {
      return defaultController.userModelList
          .where((u) => u.branchCode == adminBranch)
          .toList();
    }
    return defaultController.userModelList;
  }

  List<DropdownMenuItem<int>> _buildFromManagerDropdownItems() {
    return fromManagerUsers.where((u) => u.counterMstId != null).map((u) {
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

  List<AppDropdownItem<int>> _buildFromManagerAppDropdownItems() {
    return fromManagerUsers.where((u) => u.counterMstId != null).map((u) {
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
      );
    }).toList();
  }

  // ==================== CALCULATION GETTERS ====================
  int get totalPacket => entries.fold(
      0, (prev, e) => prev + (int.tryParse(e['pcs']?.toString() ?? '1') ?? 1));

  double get totalWt => entries.fold(
      0.0, (prev, e) => prev + (double.tryParse(e['wt']?.toString() ?? '0') ?? 0.0));

  double get totalAmountRs => entries.fold(
      0.0,
      (prev, e) =>
          prev +
          (double.tryParse(e['amountRs']?.toString() ?? e['amount']?.toString() ?? '0') ??
              0.0));

  double get totalRateRs => totalWt == 0 ? 0.0 : totalAmountRs / totalWt;

  double get totalAmountDollar => entries.fold(
      0.0,
      (prev, e) =>
          prev + (double.tryParse(e['amountDollar']?.toString() ?? '0') ?? 0.0));

  double get totalRateDollar => totalWt == 0 ? 0.0 : totalAmountDollar / totalWt;

  // ==================== GST / NET / ROUND / BROKERAGE / FINAL ====================
  // Same calculation as the old Polish Sale screen:
  //   Tot          = item totals                         (Rs and $)
  //   GST amt      = Tot x GST %
  //   Gross        = Tot + GST
  //   Net Rs       = typed (defaults to Gross);  Net $ = Net Rs / dollar rate
  //   Round        = Gross - Net
  //   Brokerage    = Tot x Brokerage %
  //   Final        = Gross - Brokerage

  double _num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  double get sgstPer => _num(sgstPerController);
  double get cgstPer => _num(cgstPerController);
  double get igstPer => _num(igstPerController);
  double get broPer => _num(broPerController);
  double get _dollarRateValue => double.tryParse(dollarRateController.text.trim()) ?? 0.0;

  double get sgstRs => totalAmountRs * sgstPer / 100;
  double get cgstRs => totalAmountRs * cgstPer / 100;
  double get igstRs => totalAmountRs * igstPer / 100;
  double get sgstDollar => totalAmountDollar * sgstPer / 100;
  double get cgstDollar => totalAmountDollar * cgstPer / 100;
  double get igstDollar => totalAmountDollar * igstPer / 100;

  double get grossRs => totalAmountRs + sgstRs + cgstRs + igstRs;
  double get grossDollar => totalAmountDollar + sgstDollar + cgstDollar + igstDollar;

  double get netRs => double.tryParse(netRsController.text.trim()) ?? grossRs;
  double get netDollar => _dollarRateValue > 0 ? netRs / _dollarRateValue : grossDollar;

  double get roundRs => grossRs - netRs;
  double get roundDollar => grossDollar - netDollar;

  double get broRs => totalAmountRs * broPer / 100;
  double get broDollar => totalAmountDollar * broPer / 100;

  double get finalRs => grossRs - broRs;
  double get finalDollar => grossDollar - broDollar;

  /// Re-calculates Net Rs from items + GST. Called whenever items, GST % or
  /// the dollar rate change; a Net Rs typed by the user stays until then.
  void _recalcSummary() {
    // The summary card listens to these controllers, so no setState is needed.
    final String net = grossRs.toStringAsFixed(2);
    if (netRsController.text != net) netRsController.text = net;
  }

  void _resetSummary() {
    sgstPerController.text = '0.000';
    cgstPerController.text = '0.000';
    igstPerController.text = '0.000';
    broPerController.clear();
    netRsController.text = '0.00';
  }

  double _r(double v, int d) => double.parse(v.toStringAsFixed(d));

  /// Values saved into PolishSaleLooseMst.
  Map<String, dynamic> _summaryPayload() => {
        'SGstPer': _r(sgstPer, 3),
        'CGstPer': _r(cgstPer, 3),
        'IGstPer': _r(igstPer, 3),
        'SGstAmont': _r(sgstRs, 2),
        'CGstAmont': _r(cgstRs, 2),
        'IGstAmont': _r(igstRs, 2),
        'SGstUsdAmont': _r(sgstDollar, 3),
        'CGstUsdAmont': _r(cgstDollar, 3),
        'IGstUsdAmont': _r(igstDollar, 3),
        'TotRsAmt': _r(totalAmountRs, 2),
        'TotUsdAmt': _r(totalAmountDollar, 3),
        'RoundRs': _r(roundRs, 2),
        'RoundUsd': _r(roundDollar, 3),
        'NetRsAmount': _r(netRs, 2),
        'NetUsdAmount': _r(netDollar, 3),
        'BroPer': _r(broPer, 3),
        'BroRsAmount': _r(broRs, 2),
        'BroUSDAmount': _r(broDollar, 3),
        'FinalRsAmount': _r(finalRs, 2),
        'FinalUsdAmount': _r(finalDollar, 3),
      };

  // Backwards compatibility aliases
  double get totalAmount => totalAmountRs;
  double get totalRate => totalRateRs;

  @override
  void initState() {
    super.initState();
    wtController.addListener(_updateItemAmountFromRs);
    rateRsController.addListener(_updateItemAmountFromRs);
    rateDollarController.addListener(_updateItemAmountFromDollar);
    dollarRateController.addListener(_updateItemAmountFromRs);
    termsController.addListener(_recalculateDueDate);
    sgstPerController.addListener(_recalcSummary);
    cgstPerController.addListener(_recalcSummary);
    igstPerController.addListener(_recalcSummary);
    dollarRateController.addListener(_recalcSummary);

    _dateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _invDateFocus.requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled && !_isFromEdit) _openDatePicker(isInvDate: false);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _invDateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _termsFocus.requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled && !_isFromEdit) _openDatePicker(isInvDate: true);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _dueDateFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          if (_isFromManagerEnabled) {
            _fromManagerFocus.requestFocus();
          } else {
            _brokerFocus.requestFocus();
          }
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isEnabled) _openDueDatePicker();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    saleDataGridSource.value = defaultController.polishSaleList;

    _listWorker = ever(defaultController.polishSaleList, (list) {
      if (mounted) {
        saleDataGridSource.value = list;
        setState(() {});
      }
    });

    _userListWorker = ever(defaultController.userModelList, (_) {
      if (mounted) {
        _initFromManager();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadMasterData();
      if (defaultController.polishSaleList.isEmpty) {
        defaultController.getSaleData();
      }
      if (defaultController.saleDetailsList.isEmpty) {
        defaultController.getSaleDetailsData();
      }
      if (defaultController.partyMstList.isEmpty) {
        defaultController.getPartyData();
      }
      if (defaultController.purchaseDataList.isEmpty) {
        defaultController.getPurchaseData();
      }
      if (defaultController.polishPurchaseList.isEmpty) {
        defaultController.getPolishPurchaseData();
      }
      defaultController.ensurePolishPurchaseDetailsLoaded();
      if (defaultController.roughModel.isEmpty) {
        defaultController.getRoughData();
      }
      if (defaultController.qualityModelList.isEmpty) {
        defaultController.getQualityData();
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
      if (defaultController.charniModelList.isEmpty) {
        defaultController.getCharniData();
      }
      if (defaultController.userModelList.isEmpty) {
        await defaultController.getUserData();
      }
      _initFromManager();
      _updateBrokerDetails(_selectedTypeBroker.value);
    });
  }

  void _loadMasterData() {
    if (defaultController.purchaseDataList.isEmpty) defaultController.getPurchaseData();
    if (defaultController.roughDetailsModel.isEmpty) defaultController.getPurchaseDetailsData();
    if (defaultController.polishPurchaseList.isEmpty) defaultController.getPolishPurchaseData();
    defaultController.ensurePolishPurchaseDetailsLoaded();
    if (defaultController.roughModel.isEmpty) defaultController.getRoughData();
    if (defaultController.qualityModelList.isEmpty) defaultController.getQualityData();
    if (defaultController.shapeModelList.isEmpty) defaultController.getShapeData();
    if (defaultController.colorModelList.isEmpty) defaultController.getColorData();
    if (defaultController.clarityModelList.isEmpty) defaultController.getClarityData();
    if (defaultController.charniModelList.isEmpty) defaultController.getCharniData();
  }

  @override
  void dispose() {
    _listWorker?.dispose();
    _userListWorker?.dispose();

    wtController.removeListener(_updateItemAmountFromRs);
    rateRsController.removeListener(_updateItemAmountFromRs);
    rateDollarController.removeListener(_updateItemAmountFromDollar);
    dollarRateController.removeListener(_updateItemAmountFromRs);
    termsController.removeListener(_recalculateDueDate);
    sgstPerController.removeListener(_recalcSummary);
    cgstPerController.removeListener(_recalcSummary);
    igstPerController.removeListener(_recalcSummary);
    dollarRateController.removeListener(_recalcSummary);
    sgstPerController.dispose();
    cgstPerController.dispose();
    igstPerController.dispose();
    netRsController.dispose();
    broPerController.dispose();

    idController.dispose();
    dateController.dispose();
    invoiceNoController.dispose();
    invDateController.dispose();
    termsController.dispose();
    dueDateController.dispose();
    brokerMobileController.dispose();
    partyContactController.dispose();
    partyAddressController.dispose();
    partyLocationController.dispose();
    partyMobileController.dispose();
    dollarRateController.dispose();

    invNoItemController.dispose();
    pcsController.dispose();
    wtController.dispose();
    rateRsController.dispose();
    amountRsController.dispose();
    rateDollarController.dispose();
    amountDollarController.dispose();
    penWtController.dispose();
    descripController.dispose();

    fromDateController.dispose();
    toDateController.dispose();

    _idFocus.dispose();
    _dateFocus.dispose();
    _invoiceNoFocus.dispose();
    _invDateFocus.dispose();
    _termsFocus.dispose();
    _dueDateFocus.dispose();
    _fromManagerFocus.dispose();
    _brokerFocus.dispose();
    _partyFocus.dispose();
    _currencyFocus.dispose();
    _dollarRateFocus.dispose();

    _typeFocus.dispose();
    _itemInvFocus.dispose();
    _qualityFocus.dispose();
    _shapeFocus.dispose();
    _colorFocus.dispose();
    _clarityFocus.dispose();
    _charniFocus.dispose();
    _pcsFocus.dispose();
    _wtFocus.dispose();
    _rateRsFocus.dispose();
    _rateDollarFocus.dispose();
    _penWtFocus.dispose();
    _searchKeyBoardFocus.dispose();
    super.dispose();
  }

  // ==================== CALCULATION & AUTO-FILL HELPERS ====================

  void _updateItemAmountFromRs() {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    try {
      final double wt = double.tryParse(wtController.text) ?? 0.0;
      final double rateRs = double.tryParse(rateRsController.text) ?? 0.0;
      final double dollarRate = double.tryParse(dollarRateController.text) ?? 100.0;

      final double amtRs = wt * rateRs;
      amountRsController.text = amtRs.toStringAsFixed(4);

      if (dollarRate > 0) {
        final double rateD = rateRs / dollarRate;
        final double amtD = wt * rateD;
        rateDollarController.text = rateD.toStringAsFixed(4);
        amountDollarController.text = amtD.toStringAsFixed(4);
      }
    } finally {
      _isConvertingRate = false;
    }
  }

  void _updateItemAmountFromDollar() {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    try {
      final double wt = double.tryParse(wtController.text) ?? 0.0;
      final double rateD = double.tryParse(rateDollarController.text) ?? 0.0;
      final double dollarRate = double.tryParse(dollarRateController.text) ?? 100.0;

      final double amtD = wt * rateD;
      amountDollarController.text = amtD.toStringAsFixed(4);

      final double rateRs = rateD * dollarRate;
      final double amtRs = wt * rateRs;
      rateRsController.text = rateRs.toStringAsFixed(2);
      amountRsController.text = amtRs.toStringAsFixed(4);
    } finally {
      _isConvertingRate = false;
    }
  }

  void _updatePartyDetails(String? partyCode) {
    if (partyCode == null || partyCode.isEmpty) {
      partyContactController.clear();
      partyAddressController.clear();
      partyLocationController.clear();
      partyMobileController.clear();
      return;
    }
    final int? code = int.tryParse(partyCode);
    final party = defaultController.partyMstList.firstWhereOrNull(
      (p) => p.partyCode == code || p.partyMstID == code,
    );
    if (party != null) {
      partyContactController.text = party.contactPerson ?? '';
      partyAddressController.text = party.address ?? '';
      partyLocationController.text = party.city ?? party.location ?? '';
      partyMobileController.text = party.mobileno ?? party.phNo ?? '';
    } else {
      partyContactController.clear();
      partyAddressController.clear();
      partyLocationController.clear();
      partyMobileController.clear();
    }
  }

  void _updateBrokerDetails(String? brokerCode) {
    if (brokerCode == null || brokerCode.isEmpty) {
      brokerMobileController.clear();
      return;
    }
    final int? code = int.tryParse(brokerCode);
    final broker = defaultController.partyMstList.firstWhereOrNull(
      (p) => p.partyCode == code || p.partyMstID == code,
    );
    if (broker != null) {
      brokerMobileController.text = broker.mobileno ?? broker.phNo ?? '';
    } else {
      brokerMobileController.clear();
    }
  }

  /// Shows the next Invoice No (CompanyMst InvoicePrefix + running no + InvoiceSuffix).
  /// The server assigns the final number on save, so if another user saves
  /// first the saved sale gets the following number.
  Future<void> _loadNextInvoiceNo() async {
    final String? next = await defaultController.getNextSaleInvoiceNo();
    if (!mounted || _isFromEdit || !_isEnabled) return;
    setState(() {
      invoiceNoController.text = next ?? '';
    });
    if (next == null) {
      infoDialog(
          messageText:
              'Could not get the next Invoice No. It will be generated when you save.');
    }
  }

  void _recalculateDueDate() {
    final invDate = selectedInvDate ?? selectedDate ?? DateTime.now();
    final terms = int.tryParse(termsController.text.trim()) ?? 0;
    final due = invDate.add(Duration(days: terms));
    dueDate = DateFormat('yyyy-MM-dd').format(due);
    dueDateController.text = DateFormat('dd-MM-yyyy').format(due);
  }

  // ==================== WORKFLOW & CRUD METHODS ====================

  void _enableFields({bool? needFocus}) {
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      selectedPolishSaleMstID.value = 0;
      idController.text = '0';
      selectedDate = DateTime.now();
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      selectedInvDate = DateTime.now();
      invDateController.text = DateFormat('dd-MM-yyyy').format(selectedInvDate!);
      termsController.text = '0';
      _recalculateDueDate();
      _initFromManager();
      invoiceNoController.clear();
    });
    _loadNextInvoiceNo();

    if (needFocus == null || needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _dateFocus.requestFocus();
      });
    }
  }

  void _openDatePicker({required bool isInvDate}) async {
    DateTime? initial = isInvDate
        ? (selectedInvDate ?? DateTime.now())
        : (selectedDate ?? DateTime.now());

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isInvDate) {
          selectedInvDate = pickedDate;
          invDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
          _recalculateDueDate();
        } else {
          selectedDate = pickedDate;
          dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        }
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        if (isInvDate) {
          _termsFocus.requestFocus();
        } else {
          _invDateFocus.requestFocus();
        }
      });
    }
  }

  void _openDueDatePicker() async {
    DateTime? initial = dueDate != null ? DateTime.tryParse(dueDate!) : DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dueDate = DateFormat('yyyy-MM-dd').format(picked);
        dueDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        final base = selectedInvDate ?? selectedDate ?? DateTime.now();
        final diff = picked.difference(base).inDays;
        termsController.text = diff >= 0 ? diff.toString() : '0';
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isFromManagerEnabled) {
          _fromManagerFocus.requestFocus();
        } else {
          _brokerFocus.requestFocus();
        }
      });
    }
  }

  Future<void> _updatePolishPendingWeight(String clarityVal) async {
    if (_selectedItemType.value != 'POLISH/REJECTION') return;
    if (clarityVal.trim().isEmpty) {
      penWtController.clear();
      return;
    }

    if (defaultController.polishPurchaseDetailList.isEmpty) {
      await defaultController.ensurePolishPurchaseDetailsLoaded();
    }

    final int currentCompany = defaultController.companyCode.value;
    final validMstIds = defaultController.polishPurchaseList
        .where((p) {
          if (currentCompany == 0) return true;
          if (p.companyCode == null || p.companyCode == 0) return true;
          return p.companyCode == currentCompany;
        })
        .map((p) => p.polishPurMstID)
        .where((id) => id != null)
        .toSet();

    final cleanSelected = clarityVal.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    final int? clarityCode = _resolveClarityCode(clarityVal);

    final matchingDetails = defaultController.polishPurchaseDetailList.where((d) {
      if (validMstIds.isNotEmpty && d.polishPurMstID != null && !validMstIds.contains(d.polishPurMstID)) {
        return false;
      }
      final dName = d.clarity?.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
      if (dName != null && dName.isNotEmpty && dName == cleanSelected) {
        return true;
      }
      if (clarityCode != null && d.clarityCode != null && d.clarityCode == clarityCode) {
        return true;
      }
      final dResolved = _resolveClarityCode(d.clarity);
      if (clarityCode != null && dResolved != null && clarityCode == dResolved) {
        return true;
      }
      return false;
    }).toList();

    double totalWt = 0.0;
    for (var d in matchingDetails) {
      final double w = double.tryParse(d.wt?.toString() ?? '0') ?? 0.0;
      totalWt += w;
    }

    penWtController.text = totalWt > 0 ? totalWt.toStringAsFixed(3) : '0.000';
  }

  void _addOrUpdateEntry() {
    if (_selectedItemType.value.isEmpty) {
      infoDialog(messageText: 'Please select a Type (ROUGH or POLISH/REJECTION)');
      _typeFocus.requestFocus();
      return;
    }
    final bool isRough = _selectedItemType.value == 'ROUGH';
    final bool isPolish = _selectedItemType.value == 'POLISH/REJECTION';

    if (isPolish && _selectedClarity.value.trim().isEmpty) {
      infoDialog(messageText: 'Please select Clarity for POLISH/REJECTION');
      _clarityFocus.requestFocus();
      return;
    }

    final double wt = double.tryParse(wtController.text) ?? 0.0;
    if (wt <= 0) {
      infoDialog(messageText: 'Please enter valid Weight');
      _wtFocus.requestFocus();
      return;
    }

    final double? penWt = penWtController.text.trim().isNotEmpty
        ? double.tryParse(penWtController.text.trim())
        : null;
    if (penWt != null && wt > penWt) {
      infoDialog(
        messageText:
            'Weight (${wt.toStringAsFixed(3)}) cannot be greater than Pending Weight (${penWt.toStringAsFixed(3)})',
      );
      _wtFocus.requestFocus();
      return;
    }

    final double rateRs = double.tryParse(rateRsController.text) ?? 0.0;
    if (rateRs <= 0) {
      infoDialog(messageText: 'Please enter valid Rate (Rs)');
      _rateRsFocus.requestFocus();
      return;
    }

    final double rateD = double.tryParse(rateDollarController.text) ?? 0.0;
    final double amtRs = wt * rateRs;
    final double amtD = wt * rateD;

    final String selectedInv = _selectedItemInvNo.value.trim().isNotEmpty
        ? _selectedItemInvNo.value.trim()
        : invNoItemController.text.trim();

    final matchingPurchase = defaultController.purchaseDataList.firstWhereOrNull(
      (p) => p.invoiceNo?.trim() == selectedInv,
    );

    // Rough Type of the item being edited (old-style sales stored it directly)
    final dynamic editingRoughTypeCode = (_editingEntryIndex != null &&
            _editingEntryIndex! >= 0 &&
            _editingEntryIndex! < entries.length)
        ? entries[_editingEntryIndex!]['roughTypeCode']
        : null;

    final entryData = {
      if (selectedItemDetId.value.isNotEmpty) 'id': selectedItemDetId.value,
      if (isRough && editingRoughTypeCode != null) 'roughTypeCode': editingRoughTypeCode,
      'type': _selectedItemType.value,
      'invNo': isRough ? selectedInv : '',
      'roughPurMstID': isRough ? matchingPurchase?.roughPurMstID : null,
      'quality': isRough ? _selectedQuality.value.trim() : '',
      'qualityCode': isRough ? _resolveQualityCode(_selectedQuality.value) : null,
      'shape': isPolish ? _selectedShape.value.trim() : '',
      'shapeCode': isPolish ? _resolveShapeCode(_selectedShape.value) : null,
      'color': isPolish ? _selectedColor.value.trim() : '',
      'colorCode': isPolish ? _resolveColorCode(_selectedColor.value) : null,
      'clarity': isPolish ? _selectedClarity.value.trim() : '',
      'clarityCode': isPolish ? _resolveClarityCode(_selectedClarity.value) : null,
      'charni': _selectedCharni.value.trim(),
      'charniCode': _resolveCharniCode(_selectedCharni.value),
      'pcs': pcsController.text.trim().isEmpty ? '1' : pcsController.text.trim(),
      'wt': wt.toStringAsFixed(3),
      'rateRs': rateRs.toStringAsFixed(2),
      'amountRs': amtRs.toStringAsFixed(4),
      'rateDollar': rateD.toStringAsFixed(4),
      'amountDollar': amtD.toStringAsFixed(4),
      'penWt': penWtController.text.trim(),
      'description': descripController.text.trim(),
      // Backwards-compatible aliases:
      'rough': _selectedItemType.value,
      'rate': rateRs.toStringAsFixed(2),
      'amount': amtRs.toStringAsFixed(2),
    };

    setState(() {
      if (_editingEntryIndex != null &&
          _editingEntryIndex! >= 0 &&
          _editingEntryIndex! < entries.length) {
        entries[_editingEntryIndex!] = entryData;
      } else {
        entries.add(entryData);
      }

      _clearEntryInputs();
      Future.delayed(const Duration(milliseconds: 50), () {
        _typeFocus.requestFocus();
      });
    });
    _recalcSummary();
  }

  void _clearEntryInputs() {
    _editingEntryIndex = null;
    selectedItemDetId.value = '';
    _selectedItemType.value = 'ROUGH';
    invNoItemController.clear();
    _selectedItemInvNo.value = '';
    _selectedQuality.value = '';
    _selectedShape.value = '';
    _selectedColor.value = '';
    _selectedClarity.value = '';
    _selectedCharni.value = '';
    pcsController.text = '1';
    wtController.clear();
    rateRsController.clear();
    amountRsController.text = '0.0000';
    rateDollarController.text = '0.0000';
    amountDollarController.text = '0.0000';
    penWtController.clear();
    descripController.clear();
  }

  void _deleteEntry(int index) {
    if (!_isEnabled) return;
    if (index < 0 || index >= entries.length) return;
    if (_isFromEdit) {
      if (entries.length == 1) {
        infoDialog(messageText: 'Cannot delete the only remaining sale item.');
        return;
      }
      final entryId = int.tryParse(entries[index]['id'] ?? '');
      if (entryId != null) {
        defaultController.deletePolishSaleItem(id: entryId).then((ok) {
          if (!ok) return;
          setState(() {
            if (_editingEntryIndex == index) {
              _clearEntryInputs();
            } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
              _editingEntryIndex = _editingEntryIndex! - 1;
            }
            entries.removeAt(index);
            _recalcSummary();
          });
        });
      } else {
        setState(() {
          if (_editingEntryIndex == index) {
            _clearEntryInputs();
          } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
            _editingEntryIndex = _editingEntryIndex! - 1;
          }
          entries.removeAt(index);
          _recalcSummary();
        });
      }
    } else {
      setState(() {
        if (_editingEntryIndex == index) {
          _clearEntryInputs();
        } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
          _editingEntryIndex = _editingEntryIndex! - 1;
        }
        entries.removeAt(index);
        _recalcSummary();
      });
    }
  }

  void _editEntry(int index) {
    if (!_isEnabled) return;
    if (index < 0 || index >= entries.length) return;
    final entry = entries[index];
    setState(() {
      _editingEntryIndex = index;
      if (_isFromEdit) {
        selectedItemDetId.value = entry['id']?.toString() ?? '';
      }
      _selectedItemType.value = entry['type']?.toString() ?? 'ROUGH';
      final inv = entry['invNo']?.toString() ?? '';
      invNoItemController.text = inv;
      _selectedItemInvNo.value = inv;
      _selectedQuality.value = entry['quality']?.toString() ?? entry['qualityCode']?.toString() ?? '';
      _selectedShape.value = entry['shape']?.toString() ?? entry['shapeCode']?.toString() ?? '';
      _selectedColor.value = entry['color']?.toString() ?? entry['colorCode']?.toString() ?? '';
      _selectedClarity.value = entry['clarity']?.toString() ?? entry['clarityCode']?.toString() ?? '';
      _selectedCharni.value = entry['charni']?.toString() ?? entry['charniCode']?.toString() ?? '';
      pcsController.text = entry['pcs']?.toString() ?? '1';
      wtController.text = entry['wt']?.toString() ?? '';
      rateRsController.text = entry['rateRs']?.toString() ?? entry['rate']?.toString() ?? '';
      amountRsController.text = entry['amountRs']?.toString() ?? entry['amount']?.toString() ?? '';
      rateDollarController.text = entry['rateDollar']?.toString() ?? '';
      amountDollarController.text = entry['amountDollar']?.toString() ?? '';
      penWtController.text = entry['penWt']?.toString() ?? '';
      descripController.text = entry['description']?.toString() ?? '';
    });
    _typeFocus.requestFocus();
  }

  Future<void> _handleSave() async {
    if (!_isEnabled) return;

    if (_selectedTypeParty.value.isEmpty) {
      infoDialog(messageText: 'Please select a Party.');
      _partyFocus.requestFocus();
      return;
    }

    if (entries.isEmpty) {
      infoDialog(messageText: 'Please add at least one item.');
      _typeFocus.requestFocus();
      return;
    }

    final double dollarRate = double.tryParse(dollarRateController.text.trim()) ?? 100.0;
    final int? fromUserId = _selectedFromManagerId.value;
    final int dueDays = int.tryParse(termsController.text.trim()) ?? 0;

    bool ok = false;
    int savedId = 0;
    String savedInvoiceNo = invoiceNoController.text.trim();

    if (_isFromEdit) {
      savedId = selectedPolishSaleMstID.value;
      ok = await defaultController.updatePolishSaleData(
        id: savedId,
        invoiceNo: savedInvoiceNo,
        partyCode: _selectedTypeParty.value,
        invoiceDate: selectedDate ?? DateTime.now(),
        brokerCode: _selectedTypeBroker.value,
        dueDays: dueDays,
        dueDate: dueDate,
        rdType: _selectedCurrency.value,
        dollarRate: dollarRate,
        fromUserId: fromUserId,
        entries: entries,
        totalAmt: totalAmountRs,
        totalAmtDollar: totalAmountDollar,
        totalWt: totalWt,
        totalRate: totalRateRs,
        totalRateDollar: totalRateDollar,
        totalPcs: totalPacket,
        summary: _summaryPayload(),
      );
    } else {
      final saved = await defaultController.addPolishSaleData(
        partyCode: _selectedTypeParty.value,
        invoiceDate: selectedDate ?? DateTime.now(),
        brokerCode: _selectedTypeBroker.value,
        dueDays: dueDays,
        dueDate: dueDate,
        rdType: _selectedCurrency.value,
        dollarRate: dollarRate,
        fromUserId: fromUserId,
        entries: entries,
        totalAmt: totalAmountRs,
        totalAmtDollar: totalAmountDollar,
        totalWt: totalWt,
        totalRate: totalRateRs,
        totalRateDollar: totalRateDollar,
        totalPcs: totalPacket,
        summary: _summaryPayload(),
      );
      ok = saved != null;
      if (saved != null) {
        savedId = saved['id'] as int? ?? 0;
        savedInvoiceNo = saved['invoiceNo']?.toString() ?? savedInvoiceNo;
        invoiceNoController.text = savedInvoiceNo;
      }
    }

    if (ok == true) {
      // Same as the old Sale screen: print the invoice after saving
      // (controlled by the Preview / Print checkboxes in the action bar).
      if (_chkPreview.value || _chkPrint.value) {
        await _printSale(id: savedId, invoiceNo: savedInvoiceNo);
      }
      if (_isFiltered.value) {
        _applyDateFilter();
      } else {
        saleDataGridSource.value = List<PolishSaleModel>.from(defaultController.polishSaleList);
      }
      _handleCancel();
    }
  }

  Future<void> _handleDelete() async {
    if (!_isEnabled || !_isFromEdit) return;
    final bool ok = await defaultController.deletePolishSaleData(
      id: selectedPolishSaleMstID.value,
      entries: entries,
    );
    if (ok == true) {
      if (_isFiltered.value) {
        _applyDateFilter();
      } else {
        saleDataGridSource.value = List<PolishSaleModel>.from(defaultController.polishSaleList);
      }
      _handleCancel();
    }
  }

  void _handleCancel() {
    idController.text = '0';
    dateController.clear();
    invoiceNoController.clear();
    invDateController.clear();
    termsController.text = '0';
    dueDateController.clear();

    _selectedTypeParty.value = '';
    _selectedTypeBroker.value = '22';
    partyContactController.clear();
    partyAddressController.clear();
    partyLocationController.clear();
    partyMobileController.clear();
    brokerMobileController.clear();

    _clearEntryInputs();
    selectedPolishSaleMstID.value = 0;
    entries.clear();
    _resetSummary();
    selectedDate = null;
    selectedInvDate = null;
    dueDate = null;

    setState(() {
      _isFromEdit = false;
      _isEnabled = false;
    });
  }

  Future<void> _handlePrint() async {
    if (!_isFromEdit || selectedDate == null || _selectedTypeParty.value.isEmpty) return;
    await _printSale(
      id: selectedPolishSaleMstID.value,
      invoiceNo: invoiceNoController.text.trim(),
      forcePreview: true,
    );
  }

  Future<void> _printSale({
    required int id,
    required String invoiceNo,
    bool forcePreview = false,
  }) async {
    if (selectedDate == null || _selectedTypeParty.value.isEmpty) return;
    await defaultController.printPolishSaleInvoice(
      id: id,
      invoiceNo: invoiceNo,
      invoiceDate: selectedDate!,
      partyCode: _selectedTypeParty.value,
      brokerCode: _selectedTypeBroker.value,
      dueDateText: dueDateController.text,
      dueDays: termsController.text.trim(),
      entries: entries,
      totalAmt: totalAmountRs,
      totalWt: totalWt,
      totalRate: totalRateRs,
      preview: forcePreview || _chkPreview.value,
      share: _chkPrint.value,
    );
  }

  void _selectSaleById(int id) {
    selectedPolishSaleMstID.value = id;
    idController.text = id.toString();

    final PolishSaleModel? partyEntry = defaultController.polishSaleList.firstWhereOrNull(
      (entry) => entry.polishSaleMstID == id,
    );
    if (partyEntry == null) return;

    final List<SaleDetailsModel> roughEntries = defaultController.saleDetailsList
        .where((entry) => entry.polishSaleMstID == id)
        .toList();

    selectedDate = dateFormat(partyEntry.invoiceDate!);
    dateController.text = formatDate(partyEntry.invoiceDate!);
    selectedInvDate = selectedDate;
    invDateController.text = dateController.text;
    invoiceNoController.text = partyEntry.invoiceNo ?? '';
    termsController.text = (partyEntry.dueDay ?? 0).toString();
    if (partyEntry.dueDate != null && partyEntry.dueDate!.isNotEmpty) {
      dueDate = partyEntry.dueDate;
      dueDateController.text = formatDate(partyEntry.dueDate!);
    } else {
      _recalculateDueDate();
    }

    _selectedTypeParty.value = partyEntry.partyCode?.toString() ?? '';
    _selectedTypeBroker.value = (partyEntry.brokerCode ?? 22).toString();
    _updatePartyDetails(_selectedTypeParty.value);
    _updateBrokerDetails(_selectedTypeBroker.value);

    _selectedCurrency.value = partyEntry.rdType ?? 'RS';
    dollarRateController.text = (partyEntry.dollarRate ?? 100.0).toString();
    if (partyEntry.logID != null && partyEntry.logID! > 0) {
      _selectedFromManagerId.value = partyEntry.logID;
    }

    _clearEntryInputs();
    entries.clear();
    for (var roughEntry in roughEntries) {
      final double carats = (roughEntry.carats ?? 0.0).toDouble();
      final double rateRs = (roughEntry.rateRs ?? 0.0).toDouble();
      final double rateD = (roughEntry.rateD ?? 0.0).toDouble();
      final double amtRs = carats * rateRs;
      final double amtD = carats * rateD;

      entries.add({
        'id': roughEntry.polishSaleDetID?.toString() ?? '',
        'type': (roughEntry.type != null && roughEntry.type!.isNotEmpty)
            ? roughEntry.type!
            : 'ROUGH',
        'invNo': roughEntry.invNo ?? '',
        'roughPurMstID': roughEntry.roughPurMstID,
        'quality': roughEntry.qualityCode?.toString() ?? '',
        'qualityCode': roughEntry.qualityCode,
        'shape': roughEntry.shapeCode?.toString() ?? '',
        'shapeCode': roughEntry.shapeCode,
        'color': roughEntry.colorCode?.toString() ?? '',
        'colorCode': roughEntry.colorCode,
        'clarity': roughEntry.clarityCode?.toString() ?? '',
        'clarityCode': roughEntry.clarityCode,
        'charni': roughEntry.charniCode?.toString() ?? '',
        'charniCode': roughEntry.charniCode,
        'pcs': (roughEntry.pcs ?? 1).toString(),
        'wt': carats.toStringAsFixed(3),
        'rateRs': rateRs.toStringAsFixed(2),
        'amountRs': amtRs.toStringAsFixed(4),
        'rateDollar': rateD.toStringAsFixed(4),
        'amountDollar': amtD.toStringAsFixed(4),
        'penWt': (roughEntry.penCarats ?? 0.0).toString(),
        'description': roughEntry.description?.toString() ?? '',
        'rough': roughEntry.roughTypeCode?.toString() ?? '1',
        'roughTypeCode': roughEntry.roughTypeCode,
        'rate': rateRs.toStringAsFixed(2),
        'amount': amtRs.toStringAsFixed(2),
      });
    }

    // GST / Brokerage % and Net Rs saved with the sale
    double? toD(dynamic v) => v == null ? null : double.tryParse(v.toString());
    sgstPerController.text = (toD(partyEntry.sGstPer) ?? 0).toStringAsFixed(3);
    cgstPerController.text = (toD(partyEntry.cGstPer) ?? 0).toStringAsFixed(3);
    igstPerController.text = (toD(partyEntry.iGstPer) ?? 0).toStringAsFixed(3);
    final double? savedBro = toD(partyEntry.broPer);
    broPerController.text = (savedBro != null && savedBro != 0) ? savedBro.toStringAsFixed(3) : '';
    _recalcSummary();
    final double? savedNet = toD(partyEntry.netRsAmount);
    if (savedNet != null && savedNet != 0) {
      netRsController.text = savedNet.toStringAsFixed(2);
    }

    setState(() {
      _isFromEdit = true;
      _isEnabled = false;
      _isSearch = false;
    });
  }

  // ==================== SEARCH DATE FILTERING ====================

  void _applyDateFilter() {
    if (fromDate != null && toDate != null) {
      _isFiltered.value = true;
      filteredDataGridSource.value = defaultController.polishSaleList.where((sale) {
        if (sale.invoiceDate == null) return false;
        final invoiceDate = DateTime.parse(sale.invoiceDate!);
        return invoiceDate.isAfter(fromDate!) &&
            invoiceDate.isBefore(toDate!.add(const Duration(days: 1)));
      }).toList();
      saleDataGridSource.value = filteredDataGridSource;
      _searchKeyBoardFocus.requestFocus();
    } else {
      infoDialog(messageText: 'Please select both From Date and To Date');
    }
  }

  void _removeDateFilter() {
    saleDataGridSource.value = defaultController.polishSaleList;
    toDateController.clear();
    fromDateController.clear();
    fromDate = null;
    toDate = null;
    _isFiltered.value = false;
  }

  // ==================== DROPDOWNS ====================

  List<DropdownMenuItem<String>> get dropdownItemsType => const [
        DropdownMenuItem<String>(
          value: 'ROUGH',
          child: Text('ROUGH', style: TextStyle(fontSize: 13)),
        ),
        DropdownMenuItem<String>(
          value: 'POLISH/REJECTION',
          child: Text('POLISH/REJECTION', style: TextStyle(fontSize: 13)),
        ),
      ];

  List<DropdownMenuItem<String>> get dropdownItemsCurrency => const [
        DropdownMenuItem<String>(
          value: 'RS',
          child: Text('RS', style: TextStyle(fontSize: 13)),
        ),
        DropdownMenuItem<String>(
          value: '\$',
          child: Text('\$', style: TextStyle(fontSize: 13)),
        ),
      ];

  List<DropdownMenuItem<String>> get dropdownItemsInvoice {
    final seen = <String>{};
    final int currentCompany = defaultController.companyCode.value;
    final items = <DropdownMenuItem<String>>[];

    for (var p in defaultController.purchaseDataList) {
      if (currentCompany != 0 &&
          p.companyCode != null &&
          p.companyCode != 0 &&
          p.companyCode != currentCompany) {
        continue;
      }
      final inv = p.invoiceNo?.trim();
      if (inv == null || inv.isEmpty) continue;
      if (seen.add(inv)) {
        final double tWt =
            double.tryParse(p.tWeight?.toString() ?? '0') ?? 0.0;
        final wtStr = tWt > 0 ? ' (Wt: ${tWt.toStringAsFixed(3)})' : '';
        items.add(DropdownMenuItem<String>(
          value: inv,
          child: Text(
            '$inv$wtStr',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ));
      }
    }

    if (_selectedItemInvNo.value.trim().isNotEmpty &&
        seen.add(_selectedItemInvNo.value.trim())) {
      items.add(DropdownMenuItem<String>(
        value: _selectedItemInvNo.value.trim(),
        child: Text(
          _selectedItemInvNo.value.trim(),
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ));
    }

    return items;
  }

  List<AppDropdownItem<String>> get appDropdownItemsInvoice {
    final seen = <String>{};
    final int currentCompany = defaultController.companyCode.value;
    final items = <AppDropdownItem<String>>[];

    for (var p in defaultController.purchaseDataList) {
      if (currentCompany != 0 &&
          p.companyCode != null &&
          p.companyCode != 0 &&
          p.companyCode != currentCompany) {
        continue;
      }
      final inv = p.invoiceNo?.trim();
      if (inv == null || inv.isEmpty) continue;
      if (seen.add(inv)) {
        final double tWt =
            double.tryParse(p.tWeight?.toString() ?? '0') ?? 0.0;
        items.add(AppDropdownItem<String>(
          value: inv,
          label: inv,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Wt: ${tWt.toStringAsFixed(3)} Ct',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      }
    }

    if (_selectedItemInvNo.value.trim().isNotEmpty &&
        seen.add(_selectedItemInvNo.value.trim())) {
      items.add(AppDropdownItem<String>(
        value: _selectedItemInvNo.value.trim(),
        label: _selectedItemInvNo.value.trim(),
      ));
    }

    return items;
  }

  List<DropdownMenuItem<String>> get dropdownItemsParty {
    final seen = <int>{};
    return defaultController.partyMstList
        .where((p) =>
            (p.typeCode == 2 ||
                p.partyType?.toUpperCase() == 'PARTY' ||
                p.partyCode.toString() == _selectedTypeParty.value) &&
            p.companyCode == defaultController.companyCode.value &&
            p.partyCode != null &&
            seen.add(p.partyCode!))
        .map((p) => DropdownMenuItem<String>(
              value: p.partyCode.toString(),
              child: Text(p.partyName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsBroker {
    final seen = <int>{};
    return defaultController.partyMstList
        .where((p) =>
            (p.typeCode == 5 ||
                p.partyType?.toUpperCase() == 'BROKER' ||
                p.partyCode.toString() == _selectedTypeBroker.value) &&
            p.companyCode == defaultController.companyCode.value &&
            p.partyCode != null &&
            seen.add(p.partyCode!))
        .map((p) => DropdownMenuItem<String>(
              value: p.partyCode.toString(),
              child: Text(p.partyName ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsClarity {
    final seen = <String>{};
    return defaultController.clarityModelList
        .where((c) =>
            c.clarityName != null &&
            c.clarityName!.trim().isNotEmpty &&
            seen.add(c.clarityName!.trim()))
        .map((c) => DropdownMenuItem<String>(
              value: c.clarityName!.trim(),
              child: Text(c.clarityName!.trim(),
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsCharni {
    final seen = <String>{};
    return defaultController.charniModelList
        .where((c) =>
            c.charniName != null &&
            c.charniName!.trim().isNotEmpty &&
            seen.add(c.charniName!.trim()))
        .map((c) => DropdownMenuItem<String>(
              value: c.charniName!.trim(),
              child: Text(c.charniName!.trim(),
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsQuality {
    final seen = <String>{};
    return defaultController.qualityModelList
        .where((q) {
          final val = (q.qualityCode ?? q.qualityMstID)?.toString() ?? q.qualityName?.trim() ?? '';
          return val.isNotEmpty && seen.add(val);
        })
        .map((q) {
          final val = (q.qualityCode ?? q.qualityMstID)?.toString() ?? q.qualityName?.trim() ?? '';
          return DropdownMenuItem<String>(
            value: val,
            child: Text(q.qualityName?.trim() ?? val,
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          );
        })
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsShape {
    final seen = <String>{};
    return defaultController.shapeModelList
        .where((s) {
          final val = (s.shapeCode ?? s.shapeMstId)?.toString() ?? s.shapeName?.trim() ?? '';
          return val.isNotEmpty && seen.add(val);
        })
        .map((s) {
          final val = (s.shapeCode ?? s.shapeMstId)?.toString() ?? s.shapeName?.trim() ?? '';
          return DropdownMenuItem<String>(
            value: val,
            child: Text(s.shapeName?.trim() ?? val,
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          );
        })
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsColor {
    final seen = <String>{};
    return defaultController.colorModelList
        .where((c) {
          final val = (c.colorCode ?? c.colorMstID)?.toString() ?? c.colorName?.trim() ?? '';
          return val.isNotEmpty && seen.add(val);
        })
        .map((c) {
          final val = (c.colorCode ?? c.colorMstID)?.toString() ?? c.colorName?.trim() ?? '';
          return DropdownMenuItem<String>(
            value: val,
            child: Text(c.colorName?.trim() ?? val,
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          );
        })
        .toList();
  }

  String? _findMatchingDropdownValue(List<DropdownMenuItem<String>> items, String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final clean = val.trim();
    for (var item in items) {
      if (item.value == clean) return item.value;
    }
    for (var item in items) {
      if (item.value != null && item.value!.toLowerCase() == clean.toLowerCase()) {
        return item.value;
      }
    }
    for (var item in items) {
      if (item.child is Text &&
          (item.child as Text).data?.trim().toLowerCase() == clean.toLowerCase()) {
        return item.value;
      }
    }
    return null;
  }

  int? _resolveQualityCode(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final str = val.toString().trim();
    final item = defaultController.qualityModelList.firstWhereOrNull(
      (q) => q.qualityCode?.toString() == str ||
             q.qualityMstID?.toString() == str ||
             q.qualityName?.trim().toLowerCase() == str.toLowerCase(),
    );
    return item?.qualityCode ?? item?.qualityMstID ?? int.tryParse(str);
  }

  int? _resolveShapeCode(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final str = val.toString().trim();
    final item = defaultController.shapeModelList.firstWhereOrNull(
      (s) => s.shapeCode?.toString() == str ||
             s.shapeMstId?.toString() == str ||
             s.shapeName?.trim().toLowerCase() == str.toLowerCase(),
    );
    return item?.shapeCode ?? item?.shapeMstId ?? int.tryParse(str);
  }

  int? _resolveColorCode(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final str = val.toString().trim();
    final item = defaultController.colorModelList.firstWhereOrNull(
      (c) => c.colorCode?.toString() == str ||
             c.colorMstID?.toString() == str ||
             c.colorName?.trim().toLowerCase() == str.toLowerCase(),
    );
    return item?.colorCode ?? item?.colorMstID ?? int.tryParse(str);
  }

  int? _resolveClarityCode(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final str = val.toString().trim();
    final item = defaultController.clarityModelList.firstWhereOrNull(
      (c) => c.clarityMstID?.toString() == str ||
             c.clarityName?.trim().toLowerCase() == str.toLowerCase(),
    );
    return item?.clarityMstID ?? int.tryParse(str);
  }

  int? _resolveCharniCode(dynamic val) {
    if (val == null || val.toString().trim().isEmpty) return null;
    final str = val.toString().trim();
    final item = defaultController.charniModelList.firstWhereOrNull(
      (c) => c.charniCode?.toString() == str ||
             c.charniMstID?.toString() == str ||
             c.charniName?.trim().toLowerCase() == str.toLowerCase(),
    );
    return item?.charniCode ?? item?.charniMstID ?? int.tryParse(str);
  }

  // ==================== MAIN BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onEdit: (_isFromEdit && !_isEnabled)
            ? () {
                setState(() => _isEnabled = true);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _typeFocus.requestFocus();
                });
              }
            : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: (_isEnabled || _isFromEdit) ? _handleCancel : null,
        onExit: () {
          if (_isSearch) {
            setState(() => _isSearch = false);
          } else {
            tabController.closeCurrentTab();
          }
        },
        onSearch: () {
          setState(() {
            _isSearch = !_isSearch;
          });
          if (_isSearch) {
            defaultController.getSaleData(force: true);
            defaultController.getSaleDetailsData(force: true);
          }
        },
        onPrint: _isFromEdit ? _handlePrint : null,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader)
                Header(title: _isSearch ? 'Sale Search' : 'Sale Entry'),
              Expanded(
                child: _isSearch ? _buildSearchView() : _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== SEARCH / DIRECTORY VIEW ====================

  Widget _buildSearchView() {
    return KeyboardListener(
      focusNode: _searchKeyBoardFocus,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          final int currentIndex = _dataGridController.selectedIndex;
          final int totalRows = saleDataGridSource.length;

          if (event.logicalKey == LogicalKeyboardKey.enter &&
              _dataGridController.selectedRow != null) {
            final int id = _dataGridController.selectedRow!.getCells()[0].value;
            _selectSaleById(id);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
              currentIndex < totalRows - 1) {
            _dataGridController.selectedIndex = currentIndex + 1;
            _dataGridController
                .scrollToRow(double.parse(_dataGridController.selectedIndex.toString()));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && currentIndex > 0) {
            _dataGridController.selectedIndex = currentIndex - 1;
            _dataGridController
                .scrollToRow(double.parse(_dataGridController.selectedIndex.toString()));
          } else if (event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.keyE) {
            setState(() => _isSearch = false);
          } else if (event.logicalKey == LogicalKeyboardKey.keyR && _isFiltered.value) {
            _removeDateFilter();
          } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            _applyDateFilter();
          }
        }
      },
      child: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;
                final dateFields = [
                  AppTextField(
                    label: 'From Date',
                    controller: fromDateController,
                    readOnly: true,
                    prefixIcon: Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.textSecondary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          fromDate = picked;
                          fromDateController.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                          if (toDateController.text.isNotEmpty) _applyDateFilter();
                        });
                      }
                    },
                  ),
                  AppTextField(
                    label: 'To Date',
                    controller: toDateController,
                    readOnly: true,
                    prefixIcon: Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.textSecondary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          toDate = picked;
                          toDateController.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                          if (fromDateController.text.isNotEmpty) _applyDateFilter();
                        });
                      }
                    },
                  ),
                ];

                final actionButtons = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      text: 'Filter',
                      shortcutLabel: 'F',
                      icon: Icons.filter_alt_rounded,
                      onPressed: _applyDateFilter,
                    ),
                    Obx(() => AppButton(
                          text: 'Reset',
                          shortcutLabel: 'R',
                          icon: Icons.refresh_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: _isFiltered.value ? _removeDateFilter : null,
                        )),
                    AppButton(
                      text: 'Close Search',
                      shortcutLabel: 'Esc',
                      icon: Icons.close_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => setState(() => _isSearch = false),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: dateFields[0]),
                          const SizedBox(width: 10),
                          Expanded(child: dateFields[1]),
                        ],
                      ),
                      const SizedBox(height: 10),
                      actionButtons,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: dateFields[0]),
                    const SizedBox(width: 12),
                    Expanded(child: dateFields[1]),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: actionButtons,
                    ),
                  ],
                );
              },
            ),
          ),
          Obx(() => defaultController.isLoading.value
              ? LinearProgressIndicator(color: AppColors.primary, minHeight: 2)
              : const SizedBox.shrink()),
          // Table of Sales
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Obx(
                    () {
                      final searchSource = SaleDataGridSource(saleDataGridSource);
                      return AppDataGrid(
                        controller: _dataGridController,
                        source: searchSource,
                        columns: _buildSearchGridColumns(),
                        tableSummaryRows: [
                          GridTableSummaryRow(
                            title: 'Total ${saleDataGridSource.length}',
                            showSummaryInRow: false,
                            titleColumnSpan: 1,
                            columns: const <GridSummaryColumn>[
                              GridSummaryColumn(
                                  name: 'Tot Wt',
                                  columnName: 'Tot Wt',
                                  summaryType: GridSummaryType.sum),
                              GridSummaryColumn(
                                  name: 'Tot Amt Rs',
                                  columnName: 'Tot Amt Rs',
                                  summaryType: GridSummaryType.sum),
                            ],
                            position: GridTableSummaryRowPosition.bottom,
                          )
                        ],
                        rowHeight: 30,
                        headerRowHeight: 36,
                        allowSorting: true,
                        allowMultiColumnSorting: true,
                        showSortNumbers: true,
                        allowFiltering: true,
                        allowColumnsResizing: true,
                        selectionMode: SelectionMode.single,
                        columnWidthMode: ColumnWidthMode.auto,
                        frozenColumnsCount: 1,
                        onCellDoubleTap: (details) {
                          if (details.rowColumnIndex.rowIndex <= 0) return;
                          final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                          final rows = searchSource.effectiveRows;
                          if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                            final row = rows[dataRowIndex];
                            final idCell = row
                                .getCells()
                                .firstWhereOrNull((c) => c.columnName == 'ID');
                            final dynamic idVal = idCell?.value ?? row.getCells()[0].value;
                            if (idVal != null) {
                              final int id = idVal is int ? idVal : int.tryParse(idVal.toString()) ?? 0;
                              if (id > 0) _selectSaleById(id);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MAIN FORM VIEW ====================

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 10 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Card 1: Sale Header & Parties (From Manager, Broker, Party, etc.)
            _buildHeaderCard(),
            const SizedBox(height: 12),

            // Card 2: Item Quick Entry Bar
            _buildQuickEntryCard(),
            const SizedBox(height: 12),

            // Card 3: Sale Items Table
            _buildEntriesTableCard(),
            const SizedBox(height: 12),

            // Card 4: Summary Stat Boxes
            _buildSummaryBoxesCard(),
            const SizedBox(height: 12),

            // Card 5: GST / Net / Round / Brokerage / Final
            _buildGstSummaryCard(),
            const SizedBox(height: 16),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ==================== SUB-COMPONENTS ====================

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'SALE INFORMATION',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Row 1 Fields
                final idField = AppTextField(
                  label: 'ID :',
                  controller: idController,
                  focusNode: _idFocus,
                  enabled: false,
                  prefixIcon: const Icon(Icons.tag_rounded, size: 16),
                );

                final dateField = Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                      _invDateFocus.requestFocus();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AppTextField(
                    label: 'Date :',
                    controller: dateController,
                    focusNode: _dateFocus,
                    nextFocusNode: _invDateFocus,
                    onFieldSubmitted: (_) => _invDateFocus.requestFocus(),
                    enabled: _isEnabled && !_isFromEdit,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                    onTap: (_isEnabled && !_isFromEdit)
                        ? () => _openDatePicker(isInvDate: false)
                        : null,
                  ),
                );

                final invoiceNoField = AppTextField(
                  label: 'Invoice No :',
                  controller: invoiceNoController,
                  focusNode: _invoiceNoFocus,
                  nextFocusNode: _invDateFocus,
                  onFieldSubmitted: (_) => _invDateFocus.requestFocus(),
                  enabled: _isEnabled,
                  // Auto-generated from Company master (Invoice Prefix + No + Suffix)
                  readOnly: true,
                  hintText: 'Auto',
                  prefixIcon: const Icon(Icons.receipt_long_rounded, size: 16),
                );

                final invDateField = Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                      _termsFocus.requestFocus();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AppTextField(
                    label: 'Inv Date :',
                    controller: invDateController,
                    focusNode: _invDateFocus,
                    nextFocusNode: _termsFocus,
                    onFieldSubmitted: (_) => _termsFocus.requestFocus(),
                    enabled: _isEnabled && !_isFromEdit,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.calendar_month_rounded, size: 16),
                    onTap: (_isEnabled && !_isFromEdit)
                        ? () => _openDatePicker(isInvDate: true)
                        : null,
                  ),
                );

                final termsField = AppTextField(
                  label: 'Terms :',
                  controller: termsController,
                  focusNode: _termsFocus,
                  nextFocusNode: _isFromManagerEnabled ? _fromManagerFocus : _brokerFocus,
                  onFieldSubmitted: (_) {
                    if (_isFromManagerEnabled) {
                      _fromManagerFocus.requestFocus();
                    } else {
                      _brokerFocus.requestFocus();
                    }
                  },
                  enabled: _isEnabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.timelapse_rounded, size: 16),
                );

                final dueDateField = Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                      if (_isFromManagerEnabled) {
                        _fromManagerFocus.requestFocus();
                      } else {
                        _brokerFocus.requestFocus();
                      }
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AppTextField(
                    label: 'Due Date :',
                    controller: dueDateController,
                    focusNode: _dueDateFocus,
                    enabled: _isEnabled,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.event_available_rounded, size: 16),
                    onTap: _isEnabled ? _openDueDatePicker : null,
                  ),
                );

                // Row 2 Fields: From Manager, Broker, Broker Mo. No, Currency, Dollar Rate
                final fromManagerField = Obx(
                  () => AppDropdown<int>(
                    label: 'From Manager :',
                    value: _selectedFromManagerId.value,
                    items: _buildFromManagerDropdownItems(),
                    dropdownItems: _buildFromManagerAppDropdownItems(),
                    focusNode: _fromManagerFocus,
                    nextFocusNode: _brokerFocus,
                    isEnabled: _isEnabled && _isFromManagerEnabled && !_isFromEdit,
                    hintText: 'Select From Manager',
                    searchHint: 'Search manager...',
                    prefixIcon: const Icon(Icons.person_rounded, size: 16),
                    onChanged: (val) {
                      _selectedFromManagerId.value = val;
                    },
                  ),
                );

                final brokerField = Obx(
                  () => AppDropdown<String>(
                    label: 'Broker :',
                    value: _selectedTypeBroker.value.isEmpty
                        ? null
                        : _selectedTypeBroker.value,
                    items: dropdownItemsBroker,
                    focusNode: _brokerFocus,
                    nextFocusNode: _partyFocus,
                    hintText: 'Select Broker',
                    isEnabled: _isEnabled,
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 16),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedTypeBroker.value = value;
                        _updateBrokerDetails(value);
                      }
                    },
                  ),
                );

                final brokerMobileField = AppTextField(
                  label: 'Mo. No :',
                  controller: brokerMobileController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.phone_rounded, size: 16),
                );

                final currencyField = Obx(
                  () => AppDropdown<String>(
                    label: 'Rs / \$ :',
                    value: _selectedCurrency.value,
                    items: dropdownItemsCurrency,
                    focusNode: _currencyFocus,
                    nextFocusNode: _dollarRateFocus,
                    isEnabled: _isEnabled,
                    prefixIcon: const Icon(Icons.currency_exchange_rounded, size: 16),
                    onChanged: (val) {
                      if (val != null) {
                        _selectedCurrency.value = val;
                      }
                    },
                  ),
                );

                final dollarRateField = AppTextField(
                  label: '\$ Rate :',
                  controller: dollarRateController,
                  focusNode: _dollarRateFocus,
                  nextFocusNode: _typeFocus,
                  onFieldSubmitted: (_) => _typeFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                  prefixIcon: const Icon(Icons.attach_money_rounded, size: 16),
                );

                // Row 3 Fields: Party (instead of Company), Contact, Address, Location, Party Mo. No
                final partyField = Obx(
                  () => AppDropdown<String>(
                    label: 'Party :',
                    value: _selectedTypeParty.value.isEmpty
                        ? null
                        : _selectedTypeParty.value,
                    items: dropdownItemsParty,
                    focusNode: _partyFocus,
                    nextFocusNode: _currencyFocus,
                    hintText: 'Select Party',
                    isEnabled: _isEnabled,
                    prefixIcon: const Icon(Icons.business_rounded, size: 16),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedTypeParty.value = value;
                        _updatePartyDetails(value);
                      }
                    },
                  ),
                );

                final contactField = AppTextField(
                  label: 'Contact :',
                  controller: partyContactController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.person_pin_rounded, size: 16),
                );

                final addressField = AppTextField(
                  label: 'Add. :',
                  controller: partyAddressController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 16),
                );

                final locationField = AppTextField(
                  label: 'Location :',
                  controller: partyLocationController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.map_rounded, size: 16),
                );

                final partyMobileField = AppTextField(
                  label: 'Mo. No :',
                  controller: partyMobileController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 16),
                );

                if (constraints.maxWidth >= 1000) {
                  return Column(
                    children: [
                      // Row 1: ID, Date, Invoice No, Inv Date, Terms, Due Date, From Manager, Broker, Broker Mo. No
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: idField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: dateField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: invoiceNoField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: invDateField),
                          const SizedBox(width: 8),
                          Expanded(flex: 2, child: termsField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: dueDateField),
                          const SizedBox(width: 8),
                          Expanded(flex: 4, child: fromManagerField),
                          const SizedBox(width: 8),
                          Expanded(flex: 4, child: brokerField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: brokerMobileField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Row 2: Party, Contact, Address, Location, Party Mo. No, Currency, Dollar Rate
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: partyField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: contactField),
                          const SizedBox(width: 8),
                          Expanded(flex: 5, child: addressField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: locationField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: partyMobileField),
                          const SizedBox(width: 8),
                          Expanded(flex: 2, child: currencyField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: dollarRateField),
                        ],
                      ),
                    ],
                  );
                } else if (constraints.maxWidth >= 650) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: idField),
                          const SizedBox(width: 10),
                          Expanded(child: dateField),
                          const SizedBox(width: 10),
                          Expanded(child: invoiceNoField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: invDateField),
                          const SizedBox(width: 10),
                          Expanded(child: termsField),
                          const SizedBox(width: 10),
                          Expanded(child: dueDateField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(flex: 2, child: fromManagerField),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: brokerField),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: brokerMobileField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(flex: 2, child: partyField),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: currencyField),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: dollarRateField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: contactField),
                          const SizedBox(width: 10),
                          Expanded(child: addressField),
                          const SizedBox(width: 10),
                          Expanded(child: locationField),
                          const SizedBox(width: 10),
                          Expanded(child: partyMobileField),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      idField,
                      const SizedBox(height: 10),
                      dateField,
                      const SizedBox(height: 10),
                      invoiceNoField,
                      const SizedBox(height: 10),
                      invDateField,
                      const SizedBox(height: 10),
                      termsField,
                      const SizedBox(height: 10),
                      dueDateField,
                      const SizedBox(height: 10),
                      fromManagerField,
                      const SizedBox(height: 10),
                      brokerField,
                      const SizedBox(height: 10),
                      brokerMobileField,
                      const SizedBox(height: 10),
                      partyField,
                      const SizedBox(height: 10),
                      contactField,
                      const SizedBox(height: 10),
                      addressField,
                      const SizedBox(height: 10),
                      locationField,
                      const SizedBox(height: 10),
                      partyMobileField,
                      const SizedBox(height: 10),
                      currencyField,
                      const SizedBox(height: 10),
                      dollarRateField,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEntryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.diamond_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'ITEM QUICK ENTRY (Press Enter to Add Row)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_editingEntryIndex != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          'Editing Item #${_editingEntryIndex! + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // 1. Type dropdown with POLISH/REJECTION and ROUGH
                final typeDropdown = Obx(
                  () {
                    final isRough = _selectedItemType.value == 'ROUGH';
                    return AppDropdown<String>(
                      label: 'Type :',
                      value: _selectedItemType.value,
                      items: dropdownItemsType,
                      focusNode: _typeFocus,
                      nextFocusNode: isRough ? _itemInvFocus : _clarityFocus,
                      hintText: 'Select Type',
                      isEnabled: _isEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          _selectedItemType.value = value;
                          if (value == 'POLISH/REJECTION') {
                            invNoItemController.clear();
                            _selectedItemInvNo.value = '';
                            penWtController.clear();
                            _selectedQuality.value = '';
                            defaultController.ensurePolishPurchaseDetailsLoaded();
                            if (_selectedClarity.value.isNotEmpty) {
                              _updatePolishPendingWeight(_selectedClarity.value);
                            }
                          } else if (value == 'ROUGH') {
                            _selectedShape.value = '';
                            _selectedColor.value = '';
                            _selectedClarity.value = '';
                            penWtController.clear();
                          }
                        }
                      },
                    );
                  },
                );

                // 2. Invoice - Enabled when ROUGH, Disabled when POLISH/REJECTION
                final invoiceField = Obx(
                  () {
                    final isRough = _selectedItemType.value == 'ROUGH';
                    final items = dropdownItemsInvoice;
                    final selectedVal = _findMatchingDropdownValue(
                        items, _selectedItemInvNo.value);
                    return AppDropdown<String>(
                      label: 'Invoice :',
                      value: selectedVal,
                      items: items,
                      dropdownItems: appDropdownItemsInvoice,
                      focusNode: _itemInvFocus,
                      nextFocusNode: _charniFocus,
                      hintText: 'Select Invoice',
                      searchHint: 'Search invoice...',
                      isEnabled: _isEnabled && isRough,
                      onChanged: (val) {
                        if (val != null && val.isNotEmpty) {
                          _selectedItemInvNo.value = val;
                          invNoItemController.text = val;
                          final matchingPurchase = defaultController.purchaseDataList.firstWhereOrNull(
                            (p) => p.invoiceNo?.trim() == val.trim(),
                          );
                          if (matchingPurchase != null) {
                            final double tWeight = double.tryParse(matchingPurchase.tWeight?.toString() ?? '0') ?? 0.0;
                            penWtController.text = tWeight.toStringAsFixed(3);
                          }
                        } else {
                          _selectedItemInvNo.value = '';
                          invNoItemController.clear();
                          penWtController.clear();
                        }
                      },
                    );
                  },
                );

                // 3. Clarity - Enabled when POLISH/REJECTION, Disabled when ROUGH
                final clarityDropdown = Obx(
                  () {
                    final isPolish = _selectedItemType.value == 'POLISH/REJECTION';
                    return AppDropdown<String>(
                      label: 'Clarity :',
                      value: _findMatchingDropdownValue(
                          dropdownItemsClarity, _selectedClarity.value),
                      items: dropdownItemsClarity,
                      focusNode: _clarityFocus,
                      nextFocusNode: _charniFocus,
                      hintText: 'Clarity',
                      isEnabled: _isEnabled && isPolish,
                      onChanged: (val) {
                        if (val != null && val.isNotEmpty) {
                          _selectedClarity.value = val;
                          _updatePolishPendingWeight(val);
                        } else {
                          _selectedClarity.value = '';
                          penWtController.clear();
                        }
                      },
                    );
                  },
                );

                // 4. Charni (+/-) - Enabled for both
                final charniDropdown = Obx(
                  () {
                    final isRough = _selectedItemType.value == 'ROUGH';
                    return AppDropdown<String>(
                      label: 'Charni (+/-) :',
                      value: _findMatchingDropdownValue(
                          dropdownItemsCharni, _selectedCharni.value),
                      items: dropdownItemsCharni,
                      focusNode: _charniFocus,
                      nextFocusNode: isRough ? _qualityFocus : _colorFocus,
                      hintText: 'Charni',
                      isEnabled: _isEnabled,
                      onChanged: (val) {
                        if (val != null) _selectedCharni.value = val;
                      },
                    );
                  },
                );

                // 5. Quality - Enabled when ROUGH, Disabled when POLISH/REJECTION
                final qualityDropdown = Obx(
                  () {
                    final isRough = _selectedItemType.value == 'ROUGH';
                    return AppDropdown<String>(
                      label: 'Quality :',
                      value: _findMatchingDropdownValue(
                          dropdownItemsQuality, _selectedQuality.value),
                      items: dropdownItemsQuality,
                      focusNode: _qualityFocus,
                      nextFocusNode: _pcsFocus,
                      hintText: 'Quality',
                      isEnabled: _isEnabled && isRough,
                      onChanged: (val) {
                        if (val != null) _selectedQuality.value = val;
                      },
                    );
                  },
                );

                // 6. Color - Enabled when POLISH/REJECTION, Disabled when ROUGH
                final colorDropdown = Obx(
                  () {
                    final isPolish = _selectedItemType.value == 'POLISH/REJECTION';
                    return AppDropdown<String>(
                      label: 'Color :',
                      value: _findMatchingDropdownValue(
                          dropdownItemsColor, _selectedColor.value),
                      items: dropdownItemsColor,
                      focusNode: _colorFocus,
                      nextFocusNode: _shapeFocus,
                      hintText: 'Color',
                      isEnabled: _isEnabled && isPolish,
                      onChanged: (val) {
                        if (val != null) _selectedColor.value = val;
                      },
                    );
                  },
                );

                // 7. Shape - Enabled when POLISH/REJECTION, Disabled when ROUGH
                final shapeDropdown = Obx(
                  () {
                    final isPolish = _selectedItemType.value == 'POLISH/REJECTION';
                    return AppDropdown<String>(
                      label: 'Shape :',
                      value: _findMatchingDropdownValue(
                          dropdownItemsShape, _selectedShape.value),
                      items: dropdownItemsShape,
                      focusNode: _shapeFocus,
                      nextFocusNode: _pcsFocus,
                      hintText: 'Shape',
                      isEnabled: _isEnabled && isPolish,
                      onChanged: (val) {
                        if (val != null) _selectedShape.value = val;
                      },
                    );
                  },
                );

                // 8. Pcs
                final pcsField = AppTextField(
                  label: 'Pcs :',
                  controller: pcsController,
                  focusNode: _pcsFocus,
                  nextFocusNode: _wtFocus,
                  onFieldSubmitted: (_) => _wtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                );

                // 9. Wt
                final wtField = AppTextField(
                  label: 'Wt :',
                  controller: wtController,
                  focusNode: _wtFocus,
                  nextFocusNode: _rateRsFocus,
                  onFieldSubmitted: (_) {
                    final double wt =
                        double.tryParse(wtController.text.trim()) ?? 0.0;
                    final double? penWt =
                        penWtController.text.trim().isNotEmpty
                            ? double.tryParse(penWtController.text.trim())
                            : null;
                    if (penWt != null && wt > penWt) {
                      infoDialog(
                        messageText:
                            'Weight (${wt.toStringAsFixed(3)}) cannot be greater than Pending Weight (${penWt.toStringAsFixed(3)})',
                      );
                      _wtFocus.requestFocus();
                      return;
                    }
                    _rateRsFocus.requestFocus();
                  },
                  enabled: _isEnabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 10. Rate (Rs)
                final rateRsField = AppTextField(
                  label: 'Rate (Rs) :',
                  controller: rateRsController,
                  focusNode: _rateRsFocus,
                  nextFocusNode: _rateDollarFocus,
                  onFieldSubmitted: (_) => _rateDollarFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 11. Amount (Rs)
                final amountRsField = AppTextField(
                  label: 'Amount (Rs) :',
                  controller: amountRsController,
                  enabled: false,
                );

                // 12. Rate ($)
                final rateDollarField = AppTextField(
                  label: 'Rate (\$) :',
                  controller: rateDollarController,
                  focusNode: _rateDollarFocus,
                  nextFocusNode: _penWtFocus,
                  onFieldSubmitted: (_) => _penWtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                  ],
                );

                // 13. Amount ($)
                final amountDollarField = AppTextField(
                  label: 'Amount (\$) :',
                  controller: amountDollarController,
                  enabled: false,
                );

                // 14. Pen Wt
                final penWtField = AppTextField(
                  label: 'Pen Wt :',
                  controller: penWtController,
                  focusNode: _penWtFocus,
                  enabled: _isEnabled,
                  readOnly: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                  onFieldSubmitted: (_) => _addOrUpdateEntry(),
                );

                final bool isEditingItem = _editingEntryIndex != null;
                final actionButtons = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: isEditingItem ? 'Update' : 'Add',
                      shortcutLabel: 'Enter',
                      icon: isEditingItem
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      onPressed: _isEnabled ? _addOrUpdateEntry : null,
                    ),
                    if (isEditingItem) ...[
                      const SizedBox(width: 6),
                      AppButton(
                        text: 'Cancel',
                        icon: Icons.close_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          setState(() {
                            _clearEntryInputs();
                          });
                          _typeFocus.requestFocus();
                        },
                      ),
                    ],
                  ],
                );

                const double minRowWidth = 1440.0;
                final bool canExpand = constraints.maxWidth >= minRowWidth;

                if (canExpand) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 13, child: typeDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: invoiceField),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: clarityDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: charniDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: qualityDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 8, child: colorDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: shapeDropdown),
                      const SizedBox(width: 6),
                      Expanded(flex: 6, child: pcsField),
                      const SizedBox(width: 6),
                      Expanded(flex: 8, child: wtField),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: rateRsField),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: amountRsField),
                      const SizedBox(width: 6),
                      Expanded(flex: 9, child: rateDollarField),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: amountDollarField),
                      const SizedBox(width: 6),
                      Expanded(flex: 8, child: penWtField),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: actionButtons,
                      ),
                    ],
                  );
                } else {
                  // Narrow screens: equal-width cells that wrap onto as many
                  // lines as needed, so every field stays visible.
                  const double gap = 6;
                  final double width = constraints.maxWidth;
                  final int columns = (width / 150).floor().clamp(2, 8).toInt();
                  final double cell = (width - gap * (columns - 1)) / columns;
                  final fields = <Widget>[
                    typeDropdown,
                    invoiceField,
                    clarityDropdown,
                    charniDropdown,
                    qualityDropdown,
                    colorDropdown,
                    shapeDropdown,
                    pcsField,
                    wtField,
                    rateRsField,
                    amountRsField,
                    rateDollarField,
                    amountDollarField,
                    penWtField,
                  ];
                  return Wrap(
                    spacing: gap,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      for (final f in fields) SizedBox(width: cell, child: f),
                      SizedBox(
                        width: cell,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: actionButtons,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesTableCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final titleWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_list_bulleted_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'SALE ITEMS LIST (${entries.length})',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                );

                final summaryPills = Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: constraints.maxWidth < 600 ? WrapAlignment.start : WrapAlignment.end,
                  children: [
                    _buildSummaryPill('Packets: ', '$totalPacket', AppColors.textSecondary),
                    _buildSummaryPill(
                        'Total Wt: ', '${totalWt.toStringAsFixed(3)} Cts', AppColors.primary),
                    _buildSummaryPill('Avg Rate (Rs): ',
                        '₹ ${totalRateRs.toStringAsFixed(2)}', AppColors.textPrimary),
                    _buildSummaryPill('Total Amt (Rs): ',
                        '₹ ${totalAmountRs.toStringAsFixed(2)}', AppColors.success),
                    _buildSummaryPill('Avg Rate (\$): ',
                        '\$ ${totalRateDollar.toStringAsFixed(4)}', AppColors.textPrimary),
                    _buildSummaryPill('Total Amt (\$): ',
                        '\$ ${totalAmountDollar.toStringAsFixed(2)}', AppColors.warning),
                  ],
                );

                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget,
                      const SizedBox(height: 8),
                      summaryPills,
                    ],
                  );
                }

                // Flexible gives the pills a bounded width so they wrap to
                // more lines on narrow screens instead of overflowing.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: titleWidget,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: summaryPills,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Entries Table matching the grid columns in the reference image
            if (entries.isEmpty)
              Container(
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_outlined, size: 28, color: AppColors.textMuted),
                    const SizedBox(height: 6),
                    Text('No sale items added yet',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('Select a Type, Invoice/Specs, Weight, Rate, and press Enter to add',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth < 1150 ? 1150 : constraints.maxWidth,
                      ),
                      child: Table(
                        border: TableBorder.all(color: AppColors.border, width: 1),
                        columnWidths: const {
                          0: FixedColumnWidth(45), // Srno
                          1: FlexColumnWidth(1.8), // Type
                          2: FlexColumnWidth(1.6), // InvNo
                          3: FlexColumnWidth(1.6), // Clarity
                          4: FlexColumnWidth(1.8), // Charni
                          5: FlexColumnWidth(1.6), // Quality
                          6: FlexColumnWidth(1.4), // Color
                          7: FlexColumnWidth(1.6), // Shape
                          8: FixedColumnWidth(50), // Pc
                          9: FlexColumnWidth(1.6), // Wt
                          10: FlexColumnWidth(1.8), // Rate Rs
                          11: FlexColumnWidth(2.0), // Amount Rs
                          12: FlexColumnWidth(1.8), // Rate Dollar
                          13: FlexColumnWidth(2.0), // Amount Dollar
                          14: FixedColumnWidth(80), // Actions
                        },
                        children: [
                          // Table Header
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                            children: [
                              _buildTableHeaderCell('Srno', align: TextAlign.center),
                              _buildTableHeaderCell('Type'),
                              _buildTableHeaderCell('InvNo'),
                              _buildTableHeaderCell('Clarity'),
                              _buildTableHeaderCell('Charni'),
                              _buildTableHeaderCell('Quality'),
                              _buildTableHeaderCell('Color'),
                              _buildTableHeaderCell('Shape'),
                              _buildTableHeaderCell('Pc', align: TextAlign.right),
                              _buildTableHeaderCell('Wt', align: TextAlign.right),
                              _buildTableHeaderCell('Rate Rs', align: TextAlign.right),
                              _buildTableHeaderCell('Amount Rs', align: TextAlign.right),
                              _buildTableHeaderCell('Rate Dollar', align: TextAlign.right),
                              _buildTableHeaderCell('Amount Dollar', align: TextAlign.right),
                              _buildTableHeaderCell('Actions', align: TextAlign.center),
                            ],
                          ),
                          // Data Rows
                          for (int i = 0; i < entries.length; i++)
                            TableRow(
                              decoration: BoxDecoration(
                                color: _editingEntryIndex == i
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : (i % 2 == 0 ? AppColors.surface : AppColors.tableRowAlt),
                              ),
                              children: [
                                _buildTableCell('${i + 1}', align: TextAlign.center),
                                _buildTableCell(entries[i]['type']?.toString() ?? 'ROUGH'),
                                _buildTableCell((entries[i]['invNo']?.toString().isNotEmpty ?? false) ? entries[i]['invNo'].toString() : '-'),
                                _buildTableCell((entries[i]['clarity'] != null && entries[i]['clarity'].toString().isNotEmpty) ? getClarityName(entries[i]['clarity']) : '-'),
                                _buildTableCell((entries[i]['charni'] != null && entries[i]['charni'].toString().isNotEmpty) ? getCharniName(entries[i]['charni']) : '-'),
                                _buildTableCell((entries[i]['quality'] != null && entries[i]['quality'].toString().isNotEmpty) ? getQualityName(entries[i]['quality']) : '-'),
                                _buildTableCell((entries[i]['color'] != null && entries[i]['color'].toString().isNotEmpty) ? getColorName(entries[i]['color']) : '-'),
                                _buildTableCell((entries[i]['shape'] != null && entries[i]['shape'].toString().isNotEmpty) ? getShapeName(entries[i]['shape']) : '-'),
                                _buildTableCell(entries[i]['pcs']?.toString() ?? '1',
                                    align: TextAlign.right),
                                _buildTableCell(entries[i]['wt']?.toString() ?? '0.000',
                                    align: TextAlign.right),
                                _buildTableCell('₹ ${entries[i]['rateRs'] ?? entries[i]['rate'] ?? '0.00'}',
                                    align: TextAlign.right),
                                _buildTableCell('₹ ${entries[i]['amountRs'] ?? entries[i]['amount'] ?? '0.00'}',
                                    align: TextAlign.right, isBold: true),
                                _buildTableCell('\$ ${entries[i]['rateDollar'] ?? '0.00'}',
                                    align: TextAlign.right),
                                _buildTableCell('\$ ${entries[i]['amountDollar'] ?? '0.00'}',
                                    align: TextAlign.right, isBold: true),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: _isEnabled ? () => _editEntry(i) : null,
                                          borderRadius: BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              _editingEntryIndex == i
                                                  ? Icons.edit_rounded
                                                  : Icons.edit_outlined,
                                              size: 15,
                                              color: !_isEnabled
                                                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                                                  : (_editingEntryIndex == i
                                                      ? AppColors.warning
                                                      : AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: _isEnabled ? () => _deleteEntry(i) : null,
                                          borderRadius: BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(Icons.delete_outline_rounded,
                                                size: 15,
                                                color: !_isEnabled
                                                    ? AppColors.textSecondary.withValues(alpha: 0.4)
                                                    : AppColors.danger),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Totals Row
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
                            children: [
                              _buildTableCell('', align: TextAlign.center),
                              _buildTableCell('TOTAL', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('', isBold: true),
                              _buildTableCell('$totalPacket',
                                  align: TextAlign.right, isBold: true),
                              _buildTableCell(totalWt.toStringAsFixed(3),
                                  align: TextAlign.right, isBold: true),
                              _buildTableCell('₹ ${totalRateRs.toStringAsFixed(2)}',
                                  align: TextAlign.right, isBold: true),
                              _buildTableCell('₹ ${totalAmountRs.toStringAsFixed(2)}',
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.primary),
                              _buildTableCell('\$ ${totalRateDollar.toStringAsFixed(4)}',
                                  align: TextAlign.right, isBold: true),
                              _buildTableCell('\$ ${totalAmountDollar.toStringAsFixed(2)}',
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.primary),
                              _buildTableCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBoxesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final packetBox = _buildStatField('Packet', '$totalPacket');
            final wtBox = _buildStatField('Wt', totalWt.toStringAsFixed(4));
            final rateRsBox = _buildStatField('Rate (Rs)', totalRateRs.toStringAsFixed(4));
            final amtRsBox = _buildStatField('Amount (Rs)', totalAmountRs.toStringAsFixed(4));
            final rateDBox = _buildStatField('Rate (\$)', totalRateDollar.toStringAsFixed(4));
            final amtDBox = _buildStatField('Amount (\$)', totalAmountDollar.toStringAsFixed(4));

            if (constraints.maxWidth >= 800) {
              return Row(
                children: [
                  Expanded(child: packetBox),
                  const SizedBox(width: 8),
                  Expanded(child: wtBox),
                  const SizedBox(width: 8),
                  Expanded(child: rateRsBox),
                  const SizedBox(width: 8),
                  Expanded(child: amtRsBox),
                  const SizedBox(width: 8),
                  Expanded(child: rateDBox),
                  const SizedBox(width: 8),
                  Expanded(child: amtDBox),
                ],
              );
            } else {
              return Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  packetBox,
                  wtBox,
                  rateRsBox,
                  amtRsBox,
                  rateDBox,
                  amtDBox,
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ==================== GST / NET / BROKERAGE CARD ====================

  Widget _buildGstSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            sgstPerController,
            cgstPerController,
            igstPerController,
            netRsController,
            broPerController,
            dollarRateController,
          ]),
          builder: (context, _) {
            final gst = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _summaryRow('', [
                  _summaryHeader(''),
                  _summaryHeader('Rs Amount'),
                  _summaryHeader('\$ Amount'),
                ]),
                _summaryRow('SGST :', [
                  _summaryInput(sgstPerController),
                  _summaryValue(sgstRs.toStringAsFixed(2)),
                  _summaryValue(sgstDollar.toStringAsFixed(2)),
                ]),
                _summaryRow('CGST :', [
                  _summaryInput(cgstPerController),
                  _summaryValue(cgstRs.toStringAsFixed(2)),
                  _summaryValue(cgstDollar.toStringAsFixed(2)),
                ]),
                _summaryRow('IGST :', [
                  _summaryInput(igstPerController),
                  _summaryValue(igstRs.toStringAsFixed(2)),
                  _summaryValue(igstDollar.toStringAsFixed(2)),
                ]),
                _summaryRow('Tot Rs Amount :', [
                  _summaryValue(totalAmountRs.toStringAsFixed(2)),
                  _summaryLabel('Tot \$ Amount :'),
                  _summaryValue(totalAmountDollar.toStringAsFixed(3)),
                ]),
              ],
            );

            final net = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _summaryRow('', [_summaryHeader(''), _summaryHeader(''), _summaryHeader('')]),
                _summaryRow('Net Rs Amount :', [
                  _summaryInput(netRsController, decimals: 2),
                  _summaryLabel('Net \$ Amount :'),
                  _summaryValue(netDollar.toStringAsFixed(3)),
                ]),
                _summaryRow('Round Amt :', [
                  _summaryValue(roundRs.abs() < 0.005 ? '' : roundRs.toStringAsFixed(2)),
                  _summaryLabel('Round \$ :'),
                  _summaryValue(roundDollar.abs() < 0.0005 ? '' : roundDollar.toStringAsFixed(3)),
                ]),
                _summaryRow('Brokerage(%) :', [
                  _summaryInput(broPerController, hint: '0.000'),
                  _summaryValue(broPer == 0 ? '' : broRs.toStringAsFixed(2)),
                  _summaryValue(broPer == 0 ? '' : broDollar.toStringAsFixed(3)),
                ]),
                _summaryRow('Final Rs Amount :', [
                  _summaryValue(finalRs.toStringAsFixed(2), bold: true),
                  _summaryLabel('Final \$ Amount :'),
                  _summaryValue(finalDollar.toStringAsFixed(3), bold: true),
                ]),
              ],
            );

            return LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: gst),
                    const SizedBox(width: 24),
                    Expanded(child: net),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [gst, const SizedBox(height: 8), net],
              );
            });
          },
        ),
      ),
    );
  }

  Widget _summaryRow(String label, List<Widget> cells) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _summaryLabel(label),
            ),
          ),
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: cells[i]),
          ],
        ],
      ),
    );
  }

  Widget _summaryLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }

  Widget _summaryHeader(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
    );
  }

  // Compact fields - same size/look as the Rough Purchase calculation fields
  static const EdgeInsets _summaryFieldPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 4);

  /// Read-only value (grey disabled field, as in Rough Purchase).
  Widget _summaryValue(String value, {bool bold = false}) {
    return AppTextField(
      controller: TextEditingController(text: value),
      enabled: false,
      textAlign: TextAlign.right,
      contentPadding: _summaryFieldPadding,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: bold ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }

  /// Editable number field (compact).
  Widget _summaryInput(TextEditingController controller, {int decimals = 3, String? hint}) {
    return AppTextField(
      controller: controller,
      enabled: _isEnabled,
      hintText: hint ?? '0.00',
      textAlign: TextAlign.right,
      contentPadding: _summaryFieldPadding,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('^\\d*\\.?\\d{0,$decimals}')),
      ],
    );
  }

  Widget _buildStatField(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  TableCell _buildTableHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          textAlign: align,
        ),
      ),
    );
  }

  TableCell _buildTableCell(String text,
      {TextAlign align = TextAlign.left, bool isBold = false, Color? color}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.textPrimary,
          ),
          textAlign: align,
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppButton(
            text: 'Add',
            icon: Icons.add_rounded,
            onPressed: !_isEnabled ? () => _enableFields() : null,
          ),
          AppButton(
            text: 'Edit',
            icon: Icons.edit_note_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: (_isFromEdit && !_isEnabled)
                ? () {
                    setState(() => _isEnabled = true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _typeFocus.requestFocus();
                    });
                  }
                : null,
          ),
          Obx(() => AppButton(
                text: 'Save',
                icon: Icons.save_rounded,
                isLoading: defaultController.isLoading.value,
                onPressed: _isEnabled ? _handleSave : null,
              )),
          Obx(() => AppButton(
                text: 'Delete',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                isLoading: defaultController.isDeleteLoading.value,
                onPressed: (_isFromEdit && _isEnabled) ? _handleDelete : null,
              )),
          AppButton(
            text: 'Cancel',
            icon: Icons.cancel_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: (_isEnabled || _isFromEdit) ? _handleCancel : null,
          ),
          AppButton(
            text: 'Exit',
            icon: Icons.exit_to_app_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => tabController.closeCurrentTab(),
          ),
          AppButton(
            text: 'Search',
            icon: Icons.search_rounded,
            variant: AppButtonVariant.outline,
            onPressed: () {
              setState(() => _isSearch = true);
              defaultController.getSaleData(force: true);
              defaultController.getSaleDetailsData(force: true);
            },
          ),
          AppButton(
            text: 'Print',
            icon: Icons.print_rounded,
            variant: AppButtonVariant.outline,
            onPressed: _isFromEdit ? _handlePrint : null,
          ),
          // Checkboxes matching reference screenshot
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _chkPrint.value,
                  onChanged: (val) => _chkPrint.value = val ?? false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text('Print', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _chkPreview.value,
                  onChanged: (val) => _chkPreview.value = val ?? true,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text('Preview', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DATAGRID COLUMNS DEFINITIONS ====================

  List<GridColumn> _buildSearchGridColumns() {
    return <GridColumn>[
      GridColumn(
        columnName: 'ID',
        visible: false,
        label: _buildGridHeader('ID'),
      ),
      GridColumn(
        columnName: 'Invoice No',
        label: _buildGridHeader('Invoice No'),
      ),
      GridColumn(
        columnName: 'Invoice Date',
        label: _buildGridHeader('Invoice Date'),
      ),
      GridColumn(
        columnName: 'Party',
        label: _buildGridHeader('Party'),
      ),
      GridColumn(
        columnName: 'Broker',
        label: _buildGridHeader('Broker'),
      ),
      GridColumn(
        columnName: 'Tot Wt',
        label: _buildGridHeader('Tot Wt'),
      ),
      GridColumn(
        columnName: 'Tot Amt Rs',
        label: _buildGridHeader('Tot Amt Rs'),
      ),
    ];
  }

  Widget _buildGridHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
