import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/purchase/invoice_generator.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_datagrid.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_details_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PurchaseFormScreen extends StatefulWidget {
  final bool showHeader;

  const PurchaseFormScreen({super.key, required this.showHeader});

  @override
  PurchaseFormScreenState createState() => PurchaseFormScreenState();
}

class PurchaseFormScreenState extends State<PurchaseFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmroughpurchaseform',
        'rough purchase',
      ]);
  // ==================== MASTER HEADER CONTROLLERS ====================
  final TextEditingController idController = TextEditingController();
  final TextEditingController crIdController = TextEditingController();
  final TextEditingController invNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController recDateController = TextEditingController();
  final TextEditingController siteController = TextEditingController();
  final RxString _selectedBillType = 'BILL'.obs;
  final RxString _selectedTypeParty = ''.obs;
  final RxString _selectedTypeBroker = ''.obs;
  final TextEditingController dueDaysController = TextEditingController(text: '0');
  final TextEditingController dueDateController = TextEditingController();
  final RxString _selectedCurrency = 'RS'.obs;
  final TextEditingController dollarRateController = TextEditingController(text: '71.000');

  // ==================== SUB-DETAILS (ROUGH ITEM) CONTROLLERS ====================
  final RxString _selectedType = ''.obs;
  final TextEditingController itemSiteController = TextEditingController();
  final RxString _selectedQuality = ''.obs;
  final RxString _selectedCharni = ''.obs;
  final TextEditingController pcsController = TextEditingController();
  final TextEditingController wtController = TextEditingController();
  final TextEditingController rateRsController = TextEditingController();
  final TextEditingController amountRsController = TextEditingController();
  final TextEditingController rateDollarController = TextEditingController();
  final TextEditingController amountDollarController = TextEditingController();
  final TextEditingController descripController = TextEditingController();

  // ==================== BOTTOM SECTION: EXPENSES & DEDUCTIONS ====================
  final RxBool _chkExp = false.obs; // In reference image, Fix is checked by default
  final TextEditingController expPerController = TextEditingController(text: '0.0000');
  final TextEditingController expFixDollarController = TextEditingController();
  final TextEditingController expFixRsController = TextEditingController(text: '0.000');

  final RxBool _chkLin = false.obs;
  final TextEditingController linPerController = TextEditingController();
  final TextEditingController linFixDollarController = TextEditingController(text: '0.000');
  final TextEditingController linFixRsController = TextEditingController(text: '0.000');

  final TextEditingController totExpPerController = TextEditingController(text: '0.0000');
  final TextEditingController totExpFixDollarController = TextEditingController(text: '0.000');
  final TextEditingController totExpFixRsController = TextEditingController(text: '0.000');

  final RxBool _chkBro = false.obs;
  final TextEditingController broPerController = TextEditingController();
  final TextEditingController broFixDollarController = TextEditingController(text: '0.000');
  final TextEditingController broRsController = TextEditingController(text: '0.000');

  final RxBool _chkAdd = false.obs;
  final TextEditingController addPerController = TextEditingController();
  final TextEditingController addFixDollarController = TextEditingController(text: '0.000');
  final TextEditingController addFixRsController = TextEditingController(text: '0.000');

  final RxBool _chkLess = false.obs;
  final TextEditingController lessPerController = TextEditingController();
  final TextEditingController lessFixDollarController = TextEditingController(text: '0.000');
  final TextEditingController lessFixRsController = TextEditingController(text: '0.000');

  final TextEditingController remarksController = TextEditingController();

  // ==================== BOTTOM SECTION: CHARGES, TAXES & SUMMARY ====================
  final RxBool _chkInv = false.obs;
  final TextEditingController invChargePerController = TextEditingController();
  final TextEditingController invChargeDollarController = TextEditingController(text: '0.000');
  final TextEditingController invChargeRsController = TextEditingController(text: '0.000');

  final RxBool _chkCom = false.obs;
  final TextEditingController comPerController = TextEditingController();
  final TextEditingController comDollarController = TextEditingController(text: '0.000');
  final TextEditingController comRsController = TextEditingController(text: '0.000');

  final TextEditingController totAmtDollarController = TextEditingController(text: '0.000');
  final TextEditingController totAmtRsController = TextEditingController(text: '0.000');

  final TextEditingController gstPerController = TextEditingController(text: '0.25');
  final TextEditingController gstAmtDollarController = TextEditingController(text: '0.000');
  final TextEditingController gstAmtRsController = TextEditingController(text: '0.000');

  final TextEditingController netAmtDollarController = TextEditingController(text: '0.000');
  final TextEditingController netAmtRsController = TextEditingController(text: '0.000');

  final TextEditingController roundOfDollarController = TextEditingController(text: '0.000');
  final TextEditingController roundOfRsController = TextEditingController(text: '0.000');

  final TextEditingController finalAmtDollarController = TextEditingController(text: '0.000');
  final TextEditingController finalAmtRsController = TextEditingController(text: '0.000');

  final TextEditingController expBrNetDollarController = TextEditingController(text: '0.000');
  final TextEditingController expBrNetRsController = TextEditingController(text: '0.000');

  final TextEditingController totNetAmtDollarController = TextEditingController(text: '0.000');
  final TextEditingController totNetAmtRsController = TextEditingController(text: '0.000');

  // ==================== FOCUS NODES ====================
  final FocusNode _invNoFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _recDateFocus = FocusNode();
  final FocusNode _siteFocus = FocusNode();
  final FocusNode _billTypeFocus = FocusNode();
  final FocusNode _partyFocus = FocusNode();
  final FocusNode _brokerFocus = FocusNode();
  final FocusNode _dueDaysFocus = FocusNode();
  final FocusNode _dueDateFocus = FocusNode();
  final FocusNode _currencyFocus = FocusNode();
  final FocusNode _dollarRateFocus = FocusNode();

  final FocusNode _roughFocus = FocusNode();
  final FocusNode _itemSiteFocus = FocusNode();
  final FocusNode _qualityFocus = FocusNode();
  final FocusNode _charniFocus = FocusNode();
  final FocusNode _pcsFocus = FocusNode();
  final FocusNode _wtFocus = FocusNode();
  final FocusNode _rateRsFocus = FocusNode();
  final FocusNode _rateDollarFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();
  final DefaultController defaultController = Get.find<DefaultController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> entries = [];
  final RxInt selectedRoughPurMstID = 0.obs;
  final RxString selectedRoughId = ''.obs;
  int? _editingEntryIndex;

  DateTime? selectedDate;
  DateTime? selectedRecDate;
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

  RxList<PurchaseDetailsModel> purchaseDataGridSource = <PurchaseDetailsModel>[].obs;
  RxList<PurchaseDetailsModel> filteredDataGridSource = <PurchaseDetailsModel>[].obs;
  Worker? _listWorker;

  // ==================== ITEM TOTAL COMPUTATIONS ====================
  int get totalPc => entries.fold(0, (prev, e) => prev + (int.tryParse(e['pc']?.toString() ?? '0') ?? 0));
  double get totalWt => entries.fold(0.0, (prev, e) => prev + (double.tryParse(e['wt']?.toString() ?? '0') ?? 0.0));
  double get totalAmountRs => entries.fold(0.0, (prev, e) => prev + (double.tryParse(e['amtRs']?.toString() ?? e['amount']?.toString() ?? '0') ?? 0.0));
  double get totalAmountDollar => entries.fold(0.0, (prev, e) => prev + (double.tryParse(e['amtDollar']?.toString() ?? '0') ?? 0.0));
  double get totalRateRs => totalWt == 0 ? 0 : totalAmountRs / totalWt;
  double get totalRateDollar => totalWt == 0 ? 0 : totalAmountDollar / totalWt;

  // Backwards compatibility aliases
  double get totalAmount => totalAmountRs;
  double get totalRate => totalRateRs;

  @override
  void initState() {
    super.initState();
    crIdController.text = defaultController.effectiveCrId;
    wtController.addListener(_updateItemAmount);
    purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(defaultController.purchaseDataList);

    _listWorker = ever(defaultController.purchaseDataList, (list) {
      if (mounted) {
        if (_isFiltered.value) {
          _applyDateFilter();
        } else {
          purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(list);
        }
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultController.purchaseDataList.isEmpty) {
        defaultController.getPurchaseData();
      }
      if (defaultController.roughDetailsModel.isEmpty) {
        defaultController.getPurchaseDetailsData();
      }
      if (defaultController.partyMstList.isEmpty) {
        defaultController.getPartyData();
      }
      if (defaultController.roughModel.isEmpty) {
        defaultController.getRoughData();
      }
      if (defaultController.qualityModelList.isEmpty) {
        defaultController.getQualityData();
      }
      if (defaultController.charniModelList.isEmpty) {
        defaultController.getCharniData();
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
    recDateController.dispose();
    siteController.dispose();
    dueDaysController.dispose();
    dueDateController.dispose();
    dollarRateController.dispose();

    itemSiteController.dispose();
    pcsController.dispose();
    wtController.dispose();
    rateRsController.dispose();
    amountRsController.dispose();
    rateDollarController.dispose();
    amountDollarController.dispose();
    descripController.dispose();

    expPerController.dispose();
    expFixDollarController.dispose();
    expFixRsController.dispose();
    linPerController.dispose();
    linFixDollarController.dispose();
    linFixRsController.dispose();
    totExpPerController.dispose();
    totExpFixDollarController.dispose();
    totExpFixRsController.dispose();
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

    invChargePerController.dispose();
    invChargeDollarController.dispose();
    invChargeRsController.dispose();
    comPerController.dispose();
    comDollarController.dispose();
    comRsController.dispose();
    totAmtDollarController.dispose();
    totAmtRsController.dispose();
    gstPerController.dispose();
    gstAmtDollarController.dispose();
    gstAmtRsController.dispose();
    netAmtDollarController.dispose();
    netAmtRsController.dispose();
    roundOfDollarController.dispose();
    roundOfRsController.dispose();
    finalAmtDollarController.dispose();
    finalAmtRsController.dispose();
    expBrNetDollarController.dispose();
    expBrNetRsController.dispose();
    totNetAmtDollarController.dispose();
    totNetAmtRsController.dispose();

    fromDateController.dispose();
    toDateController.dispose();

    _invNoFocus.dispose();
    _dateFocus.dispose();
    _recDateFocus.dispose();
    _siteFocus.dispose();
    _billTypeFocus.dispose();
    _partyFocus.dispose();
    _brokerFocus.dispose();
    _dueDaysFocus.dispose();
    _dueDateFocus.dispose();
    _currencyFocus.dispose();
    _dollarRateFocus.dispose();
    _roughFocus.dispose();
    _itemSiteFocus.dispose();
    _qualityFocus.dispose();
    _charniFocus.dispose();
    _pcsFocus.dispose();
    _wtFocus.dispose();
    _rateRsFocus.dispose();
    _rateDollarFocus.dispose();
    _descFocus.dispose();

    super.dispose();
  }

  // ==================== DUAL CURRENCY & AMOUNT CONVERSIONS ====================
  void _onRateRsChanged(String val) {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    final double rateRs = double.tryParse(val) ?? 0.0;
    final double dollarRate = double.tryParse(dollarRateController.text) ?? 1.0;
    if (dollarRate > 0) {
      final double rateDollar = rateRs / dollarRate;
      rateDollarController.text = rateDollar > 0 ? rateDollar.toStringAsFixed(2) : '';
    }
    _updateItemAmount();
    _isConvertingRate = false;
  }

  void _onRateDollarChanged(String val) {
    if (_isConvertingRate) return;
    _isConvertingRate = true;
    final double rateDollar = double.tryParse(val) ?? 0.0;
    final double dollarRate = double.tryParse(dollarRateController.text) ?? 1.0;
    final double rateRs = rateDollar * dollarRate;
    rateRsController.text = rateRs > 0 ? rateRs.toStringAsFixed(2) : '';
    _updateItemAmount();
    _isConvertingRate = false;
  }

  void _updateItemAmount() {
    final double wt = double.tryParse(wtController.text) ?? 0.0;
    final double rateRs = double.tryParse(rateRsController.text) ?? 0.0;
    final double rateDollar = double.tryParse(rateDollarController.text) ?? 0.0;
    final amts = _itemAmounts(wt, rateRs, rateDollar);
    amountRsController.text = amts[0] > 0 ? amts[0].toStringAsFixed(2) : '0.00';
    amountDollarController.text = amts[1] > 0 ? amts[1].toStringAsFixed(2) : '0.00';
  }

  /// [amount Rs, amount $] of an item. The rate of the other currency is shown
  /// rounded to 2 decimals, so its amount is worked out from the exact amount
  /// of the entry currency (before: 100 ct x ₹1000 at 71 = $1408.00 instead of
  /// $1408.45).
  List<double> _itemAmounts(double wt, double rateRs, double rateDollar) {
    final double exchange = double.tryParse(dollarRateController.text) ?? 0.0;
    double amtRs = wt * rateRs;
    double amtD = wt * rateDollar;
    if (exchange > 0) {
      if (_selectedCurrency.value == 'USD') {
        if (amtD > 0) amtRs = amtD * exchange;
      } else {
        if (amtRs > 0) amtD = amtRs / exchange;
      }
    }
    return [amtRs, amtD];
  }

  void _clearEntryInputs() {
    _selectedType.value = '';
    itemSiteController.clear();
    _selectedQuality.value = '';
    _selectedCharni.value = '';
    pcsController.clear();
    wtController.clear();
    rateRsController.clear();
    amountRsController.clear();
    rateDollarController.clear();
    amountDollarController.clear();
    descripController.clear();
    selectedRoughId.value = '';
    _editingEntryIndex = null;
  }

  void _recalculateEntriesForExchangeRate() {
    final double exchangeRate = double.tryParse(dollarRateController.text) ?? 0.0;
    if (exchangeRate <= 0) return;

    final bool isUsd = _selectedCurrency.value == 'USD';

    setState(() {
      for (var entry in entries) {
        final double wt = double.tryParse(entry['wt']?.toString() ?? '0') ?? 0.0;

        if (isUsd) {
          double rateD = double.tryParse(entry['rateDollar']?.toString() ?? '0') ?? 0.0;
          if (rateD == 0.0) {
            final double rateR = double.tryParse(entry['rateRs']?.toString() ?? entry['rate']?.toString() ?? '0') ?? 0.0;
            if (rateR > 0) {
              rateD = rateR / exchangeRate;
            }
          }
          final double rateR = rateD * exchangeRate;
          final double amtD = wt * rateD;
          final double amtR = wt * rateR;

          entry['rateDollar'] = rateD.toStringAsFixed(2);
          entry['amtDollar'] = amtD.toStringAsFixed(2);
          entry['rateRs'] = rateR.toStringAsFixed(2);
          entry['amtRs'] = amtR.toStringAsFixed(2);
          entry['rate'] = rateR.toStringAsFixed(2);
          entry['amount'] = amtR.toStringAsFixed(2);
        } else {
          double rateR = double.tryParse(entry['rateRs']?.toString() ?? entry['rate']?.toString() ?? '0') ?? 0.0;
          if (rateR == 0.0) {
            final double rateD = double.tryParse(entry['rateDollar']?.toString() ?? '0') ?? 0.0;
            if (rateD > 0) {
              rateR = rateD * exchangeRate;
            }
          }
          final double rateD = rateR / exchangeRate;
          final double amtR = wt * rateR;
          final double amtD = amtR / exchangeRate; // exact, not from the rounded $ rate

          entry['rateRs'] = rateR.toStringAsFixed(2);
          entry['amtRs'] = amtR.toStringAsFixed(2);
          entry['rateDollar'] = rateD.toStringAsFixed(2);
          entry['amtDollar'] = amtD.toStringAsFixed(2);
          entry['rate'] = rateR.toStringAsFixed(2);
          entry['amount'] = amtR.toStringAsFixed(2);
        }
      }

      if (rateDollarController.text.isNotEmpty || rateRsController.text.isNotEmpty) {
        if (isUsd) {
          final double rateD = double.tryParse(rateDollarController.text) ?? 0.0;
          if (rateD > 0) {
            final double rateR = rateD * exchangeRate;
            rateRsController.text = rateR.toStringAsFixed(2);
            _updateItemAmount();
          }
        } else {
          final double rateR = double.tryParse(rateRsController.text) ?? 0.0;
          if (rateR > 0) {
            final double rateD = rateR / exchangeRate;
            rateDollarController.text = rateD.toStringAsFixed(2);
            _updateItemAmount();
          }
        }
      }
    });

    _updateCalculations();
  }

  // ==================== BOTTOM EXPENSE & TAX CALCULATIONS ====================
  void _updateCalculations() {
    final double dollarRate = double.tryParse(dollarRateController.text) ?? 1.0;
    final bool isUsd = _selectedCurrency.value == 'USD';
    final double gridAmtD = totalAmountDollar;
    final double gridAmtRs = totalAmountRs;

    // Helper to calculate a row's dollar and rupees given base amounts
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
        if (isUsd) {
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

    // 1. Inv Charge & Comm. (calculated from grid subtotal amounts)
    final (invP, invD, invR) = calcRow(
      isFix: _chkInv.value,
      perCtrl: invChargePerController,
      fixDCtrl: invChargeDollarController,
      fixRCtrl: invChargeRsController,
      baseAmtD: gridAmtD,
      baseAmtRs: gridAmtRs,
    );

    final (comP, comD, comR) = calcRow(
      isFix: _chkCom.value,
      perCtrl: comPerController,
      fixDCtrl: comDollarController,
      fixRCtrl: comRsController,
      baseAmtD: gridAmtD,
      baseAmtRs: gridAmtRs,
    );

    // 2. Total Amt ($ & Rs) = Grid Amount + Inv Charge + Comm.
    final double totAmtD = gridAmtD + invD + comD;
    final double totAmtRs = gridAmtRs + invR + comR;
    totAmtDollarController.text = totAmtD.toStringAsFixed(3);
    totAmtRsController.text = totAmtRs.toStringAsFixed(3);

    // 3. GST % (calculated on Total Amt)
    double gstP = double.tryParse(gstPerController.text) ?? 0.25;
    double gstD = totAmtD * gstP / 100;
    double gstR = totAmtRs * gstP / 100;
    gstAmtDollarController.text = gstD.toStringAsFixed(3);
    gstAmtRsController.text = gstR.toStringAsFixed(3);

    // 4. Net Amount ($ & Rs) = Total Amt + GST
    double netD = totAmtD + gstD;
    double netR = totAmtRs + gstR;
    netAmtDollarController.text = netD.toStringAsFixed(3);
    netAmtRsController.text = netR.toStringAsFixed(3);

    // 5. Left side: Expense, License, Total Expense, Brokerage, Add (+), Less (-)
    // All calculated on Net Amount (netD, netR)
    final (expP, expD, expR) = calcRow(
      isFix: _chkExp.value,
      perCtrl: expPerController,
      fixDCtrl: expFixDollarController,
      fixRCtrl: expFixRsController,
      baseAmtD: netD,
      baseAmtRs: netR,
    );

    final (linP, linD, linR) = calcRow(
      isFix: _chkLin.value,
      perCtrl: linPerController,
      fixDCtrl: linFixDollarController,
      fixRCtrl: linFixRsController,
      baseAmtD: netD,
      baseAmtRs: netR,
    );

    totExpPerController.text = (expP + linP).toStringAsFixed(4);
    totExpFixDollarController.text = (expD + linD).toStringAsFixed(3);
    totExpFixRsController.text = (expR + linR).toStringAsFixed(3);

    final (broP, broD, broR) = calcRow(
      isFix: _chkBro.value,
      perCtrl: broPerController,
      fixDCtrl: broFixDollarController,
      fixRCtrl: broRsController,
      baseAmtD: netD,
      baseAmtRs: netR,
    );

    final (addP, addD, addR) = calcRow(
      isFix: _chkAdd.value,
      perCtrl: addPerController,
      fixDCtrl: addFixDollarController,
      fixRCtrl: addFixRsController,
      baseAmtD: netD,
      baseAmtRs: netR,
    );

    final (lessP, lessD, lessR) = calcRow(
      isFix: _chkLess.value,
      perCtrl: lessPerController,
      fixDCtrl: lessFixDollarController,
      fixRCtrl: lessFixRsController,
      baseAmtD: netD,
      baseAmtRs: netR,
    );

    // 6. Round Off
    double rndD = 0.0;
    double rndR = 0.0;
    if (isUsd) {
      rndD = double.tryParse(roundOfDollarController.text) ?? 0.0;
      rndR = dollarRate > 0 ? rndD * dollarRate : 0.0;
      roundOfRsController.text = rndR.toStringAsFixed(3);
    } else {
      rndR = double.tryParse(roundOfRsController.text) ?? 0.0;
      rndD = dollarRate > 0 ? rndR / dollarRate : 0.0;
      roundOfDollarController.text = rndD.toStringAsFixed(3);
    }

    // 7. Final Amount
    double finD = netD - rndD;
    double finR = netR - rndR;
    finalAmtDollarController.text = finD.toStringAsFixed(3);
    finalAmtRsController.text = finR.toStringAsFixed(3);

    // 8. Exp / Br Net Amount = Net Amt + Total Expense (exp + lin) + Brokerage
    double expBrD = netD + (expD + linD) + broD;
    double expBrR = netR + (expR + linR) + broR;
    expBrNetDollarController.text = expBrD.toStringAsFixed(3);
    expBrNetRsController.text = expBrR.toStringAsFixed(3);

    // 9. Tot Net Amt = Exp / Br Net Amount + Add (+) - Less (-)
    double totNetD = expBrD + addD - lessD;
    double totNetR = expBrR + addR - lessR;
    totNetAmtDollarController.text = totNetD.toStringAsFixed(3);
    totNetAmtRsController.text = totNetR.toStringAsFixed(3);

    if (mounted) setState(() {});
  }

  DateTime? selectedSiteDate;

  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    if (_isFromEdit) {
      _handleCancel();
    }
    final effectiveCrId = defaultController.effectiveCrId;
    crIdController.text = effectiveCrId;
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText: 'Cannot add entry: Only users with a branch and designation code 4 are permitted to add entries.',
      );
      return;
    }
    setState(() {
      _isEnabled = true;
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      }
      if (selectedRecDate == null) {
        selectedRecDate = DateTime.now();
        recDateController.text = DateFormat('dd-MM-yyyy').format(selectedRecDate!);
      }
      if (selectedSiteDate == null) {
        final now = DateTime.now();
        selectedSiteDate = DateTime(now.year, now.month, 1);

        siteController.text =
            DateFormat('dd-MM-yyyy').format(selectedSiteDate!);
      }
      final brokers = dropdownItemsBroker;
      if (brokers.isNotEmpty && !brokers.any((b) => b.value == _selectedTypeBroker.value)) {
        _selectedTypeBroker.value = brokers.first.value ?? '';
      }
      if (needFocus) {
        Future.delayed(const Duration(milliseconds: 60), () {
          _invNoFocus.requestFocus();
        });
      }
    });
  }

  void _openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final now = DateTime.now();
      final dateWithTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );
      setState(() {
        selectedDate = dateWithTime;
        dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        if (dueDaysController.text.isNotEmpty) {
          final days = int.tryParse(dueDaysController.text) ?? 0;
          final calcDue = dateWithTime.add(Duration(days: days));
          dueDate = formatToIsoUtc(calcDue);
          dueDateController.text = DateFormat('dd-MM-yyyy').format(calcDue);
        }
      });
      _recDateFocus.requestFocus();
    }
  }

  void _openRecDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedRecDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final now = DateTime.now();
      final dateWithTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );
      setState(() {
        selectedRecDate = dateWithTime;
        recDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
      _siteFocus.requestFocus();
    }
  }

  void _openSiteDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedSiteDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final now = DateTime.now();
      final dateWithTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );
      setState(() {
        selectedSiteDate = dateWithTime;
        siteController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
      _billTypeFocus.requestFocus();
    }
  }

  String? _formatSiteDateForApi(String text) {
    if (selectedSiteDate != null) {
      return formatToIsoUtc(selectedSiteDate);
    }
    if (text.trim().isEmpty) return null;
    return formatToIsoUtc(text.trim());
  }

  void _openDueDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final now = DateTime.now();
      final dateWithTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );
      setState(() {
        dueDate = formatToIsoUtc(dateWithTime);
        dueDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  void _addEntry() {
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText: 'Cannot add entry: CrId is required.',
      );
      return;
    }
    final double wt = double.tryParse(wtController.text.trim()) ?? 0;
    final double rateRs = double.tryParse(rateRsController.text.trim()) ?? 0;
    final double rateDollar = double.tryParse(rateDollarController.text.trim()) ?? 0;
    final bool isUsd = _selectedCurrency.value == 'USD';

    if (_selectedType.value.trim().isEmpty) {
      infoDialog(messageText: 'Please select Rough Type');
      _roughFocus.requestFocus();
      return;
    }
    if (_selectedQuality.value.trim().isEmpty) {
      infoDialog(messageText: 'Please select Quality');
      _qualityFocus.requestFocus();
      return;
    }
    if (_selectedCharni.value.trim().isEmpty) {
      infoDialog(messageText: 'Please select Charni');
      _charniFocus.requestFocus();
      return;
    }
    if (wtController.text.trim().isEmpty || wt <= 0) {
      infoDialog(messageText: 'Please enter valid weight');
      _wtFocus.requestFocus();
      return;
    }
    if (rateRs < 0 && rateDollar < 0) {
      infoDialog(messageText: 'Please enter a valid rate');
      (isUsd ? _rateDollarFocus : _rateRsFocus).requestFocus();
      return;
    }

    final amts = _itemAmounts(wt, rateRs, rateDollar);
    final double amtRs = amts[0];
    final double amtDollar = amts[1];

    final entryData = {
      if (selectedRoughId.value.isNotEmpty) 'id': selectedRoughId.value,
      'rough': _selectedType.value,
      'site': itemSiteController.text.trim(),
      'quality': _selectedQuality.value,
      'charni': _selectedCharni.value,
      'pc': pcsController.text.trim().isEmpty ? '0' : pcsController.text.trim(),
      'wt': wt.toStringAsFixed(3),
      'rateRs': rateRs.toStringAsFixed(2),
      'amtRs': amtRs.toStringAsFixed(2),
      'rateDollar': rateDollar.toStringAsFixed(2),
      'amtDollar': amtDollar.toStringAsFixed(2),
      'rate': rateRs.toStringAsFixed(2),
      'amount': amtRs.toStringAsFixed(2),
      'description': descripController.text.trim(),
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
    });

    _updateCalculations();
    _roughFocus.requestFocus();
  }

  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;
    if (crIdController.text.trim().isEmpty) {
      infoDialog(
        messageText: 'Cannot save entry: CrId is required.',
      );
      return;
    }
    if (_selectedTypeParty.value.isEmpty) {
      infoDialog(messageText: 'Please Select Party');
      _partyFocus.requestFocus();
      return;
    }
    if (entries.isEmpty) {
      infoDialog(messageText: 'Please Add Rough Data');
      _roughFocus.requestFocus();
      return;
    }
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (e['rough'] == null || e['rough'].toString().trim().isEmpty) {
        infoDialog(messageText: 'Row ${i + 1}: Please select Rough Type');
        return;
      }
      if (e['quality'] == null || e['quality'].toString().trim().isEmpty) {
        infoDialog(messageText: 'Row ${i + 1}: Please select Quality');
        return;
      }
      if (e['charni'] == null || e['charni'].toString().trim().isEmpty) {
        infoDialog(messageText: 'Row ${i + 1}: Please select Charni');
        return;
      }
      final double entryWt = double.tryParse(e['wt']?.toString() ?? '') ?? 0.0;
      if (entryWt <= 0) {
        infoDialog(messageText: 'Row ${i + 1}: Please enter valid weight');
        return;
      }
    }

    final double dollarRate = double.tryParse(dollarRateController.text) ?? 80.0;

    final bool isSuccess;
    if (_isFromEdit) {
      isSuccess = await defaultController.updatePurchaseData(
        id: selectedRoughPurMstID.value,
        partyCode: _selectedTypeParty.value,
        invoiceNo: invNoController.text.trim(),
        invoiceDate: selectedDate,
        recDate: selectedRecDate,
        brokerCode: _selectedTypeBroker.value,
        dueDays: dueDaysController.text.trim(),
        dueDate: dueDate,
        onlyDueDate: dueDateController.text.trim(),
        pSite: _formatSiteDateForApi(siteController.text),
        billType: _selectedBillType.value,
        rdType: _selectedCurrency.value,
        exchange: dollarRate,
        totalPc: totalPc,
        totalWt: totalWt,
        totalRate: totalRateRs,
        totalAmt: totalAmountRs,
        totalAmtRs: totalAmountRs,
        totalAmtDollar: totalAmountDollar,
        totalRateRs: totalRateRs,
        totalRateDollar: totalRateDollar,
        expPer: double.tryParse(expPerController.text) ?? 0.0,
        expFix: double.tryParse(expFixDollarController.text) ?? 0.0,
        expFixRs: double.tryParse(expFixRsController.text) ?? 0.0,
        linPer: double.tryParse(linPerController.text) ?? 0.0,
        linFix: double.tryParse(linFixDollarController.text) ?? 0.0,
        linFixRs: double.tryParse(linFixRsController.text) ?? 0.0,
        totExpPer: double.tryParse(totExpPerController.text) ?? 0.0,
        totExpFix: double.tryParse(totExpFixDollarController.text) ?? 0.0,
        totExpFixRs: double.tryParse(totExpFixRsController.text) ?? 0.0,
        broPer: double.tryParse(broPerController.text) ?? 0.0,
        broFix: double.tryParse(broFixDollarController.text) ?? 0.0,
        broRs: double.tryParse(broRsController.text) ?? 0.0,
        addPer: double.tryParse(addPerController.text) ?? 0.0,
        addFix: double.tryParse(addFixDollarController.text) ?? 0.0,
        addFixRs: double.tryParse(addFixRsController.text) ?? 0.0,
        lessPer: double.tryParse(lessPerController.text) ?? 0.0,
        lessFix: double.tryParse(lessFixDollarController.text) ?? 0.0,
        lessFixRs: double.tryParse(lessFixRsController.text) ?? 0.0,
        invCharge: double.tryParse(invChargeDollarController.text) ?? 0.0,
        invChargePer: double.tryParse(invChargePerController.text) ?? 0.0,
        invChargeRs: double.tryParse(invChargeRsController.text) ?? 0.0,
        comPer: double.tryParse(comPerController.text) ?? 0.0,
        comFix: double.tryParse(comDollarController.text) ?? 0.0,
        comFixRs: double.tryParse(comRsController.text) ?? 0.0,
        gstPer: double.tryParse(gstPerController.text) ?? 0.25,
        gstAmtRs: double.tryParse(gstAmtRsController.text) ?? 0.0,
        gstAmtDollar: double.tryParse(gstAmtDollarController.text) ?? 0.0,
        netAmtDollar: double.tryParse(netAmtDollarController.text) ?? 0.0,
        netAmtRs: double.tryParse(netAmtRsController.text) ?? 0.0,
        roundOfDollar: double.tryParse(roundOfDollarController.text) ?? 0.0,
        roundOfRs: double.tryParse(roundOfRsController.text) ?? 0.0,
        finalNetAmtDollar: double.tryParse(finalAmtDollarController.text) ?? 0.0,
        finalNetAmtRs: double.tryParse(finalAmtRsController.text) ?? 0.0,
        finalAmtRs: double.tryParse(finalAmtRsController.text) ?? 0.0,
        finalAmtD: double.tryParse(finalAmtDollarController.text) ?? 0.0,
        totNetAmtDollar: double.tryParse(totNetAmtDollarController.text) ?? 0.0,
        totNetAmtRs: double.tryParse(totNetAmtRsController.text) ?? 0.0,
        chkExp: _chkExp.value ? 'FIX' : 'PER',
        chkLin: _chkLin.value ? 'FIX' : 'PER',
        chkBro: _chkBro.value ? 'FIX' : 'PER',
        chkAdd: _chkAdd.value ? 'FIX' : 'PER',
        chkLess: _chkLess.value ? 'FIX' : 'PER',
        chkInv: _chkInv.value ? 'FIX' : 'PER',
        chkCom: _chkCom.value ? 'FIX' : 'PER',
        remarks: remarksController.text.trim(),
        crId: crIdController.text.trim(),
        entries: entries,
      );
    } else {
      isSuccess = await defaultController.addPurchaseData(
        partyCode: _selectedTypeParty.value,
        invoiceNo: invNoController.text.trim(),
        invoiceDate: selectedDate,
        recDate: selectedRecDate,
        brokerCode: _selectedTypeBroker.value,
        dueDays: dueDaysController.text.trim(),
        dueDate: dueDate,
        onlyDueDate: dueDateController.text.trim(),
        pSite: _formatSiteDateForApi(siteController.text),
        billType: _selectedBillType.value,
        rdType: _selectedCurrency.value,
        exchange: dollarRate,
        totalPc: totalPc,
        totalWt: totalWt,
        totalRate: totalRateRs,
        totalAmt: totalAmountRs,
        totalAmtRs: totalAmountRs,
        totalAmtDollar: totalAmountDollar,
        totalRateRs: totalRateRs,
        totalRateDollar: totalRateDollar,
        expPer: double.tryParse(expPerController.text) ?? 0.0,
        expFix: double.tryParse(expFixDollarController.text) ?? 0.0,
        expFixRs: double.tryParse(expFixRsController.text) ?? 0.0,
        linPer: double.tryParse(linPerController.text) ?? 0.0,
        linFix: double.tryParse(linFixDollarController.text) ?? 0.0,
        linFixRs: double.tryParse(linFixRsController.text) ?? 0.0,
        totExpPer: double.tryParse(totExpPerController.text) ?? 0.0,
        totExpFix: double.tryParse(totExpFixDollarController.text) ?? 0.0,
        totExpFixRs: double.tryParse(totExpFixRsController.text) ?? 0.0,
        broPer: double.tryParse(broPerController.text) ?? 0.0,
        broFix: double.tryParse(broFixDollarController.text) ?? 0.0,
        broRs: double.tryParse(broRsController.text) ?? 0.0,
        addPer: double.tryParse(addPerController.text) ?? 0.0,
        addFix: double.tryParse(addFixDollarController.text) ?? 0.0,
        addFixRs: double.tryParse(addFixRsController.text) ?? 0.0,
        lessPer: double.tryParse(lessPerController.text) ?? 0.0,
        lessFix: double.tryParse(lessFixDollarController.text) ?? 0.0,
        lessFixRs: double.tryParse(lessFixRsController.text) ?? 0.0,
        invCharge: double.tryParse(invChargeDollarController.text) ?? 0.0,
        invChargePer: double.tryParse(invChargePerController.text) ?? 0.0,
        invChargeRs: double.tryParse(invChargeRsController.text) ?? 0.0,
        comPer: double.tryParse(comPerController.text) ?? 0.0,
        comFix: double.tryParse(comDollarController.text) ?? 0.0,
        comFixRs: double.tryParse(comRsController.text) ?? 0.0,
        gstPer: double.tryParse(gstPerController.text) ?? 0.25,
        gstAmtRs: double.tryParse(gstAmtRsController.text) ?? 0.0,
        gstAmtDollar: double.tryParse(gstAmtDollarController.text) ?? 0.0,
        netAmtDollar: double.tryParse(netAmtDollarController.text) ?? 0.0,
        netAmtRs: double.tryParse(netAmtRsController.text) ?? 0.0,
        roundOfDollar: double.tryParse(roundOfDollarController.text) ?? 0.0,
        roundOfRs: double.tryParse(roundOfRsController.text) ?? 0.0,
        finalNetAmtDollar: double.tryParse(finalAmtDollarController.text) ?? 0.0,
        finalNetAmtRs: double.tryParse(finalAmtRsController.text) ?? 0.0,
        finalAmtRs: double.tryParse(finalAmtRsController.text) ?? 0.0,
        finalAmtD: double.tryParse(finalAmtDollarController.text) ?? 0.0,
        totNetAmtDollar: double.tryParse(totNetAmtDollarController.text) ?? 0.0,
        totNetAmtRs: double.tryParse(totNetAmtRsController.text) ?? 0.0,
        chkExp: _chkExp.value ? 'FIX' : 'PER',
        chkLin: _chkLin.value ? 'FIX' : 'PER',
        chkBro: _chkBro.value ? 'FIX' : 'PER',
        chkAdd: _chkAdd.value ? 'FIX' : 'PER',
        chkLess: _chkLess.value ? 'FIX' : 'PER',
        chkInv: _chkInv.value ? 'FIX' : 'PER',
        chkCom: _chkCom.value ? 'FIX' : 'PER',
        remarks: remarksController.text.trim(),
        crId: crIdController.text.trim(),
        entries: entries,
      );
    }

    if (isSuccess) {
      if (_isFiltered.value) {
        _applyDateFilter();
      } else {
        purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(defaultController.purchaseDataList);
      }
      _handleCancel();
    }
  }

  void _handleCancel() {
    if (_editingEntryIndex != null) {
      setState(() {
        _clearEntryInputs();
      });
      _roughFocus.requestFocus();
      return;
    }
    setState(() {
      entries.clear();
      _editingEntryIndex = null;
      _isEnabled = false;
      _isFromEdit = false;
      _selectedTypeParty.value = '';
      _selectedType.value = '';
      _selectedQuality.value = '';
      _selectedCharni.value = '';
      _selectedTypeBroker.value = '';
      _selectedBillType.value = 'BILL';
      _selectedCurrency.value = 'RS';
      selectedRoughPurMstID.value = 0;
      selectedRoughId.value = '';
      selectedDate = null;
      selectedRecDate = null;
      selectedSiteDate = null;
      dueDate = null;
    });

    idController.clear();
    crIdController.text = defaultController.effectiveCrId;
    invNoController.clear();
    dateController.clear();
    recDateController.clear();
    siteController.clear();
    dueDaysController.text = '0';
    dueDateController.clear();
    dollarRateController.text = '71.000';

    itemSiteController.clear();
    pcsController.clear();
    wtController.clear();
    rateRsController.clear();
    amountRsController.clear();
    rateDollarController.clear();
    amountDollarController.clear();
    descripController.clear();

    _chkExp.value = false;
    expPerController.text = '0.0000';
    expFixDollarController.clear();
    expFixRsController.text = '0.000';

    _chkLin.value = false;
    linPerController.clear();
    linFixDollarController.text = '0.000';
    linFixRsController.text = '0.000';

    totExpPerController.text = '0.0000';
    totExpFixDollarController.text = '0.000';
    totExpFixRsController.text = '0.000';

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

    _chkInv.value = false;
    invChargePerController.clear();
    invChargeDollarController.text = '0.000';
    invChargeRsController.text = '0.000';

    _chkCom.value = false;
    comPerController.clear();
    comDollarController.text = '0.000';
    comRsController.text = '0.000';

    totAmtDollarController.text = '0.000';
    totAmtRsController.text = '0.000';
    gstPerController.text = '0.25';
    gstAmtDollarController.text = '0.000';
    gstAmtRsController.text = '0.000';
    netAmtDollarController.text = '0.000';
    netAmtRsController.text = '0.000';
    roundOfDollarController.text = '0.000';
    roundOfRsController.text = '0.000';
    finalAmtDollarController.text = '0.000';
    finalAmtRsController.text = '0.000';
    expBrNetDollarController.text = '0.000';
    expBrNetRsController.text = '0.000';
    totNetAmtDollarController.text = '0.000';
    totNetAmtRsController.text = '0.000';
    _clearGridSelection();
  }

  void _clearGridSelection() {
    try {
      _dataGridController.selectedRow = null;
      _dataGridController.selectedRows = [];
      _dataGridController.selectedIndex = -1;
    } catch (_) {}
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit) return;
    final bool isSuccess = await defaultController.deletePurchaseData(
      id: selectedRoughPurMstID.value,
      entries: entries,
    );
    if (isSuccess) {
      if (_isFiltered.value) {
        _applyDateFilter();
      } else {
        purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(defaultController.purchaseDataList);
      }
      _handleCancel();
    }
  }

  Future<void> _handlePrint() async {
    if (!_isFromEdit || selectedDate == null) return;
    final invoiceGenerator = PurchaseInvoiceGenerator();
    final pdfData = await invoiceGenerator.generateInvoice(
      id: defaultController.purchaseDataList.length + 1,
      invoiceDate: selectedDate!,
      invoiceNo: invNoController.text,
      partyCode: _selectedTypeParty.value,
      brokerCode: _selectedTypeBroker.value,
      dueDate: dueDateController.text,
      dueDays: dueDaysController.text,
      entries: entries,
      totalWt: totalWt,
      totalAmt: totalAmountRs,
      totalRate: totalRateRs,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  void _applyDateFilter() {
    if (fromDate != null && toDate != null) {
      _isFiltered.value = true;
      filteredDataGridSource.value = defaultController.purchaseDataList.where((purchase) {
        if (purchase.invoiceDate == null || purchase.invoiceDate!.isEmpty) return false;
        final invoiceDate = DateTime.tryParse(purchase.invoiceDate!);
        if (invoiceDate == null) return false;
        return invoiceDate.isAfter(fromDate!.subtract(const Duration(seconds: 1))) &&
            invoiceDate.isBefore(toDate!.add(const Duration(days: 1)));
      }).toList();
      purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(filteredDataGridSource);
    } else {
      infoDialog(messageText: 'Please select both From Date and To Date');
    }
  }

  void _removeDateFilter() {
    purchaseDataGridSource.value = List<PurchaseDetailsModel>.from(defaultController.purchaseDataList);
    toDateController.clear();
    fromDateController.clear();
    fromDate = null;
    toDate = null;
    _isFiltered.value = false;
  }

  List<DropdownMenuItem<String>> get dropdownItemsRough {
    return defaultController.roughModel.map((item) {
      return DropdownMenuItem<String>(
        value: item.roughTypeCode.toString(),
        child: Text(item.roughTypeName ?? '', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsQuality {
    return defaultController.qualityModelList.map((item) {
      final code = (item.qualityCode ?? item.qualityMstID).toString();
      return DropdownMenuItem<String>(
        value: code,
        child: Text(item.qualityName ?? code, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsCharni {
    return defaultController.charniModelList.map((item) {
      final code = (item.charniCode ?? item.charniMstID).toString();
      return DropdownMenuItem<String>(
        value: code,
        child: Text(item.charniName ?? code, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsParty {
    return defaultController.partyMstList
        .where((p) => p.typeCode == 1 && p.companyCode == defaultController.companyCode.value)
        .map((p) {
          return DropdownMenuItem<String>(
            value: p.partyCode.toString(),
            child: Text(p.partyName ?? '', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          );
        })
        .toSet()
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsBroker {
    return defaultController.partyMstList
        .where((p) {
          final isBroker = (p.partyType != null && p.partyType!.trim().toUpperCase() == 'BROKER') ||
              p.typeCode == 5;
          return isBroker && p.companyCode == defaultController.companyCode.value;
        })
        .map((p) {
          return DropdownMenuItem<String>(
            value: p.partyCode.toString(),
            child: Text(p.partyName ?? '', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          );
        })
        .toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsBillType {
    return const [
      DropdownMenuItem(value: 'BILL', child: Text('Bill', style: TextStyle(fontSize: 13))),
      DropdownMenuItem(value: 'WITHOUT', child: Text('Without Bill', style: TextStyle(fontSize: 13))),
    ];
  }

  List<DropdownMenuItem<String>> get dropdownItemsCurrency {
    return const [
      DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontSize: 13))),
      DropdownMenuItem(value: 'RS', child: Text('RS (₹)', style: TextStyle(fontSize: 13))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: _isEnabled ? _handleCancel : null,
        onExit: () => tabController.closeCurrentTab(),
        onSearch: () {
          setState(() {
            _isSearch = !_isSearch;
          });
          if (_isSearch) {
            _clearGridSelection();
          }
        },
        onPrint: _isFromEdit ? _handlePrint : null,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) Header(title: _isSearch ? 'Purchase Search' : 'Purchase Entry'),
              Expanded(
                child: _isSearch ? _buildSearchView() : _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== SEARCH / DATAGRID VIEW ====================
  Widget _buildSearchView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;
              final dateFields = [
                AppTextField(
                  label: 'From Date',
                  controller: fromDateController,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        fromDate = picked;
                        fromDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                        if (toDateController.text.isNotEmpty) _applyDateFilter();
                      });
                    }
                  },
                ),
                AppTextField(
                  label: 'To Date',
                  controller: toDateController,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        toDate = picked;
                        toDateController.text = DateFormat('dd-MM-yyyy').format(picked);
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
                    icon: Icons.filter_alt_rounded,
                    onPressed: _applyDateFilter,
                  ),
                  Obx(() => _isFiltered.value
                      ? AppButton(
                          text: 'Reset',
                          variant: AppButtonVariant.outline,
                          onPressed: _removeDateFilter,
                        )
                      : const SizedBox.shrink()),
                  AppButton(
                    text: 'Close Search',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.close_rounded,
                    onPressed: () {
                      setState(() {
                        _isSearch = false;
                      });
                      _clearGridSelection();
                    },
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
                  const SizedBox(width: 16),
                  actionButtons,
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Obx(() {
            final purchaseSource = PurchaseDataGridSource(purchaseDataGridSource);
            return AppDataGrid(
              controller: _dataGridController,
              source: purchaseSource,
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
                  width: 60,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'CrId',
                  width: 65,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('CrId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Invoice No',
                  width: 90,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerLeft,
                    child: const Text('Invoice No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Inv. Date',
                  width: 95,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('Inv. Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Rec Date',
                  width: 95,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('Rec Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Party',
                  width: 160,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerLeft,
                    child: const Text('Party', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Broker',
                  width: 140,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerLeft,
                    child: const Text('Broker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Rs / \$',
                  width: 65,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('Rs / \$', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Exchange',
                  width: 80,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Exchange', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Tot Wt',
                  width: 100,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Tot Wt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Tot Amt Rs',
                  width: 110,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Tot Amt Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Tot Amt (\$)',
                  width: 110,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Tot Amt (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'BillType',
                  width: 75,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.center,
                    child: const Text('BillType', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Amt Rs 1',
                  width: 100,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Amt Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Amt \$ 1',
                  width: 100,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Amt \$', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Round Of Rs 1',
                  width: 90,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Round Of Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Round Of \$ 1',
                  width: 90,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Round Of \$', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Net Amt Dollar',
                  width: 130,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Net Amt Dollar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Net Amt Rs',
                  width: 120,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Net Amt Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Amt Rs 2',
                  width: 105,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Amt Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Final Amt D',
                  width: 105,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Final Amt D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Round Of Rs 2',
                  width: 90,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Round Of Rs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                GridColumn(
                  columnName: 'Round Of D',
                  width: 90,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    alignment: Alignment.centerRight,
                    child: const Text('Round Of D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      name: 'Final Amt Rs 1',
                      columnName: 'Final Amt Rs 1',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Final Amt \$ 1',
                      columnName: 'Final Amt \$ 1',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Round Of Rs 1',
                      columnName: 'Round Of Rs 1',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Round Of \$ 1',
                      columnName: 'Round Of \$ 1',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Final Net Amt Dollar',
                      columnName: 'Final Net Amt Dollar',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Final Net Amt Rs',
                      columnName: 'Final Net Amt Rs',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Final Amt Rs 2',
                      columnName: 'Final Amt Rs 2',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Final Amt D',
                      columnName: 'Final Amt D',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Round Of Rs 2',
                      columnName: 'Round Of Rs 2',
                      summaryType: GridSummaryType.sum,
                    ),
                    GridSummaryColumn(
                      name: 'Round Of D',
                      columnName: 'Round Of D',
                      summaryType: GridSummaryType.sum,
                    ),
                  ],
                  position: GridTableSummaryRowPosition.bottom,
                ),
              ],
              onCellTap: (details) {
                if (details.rowColumnIndex.rowIndex <= 0) return;
                final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                final rows = purchaseSource.effectiveRows;
                if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                  _loadSelectedRowForEdit(rows[dataRowIndex]);
                }
              },
              onCellDoubleTap: (details) {
                if (details.rowColumnIndex.rowIndex <= 0) return;
                final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                final rows = purchaseSource.effectiveRows;
                if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                  _loadSelectedRowForEdit(rows[dataRowIndex]);
                }
              },
              onSelectionChanged: (addedRows, _) {
                if (addedRows.isNotEmpty) {
                  _loadSelectedRowForEdit(addedRows.first);
                }
              },
            );
          }),
        ),
      ],
    );
  }

  bool _isLoadingRow = false;
  void _loadSelectedRowForEdit(DataGridRow row) {
    if (_isLoadingRow) return;
    _isLoadingRow = true;
    try {
      setState(() {
        entries.clear();
        _isFromEdit = true;
        _isEnabled = false;
      });

    final id = row.getCells()[0].value;
    selectedRoughPurMstID.value = id;

    final partyEntry = defaultController.purchaseDataList.firstWhereOrNull(
      (entry) => entry.roughPurMstID == id,
    );
    if (partyEntry == null) return;
    final roughEntries = defaultController.roughDetailsModel.where(
      (entry) => entry.roughPurMstID == id,
    ).toList();

    idController.text = id.toString();
    crIdController.text = partyEntry.crId != null && partyEntry.crId != 0
        ? partyEntry.crId.toString()
        : defaultController.effectiveCrId;
    invNoController.text = partyEntry.invoiceNo ?? '';
    if (partyEntry.invoiceDate != null && partyEntry.invoiceDate!.isNotEmpty) {
      try {
        selectedDate = dateFormat(partyEntry.invoiceDate!);
        dateController.text = formatDate(partyEntry.invoiceDate!);
      } catch (_) {}
    }
    if (partyEntry.recdate != null && partyEntry.recdate!.isNotEmpty) {
      try {
        selectedRecDate = DateTime.tryParse(partyEntry.recdate!);
        recDateController.text = formatDate(partyEntry.recdate!);
      } catch (_) {}
    }
    if (partyEntry.dueDate != null && partyEntry.dueDate!.isNotEmpty) {
      try {
        dueDate = formatToIsoUtc(partyEntry.dueDate!);
        dueDateController.text = formatDate(partyEntry.dueDate!);
      } catch (_) {}
    }
    dueDaysController.text = partyEntry.dueDay?.toString() ?? '';
    if (partyEntry.pSite != null && partyEntry.pSite!.isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(partyEntry.pSite!);
        if (parsed != null) {
          selectedSiteDate = parsed;
          siteController.text = DateFormat('dd-MM-yyyy').format(parsed);
        } else {
          siteController.text = formatDate(partyEntry.pSite!);
        }
      } catch (_) {
        siteController.text = partyEntry.pSite ?? '';
      }
    } else {
      selectedSiteDate = null;
      siteController.text = '';
    }
    _selectedBillType.value = partyEntry.bIllType ?? 'BILL';
    _selectedTypeParty.value = partyEntry.partyCode?.toString() ?? '';
    _selectedTypeBroker.value = partyEntry.brokerCode?.toString() ?? '22';
    _selectedCurrency.value = partyEntry.rDType ?? 'RS';
    dollarRateController.text = partyEntry.exchange?.toString() ?? '71.000';
    _clearEntryInputs();

    setState(() {
      final double exRate = double.tryParse(dollarRateController.text) ?? 1.0;
      for (var r in roughEntries) {
        final double wtVal = (r.wt is num) ? (r.wt as num).toDouble() : (double.tryParse(r.wt?.toString() ?? '0') ?? 0);
        double rateR = (r.rateRs is num) ? (r.rateRs as num).toDouble() : (double.tryParse(r.rateRs?.toString() ?? '0') ?? 0);
        double rateD = (r.rateDollar is num) ? (r.rateDollar as num).toDouble() : (double.tryParse(r.rateDollar?.toString() ?? '0') ?? 0);
        if (rateD == 0 && rateR > 0 && exRate > 0) {
          rateD = rateR / exRate;
        } else if (rateR == 0 && rateD > 0 && exRate > 0) {
          rateR = rateD * exRate;
        }
        final double amtR = (r.amtRs is num) ? (r.amtRs as num).toDouble() : (wtVal * rateR);
        final double amtD = (r.amtDollar is num) ? (r.amtDollar as num).toDouble() : (wtVal * rateD);

        entries.add({
          'id': r.roughPurDetID.toString(),
          'rough': r.roughTypeCode?.toString() ?? '',
          'site': r.site ?? '',
          'quality': r.roughQualityCode?.toString() ?? '',
          'charni': r.roughCharniCode?.toString() ?? '',
          'pc': r.pc?.toString() ?? '0',
          'wt': wtVal.toStringAsFixed(3),
          'rateRs': rateR.toStringAsFixed(2),
          'amtRs': amtR.toStringAsFixed(2),
          'rateDollar': rateD.toStringAsFixed(2),
          'amtDollar': amtD.toStringAsFixed(2),
          'rate': rateR.toStringAsFixed(2),
          'amount': amtR.toStringAsFixed(2),
          'description': r.description ?? '',
        });
      }
    });

    _chkExp.value = partyEntry.chkExp == 'FIX' || partyEntry.chkExp == '1';
    expPerController.text = partyEntry.expPer?.toString() ?? '0.0000';
    expFixDollarController.text = partyEntry.expFix?.toString() ?? '0.000';
    expFixRsController.text = partyEntry.expFixRs?.toString() ?? '0.000';

    _chkLin.value = partyEntry.chkLin == 'FIX' || partyEntry.chkLin == '1';
    linPerController.text = partyEntry.linPer?.toString() ?? '';
    linFixDollarController.text = partyEntry.linFix?.toString() ?? '0.000';
    linFixRsController.text = partyEntry.linFixRs?.toString() ?? '0.000';

    _chkBro.value = partyEntry.chkBro == 'FIX' || partyEntry.chkBro == '1';
    broPerController.text = partyEntry.broPer?.toString() ?? '';
    broFixDollarController.text = partyEntry.broFix?.toString() ?? '0.000';
    broRsController.text = partyEntry.broRs?.toString() ?? '0.000';

    _chkAdd.value = partyEntry.chkAdd == 'FIX' || partyEntry.chkAdd == '1';
    addPerController.text = partyEntry.addPer?.toString() ?? '';
    addFixDollarController.text = partyEntry.addFix?.toString() ?? '0.000';
    addFixRsController.text = partyEntry.addFixRs?.toString() ?? '0.000';

    _chkLess.value = partyEntry.chkLess == 'FIX' || partyEntry.chkLess == '1';
    lessPerController.text = partyEntry.lessPer?.toString() ?? '';
    lessFixDollarController.text = partyEntry.lessFix?.toString() ?? '0.000';
    lessFixRsController.text = partyEntry.lessFixRs?.toString() ?? '0.000';

    remarksController.text = partyEntry.remarks ?? '';

    _chkInv.value = partyEntry.chkInv == 'FIX' || partyEntry.chkInv == '1';
    invChargePerController.text = partyEntry.invChargePer?.toString() ?? '';
    invChargeDollarController.text = partyEntry.invCharge?.toString() ?? '0.000';
    invChargeRsController.text = partyEntry.invChargeRs?.toString() ?? '0.000';

    _chkCom.value = partyEntry.chkCom == 'FIX' || partyEntry.chkCom == '1';
    comPerController.text = partyEntry.comPer?.toString() ?? '';
    comDollarController.text = partyEntry.comFix?.toString() ?? '0.000';
    comRsController.text = partyEntry.comFixRs?.toString() ?? '0.000';

    roundOfDollarController.text = partyEntry.roundOfD?.toString() ?? '0.000';
    roundOfRsController.text = partyEntry.roundOfRs?.toString() ?? '0.000';

    gstPerController.text = partyEntry.gstPer?.toString() ?? '0.25';

    _updateCalculations();

    setState(() {
      _isSearch = false;
      _isFromEdit = true;
      _isEnabled = false;
    });
    _clearGridSelection();
    } finally {
      _isLoadingRow = false;
    }
  }

  // ==================== MAIN DATA ENTRY FORM ====================
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP MASTER HEADER CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'MainDetails',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final idField = AppTextField(
                          label: 'ID',
                          controller: idController,
                          enabled: false,
                          readOnly: true,
                          hintText: 'Auto',
                        );

                        final crIdField = AppTextField(
                          label: 'CrId',
                          controller: crIdController,
                          enabled: false,
                          readOnly: true,
                          hintText: '',
                        );

                        final invoiceNoField = AppTextField(
                          label: 'Inv No',
                          controller: invNoController,
                          focusNode: _invNoFocus,
                          nextFocusNode: _dateFocus,
                          enabled: _isEnabled,
                          hintText: 'e.g. K44',
                        );

                        final dateField = AppTextField(
                          label: 'Inv Date',
                          controller: dateController,
                          focusNode: _dateFocus,
                          nextFocusNode: _recDateFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                          onTap: _isEnabled ? _openDatePicker : null,
                        );

                        final recDateField = AppTextField(
                          label: 'Rec Date',
                          controller: recDateController,
                          focusNode: _recDateFocus,
                          nextFocusNode: _siteFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                          onTap: _isEnabled ? _openRecDatePicker : null,
                        );

                        final siteField = AppTextField(
                          label: 'Site',
                          controller: siteController,
                          focusNode: _siteFocus,
                          nextFocusNode: _billTypeFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                          hintText: 'dd-MM-yyyy',
                          onTap: _isEnabled ? _openSiteDatePicker : null,
                        );

                        final billTypeField = Obx(
                          () => AppDropdown<String>(
                            label: 'Bill Type',
                            focusNode: _billTypeFocus,
                            nextFocusNode: _partyFocus,
                            isEnabled: _isEnabled,
                            value: _selectedBillType.value,
                            items: dropdownItemsBillType,
                            onChanged: (val) {
                              _selectedBillType.value = val ?? 'BILL';
                            },
                          ),
                        );

                        final partyField = Obx(
                          () => AppDropdown<String>(
                            label: 'Party *',
                            focusNode: _partyFocus,
                            nextFocusNode: _brokerFocus,
                            isEnabled: _isEnabled,
                            value: _selectedTypeParty.value.isEmpty ? null : _selectedTypeParty.value,
                            items: dropdownItemsParty,
                            hintText: 'Select Party',
                            onChanged: (val) {
                              _selectedTypeParty.value = val ?? '';
                            },
                          ),
                        );

                        final brokerField = Obx(() {
                          final items = dropdownItemsBroker;
                          final String? currentValue = items.any((b) => b.value == _selectedTypeBroker.value)
                              ? _selectedTypeBroker.value
                              : (items.isNotEmpty ? items.first.value : null);

                          return AppDropdown<String>(
                            label: 'Broker',
                            focusNode: _brokerFocus,
                            nextFocusNode: _dueDaysFocus,
                            isEnabled: _isEnabled,
                            value: currentValue,
                            items: items,
                            hintText: 'Select Broker',
                            onChanged: (val) {
                              _selectedTypeBroker.value = val ?? '';
                            },
                          );
                        });

                        final dueDaysField = AppTextField(
                          label: 'Due Day',
                          controller: dueDaysController,
                          focusNode: _dueDaysFocus,
                          nextFocusNode: _currencyFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (val) {
                            if (selectedDate != null && val.isNotEmpty) {
                              final days = int.tryParse(val) ?? 0;
                              final calcDue = selectedDate!.add(Duration(days: days));
                              dueDate = formatToIsoUtc(calcDue);
                              dueDateController.text = DateFormat('dd-MM-yyyy').format(calcDue);
                            }
                          },
                        );

                        final dueDateField = AppTextField(
                          label: 'Due Date',
                          controller: dueDateController,
                          focusNode: _dueDateFocus,
                          enabled: _isEnabled,
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                          hintText: 'Auto Calculated',
                          onTap: _isEnabled ? _openDueDatePicker : null,
                        );

                        final currencyField = Obx(
                          () => AppDropdown<String>(
                            label: 'Rs / \$',
                            focusNode: _currencyFocus,
                            nextFocusNode: _dollarRateFocus,
                            isEnabled: _isEnabled,
                            value: _selectedCurrency.value,
                            items: dropdownItemsCurrency,
                            onChanged: (val) {
                              _selectedCurrency.value = val ?? 'RS';
                              _recalculateEntriesForExchangeRate();
                            },
                          ),
                        );

                        final dollarRateField = AppTextField(
                          label: '\$ Rate',
                          controller: dollarRateController,
                          focusNode: _dollarRateFocus,
                          nextFocusNode: _roughFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          hintText: '71.000',
                          onChanged: (_) {
                            _recalculateEntriesForExchangeRate();
                          },
                        );

                        if (constraints.maxWidth >= 1000) {
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: idField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 1, child: crIdField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: invoiceNoField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: dateField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: recDateField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: siteField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: billTypeField),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 4, child: partyField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 3, child: brokerField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 1, child: dueDaysField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: dueDateField),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 1, child: currencyField),
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
                                  Expanded(flex: 1, child: idField),
                                  const SizedBox(width: 10),
                                  Expanded(flex: 1, child: crIdField),
                                  const SizedBox(width: 10),
                                  Expanded(flex: 2, child: invoiceNoField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: dateField),
                                  const SizedBox(width: 10),
                                  Expanded(child: recDateField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: siteField),
                                  const SizedBox(width: 10),
                                  Expanded(child: billTypeField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              partyField,
                              const SizedBox(height: 10),
                              brokerField,
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: dueDaysField),
                                  const SizedBox(width: 10),
                                  Expanded(child: dueDateField),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: currencyField),
                                  const SizedBox(width: 10),
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

            // 2. SUB-DETAILS (ROUGH ITEM INPUT) CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 600;
                        return Row(
                          children: [
                            Icon(Icons.diamond_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'SubDetails',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            if (!isCompact) ...[
                              const Spacer(),
                              Text(
                                'Enter on Rate adds item to table automatically',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const Divider(height: 20),
                    Obx(() {
                      final bool isUsd = _selectedCurrency.value == 'USD';
                      final bool isRateRsEnabled = _isEnabled && !isUsd;
                      final bool isRateDollarEnabled = _isEnabled && isUsd;

                      final roughTypeField = AppDropdown<String>(
                        label: 'Rough Type *',
                        focusNode: _roughFocus,
                        nextFocusNode: _itemSiteFocus,
                        isEnabled: _isEnabled,
                        value: _selectedType.value.isEmpty ? null : _selectedType.value,
                        items: dropdownItemsRough,
                        hintText: 'Select Rough',
                        onChanged: (val) {
                          _selectedType.value = val ?? '';
                        },
                      );

                      final itemSiteField = AppTextField(
                        label: 'Site',
                        controller: itemSiteController,
                        focusNode: _itemSiteFocus,
                        nextFocusNode: _qualityFocus,
                        enabled: _isEnabled,
                        hintText: 'Site',
                      );

                      final qualityField = AppDropdown<String>(
                        label: 'Quality *',
                        focusNode: _qualityFocus,
                        nextFocusNode: _charniFocus,
                        isEnabled: _isEnabled,
                        value: _selectedQuality.value.isEmpty ? null : _selectedQuality.value,
                        items: dropdownItemsQuality,
                        hintText: 'Quality',
                        onChanged: (val) {
                          _selectedQuality.value = val ?? '';
                        },
                      );

                      final charniField = AppDropdown<String>(
                        label: 'Charni (+/-) *',
                        focusNode: _charniFocus,
                        nextFocusNode: _pcsFocus,
                        isEnabled: _isEnabled,
                        value: _selectedCharni.value.isEmpty ? null : _selectedCharni.value,
                        items: dropdownItemsCharni,
                        hintText: 'Charni',
                        onChanged: (val) {
                          _selectedCharni.value = val ?? '';
                        },
                      );

                      final pcsField = AppTextField(
                        label: 'Pcs',
                        controller: pcsController,
                        focusNode: _pcsFocus,
                        nextFocusNode: _wtFocus,
                        enabled: _isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        hintText: '0',
                      );

                      final wtField = AppTextField(
                        label: 'Wt (Cts) *',
                        controller: wtController,
                        focusNode: _wtFocus,
                        nextFocusNode: isUsd ? _rateDollarFocus : _rateRsFocus,
                        enabled: _isEnabled,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        hintText: '0.000',
                        onChanged: (_) => _updateItemAmount(),
                        onFieldSubmitted: (_) => (isUsd ? _rateDollarFocus : _rateRsFocus).requestFocus(),
                      );

                      final rateRsField = AppTextField(
                        label: 'Rate (₹)',
                        controller: rateRsController,
                        focusNode: _rateRsFocus,
                        nextFocusNode: isUsd ? _rateDollarFocus : null,
                        enabled: isRateRsEnabled,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        hintText: '0.00',
                        onChanged: _onRateRsChanged,
                        onFieldSubmitted: !isUsd ? (_) => _addEntry() : null,
                      );

                      final amountRsField = AppTextField(
                        label: 'Amount (₹)',
                        controller: amountRsController,
                        enabled: false,
                        hintText: '0.00',
                      );

                      final rateDollarField = AppTextField(
                        label: 'Rate (\$)',
                        controller: rateDollarController,
                        focusNode: _rateDollarFocus,
                        enabled: isRateDollarEnabled,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        hintText: '0.00',
                        onChanged: _onRateDollarChanged,
                        onFieldSubmitted: isUsd ? (_) => _addEntry() : null,
                      );

                      final amountDollarField = AppTextField(
                        label: 'Amount (\$)',
                        controller: amountDollarController,
                        enabled: false,
                        hintText: '0.00',
                      );

                      final isEditingItem = _editingEntryIndex != null;
                      final addButton = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            text: isEditingItem ? 'Update' : '',
                            icon: isEditingItem ? Icons.check_rounded : Icons.add_rounded,
                            shortcutLabel: 'Enter',
                            onPressed: _isEnabled ? _addEntry : null,
                          ),
                          if (isEditingItem) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              tooltip: 'Cancel Edit',
                              onPressed: () {
                                setState(() {
                                  _clearEntryInputs();
                                });
                              },
                            ),
                          ],
                        ],
                      );

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final double availWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 1215.0;
                          final double totalWidth = availWidth > 1215.0 ? availWidth : 1215.0;
                          final double extra = totalWidth - 1215.0;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(width: 140 + (extra * 0.14), child: roughTypeField),
                                const SizedBox(width: 8),
                                SizedBox(width: 80 + (extra * 0.06), child: itemSiteField),
                                const SizedBox(width: 8),
                                SizedBox(width: 110 + (extra * 0.10), child: qualityField),
                                const SizedBox(width: 8),
                                SizedBox(width: 115 + (extra * 0.10), child: charniField),
                                const SizedBox(width: 8),
                                SizedBox(width: 75 + (extra * 0.05), child: pcsField),
                                const SizedBox(width: 8),
                                SizedBox(width: 90 + (extra * 0.08), child: wtField),
                                const SizedBox(width: 8),
                                SizedBox(width: 100 + (extra * 0.10), child: rateRsField),
                                const SizedBox(width: 8),
                                SizedBox(width: 115 + (extra * 0.12), child: amountRsField),
                                const SizedBox(width: 8),
                                SizedBox(width: 100 + (extra * 0.10), child: rateDollarField),
                                const SizedBox(width: 8),
                                SizedBox(width: 115 + (extra * 0.15), child: amountDollarField),
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

            // 3. ROUGH ITEMS TABLE CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEntriesTable(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. BOTTOM SECTION: EXPENSES & CALCULATIONS
            _buildCalculationsSection(),
            const SizedBox(height: 20),

            // 5. ACTION TOOLBAR BAR
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    if (_isFromEdit) ...[
                      AppButton(
                        text: 'Delete',
                        variant: AppButtonVariant.danger,
                        icon: Icons.delete_outline_rounded,
                        isLoading: defaultController.isDeleteLoading.value,
                        onPressed: _handleDelete,
                      ),
                      AppButton(
                        text: 'Print',
                        variant: AppButtonVariant.outline,
                        icon: Icons.print_rounded,
                        onPressed: _handlePrint,
                      ),
                    ],
                    if (_isEnabled)
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
                        _clearGridSelection();
                      },
                    ),
                    AppButton(
                      text: 'Exit',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.exit_to_app_rounded,
                      onPressed: () => tabController.closeCurrentTab(),
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

  // ==================== ENTRIES TABLE WIDGET ====================
  Widget _buildEntriesTable() {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              'No rough items added yet.',
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
            final double availWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 980.0;
            final double tableWidth = availWidth > 980.0 ? availWidth : 980.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: AppColors.borderLight, width: 1),
              ),
              columnWidths: const {
                0: FixedColumnWidth(48),  // SR
                1: FlexColumnWidth(2.5),  // Rough
                2: FixedColumnWidth(75),  // Site
                3: FlexColumnWidth(2.0),  // Quality
                4: FlexColumnWidth(2.0),  // Charni
                5: FixedColumnWidth(60),  // Pc
                6: FixedColumnWidth(85),  // Wt
                7: FixedColumnWidth(90),  // Rate Rs
                8: FixedColumnWidth(105), // Amt Rs
                9: FixedColumnWidth(85),  // Rate Dollar
                10: FixedColumnWidth(100), // Amt Dollar
                11: FixedColumnWidth(85),  // Actions
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                  children: [
                    _buildTableCell('SR.', isHeader: true, align: TextAlign.center),
                    _buildTableCell('ROUGH TYPE', isHeader: true),
                    _buildTableCell('SITE', isHeader: true),
                    _buildTableCell('QUALITY', isHeader: true),
                    _buildTableCell('CHARNI', isHeader: true),
                    _buildTableCell('PC', isHeader: true, align: TextAlign.right),
                    _buildTableCell('WT (CTS)', isHeader: true, align: TextAlign.right),
                    _buildTableCell('RATE (₹)', isHeader: true, align: TextAlign.right),
                    _buildTableCell('AMOUNT (₹)', isHeader: true, align: TextAlign.right),
                    _buildTableCell('RATE (\$)', isHeader: true, align: TextAlign.right),
                    _buildTableCell('AMOUNT (\$)', isHeader: true, align: TextAlign.right),
                    _buildTableCell('ACTIONS', isHeader: true, align: TextAlign.center),
                  ],
                ),

                // Rows
                for (int i = 0; i < entries.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: _editingEntryIndex == i
                          ? AppColors.primary.withOpacity(0.12)
                          : (i.isEven ? AppColors.surface : AppColors.tableRowAlt),
                    ),
                    children: [
                      _buildTableCell('${i + 1}', align: TextAlign.center),
                      _buildTableCell(getRoughName(entries[i]['rough']?.toString())),
                      _buildTableCell(entries[i]['site']?.toString() ?? '-'),
                      _buildTableCell(getQualityName(entries[i]['quality'])),
                      _buildTableCell(getCharniName(entries[i]['charni'])),
                      _buildTableCell(entries[i]['pc']?.toString() ?? '0', align: TextAlign.right),
                      _buildTableCell(entries[i]['wt']?.toString() ?? '0.000', align: TextAlign.right),
                      _buildTableCell(entries[i]['rateRs']?.toString() ?? '0.00', align: TextAlign.right),
                      _buildTableCell(entries[i]['amtRs']?.toString() ?? '0.00', align: TextAlign.right),
                      _buildTableCell(entries[i]['rateDollar']?.toString() ?? '0.00', align: TextAlign.right),
                      _buildTableCell(entries[i]['amtDollar']?.toString() ?? '0.00', align: TextAlign.right),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _editingEntryIndex == i ? Icons.edit : Icons.edit_outlined,
                                size: 16,
                                color: _isEnabled
                                    ? (_editingEntryIndex == i ? AppColors.warning : AppColors.primary)
                                    : AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              splashRadius: 14,
                              tooltip: 'Edit Item',
                              onPressed: _isEnabled ? () {
                                selectedRoughId.value = entries[i]['id']?.toString() ?? '';
                                _selectedType.value = entries[i]['rough']?.toString() ?? '';
                                itemSiteController.text = entries[i]['site']?.toString() ?? '';
                                _selectedQuality.value = entries[i]['quality']?.toString() ?? '';
                                _selectedCharni.value = entries[i]['charni']?.toString() ?? '';
                                pcsController.text = entries[i]['pc']?.toString() ?? '0';
                                wtController.text = entries[i]['wt']?.toString() ?? '';
                                rateRsController.text = entries[i]['rateRs']?.toString() ?? '';
                                amountRsController.text = entries[i]['amtRs']?.toString() ?? '';
                                rateDollarController.text = entries[i]['rateDollar']?.toString() ?? '';
                                amountDollarController.text = entries[i]['amtDollar']?.toString() ?? '';
                                descripController.text = entries[i]['description']?.toString() ?? '';
                                setState(() {
                                  _editingEntryIndex = i;
                                });
                                _roughFocus.requestFocus();
                              } : null,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 16,
                                  color: _isEnabled
                                      ? AppColors.danger
                                      : AppColors.textSecondary.withValues(alpha: 0.5)),
                              splashRadius: 14,
                              tooltip: 'Delete Item',
                              onPressed: _isEnabled ? () {
                                if (_isFromEdit) {
                                  if (entries.length == 1) {
                                    infoDialog(messageText: 'Cannot delete the only rough entry in edit mode.');
                                    return;
                                  }
                                  // Only removed from the list here; the item is
                                  // deleted in the database when the purchase is
                                  // saved (all together), so Cancel keeps it.
                                }
                                setState(() {
                                  if (_editingEntryIndex == i) {
                                    _clearEntryInputs();
                                  } else if (_editingEntryIndex != null && _editingEntryIndex! > i) {
                                    _editingEntryIndex = _editingEntryIndex! - 1;
                                  }
                                  entries.removeAt(i);
                                });
                                _updateCalculations();
                              } : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Total Summary Row
                TableRow(
                  decoration: BoxDecoration(color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('', isHeader: true),
                    _buildTableCell('TOTAL', isHeader: true),
                    _buildTableCell('', isHeader: true),
                    _buildTableCell('', isHeader: true),
                    _buildTableCell('', isHeader: true),
                    _buildTableCell(totalPc.toString(), isHeader: true, align: TextAlign.right),
                    _buildTableCell(totalWt.toStringAsFixed(4), isHeader: true, align: TextAlign.right),
                    _buildTableCell(totalRateRs.toStringAsFixed(3), isHeader: true, align: TextAlign.right),
                    _buildTableCell(totalAmountRs.toStringAsFixed(3), isHeader: true, align: TextAlign.right),
                    _buildTableCell(totalRateDollar.toStringAsFixed(6), isHeader: true, align: TextAlign.right),
                    _buildTableCell(totalAmountDollar.toStringAsFixed(3), isHeader: true, align: TextAlign.right),
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

  // ==================== BOTTOM CALCULATION & SUMMARY CARDS ====================
  Widget _buildCalculationsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;
        final leftCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const SizedBox(width: 158),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Per', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Fix (\$)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('Fix Rs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Row 1: Expense
                _buildCalcInputRow(
                  title: 'Expense :',
                  isFixChecked: _chkExp,
                  perController: expPerController,
                  fixDollarController: expFixDollarController,
                  fixRsController: expFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),
                // Row 2: License
                _buildCalcInputRow(
                  title: 'Lincense :',
                  isFixChecked: _chkLin,
                  perController: linPerController,
                  fixDollarController: linFixDollarController,
                  fixRsController: linFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),
                // Row 3: Total Expense (Read-only summary with textfields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const SizedBox(width: 58),
                      const SizedBox(
                        width: 100,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              'Total Expense :',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: totExpPerController,
                          enabled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: totExpFixDollarController,
                          enabled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: totExpFixRsController,
                          enabled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ),

                // Row 4: Brokerage
                _buildCalcInputRow(
                  title: 'Brokerage :',
                  isFixChecked: _chkBro,
                  perController: broPerController,
                  fixDollarController: broFixDollarController,
                  fixRsController: broRsController,
                  onChanged: (_) => _updateCalculations(),
                ),
                // Row 5: Add (+)
                _buildCalcInputRow(
                  title: 'Add (+) :',
                  isFixChecked: _chkAdd,
                  perController: addPerController,
                  fixDollarController: addFixDollarController,
                  fixRsController: addFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),
                // Row 6: Less (-)
                _buildCalcInputRow(
                  title: 'Less (-) :',
                  isFixChecked: _chkLess,
                  perController: lessPerController,
                  fixDollarController: lessFixDollarController,
                  fixRsController: lessFixRsController,
                  onChanged: (_) => _updateCalculations(),
                ),
                const SizedBox(height: 4),
                // Row 7: Remark
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 158,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              'Remark :',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AppTextField(
                          controller: remarksController,
                          enabled: _isEnabled,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          hintText: 'Enter purchase remarks or notes...',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        final rightCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Inv Charge
                _buildSummaryChargeRow(
                  title: 'Inv Charge :',
                  isFixChecked: _chkInv,
                  inputController: invChargePerController,
                  dollarController: invChargeDollarController,
                  rsController: invChargeRsController,
                  onChanged: (_) => _updateCalculations(),
                ),

                // Row 2: Comm.
                _buildSummaryChargeRow(
                  title: 'Comm. :',
                  isFixChecked: _chkCom,
                  inputController: comPerController,
                  dollarController: comDollarController,
                  rsController: comRsController,
                  onChanged: (_) => _updateCalculations(),
                ),

                // Row 3: Total Amt
                _buildDisplayRow('Total Amt (\$) :', totAmtDollarController, totAmtRsController),

                // Row 4: GST %
                _buildGstRow(),

                // Row 5: Net Amt
                _buildDisplayRow('Net Amt (\$) :', netAmtDollarController, netAmtRsController),

                // Row 6: Round Of
                _buildRoundOfRow(),

                // Row 7: Final Amt
                _buildDisplayRow('Final Amt (\$) :', finalAmtDollarController, finalAmtRsController),

                // Row 8: Exp / Br Net Amount
                _buildDisplayRow('Exp / Br Net Amount (\$) :', expBrNetDollarController, expBrNetRsController),

                // Row 9: Tot Net Amt
                _buildDisplayRow('Tot Net Amt (\$) :', totNetAmtDollarController, totNetAmtRsController),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: leftCard),
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

  // Helper row for Left Card (Expense/Deduction)
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
        final bool isUsd = _selectedCurrency.value == 'USD';
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
                    Text(isFix ? 'Fix' : 'Per', style: const TextStyle(fontSize: 11)),
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: perController,
                enabled: _isEnabled && !isFix,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: fixDollarController,
                enabled: _isEnabled && isFix && isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: fixRsController,
                enabled: _isEnabled && isFix && !isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper row for Right Card (Inv Charge, Comm)
  Widget _buildSummaryChargeRow({
    required String title,
    required RxBool isFixChecked,
    required TextEditingController inputController,
    required TextEditingController dollarController,
    required TextEditingController rsController,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Obx(() {
        final bool isUsd = _selectedCurrency.value == 'USD';
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
                    Text(isFix ? 'Fix' : 'Per', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 82,
              child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              width: 60,
              child: AppTextField(
                controller: inputController,
                enabled: _isEnabled && !isFix,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(
              width: 35,
              child: Center(
                child: Text('(\$) :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: dollarController,
                enabled: _isEnabled && isFix && isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(
              width: 28,
              child: Center(
                child: Text('Rs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: rsController,
                enabled: _isEnabled && isFix && !isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGstRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const SizedBox(width: 58),
          const SizedBox(
            width: 82,
            child: Text('Gst Per :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 60,
            child: AppTextField(
              controller: gstPerController,
              enabled: _isEnabled,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateCalculations(),
            ),
          ),
          const SizedBox(
            width: 35,
            child: Center(
              child: Text('(\$) :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: AppTextField(
              controller: gstAmtDollarController,
              enabled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: '0.000',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(
            width: 28,
            child: Center(
              child: Text('Rs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: AppTextField(
              controller: gstAmtRsController,
              enabled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: '0.000',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundOfRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Obx(() {
        final bool isUsd = _selectedCurrency.value == 'USD';

        return Row(
          children: [
            const SizedBox(
              width: 235,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Round Of (\$) :',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: roundOfDollarController,
                enabled: _isEnabled && isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                onChanged: (_) => _updateCalculations(),
              ),
            ),
            const SizedBox(
              width: 28,
              child: Center(
                child: Text('Rs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: roundOfRsController,
                enabled: _isEnabled && !isUsd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                hintText: '0.000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                onChanged: (_) => _updateCalculations(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDisplayRow(String title, TextEditingController dollarCtrl, TextEditingController rsCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 235,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            child: AppTextField(
              controller: dollarCtrl,
              enabled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: '0.000',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(
            width: 28,
            child: Center(
              child: Text('Rs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: AppTextField(
              controller: rsCtrl,
              enabled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: '0.000',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
