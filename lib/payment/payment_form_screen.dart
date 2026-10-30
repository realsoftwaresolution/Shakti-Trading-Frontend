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
import 'package:real_web_rough_entry_system/party/party_model.dart';
import 'package:real_web_rough_entry_system/payment/account_party_credit_debit_datagrid.dart';
import 'package:real_web_rough_entry_system/payment/book_party_credit_debit_datagrid.dart';
import 'package:real_web_rough_entry_system/payment/edit_account_party_credit_debit_datagrid.dart';
import 'package:real_web_rough_entry_system/payment/edit_book_party_credit_debit_datagrid.dart';
import 'package:real_web_rough_entry_system/payment/payment_datagrid.dart';
import 'package:real_web_rough_entry_system/payment/payment_details_model.dart';
import 'package:real_web_rough_entry_system/payment/payment_mst_model.dart';
import 'package:real_web_rough_entry_system/payment/pending_payment_model.dart';

class PaymentFormScreen extends StatefulWidget {
  final bool showHeader;
  final Map<String, String>? preFilledData;
  final RxList<PaymentDetailsModel>? editAccountPartyCreditDebitDataGridSource;
  final RxList<PaymentDetailsModel>? editBookPartyCreditDebitDataGridSource;
  final RxString? selectedTypeAccountParty;
  final RxString? selectedTypeBookParty;

  const PaymentFormScreen({
    super.key,
    required this.showHeader,
    this.preFilledData,
    this.editAccountPartyCreditDebitDataGridSource,
    this.editBookPartyCreditDebitDataGridSource,
    this.selectedTypeAccountParty,
    this.selectedTypeBookParty,
  });

  @override
  PaymentFormScreenState createState() => PaymentFormScreenState();
}

class PaymentFormScreenState extends State<PaymentFormScreen> {
  // Text Controllers
  final TextEditingController invNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController checkNoController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController balance1Controller = TextEditingController();
  final TextEditingController balance2Controller = TextEditingController();
  final TextEditingController jamaCreditController = TextEditingController();
  final TextEditingController udharDebitController = TextEditingController();
  final TextEditingController mstIdController = TextEditingController();
  final TextEditingController remarks1Controller = TextEditingController();
  final TextEditingController bookUdharController = TextEditingController();
  final TextEditingController bookCreditController = TextEditingController();
  final TextEditingController accountUdharController = TextEditingController();
  final TextEditingController accountCreditController = TextEditingController();

  // Search Filter Controllers
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Focus Nodes for ERP Keyboard Traversal
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _checkNoFocus = FocusNode();
  final FocusNode _bookPartyFocNode = FocusNode();
  final FocusNode _accountPartyFocus = FocusNode();
  final FocusNode _jamaCreditFocus = FocusNode();
  final FocusNode _udharDebitFocus = FocusNode();
  final FocusNode _remarks1Focus = FocusNode();
  final FocusNode _searchKeyBoardFocus = FocusNode();

  // DataGrid Controllers & Keys
  final DataGridController _dataGridController = DataGridController();
  final DataGridController _bookDataGridController = DataGridController();
  final DataGridController _accountDataGridController = DataGridController();
  final GlobalKey bookPartyDataGridKey = GlobalKey();
  final GlobalKey accountPartyDataGridKey = GlobalKey();

  // Reactive State
  final DefaultController defaultController = Get.find<DefaultController>();
  final RxInt selectedPaymentMstID = 0.obs;
  RxString selectedTypeBookParty = ''.obs;
  RxString selectedTypeAccountParty = ''.obs;
  final RxBool _isFiltered = false.obs;

  // Data Sources
  RxList<PaymentMstModel> paymentDataGridSource = <PaymentMstModel>[].obs;
  RxList<PendingPaymentModel> bookPartyCreditDebitDataGridSource = <PendingPaymentModel>[].obs;
  RxList<PaymentDetailsModel> editBookPartyCreditDebitDataGridSource = <PaymentDetailsModel>[].obs;
  RxList<PendingPaymentModel> accountPartyCreditDebitDataGridSource = <PendingPaymentModel>[].obs;
  RxList<PaymentDetailsModel> editAccountPartyCreditDebitDataGridSource = <PaymentDetailsModel>[].obs;
  RxList<PaymentMstModel> filteredDataGridSource = <PaymentMstModel>[].obs;
  Worker? _listWorker;
  List<Map<String, String>> entries = [];

  // Form State Flags
  bool _isEnabled = false;
  bool _isCreditEnabled = false;
  bool _isDebitEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;

  DateTime? selectedDate;
  String? paymentDay;
  DateTime? fromDate;
  DateTime? toDate;

  final _formKey = GlobalKey<FormState>();

  // Calculation getters for Edit settlement adjustments
  double get totalJAmtRsBook => editBookPartyCreditDebitDataGridSource.fold(
      0.0, (prev, e) => prev + (e.jAmtRs ?? 0.0));

  double get totalUAmtRsBook => editBookPartyCreditDebitDataGridSource.fold(
      0.0, (prev, e) => prev + (e.uAmtRs ?? 0.0));

  double get totalJAmtRsAccount => editAccountPartyCreditDebitDataGridSource.fold(
      0.0, (prev, e) => prev + (e.jAmtRs ?? 0.0));

  double get totalUAmtRsAccount => editAccountPartyCreditDebitDataGridSource.fold(
      0.0, (prev, e) => prev + (e.uAmtRs ?? 0.0));

  @override
  void initState() {
    super.initState();
    selectedTypeAccountParty = widget.selectedTypeAccountParty ?? ''.obs;
    selectedTypeBookParty = widget.selectedTypeBookParty ?? ''.obs;

    // Load master list
    paymentDataGridSource.value = List.of(defaultController.paymentMstList);

    // Keep the search table in sync whenever the list is reloaded / changed
    // (after add, edit, delete). Keeps the date filter if one is applied.
    _listWorker = ever(defaultController.paymentMstList, (_) {
      if (!mounted) return;
      if (_isFiltered.value && fromDate != null && toDate != null) {
        paymentDataGridSource.value = _filterByDate(defaultController.paymentMstList);
      } else {
        paymentDataGridSource.value = List.of(defaultController.paymentMstList);
      }
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultController.paymentMstList.isEmpty) {
        defaultController.getPaymentMstData();
      }
      if (defaultController.paymentDetList.isEmpty) {
        defaultController.getPaymentDetData();
      }
      if (defaultController.paymentDetAccList.isEmpty) {
        defaultController.getPaymentDetAccData();
      }
      if (defaultController.pendingPaymentList.isEmpty) {
        defaultController.getPendingPaymentData();
      }
      if (defaultController.partyMstList.isEmpty) {
        defaultController.getPartyData();
      }
    });

    // Jama (Credit) Listener: Typing disables Debit & syncs on-account controllers
    jamaCreditController.addListener(_onJamaChanged);

    // Udhar (Debit) Listener: Typing disables Credit & syncs on-account controllers
    udharDebitController.addListener(_onUdharChanged);
  }

  void _onJamaChanged() {
    if (jamaCreditController.text.isNotEmpty) {
      if (_isDebitEnabled) {
        setState(() {
          _isDebitEnabled = false;
        });
      }
      final double val = double.tryParse(jamaCreditController.text) ?? 0.00;
      if (_isFromEdit) {
        bookUdharController.text = (val - totalUAmtRsBook).toStringAsFixed(2);
        accountCreditController.text = (val - totalJAmtRsAccount).toStringAsFixed(2);
      } else {
        bookUdharController.text = jamaCreditController.text;
        accountCreditController.text = jamaCreditController.text;
      }
    } else {
      if (!_isDebitEnabled && _isEnabled) {
        setState(() {
          _isDebitEnabled = true;
        });
      }
    }
  }

  void _onUdharChanged() {
    if (udharDebitController.text.isNotEmpty) {
      if (_isCreditEnabled) {
        setState(() {
          _isCreditEnabled = false;
        });
      }
      final double val = double.tryParse(udharDebitController.text) ?? 0.00;
      if (_isFromEdit) {
        bookCreditController.text = (val - totalJAmtRsBook).toStringAsFixed(2);
        accountUdharController.text = (val - totalUAmtRsAccount).toStringAsFixed(2);
      } else {
        bookCreditController.text = udharDebitController.text;
        accountUdharController.text = udharDebitController.text;
      }
    } else {
      if (!_isCreditEnabled && _isEnabled) {
        setState(() {
          _isCreditEnabled = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _listWorker?.dispose();
    jamaCreditController.removeListener(_onJamaChanged);
    udharDebitController.removeListener(_onUdharChanged);

    invNoController.dispose();
    dateController.dispose();
    checkNoController.dispose();
    dueDateController.dispose();
    balance1Controller.dispose();
    balance2Controller.dispose();
    jamaCreditController.dispose();
    udharDebitController.dispose();
    mstIdController.dispose();
    remarks1Controller.dispose();
    bookUdharController.dispose();
    bookCreditController.dispose();
    accountUdharController.dispose();
    accountCreditController.dispose();
    fromDateController.dispose();
    toDateController.dispose();

    _dateFocus.dispose();
    _checkNoFocus.dispose();
    _bookPartyFocNode.dispose();
    _accountPartyFocus.dispose();
    _jamaCreditFocus.dispose();
    _udharDebitFocus.dispose();
    _remarks1Focus.dispose();
    _searchKeyBoardFocus.dispose();
    super.dispose();
  }

  // ==================== WORKFLOW & CRUD METHODS ====================

  void _enableFields({bool? needFocus}) {
    setState(() {
      _isEnabled = true;
      _isCreditEnabled = true;
      _isDebitEnabled = true;
      _isFromEdit = false;
      selectedPaymentMstID.value = 0;
      mstIdController.text = 'AUTO';
    });

    if (needFocus == null || needFocus) {
      final now = DateTime.now();
      selectedDate = now;
      paymentDay = DateFormat('EEEE').format(now);
      dateController.text = '${DateFormat('dd-MM-yyyy').format(now)}     $paymentDay';
      Future.delayed(const Duration(milliseconds: 100), () {
        _dateFocus.requestFocus();
      });
    }
  }

  void onSelectBookParty() {
    if (selectedTypeBookParty.isNotEmpty) {
      bookPartyCreditDebitDataGridSource.value = defaultController.pendingPaymentList
          .where((e) =>
              e.partyCode == int.parse(selectedTypeBookParty.value) &&
              e.companyCode == defaultController.companyCode.value)
          .toList();
    }
  }

  void onSelectAccountParty() {
    if (selectedTypeAccountParty.isNotEmpty) {
      accountPartyCreditDebitDataGridSource.value = defaultController.pendingPaymentList
          .where((e) =>
              e.partyCode == int.parse(selectedTypeAccountParty.value) &&
              e.companyCode == defaultController.companyCode.value)
          .toList();
    }
  }

  void _openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        paymentDay = DateFormat('EEEE').format(pickedDate);
        dateController.text = '${DateFormat('dd-MM-yyyy').format(pickedDate)}     $paymentDay';
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _checkNoFocus.requestFocus();
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_isEnabled) return;

    if (_isFromEdit) {
      if (selectedTypeBookParty.isEmpty || selectedTypeAccountParty.isEmpty) {
        infoDialog(messageText: 'Please select both Book Party and Account Party.');
        return;
      }

      await defaultController.updatePaymentData(
        mstId: selectedPaymentMstID.value,
        bookJAmtRs: double.tryParse(bookCreditController.text) ?? 0.00,
        bookUAmtRs: double.tryParse(bookUdharController.text) ?? 0.00,
        accJAmtRs: double.tryParse(accountCreditController.text) ?? 0.00,
        accUAmtRs: double.tryParse(accountUdharController.text) ?? 0.00,
        accountDataGridSource: editAccountPartyCreditDebitDataGridSource,
        bookDataGridSource: editBookPartyCreditDebitDataGridSource,
        paymentDate: selectedDate,
        paymentDay: paymentDay,
        chequeNo: checkNoController.text,
        jAmtRs: double.tryParse(jamaCreditController.text) ?? 0.00,
        uAmtRs: double.tryParse(udharDebitController.text) ?? 0.00,
        remarks1: remarks1Controller.text,
        pAmtRs: double.tryParse(udharDebitController.text) ?? 0.00,
        aAmtRs: double.tryParse(jamaCreditController.text) ?? 0.00,
        partyCode: int.parse(selectedTypeBookParty.value),
        accountCode: int.parse(selectedTypeAccountParty.value),
      );
      _handleCancel();
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        if (selectedTypeBookParty.isEmpty || selectedTypeAccountParty.isEmpty) {
          infoDialog(messageText: 'Please select both Book Party and Account Party.');
          return;
        }

        final double jama = double.tryParse(jamaCreditController.text) ?? 0.00;
        final double udhar = double.tryParse(udharDebitController.text) ?? 0.00;
        if (jama == 0 && udhar == 0) {
          infoDialog(messageText: 'Please enter either Jama (Credit) or Udhar (Debit) amount.');
          return;
        }

        await defaultController.addPaymentData(
          bookJAmtRs: double.tryParse(bookCreditController.text) ?? 0.00,
          bookUAmtRs: double.tryParse(bookUdharController.text) ?? 0.00,
          accJAmtRs: double.tryParse(accountCreditController.text) ?? 0.00,
          accUAmtRs: double.tryParse(accountUdharController.text) ?? 0.00,
          accountDataGridSource: accountPartyCreditDebitDataGridSource,
          bookDataGridSource: bookPartyCreditDebitDataGridSource,
          paymentDate: selectedDate,
          paymentDay: paymentDay,
          chequeNo: checkNoController.text,
          jAmtRs: jama,
          uAmtRs: udhar,
          remarks1: remarks1Controller.text,
          pAmtRs: udhar,
          aAmtRs: jama,
          partyCode: int.parse(selectedTypeBookParty.value),
          accountCode: int.parse(selectedTypeAccountParty.value),
        );
        _handleCancel();
      } else {
        infoDialog(messageText: 'Please fill all required fields.');
      }
    }
  }

  Future<void> _handleDelete() async {
    if (!_isEnabled || !_isFromEdit) return;
    await defaultController.deletePaymentData(id: selectedPaymentMstID.value);
    _handleCancel();
  }

  void _handleCancel() {
    dateController.clear();
    invNoController.clear();
    dueDateController.clear();
    accountPartyCreditDebitDataGridSource.clear();
    bookPartyCreditDebitDataGridSource.clear();
    editAccountPartyCreditDebitDataGridSource.clear();
    editBookPartyCreditDebitDataGridSource.clear();
    remarks1Controller.clear();
    jamaCreditController.clear();
    udharDebitController.clear();
    balance1Controller.clear();
    balance2Controller.clear();
    checkNoController.clear();
    bookUdharController.clear();
    bookCreditController.clear();
    accountCreditController.clear();
    accountUdharController.clear();
    mstIdController.clear();
    selectedTypeBookParty.value = '';
    selectedTypeAccountParty.value = '';
    entries.clear();
    setState(() {
      _isFromEdit = false;
      _isEnabled = false;
      _isDebitEnabled = false;
      _isCreditEnabled = false;
    });
  }

  Future<void> _selectPaymentById(int mstId) async {
    selectedPaymentMstID.value = mstId;

    final PaymentMstModel? selectedPaymentData = defaultController.paymentMstList.firstWhereOrNull(
      (e) => e.paymentMstID == mstId,
    );
    if (selectedPaymentData == null) return;

    // editBookPartyCreditDebitDataGridSource.value = await defaultController.getBookPartyPaymentDetails(
    //   selectedPaymentData.partyCode!,
    //   mstId,
    // );

    editAccountPartyCreditDebitDataGridSource.value = await defaultController.getAccPartyPaymentDetails(
      selectedPaymentData.accountCode!,
      mstId,
    );

    mstIdController.text = mstId.toString();
    balance1Controller.text = getSelectedPartyBalance(
      partyCode: selectedPaymentData.partyCode,
      isFromEdit: true,
    ).toStringAsFixed(2);
    balance2Controller.text = getSelectedPartyBalance(
      partyCode: selectedPaymentData.accountCode,
      isFromEdit: true,
    ).toStringAsFixed(2);
    checkNoController.text = selectedPaymentData.chequeNo ?? '';
    dateController.text = formatDate(selectedPaymentData.paymentDate!, showDayOfWeek: true);
    selectedDate = dateFormat(selectedPaymentData.paymentDate!);
    paymentDay = selectedPaymentData.paymentDay;
    jamaCreditController.text = (selectedPaymentData.jAmtRs ?? 0.00).toStringAsFixed(2);
    udharDebitController.text = (selectedPaymentData.uAmtRs ?? 0.00).toStringAsFixed(2);
    remarks1Controller.text = selectedPaymentData.remarks1 ?? '';
    selectedTypeBookParty.value = selectedPaymentData.partyCode.toString();
    selectedTypeAccountParty.value = selectedPaymentData.accountCode.toString();

    if ((selectedPaymentData.jAmtRs ?? 0.00) > 0.00) {
      _isDebitEnabled = false;
      _isCreditEnabled = true;
      bookUdharController.text = ((double.tryParse(jamaCreditController.text) ?? 0.00) - totalUAmtRsBook).toStringAsFixed(2);
      accountCreditController.text = ((double.tryParse(jamaCreditController.text) ?? 0.00) - totalJAmtRsAccount).toStringAsFixed(2);
    } else if ((selectedPaymentData.uAmtRs ?? 0.00) > 0.00) {
      _isCreditEnabled = false;
      _isDebitEnabled = true;
      bookCreditController.text = ((double.tryParse(udharDebitController.text) ?? 0.00) - totalJAmtRsBook).toStringAsFixed(2);
      accountUdharController.text = ((double.tryParse(udharDebitController.text) ?? 0.00) - totalUAmtRsAccount).toStringAsFixed(2);
    }

    setState(() {
      _isFromEdit = true;
      _isEnabled = true;
      _isSearch = false;
    });
  }

  // ==================== SEARCH DATE FILTERING ====================

  void _applyDateFilter() {
    if (fromDate != null && toDate != null) {
      _isFiltered.value = true;
      filteredDataGridSource.value = _filterByDate(defaultController.paymentMstList);
      paymentDataGridSource.value = List.of(filteredDataGridSource);
      _searchKeyBoardFocus.requestFocus();
    } else {
      infoDialog(messageText: 'Please select both From Date and To Date');
    }
  }

  List<PaymentMstModel> _filterByDate(List<PaymentMstModel> list) {
    return list.where((payment) {
      if (payment.paymentDate == null) return false;
      final paymentDate = DateTime.tryParse(payment.paymentDate!);
      if (paymentDate == null) return false;
      return paymentDate.isAfter(fromDate!) &&
          paymentDate.isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();
  }

  void _removeDateFilter() {
    paymentDataGridSource.value = List.of(defaultController.paymentMstList);
    toDateController.clear();
    fromDateController.clear();
    fromDate = null;
    toDate = null;
    _isFiltered.value = false;
  }

  // ==================== PARTY CLASSIFICATION & FILTERING ====================

  bool _isCashParty(PartyMstModel? party) {
    if (party == null) return false;
    final int? typeCode = party.typeCode ?? int.tryParse(party.partyType ?? '');
    final typeName = getPartyType(typeCode).toUpperCase().trim();
    final partyType = (party.partyType ?? '').toUpperCase().trim();
    final partyName = (party.partyName ?? '').toUpperCase().trim();

    if (typeCode == 3 ||
        partyType == '3' ||
        partyType == 'CASH' ||
        typeName == 'CASH' ||
        typeName.contains('CASH')) {
      return true;
    }

    if (partyName == 'CASH' ||
        partyName.startsWith('CASH ') ||
        partyName.contains('CASH A/C') ||
        partyName.contains('PETTY CASH')) {
      return true;
    }

    return false;
  }

  bool _isBankParty(PartyMstModel? party) {
    if (party == null) return false;
    if (_isCashParty(party)) return false;

    final int? typeCode = party.typeCode ?? int.tryParse(party.partyType ?? '');
    final typeName = getPartyType(typeCode).toUpperCase().trim();
    final partyType = (party.partyType ?? '').toUpperCase().trim();
    final partyName = (party.partyName ?? '').toUpperCase().trim();

    if (typeCode == 4 ||
        partyType == '4' ||
        partyType == 'BANK' ||
        typeName == 'BANK' ||
        typeName.contains('BANK')) {
      return true;
    }

    if (partyName.contains('BANK')) {
      return true;
    }

    return false;
  }

  bool _isBankOrCashParty(PartyMstModel party) {
    return _isCashParty(party) || _isBankParty(party);
  }

  List<PartyMstModel> get filteredBookParties {
    final companyParties = defaultController.partyMstList
        .where((partyType) =>
            partyType.partyCode != null &&
            (partyType.companyCode == null ||
                partyType.companyCode == 0 ||
                partyType.companyCode == defaultController.companyCode.value))
        .toList();

    var list = companyParties.where(_isBankOrCashParty).toList();

    if (selectedTypeAccountParty.value.isNotEmpty) {
      final accParty = defaultController.partyMstList.firstWhereOrNull(
        (p) => p.partyCode.toString() == selectedTypeAccountParty.value,
      );
      if (accParty != null) {
        list = list.where((p) => p.partyCode != accParty.partyCode).toList();
        if (_isBankParty(accParty)) {
          list = list.where((p) => !_isBankParty(p)).toList();
        } else if (_isCashParty(accParty)) {
          list = list.where((p) => !_isCashParty(p)).toList();
        }
      }
    }

    if (selectedTypeBookParty.value.isNotEmpty &&
        !list.any((p) => p.partyCode.toString() == selectedTypeBookParty.value)) {
      final curBk = defaultController.partyMstList.firstWhereOrNull(
        (p) => p.partyCode.toString() == selectedTypeBookParty.value,
      );
      if (curBk != null) {
        list.insert(0, curBk);
      }
    }

    return list;
  }

  List<PartyMstModel> get filteredAccountParties {
    var list = defaultController.partyMstList
        .where((partyType) =>
            partyType.partyCode != null &&
            (partyType.companyCode == null ||
                partyType.companyCode == 0 ||
                partyType.companyCode == defaultController.companyCode.value))
        .toList();

    if (selectedTypeBookParty.value.isNotEmpty) {
      final bkParty = defaultController.partyMstList.firstWhereOrNull(
        (p) => p.partyCode.toString() == selectedTypeBookParty.value,
      );
      if (bkParty != null) {
        list = list.where((p) => p.partyCode != bkParty.partyCode).toList();
        if (_isCashParty(bkParty)) {
          list = list.where((p) => !_isCashParty(p)).toList();
        } else if (_isBankParty(bkParty)) {
          list = list.where((p) => !_isBankParty(p)).toList();
        }
      }
    }

    if (selectedTypeAccountParty.value.isNotEmpty &&
        !list.any((p) => p.partyCode.toString() == selectedTypeAccountParty.value)) {
      final curAcc = defaultController.partyMstList.firstWhereOrNull(
        (p) => p.partyCode.toString() == selectedTypeAccountParty.value,
      );
      if (curAcc != null) {
        list.insert(0, curAcc);
      }
    }

    return list;
  }

  void _resetFieldsBelowParties() {
    jamaCreditController.clear();
    udharDebitController.clear();
    remarks1Controller.clear();
    bookCreditController.clear();
    bookUdharController.clear();
    accountCreditController.clear();
    accountUdharController.clear();
    _isCreditEnabled = true;
    _isDebitEnabled = true;
  }

  void _onBookPartyChanged(String? value) {
    selectedTypeBookParty.value = value ?? '';

    if (selectedTypeAccountParty.value.isNotEmpty) {
      final bkParty = defaultController.partyMstList
          .firstWhereOrNull((p) => p.partyCode.toString() == value);
      final accParty = defaultController.partyMstList
          .firstWhereOrNull((p) => p.partyCode.toString() == selectedTypeAccountParty.value);

      bool resetAcc = false;
      if (bkParty != null && accParty != null) {
        if (bkParty.partyCode == accParty.partyCode) {
          resetAcc = true;
        } else if (_isCashParty(bkParty) && _isCashParty(accParty)) {
          resetAcc = true;
        } else if (_isBankParty(bkParty) && _isBankParty(accParty)) {
          resetAcc = true;
        }
      }
      if (resetAcc) {
        selectedTypeAccountParty.value = '';
        balance2Controller.clear();
        accountPartyCreditDebitDataGridSource.clear();
        editAccountPartyCreditDebitDataGridSource.clear();
      }
    }

    _resetFieldsBelowParties();

    if (value != null && value.isNotEmpty) {
      final selectedParty = defaultController.partyMstList
          .firstWhereOrNull((partyType) => partyType.partyCode.toString() == value);
      if (selectedParty != null) {
        balance1Controller.text = getSelectedPartyBalance(
          selectedParty: selectedParty,
        ).toStringAsFixed(2);
      }
      onSelectBookParty();
    } else {
      balance1Controller.clear();
      bookPartyCreditDebitDataGridSource.clear();
      editBookPartyCreditDebitDataGridSource.clear();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _accountPartyFocus.requestFocus();
    });
  }

  void _onAccountPartyChanged(String? value) {
    selectedTypeAccountParty.value = value ?? '';

    if (selectedTypeBookParty.value.isNotEmpty) {
      final accParty = defaultController.partyMstList
          .firstWhereOrNull((p) => p.partyCode.toString() == value);
      final bkParty = defaultController.partyMstList
          .firstWhereOrNull((p) => p.partyCode.toString() == selectedTypeBookParty.value);

      bool resetBk = false;
      if (bkParty != null && accParty != null) {
        if (bkParty.partyCode == accParty.partyCode) {
          resetBk = true;
        } else if (_isBankParty(accParty) && _isBankParty(bkParty)) {
          resetBk = true;
        } else if (_isCashParty(accParty) && _isCashParty(bkParty)) {
          resetBk = true;
        }
      }
      if (resetBk) {
        selectedTypeBookParty.value = '';
        balance1Controller.clear();
        bookPartyCreditDebitDataGridSource.clear();
        editBookPartyCreditDebitDataGridSource.clear();
      }
    }

    _resetFieldsBelowParties();

    if (value != null && value.isNotEmpty) {
      final selectedParty = defaultController.partyMstList
          .firstWhereOrNull((partyType) => partyType.partyCode.toString() == value);
      if (selectedParty != null) {
        balance2Controller.text = getSelectedPartyBalance(
          selectedParty: selectedParty,
        ).toStringAsFixed(2);
      }
      onSelectAccountParty();
    } else {
      balance2Controller.clear();
      accountPartyCreditDebitDataGridSource.clear();
      editAccountPartyCreditDebitDataGridSource.clear();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _jamaCreditFocus.requestFocus();
    });
  }

  // ==================== DROPDOWNS ====================

  List<DropdownMenuItem<String>> _buildPartyDropdownMenuItems(List<PartyMstModel> parties) {
    final seenCodes = <int>{};
    return parties
        .where((p) => p.partyCode != null && seenCodes.add(p.partyCode!))
        .map((p) {
      final partyTransactions = defaultController.creditDebitDataList
          .where((cd) => cd.partyCode == p.partyCode)
          .toList();

      final double sumCredit = partyTransactions.fold(0.0, (prev, cd) => prev + (cd.creditRs ?? 0.0));
      final double sumDebit = partyTransactions.fold(0.0, (prev, cd) => prev + (cd.debitRs ?? 0.0));
      final double balance = (sumCredit - sumDebit) +
          ((p.creditOpBalRs ?? 0.0) - (p.debitOpBalRs ?? 0.0));

      final Color badgeBg = getPartyTypeColor(p.typeCode ?? 0);
      final IconData badgeIcon = getPartyTypeIcon(p.typeCode ?? 0);

      return DropdownMenuItem<String>(
        value: p.partyCode.toString(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeBg.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 10, color: badgeBg),
                      const SizedBox(width: 3),
                      Text(
                        getPartyType(p.typeCode ?? 0),
                        style: TextStyle(fontSize: 10, color: badgeBg, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  p.partyName ?? '',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹ ${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: balance >= 0 ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: (balance >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    balance >= 0 ? 'Cr' : 'Dr',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: balance >= 0 ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsBookParty {
    return _buildPartyDropdownMenuItems(filteredBookParties);
  }

  List<DropdownMenuItem<String>> get dropdownItemsAccountParty {
    return _buildPartyDropdownMenuItems(filteredAccountParties);
  }

  List<DropdownMenuItem<String>> get dropdownItemsParty => dropdownItemsAccountParty;

  // ==================== MAIN BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = AppColors.isDark;
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: _isEnabled ? _handleCancel : null,
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
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) Header(title: _isSearch ? 'Payment Search' : 'Payment Voucher'),
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
          final int totalRows = paymentDataGridSource.length;

          if (event.logicalKey == LogicalKeyboardKey.enter && _dataGridController.selectedRow != null) {
            final dynamic idVal = _dataGridController.selectedRow!.getCells()[0].value;
            final int id = idVal is int ? idVal : int.tryParse('$idVal') ?? 0;
            if (id > 0) _selectPaymentById(id);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && currentIndex < totalRows - 1) {
            _dataGridController.selectedIndex = currentIndex + 1;
            _dataGridController.scrollToRow(double.parse(_dataGridController.selectedIndex.toString()));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && currentIndex > 0) {
            _dataGridController.selectedIndex = currentIndex - 1;
            _dataGridController.scrollToRow(double.parse(_dataGridController.selectedIndex.toString()));
          } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.keyE) {
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
                  prefixIcon: Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
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
                  prefixIcon: Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
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
                  const SizedBox(width: 16),
                  actionButtons,
                ],
              );
            },
          ),
          ),
          Obx(() => defaultController.isLoading.value
              ? LinearProgressIndicator(color: AppColors.primary, minHeight: 2)
              : const SizedBox.shrink()),
          // Table of Vouchers
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
                    final searchSource = PaymentDataGridSource(paymentDataGridSource);
                    return AppDataGrid(
                      controller: _dataGridController,
                      source: searchSource,
                      columns: _buildSearchGridColumns(),
                      tableSummaryRows: [
                        GridTableSummaryRow(
                          title: 'Total ${paymentDataGridSource.length}',
                          showSummaryInRow: false,
                          titleColumnSpan: 1,
                          columns: const <GridSummaryColumn>[
                            GridSummaryColumn(name: 'Jama AmtRs', columnName: 'Jama AmtRs', summaryType: GridSummaryType.sum),
                            GridSummaryColumn(name: 'Udhar AmtRs', columnName: 'Udhar AmtRs', summaryType: GridSummaryType.sum),
                            GridSummaryColumn(name: 'Acc. AmtRs', columnName: 'Acc. AmtRs', summaryType: GridSummaryType.sum),
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
                      // Single click only selects the row; double click (or Enter)
                      // opens it in the form - same as the other screens. Opening
                      // on selection change failed when the same row was clicked
                      // again, because its selection did not change.
                      onCellDoubleTap: (details) {
                        if (details.rowColumnIndex.rowIndex <= 0) return; // header
                        final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                        final rows = searchSource.effectiveRows; // sorted/filtered order
                        if (dataRowIndex < 0 || dataRowIndex >= rows.length) return;
                        final dynamic idVal = rows[dataRowIndex].getCells()[0].value;
                        final int id = idVal is int ? idVal : int.tryParse('$idVal') ?? 0;
                        if (id > 0) _selectPaymentById(id);
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 1: Master Voucher Details (MST ID, Date, Cheque No, Book Party, Account Party)
            _buildVoucherDetailsCard(),
            const SizedBox(height: 12),

            // Card 2: Voucher Amount & Remarks
            _buildAmountCard(),
            const SizedBox(height: 12),

            // Settlement Section: Outstanding Lists for Book Party and Account Party
            _buildSettlementSection(),
            const SizedBox(height: 16),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ==================== SUB-COMPONENTS ====================

  Widget _buildTopToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;
          final titlePart = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.payment_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment / Receipt Voucher',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    _isFromEdit
                        ? 'Editing Voucher #${selectedPaymentMstID.value}'
                        : (_isEnabled ? 'New Voucher Entry' : 'Press [Alt+A] to create a new voucher'),
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          );

          final badgePart = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isFromEdit
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : (_isEnabled ? AppColors.success.withValues(alpha: 0.12) : AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isFromEdit
                        ? AppColors.warning
                        : (_isEnabled ? AppColors.success : AppColors.textMuted),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isFromEdit
                          ? Icons.edit_note_rounded
                          : (_isEnabled ? Icons.add_circle_outline_rounded : Icons.lock_outline_rounded),
                      size: 14,
                      color: _isFromEdit
                          ? AppColors.warning
                          : (_isEnabled ? AppColors.success : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isFromEdit
                          ? 'EDIT MODE: #${selectedPaymentMstID.value}'
                          : (_isEnabled ? 'CREATE MODE' : 'READ ONLY'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isFromEdit
                            ? AppColors.warning
                            : (_isEnabled ? AppColors.success : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Search List',
                icon: Icons.search_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () => setState(() => _isSearch = true),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titlePart,
                const SizedBox(height: 10),
                badgePart,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              titlePart,
              badgePart,
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoucherDetailsCard() {
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
            Text(
              'VOUCHER IDENTIFICATION',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Must match the layout below: MST ID only takes full width in the
                // stacked (< 500px) layout. Between 500-750px it sits in a Row,
                // where an infinite width crashes layout ("RenderBox was not laid out").
                final isCompact = constraints.maxWidth < 500;
                final mstField = SizedBox(
                  width: isCompact ? double.infinity : 130,
                  child: AppTextField(
                    label: 'MST ID',
                    controller: mstIdController,
                    enabled: false,
                    prefixIcon: Icon(Icons.tag_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                );

                final dateField = Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                      _openDatePicker();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AppTextField(
                    label: 'Date (Press Enter for Picker)',
                    controller: dateController,
                    focusNode: _dateFocus,
                    nextFocusNode: _checkNoFocus,
                    enabled: _isEnabled,
                    readOnly: true,
                    prefixIcon: Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    onTap: _isEnabled ? _openDatePicker : null,
                  ),
                );

                final chequeField = AppTextField(
                  label: 'Cheque / Ref No.',
                  controller: checkNoController,
                  focusNode: _checkNoFocus,
                  nextFocusNode: _bookPartyFocNode,
                  enabled: _isEnabled,
                  prefixIcon: Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.textSecondary),
                );

                if (constraints.maxWidth >= 750) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mstField,
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: dateField),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: chequeField),
                    ],
                  );
                } else if (constraints.maxWidth >= 500) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          mstField,
                          const SizedBox(width: 12),
                          Expanded(child: dateField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      chequeField,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      mstField,
                      const SizedBox(height: 10),
                      dateField,
                      const SizedBox(height: 10),
                      chequeField,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Parties Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final isMedium = constraints.maxWidth < 1050;

                final bookPartyField = Obx(
                  () => AppDropdown<String>(
                    label: 'Book Party (Alt+Click or Tab)',
                    value: selectedTypeBookParty.value.isEmpty ? null : selectedTypeBookParty.value,
                    items: dropdownItemsBookParty,
                    focusNode: _bookPartyFocNode,
                    nextFocusNode: _accountPartyFocus,
                    hintText: 'Select Book Party',
                    isEnabled: _isEnabled,
                    itemHeight: 40.0,
                    selectedItemBuilder: (context, value) {
                      final pCode = int.tryParse(value);
                      return Text(
                        pCode != null ? getPartyName(pCode) : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      );
                    },
                    onChanged: _onBookPartyChanged,
                  ),
                );

                final bookBalanceField = SizedBox(
                  width: isCompact ? double.infinity : 160,
                  child: AppTextField(
                    label: 'Book Balance',
                    controller: balance1Controller,
                    enabled: false,
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textSecondary),
                  ),
                );

                final accountPartyField = Obx(
                  () => AppDropdown<String>(
                    label: 'Account Party (Tab)',
                    value: selectedTypeAccountParty.value.isEmpty ? null : selectedTypeAccountParty.value,
                    items: dropdownItemsAccountParty,
                    focusNode: _accountPartyFocus,
                    nextFocusNode: _jamaCreditFocus,
                    hintText: 'Select Account Party',
                    isEnabled: _isEnabled,
                    itemHeight: 40.0,
                    selectedItemBuilder: (context, value) {
                      final pCode = int.tryParse(value);
                      return Text(
                        pCode != null ? getPartyName(pCode) : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      );
                    },
                    onChanged: _onAccountPartyChanged,
                  ),
                );

                final accountBalanceField = SizedBox(
                  width: isCompact ? double.infinity : 160,
                  child: AppTextField(
                    label: 'Account Balance',
                    controller: balance2Controller,
                    enabled: false,
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textSecondary),
                  ),
                );

                if (isMedium) {
                  return Column(
                    children: [
                      if (isCompact) ...[
                        bookPartyField,
                        const SizedBox(height: 8),
                        bookBalanceField,
                        const SizedBox(height: 12),
                        accountPartyField,
                        const SizedBox(height: 8),
                        accountBalanceField,
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: bookPartyField),
                            const SizedBox(width: 10),
                            bookBalanceField,
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: accountPartyField),
                            const SizedBox(width: 10),
                            accountBalanceField,
                          ],
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: bookPartyField),
                    const SizedBox(width: 10),
                    bookBalanceField,
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: accountPartyField),
                    const SizedBox(width: 10),
                    accountBalanceField,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
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
            Text(
              'PAYMENT / RECEIPT AMOUNT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 800;

                final jamaField = AppTextField(
                  label: 'JAMA (CREDIT / RECEIPT)',
                  controller: jamaCreditController,
                  focusNode: _jamaCreditFocus,
                  enabled: _isEnabled && _isCreditEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.success),
                  onFieldSubmitted: (_) {
                    if (_isDebitEnabled) {
                       _udharDebitFocus.requestFocus();
                    } else {
                       _remarks1Focus.requestFocus();
                    }
                  },
                );

                final udharField = AppTextField(
                  label: 'UDHAR (DEBIT / PAYMENT)',
                  controller: udharDebitController,
                  focusNode: _udharDebitFocus,
                  enabled: _isEnabled && _isDebitEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.danger),
                  onFieldSubmitted: (_) => _remarks1Focus.requestFocus(),
                );

                final remarksField = AppTextField(
                  label: 'Remarks (Press Enter to allocate)',
                  controller: remarks1Controller,
                  focusNode: _remarks1Focus,
                  enabled: _isEnabled,
                  prefixIcon: Icon(Icons.notes_rounded, size: 16, color: AppColors.textSecondary),
                  onFieldSubmitted: (_) {
                    if (selectedTypeBookParty.isNotEmpty && selectedTypeAccountParty.isNotEmpty) {
                      _remarks1Focus.unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (udharDebitController.text.isNotEmpty) {
                          _bookDataGridController.beginEdit(RowColumnIndex(0, 3));
                        } else {
                          _bookDataGridController.beginEdit(RowColumnIndex(0, 4));
                        }
                      });
                    }
                  },
                );

                if (isCompact) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: jamaField),
                          const SizedBox(width: 12),
                          Expanded(child: udharField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      remarksField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: jamaField),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: udharField),
                    const SizedBox(width: 12),
                    Expanded(flex: 5, child: remarksField),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 1000;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(child: _buildBookPartyOutstandingCard()),
            // const SizedBox(width: 12),
            Expanded(child: _buildAccountPartyOutstandingCard()),
          ],
        );
      } else {
        return Column(
          children: [
            // _buildBookPartyOutstandingCard(),
            // const SizedBox(height: 12),
            _buildAccountPartyOutstandingCard(),
          ],
        );
      }
    });
  }

  Widget _buildBookPartyOutstandingCard() {
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
            // Header with On-Account Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'BOOK OUTSTANDING (${bookPartyCreditDebitDataGridSource.length})',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildPillBadge('On A/C Cr: ', bookCreditController, AppColors.success),
                    const SizedBox(width: 6),
                    _buildPillBadge('On A/C Dr: ', bookUdharController, AppColors.danger),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // DataGrid
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Obx(
                  () => AppDataGrid(
                    gridKey: bookPartyDataGridKey,
                    controller: _bookDataGridController,
                    source: _isFromEdit
                        ? EditBookPartyCreditDebitDataGrid(
                            editBookPartyCreditDebitDataGridSource,
                            _accountDataGridController,
                            udharDebitController,
                            bookUdharController,
                            bookCreditController,
                            jamaCreditController)
                        : BookPartyCreditDebitDataGrid(
                            bookPartyCreditDebitDataGridSource,
                            _accountDataGridController,
                            udharDebitController,
                            bookUdharController,
                            bookCreditController,
                            jamaCreditController),
                    columns: _buildOutstandingGridColumns(isBook: true),
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        title: 'Total',
                        showSummaryInRow: false,
                        titleColumnSpan: 1,
                        columns: const <GridSummaryColumn>[
                          GridSummaryColumn(name: 'JamaRsSum', columnName: 'Jama Rs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'OutAmtRsSum', columnName: 'Out AmtRs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'UdharRsSum', columnName: 'Udhar Rs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'AmtRsSum', columnName: 'Amt Rs', summaryType: GridSummaryType.sum),
                        ],
                        position: GridTableSummaryRowPosition.bottom,
                      )
                    ],
                    columnWidthMode: ColumnWidthMode.auto,
                    navigationMode: GridNavigationMode.cell,
                    frozenColumnsCount: 1,
                    rowHeight: 28,
                    headerRowHeight: 32,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    showSortNumbers: true,
                    allowFiltering: true,
                    allowColumnsResizing: true,
                    selectionMode: SelectionMode.single,
                    allowEditing: true,
                    editingGestureType: EditingGestureType.tap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountPartyOutstandingCard() {
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
            // Header with On-Account Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'ACCOUNT OUTSTANDING (${accountPartyCreditDebitDataGridSource.length})',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildPillBadge('On A/C Cr: ', accountCreditController, AppColors.success),
                    const SizedBox(width: 6),
                    _buildPillBadge('On A/C Dr: ', accountUdharController, AppColors.danger),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // DataGrid
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Obx(
                  () => AppDataGrid(
                    gridKey: accountPartyDataGridKey,
                    controller: _accountDataGridController,
                    source: _isFromEdit
                        ? EditAccountPartyCreditDebitDataGrid(
                            editAccountPartyCreditDebitDataGridSource,
                            udharDebitController,
                            accountUdharController,
                            accountCreditController,
                            jamaCreditController)
                        : AccountPartyCreditDebitDataGrid(
                            accountPartyCreditDebitDataGridSource,
                            udharDebitController,
                            accountUdharController,
                            accountCreditController,
                            jamaCreditController),
                    columns: _buildOutstandingGridColumns(isBook: false),
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        title: 'Total',
                        showSummaryInRow: false,
                        titleColumnSpan: 1,
                        columns: const <GridSummaryColumn>[
                          GridSummaryColumn(name: 'JamaRsSum', columnName: 'Jama Rs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'OutAmtRsSum', columnName: 'Out AmtRs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'UdharRsSum', columnName: 'Udhar Rs', summaryType: GridSummaryType.sum),
                          GridSummaryColumn(name: 'AmtRsSum', columnName: 'Amt Rs', summaryType: GridSummaryType.sum),
                        ],
                        position: GridTableSummaryRowPosition.bottom,
                      )
                    ],
                    columnWidthMode: ColumnWidthMode.auto,
                    navigationMode: GridNavigationMode.cell,
                    frozenColumnsCount: 1,
                    rowHeight: 28,
                    headerRowHeight: 32,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    showSortNumbers: true,
                    allowFiltering: true,
                    allowColumnsResizing: true,
                    selectionMode: SelectionMode.single,
                    allowEditing: true,
                    editingGestureType: EditingGestureType.tap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge(String label, TextEditingController controller, Color color) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final val = controller.text.isEmpty ? '0.00' : controller.text;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Text('₹ $val', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          AppButton(
            text: 'Add',
            icon: Icons.add_rounded,
            onPressed: !_isEnabled ? () => _enableFields() : null,
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
            onPressed: _isEnabled ? _handleCancel : null,
          ),
          AppButton(
            text: 'Search',
            icon: Icons.search_rounded,
            variant: AppButtonVariant.outline,
            onPressed: () => setState(() => _isSearch = true),
          ),
          AppButton(
            text: 'Exit',
            icon: Icons.exit_to_app_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => tabController.closeCurrentTab(),
          ),
        ],
      ),
    );
  }

  // ==================== DATAGRID COLUMNS DEFINITIONS ====================

  List<GridColumn> _buildSearchGridColumns() {
    return <GridColumn>[
      GridColumn(
        columnName: 'Id',
        visible: false,
        label: _buildGridHeader('Id'),
      ),
      GridColumn(
        columnName: 'Date',
        label: _buildGridHeader('Date'),
      ),
      GridColumn(
        columnName: 'Day',
        label: _buildGridHeader('Day'),
      ),
      GridColumn(
        columnName: 'Cheque No.',
        label: _buildGridHeader('Cheque No.'),
      ),
      GridColumn(
        columnName: 'Party',
        label: _buildGridHeader('Party'),
      ),
      GridColumn(
        columnName: 'Account',
        label: _buildGridHeader('Account'),
      ),
      GridColumn(
        columnName: 'Rate Type',
        label: _buildGridHeader('Rate Type'),
      ),
      GridColumn(
        columnName: 'Jama AmtRs',
        label: _buildGridHeader('Jama AmtRs'),
      ),
      GridColumn(
        columnName: 'Udhar AmtRs',
        label: _buildGridHeader('Udhar AmtRs'),
      ),
      GridColumn(
        columnName: 'Remarks',
        label: _buildGridHeader('Remarks'),
      ),
      GridColumn(
        columnName: 'Acc. AmtRs',
        label: _buildGridHeader('Acc. AmtRs'),
      ),
    ];
  }

  List<GridColumn> _buildOutstandingGridColumns({bool isBook = true}) {
    final creditController = isBook ? bookCreditController : accountCreditController;
    final udharController = isBook ? bookUdharController : accountUdharController;

    return <GridColumn>[
      GridColumn(
        columnName: 'Id',
        allowEditing: false,
        visible: false,
        label: _buildGridHeader('Id'),
      ),
      GridColumn(
        columnName: 'Due Date',
        allowEditing: false,
        label: _buildGridHeader('Due Date'),
      ),
      GridColumn(
        columnName: 'Inv No',
        allowEditing: false,
        label: _buildGridHeader('Inv No'),
      ),
      GridColumn(
        columnName: 'Jama Rs',
        allowEditing: creditController.text.isNotEmpty,
        label: _buildGridHeader('Jama Rs'),
      ),
      GridColumn(
        columnName: 'Udhar Rs',
        allowEditing: udharController.text.isNotEmpty,
        label: _buildGridHeader('Udhar Rs'),
      ),
      GridColumn(
        columnName: 'Out AmtRs',
        allowEditing: false,
        label: _buildGridHeader('Out AmtRs'),
        width: 150
      ),
      GridColumn(
        columnName: 'Trn Type',
        allowEditing: false,
        label: _buildGridHeader('Trn Type'),
      ),
      GridColumn(
        columnName: 'TraType',
        allowEditing: false,
        label: _buildGridHeader('TraType'),
      ),
      GridColumn(
        columnName: 'Inv Date',
        allowEditing: false,
        label: _buildGridHeader('Inv Date'),
      ),
      GridColumn(
        columnName: 'Dr/Cr',
        allowEditing: false,
        label: _buildGridHeader('Dr/Cr'),
      ),
      GridColumn(
        columnName: 'Amt Rs',
        allowEditing: false,
        width: 150,
        label: _buildGridHeader('Amt Rs'),
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
