import 'package:flutter/gestures.dart';
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
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/memo%20issue/memo_issue_details_model.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_rec_details_model.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_rec_model.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_receive_datagrid.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';

class MemoRecFormScreen extends StatefulWidget {
  final bool showHeader;

  const MemoRecFormScreen({super.key, required this.showHeader});

  @override
  MemoRecFormScreenState createState() => MemoRecFormScreenState();
}

class MemoRecFormScreenState extends State<MemoRecFormScreen> {
  // Master Controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Search Filter Controllers
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Item Quick Entry Controllers
  final TextEditingController invNoItemController = TextEditingController();
  final TextEditingController pcsController = TextEditingController(text: '1');
  final TextEditingController wtController = TextEditingController(text: '0.000');
  final TextEditingController rateRsController = TextEditingController(text: '0.00');
  final TextEditingController amountRsController = TextEditingController(text: '0.00');
  final TextEditingController rateDollarController = TextEditingController(text: '0.00');
  final TextEditingController amountDollarController = TextEditingController(text: '0.00');
  final TextEditingController penWtController = TextEditingController(text: '0.000');

  // New Return-Specific Line Controllers (Editable)
  final TextEditingController recPcsController = TextEditingController(text: '1');
  final TextEditingController recWtController = TextEditingController(text: '0.000');
  final TextEditingController saleWtController = TextEditingController(text: '0.000');
  final TextEditingController outWtController = TextEditingController(text: '0.000');
  final TextEditingController lossWtController = TextEditingController(text: '0.000');
  final TextEditingController totalWtItemController = TextEditingController(text: '0.000');
  final TextEditingController descripController = TextEditingController();

  // Focus Nodes
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _fromManagerFocus = FocusNode();
  final FocusNode _brokerFocus = FocusNode();
  final FocusNode _entryFocus = FocusNode();
  final FocusNode _recPcsFocus = FocusNode();
  final FocusNode _recWtFocus = FocusNode();
  final FocusNode _saleWtFocus = FocusNode();
  final FocusNode _outWtFocus = FocusNode();
  final FocusNode _lossWtFocus = FocusNode();
  final FocusNode _searchKeyBoardFocus = FocusNode();

  final DataGridController _dataGridController = DataGridController();
  final ScrollController _itemsTableScrollController = ScrollController();

  // State Variables
  List<Map<String, dynamic>> recEntries = [];
  int? _editingEntryIndex;

  final Rxn<int> _selectedFromManagerId = Rxn<int>();
  final RxString _selectedTypeBroker = '22'.obs;
  final RxString _selectedTypeParty = ''.obs;
  final RxInt selectedMemoRecMstID = 0.obs;

  // Selected Entry Quick-Fill Observables
  final RxString _selectedEntryId = ''.obs;
  final RxString _selectedItemType = 'ROUGH'.obs;
  final RxString _selectedClarity = ''.obs;
  final RxString _selectedCharni = ''.obs;
  final RxString _selectedQuality = ''.obs;
  final RxString _selectedColor = ''.obs;
  final RxString _selectedShape = ''.obs;
  final RxString _selectedRoughTypeCode = '1'.obs;

  DateTime? selectedDate;
  DateTime? fromDate;
  DateTime? toDate;

  bool _isEnabled = false;
  bool _isSearch = false;
  bool _isFromEdit = false;
  final RxBool _isFiltered = false.obs;

  final DefaultController defaultController = Get.find<DefaultController>();
  final TabControllerX tabController = Get.find<TabControllerX>();

  RxList<MemoRecModel> memoRecDataGridSource = <MemoRecModel>[].obs;
  RxList<MemoRecModel> filteredDataGridSource = <MemoRecModel>[].obs;
  Worker? _listWorker;
  Worker? _userListWorker;

  // Calculation Getters
  int get totalPacket =>
      recEntries.fold(0, (prev, e) => prev + (int.tryParse(e['pcs']?.toString() ?? '0') ?? 0));

  double get totalWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['wt']?.toString() ?? '0') ?? 0.0));

  int get totalRecPcs =>
      recEntries.fold(0, (prev, e) => prev + (int.tryParse(e['recPcs']?.toString() ?? '0') ?? 0));

  double get totalRecWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['recWt']?.toString() ?? '0') ?? 0.0));

  double get totalSaleWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['saleWt']?.toString() ?? '0') ?? 0.0));

  double get totalOutWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['outWt']?.toString() ?? '0') ?? 0.0));

  double get totalLossWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['lossWt']?.toString() ?? '0') ?? 0.0));

  double get totalFinalWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['totalWt']?.toString() ?? '0') ?? 0.0));

  double get totalAmountRs =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['amountRs']?.toString() ?? '0') ?? 0.0));

  double get totalAmountDollar =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['amountDollar']?.toString() ?? '0') ?? 0.0));

  double get totalRecAmountRs =>
      recEntries.fold(0.0, (prev, e) {
        final rWt = double.tryParse(e['recWt']?.toString() ?? '0') ?? 0.0;
        final rate = double.tryParse(e['rateRs']?.toString() ?? '0') ?? 0.0;
        return prev + (rWt * rate);
      });

  double get totalRecAmountDollar =>
      recEntries.fold(0.0, (prev, e) {
        final rWt = double.tryParse(e['recWt']?.toString() ?? '0') ?? 0.0;
        final rateD = double.tryParse(e['rateDollar']?.toString() ?? '0') ?? 0.0;
        return prev + (rWt * rateD);
      });

  double get totalRateRs =>
      totalRecWt > 0 ? (totalRecAmountRs / totalRecWt) : 0.0;

  double get totalRateDollar =>
      totalRecWt > 0 ? (totalRecAmountDollar / totalRecWt) : 0.0;

  double get totalPenWt =>
      recEntries.fold(0.0, (prev, e) => prev + (double.tryParse(e['penWt']?.toString() ?? '0') ?? 0.0));

  // Role Checks
  bool get isCurrentUserTypeUser {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'USER' || !defaultController.isAdmin;
  }

  bool get _isFromManagerEnabled => !isCurrentUserTypeUser;

  List<UserModel> get fromManagerUsers {
    if (isCurrentUserTypeUser) {
      final currentUserId = defaultController.currentUserId.value;
      return defaultController.userModelList
          .where((u) => u.counterMstId == currentUserId)
          .toList();
    }
    final adminBranch = defaultController.effectiveBranchCode;
    if (adminBranch > 0) {
      final filtered = defaultController.userModelList
          .where((u) => u.branchCode == adminBranch)
          .toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return defaultController.userModelList;
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

  @override
  void initState() {
    super.initState();
    _addListeners();
    memoRecDataGridSource.value = defaultController.memoRecList;

    _listWorker = ever(defaultController.memoRecList, (list) {
      if (mounted) {
        memoRecDataGridSource.value = list;
        setState(() {});
      }
    });

    _userListWorker = ever(defaultController.userModelList, (_) {
      if (mounted) {
        _initFromManager();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMasterData();
      _initFromManager();
    });
  }

  void _addListeners() {
    recWtController.addListener(_calculateTotalWeight);
    saleWtController.addListener(_calculateTotalWeight);
    outWtController.addListener(_calculateTotalWeight);
    lossWtController.addListener(_calculateTotalWeight);
  }

  void _calculateTotalWeight() {
    final rec = double.tryParse(recWtController.text.trim()) ?? 0.0;
    final sale = double.tryParse(saleWtController.text.trim()) ?? 0.0;
    final out = double.tryParse(outWtController.text.trim()) ?? 0.0;
    final loss = double.tryParse(lossWtController.text.trim()) ?? 0.0;
    totalWtItemController.text = (rec + sale + out + loss).toStringAsFixed(3);
  }

  @override
  void dispose() {
    _listWorker?.dispose();
    _userListWorker?.dispose();
    recWtController.removeListener(_calculateTotalWeight);
    saleWtController.removeListener(_calculateTotalWeight);
    outWtController.removeListener(_calculateTotalWeight);
    lossWtController.removeListener(_calculateTotalWeight);

    idController.dispose();
    dateController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    invNoItemController.dispose();
    pcsController.dispose();
    wtController.dispose();
    rateRsController.dispose();
    amountRsController.dispose();
    rateDollarController.dispose();
    amountDollarController.dispose();
    penWtController.dispose();
    recPcsController.dispose();
    recWtController.dispose();
    saleWtController.dispose();
    outWtController.dispose();
    lossWtController.dispose();
    totalWtItemController.dispose();
    descripController.dispose();

    _dateFocus.dispose();
    _fromManagerFocus.dispose();
    _brokerFocus.dispose();
    _entryFocus.dispose();
    _recPcsFocus.dispose();
    _recWtFocus.dispose();
    _saleWtFocus.dispose();
    _outWtFocus.dispose();
    _lossWtFocus.dispose();
    _searchKeyBoardFocus.dispose();
    _itemsTableScrollController.dispose();
    super.dispose();
  }

  void _loadMasterData() {
    if (defaultController.memoRecList.isEmpty) {
      defaultController.getMemoRecData();
    }
    if (defaultController.memoRecDetailsList.isEmpty) {
      defaultController.getMemoRecDetailsData();
    }
    if (defaultController.memoIssueList.isEmpty) {
      defaultController.getMemoIssueData();
    }
    if (defaultController.memoIssueDetailsList.isEmpty) {
      defaultController.getMemoIssueDetailsData();
    }
    if (defaultController.partyMstList.isEmpty) {
      defaultController.getPartyData();
    }
    if (defaultController.roughModel.isEmpty) {
      defaultController.getRoughData();
    }
    if (defaultController.charniModelList.isEmpty) {
      defaultController.getCharniData();
    }
    if (defaultController.clarityModelList.isEmpty) {
      defaultController.getClarityData();
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
    if (defaultController.userModelList.isEmpty) {
      defaultController.getUserData();
    }
  }

  // ==================== DATE PICKER ====================

  Future<void> _openDatePicker() async {
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
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isFromManagerEnabled) {
          _fromManagerFocus.requestFocus();
        } else {
          _brokerFocus.requestFocus();
        }
      });
    }
  }

  // ==================== DROPDOWNS & ENTRIES LIST ====================

  List<DropdownMenuItem<int>> _buildFromManagerDropdownItems() {
    return fromManagerUsers.where((u) => u.counterMstId != null).map((u) {
      final name = (u.userName != null && u.userName!.trim().isNotEmpty)
          ? u.userName!.trim()
          : (u.loginName ?? 'User #${u.counterMstId}');
      return DropdownMenuItem<int>(
        value: u.counterMstId,
        child: Text(
          name,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
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
              u.loginName != name)
          ? 'Login: ${u.loginName}'
          : null;
      return AppDropdownItem<int>(
        value: u.counterMstId!,
        label: name,
        subtitle: subtitle,
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsBroker {
    final seen = <int>{};
    return defaultController.partyMstList
        .where((p) =>
            (p.typeCode == 5 || p.partyCode.toString() == _selectedTypeBroker.value) &&
            p.companyCode == defaultController.companyCode.value &&
            p.partyCode != null &&
            seen.add(p.partyCode!))
        .map((p) => DropdownMenuItem<String>(
              value: p.partyCode.toString(),
              child: Text(p.partyName ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            ))
        .toList();
  }

  // Pending memo issue details filtered as per selected From Manager
  List<MemoIssueDetailsModel> get pendingEntries {
    final mgrId = _selectedFromManagerId.value;
    if (mgrId == null) return [];

    var managerMemos = defaultController.memoIssueList
        .where((m) => m.logID == mgrId)
        .toList();

    // Defensive fallback if historical records have logID == 0 or null
    if (managerMemos.isEmpty && mgrId == defaultController.currentUserId.value) {
      managerMemos = defaultController.memoIssueList
          .where((m) => m.logID == null || m.logID == 0 || m.logID == mgrId)
          .toList();
    }

    final memoIds = managerMemos.map((m) => m.memoIssueMstID).toSet();

    return defaultController.memoIssueDetailsList.where((d) {
      if (!memoIds.contains(d.memoIssueMstID)) return false;

      // Check if already added to grid (allow currently editing item)
      final isAlreadyAdded = recEntries.any((e) => e['detId'] == d.memoIssueDetID?.toString());
      if (isAlreadyAdded && d.memoIssueDetID?.toString() != _selectedEntryId.value) {
        return false;
      }

      return d.rec == null || d.rec == 'N' || d.memoIssueDetID?.toString() == _selectedEntryId.value;
    }).toList();
  }

  List<DropdownMenuItem<String>> get dropdownItemsEntry {
    return pendingEntries.map((d) {
      final parentMemo = defaultController.memoIssueList.firstWhereOrNull(
          (m) => m.memoIssueMstID == d.memoIssueMstID);
      final memoNo = (parentMemo?.invoiceNo != null && parentMemo!.invoiceNo!.isNotEmpty)
          ? parentMemo.invoiceNo!
          : '${d.memoIssueMstID}';
      final roughName = getRoughName(d.roughTypeCode?.toString());
      final label = 'Memo #$memoNo - ${d.type ?? 'ROUGH'} - ${d.carats ?? 0} ct - ₹${d.rateRs ?? d.rateD ?? 0}';
      return DropdownMenuItem<String>(
        value: d.memoIssueDetID.toString(),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<AppDropdownItem<String>> get appDropdownItemsEntry {
    return pendingEntries.map((d) {
      final parentMemo = defaultController.memoIssueList.firstWhereOrNull(
          (m) => m.memoIssueMstID == d.memoIssueMstID);
      final memoNo = (parentMemo?.invoiceNo != null && parentMemo!.invoiceNo!.isNotEmpty)
          ? parentMemo.invoiceNo!
          : '${d.memoIssueMstID}';
      final partyName = getPartyName(parentMemo?.partyCode);
      return AppDropdownItem<String>(
        value: d.memoIssueDetID.toString(),
        label: 'Memo #$memoNo | ${d.type ?? 'ROUGH'} | Wt: ${d.carats ?? 0} Cts | ₹${d.rateRs ?? d.rateD ?? 0}',
        subtitle: 'Pcs: ${d.pcs ?? 1} | Inv: ${d.invNo ?? '-'} | Party: $partyName',
      );
    }).toList();
  }

  void _onEntrySelected(String detId) {
    setState(() {
      _selectedEntryId.value = detId;
      final detail = defaultController.memoIssueDetailsList.firstWhereOrNull(
          (d) => d.memoIssueDetID?.toString() == detId);
      if (detail == null) return;

      // Fill disabled fields directly from the selected Memo Issue entry
      _selectedItemType.value = detail.type ?? 'ROUGH';
      invNoItemController.text = detail.invNo ?? '';
      _selectedClarity.value = (detail.clarityCode != null && detail.clarityCode != 0)
          ? detail.clarityCode.toString()
          : '';
      _selectedCharni.value = (detail.charniCode != null && detail.charniCode != 0)
          ? detail.charniCode.toString()
          : '';
      _selectedQuality.value = (detail.qualityCode != null && detail.qualityCode != 0)
          ? detail.qualityCode.toString()
          : '';
      _selectedColor.value = (detail.colorCode != null && detail.colorCode != 0)
          ? detail.colorCode.toString()
          : '';
      _selectedShape.value = (detail.shapeCode != null && detail.shapeCode != 0)
          ? detail.shapeCode.toString()
          : '';
      _selectedRoughTypeCode.value = (detail.roughTypeCode ?? 1).toString();
      descripController.text = detail.description ?? '';

      final int pcs = detail.pcs ?? 1;
      final double carats = (detail.carats ?? 0.0).toDouble();
      final double rateRs = (detail.rateRs ?? 0.0).toDouble();
      final double amtRs = (detail.amountRs ?? (carats * rateRs)).toDouble();
      final double rateD = (detail.rateD ?? 0.0).toDouble();
      final double amtD = (detail.amountD ?? (carats * rateD)).toDouble();
      final double penCarats = (detail.penCarats ?? 0.0).toDouble();

      pcsController.text = pcs.toString();
      wtController.text = carats.toStringAsFixed(3);
      rateRsController.text = rateRs.toStringAsFixed(2);
      amountRsController.text = amtRs.toStringAsFixed(2);
      rateDollarController.text = rateD.toStringAsFixed(4);
      amountDollarController.text = amtD.toStringAsFixed(2);
      penWtController.text = penCarats.toStringAsFixed(3);

      // Set editable return fields default values
      recPcsController.text = pcs.toString();
      recWtController.text = carats.toStringAsFixed(3);
      saleWtController.text = '0.000';
      outWtController.text = '0.000';
      lossWtController.text = '0.000';
      totalWtItemController.text = carats.toStringAsFixed(3);

      // Auto-fill broker and party from parent memo if present
      final parentMemo = defaultController.memoIssueList.firstWhereOrNull(
          (m) => m.memoIssueMstID == detail.memoIssueMstID);
      if (parentMemo != null) {
        if (parentMemo.brokerCode != null && parentMemo.brokerCode! > 0) {
          _selectedTypeBroker.value = parentMemo.brokerCode.toString();
        }
        if (parentMemo.partyCode != null && parentMemo.partyCode! > 0) {
          _selectedTypeParty.value = parentMemo.partyCode.toString();
        }
      }
    });

    // Move cursor straight to first editable field: Rec Pcs
    Future.delayed(const Duration(milliseconds: 50), () {
      _recPcsFocus.requestFocus();
    });
  }

  // ==================== FORM ACTIONS ====================

  void _enableFields([bool? needFocus]) {
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      _editingEntryIndex = null;
      selectedMemoRecMstID.value = 0;
      idController.clear();
      recEntries.clear();
      selectedDate = DateTime.now();
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      _initFromManager();
      _clearEntryInputs();
    });

    if (needFocus == null || needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isFromManagerEnabled) {
          _fromManagerFocus.requestFocus();
        } else {
          _brokerFocus.requestFocus();
        }
      });
    }
  }

  void _clearEntryInputs() {
    _editingEntryIndex = null;
    _selectedEntryId.value = '';
    _selectedItemType.value = 'ROUGH';
    invNoItemController.clear();
    _selectedClarity.value = '';
    _selectedCharni.value = '';
    _selectedQuality.value = '';
    _selectedColor.value = '';
    _selectedShape.value = '';
    _selectedRoughTypeCode.value = '1';
    descripController.clear();

    pcsController.text = '1';
    wtController.text = '0.000';
    rateRsController.text = '0.00';
    amountRsController.text = '0.00';
    rateDollarController.text = '0.00';
    amountDollarController.text = '0.00';
    penWtController.text = '0.000';

    recPcsController.text = '1';
    recWtController.text = '0.000';
    saleWtController.text = '0.000';
    outWtController.text = '0.000';
    lossWtController.text = '0.000';
    totalWtItemController.text = '0.000';
  }

  void _addOrUpdateEntry() {
    if (_selectedEntryId.value.isEmpty) {
      infoDialog(messageText: 'Please select an Entry from the dropdown.');
      _entryFocus.requestFocus();
      return;
    }

    final double recWt = double.tryParse(recWtController.text.trim()) ?? 0.0;
    final double saleWt = double.tryParse(saleWtController.text.trim()) ?? 0.0;
    final double outWt = double.tryParse(outWtController.text.trim()) ?? 0.0;
    final double lossWt = double.tryParse(lossWtController.text.trim()) ?? 0.0;
    final double totalWt = recWt + saleWt + outWt + lossWt;

    if (totalWt <= 0 && recWt <= 0) {
      infoDialog(messageText: 'Please enter valid Return Weights.');
      _recWtFocus.requestFocus();
      return;
    }

    final double rateRs = double.tryParse(rateRsController.text.trim()) ?? 0.0;
    final double rateD = double.tryParse(rateDollarController.text.trim()) ?? 0.0;

    final entryData = {
      'detId': _selectedEntryId.value,
      'type': _selectedItemType.value,
      'invNo': invNoItemController.text.trim(),
      'quality': _selectedQuality.value,
      'shape': _selectedShape.value,
      'color': _selectedColor.value,
      'clarity': _selectedClarity.value,
      'charni': _selectedCharni.value,
      'pcs': pcsController.text.trim(),
      'wt': wtController.text.trim(),
      'rateRs': rateRsController.text.trim(),
      'amountRs': amountRsController.text.trim(),
      'rateDollar': rateDollarController.text.trim(),
      'amountDollar': amountDollarController.text.trim(),
      'penWt': penWtController.text.trim(),
      'recPcs': recPcsController.text.trim(),
      'recWt': recWt.toStringAsFixed(3),
      'saleWt': saleWt.toStringAsFixed(3),
      'outWt': outWt.toStringAsFixed(3),
      'lossWt': lossWt.toStringAsFixed(3),
      'totalWt': totalWt.toStringAsFixed(3),
      'rate': rateRs.toStringAsFixed(2),
      'amount': (recWt * rateRs).toStringAsFixed(2),
      'rough': _selectedRoughTypeCode.value.isNotEmpty ? _selectedRoughTypeCode.value : '1',
      'description': descripController.text.trim(),
    };

    setState(() {
      if (_editingEntryIndex != null && _editingEntryIndex! < recEntries.length) {
        recEntries[_editingEntryIndex!] = entryData;
        _editingEntryIndex = null;
      } else {
        recEntries.add(entryData);
      }
      _clearEntryInputs();
    });

    _entryFocus.requestFocus();
  }

  void _editEntry(int index) {
    if (!_isEnabled) return;
    final entry = recEntries[index];
    setState(() {
      _editingEntryIndex = index;
      _selectedEntryId.value = entry['detId']?.toString() ?? '';
      _selectedItemType.value = entry['type']?.toString() ?? 'ROUGH';
      invNoItemController.text = entry['invNo']?.toString() ?? '';
      _selectedQuality.value = entry['quality']?.toString() ?? '';
      _selectedShape.value = entry['shape']?.toString() ?? '';
      _selectedColor.value = entry['color']?.toString() ?? '';
      _selectedClarity.value = entry['clarity']?.toString() ?? '';
      _selectedCharni.value = entry['charni']?.toString() ?? '';
      _selectedRoughTypeCode.value = entry['rough']?.toString() ?? '1';
      descripController.text = entry['description']?.toString() ?? '';

      pcsController.text = entry['pcs']?.toString() ?? '1';
      wtController.text = entry['wt']?.toString() ?? '0.000';
      rateRsController.text = entry['rateRs']?.toString() ?? entry['rate']?.toString() ?? '0.00';
      amountRsController.text = entry['amountRs']?.toString() ?? entry['amount']?.toString() ?? '0.00';
      rateDollarController.text = entry['rateDollar']?.toString() ?? '0.00';
      amountDollarController.text = entry['amountDollar']?.toString() ?? '0.00';
      penWtController.text = entry['penWt']?.toString() ?? '0.000';

      recPcsController.text = entry['recPcs']?.toString() ?? '1';
      recWtController.text = entry['recWt']?.toString() ?? '0.000';
      saleWtController.text = entry['saleWt']?.toString() ?? '0.000';
      outWtController.text = entry['outWt']?.toString() ?? '0.000';
      lossWtController.text = entry['lossWt']?.toString() ?? '0.000';
      totalWtItemController.text = entry['totalWt']?.toString() ?? '0.000';
    });

    _recPcsFocus.requestFocus();
  }

  Future<void> _deleteEntry(int index) async {
    if (!_isEnabled) return;
    final entry = recEntries[index];
    if (_isFromEdit && entry.containsKey('id') && entry['id'] != null) {
      if (recEntries.length == 1) {
        infoDialog(messageText: 'Cannot delete the only remaining return entry.');
        return;
      }
      final detId = int.tryParse(entry['detId']?.toString() ?? '') ?? 0;
      final id = int.tryParse(entry['id']?.toString() ?? '') ?? 0;
      await defaultController.deleteMemoRecRoughData(detId: detId, id: id);
    }

    setState(() {
      recEntries.removeAt(index);
      if (_editingEntryIndex == index) {
        _clearEntryInputs();
      } else if (_editingEntryIndex != null && _editingEntryIndex! > index) {
        _editingEntryIndex = _editingEntryIndex! - 1;
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_isEnabled) return;

    if (recEntries.isEmpty) {
      infoDialog(messageText: 'Please add at least one return entry.');
      _entryFocus.requestFocus();
      return;
    }

    final int? fromUserId = _selectedFromManagerId.value;
    final String party = _selectedTypeParty.value.isNotEmpty ? _selectedTypeParty.value : '1';

    if (_isFromEdit) {
      await defaultController.updateMemoRecData(
        id: selectedMemoRecMstID.value,
        partyCode: party,
        invoiceDate: selectedDate ?? DateTime.now(),
        brokerCode: _selectedTypeBroker.value,
        fromUserId: fromUserId,
        entries: recEntries,
        totalAmt: totalRecAmountRs,
        totalWt: totalRecWt,
        totalRate: totalRateRs,
        printInvoice: false,
      );
      _handleCancel();
    } else {
      await defaultController.addMemoRecData(
        partyCode: party,
        invoiceDate: selectedDate ?? DateTime.now(),
        brokerCode: _selectedTypeBroker.value,
        fromUserId: fromUserId,
        entries: recEntries,
        totalAmt: totalRecAmountRs,
        totalWt: totalWt,
        totalRecWt: totalRecWt,
        totalRecAmount: totalRecAmountRs,
        totalLossWt: totalLossWt,
        totalRate: totalRateRs,
        printInvoice: false,
      );
      _handleCancel();
    }
  }

  Future<void> _handleDelete() async {
    if (!_isEnabled || !_isFromEdit) {
      infoDialog(messageText: 'Please select a memo return entry to delete.');
      return;
    }

    await defaultController.deleteMemoRecData(
      id: selectedMemoRecMstID.value,
      entries: recEntries.map((e) => e.map((k, v) => MapEntry(k, v?.toString() ?? ''))).toList(),
    );
    _handleCancel();
  }

  void _handleCancel() {
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      _isSearch = false;
      _editingEntryIndex = null;
      selectedMemoRecMstID.value = 0;
      idController.clear();
      dateController.clear();
      _selectedTypeBroker.value = '22';
      _selectedTypeParty.value = '';
      recEntries.clear();
      _clearEntryInputs();
    });
  }

  void _selectMemoById(int id) {
    selectedMemoRecMstID.value = id;

    final MemoRecModel partyEntry = defaultController.memoRecList.firstWhere(
      (entry) => entry.memoRecMstID == id,
    );

    final List<MemoRecDetailsModel> roughEntries = defaultController.memoRecDetailsList
        .where((entry) => entry.memoRecMstID == id)
        .toList();

    selectedDate = dateFormat(partyEntry.invoiceDate!);
    dateController.text = formatDate(partyEntry.invoiceDate!);
    idController.text = id.toString();
    _selectedTypeParty.value = partyEntry.partyCode?.toString() ?? '';
    _selectedTypeBroker.value = (partyEntry.brokerCode ?? 22).toString();
    if (partyEntry.logID != null && partyEntry.logID! > 0) {
      _selectedFromManagerId.value = partyEntry.logID;
    }

    recEntries.clear();
    for (var roughEntry in roughEntries) {
      final double carats = (roughEntry.carats ?? 0.0).toDouble();
      final double recCarats = (roughEntry.recCarats ?? carats).toDouble();
      final double saleCarats = (roughEntry.saleCarats ?? 0.0).toDouble();
      final double outCarats = (roughEntry.outCarats ?? 0.0).toDouble();
      final double lossCarats = (roughEntry.lossCarats ?? 0.0).toDouble();
      final double totalCarats = (roughEntry.totalCarats ?? (recCarats + saleCarats + outCarats + lossCarats)).toDouble();
      final double rateRs = (roughEntry.rateRs ?? 0.0).toDouble();
      final double amtRs = (roughEntry.amountRs ?? (recCarats * rateRs)).toDouble();
      final double rateD = (roughEntry.rateD ?? 0.0).toDouble();
      final double amtD = (roughEntry.amountD ?? (recCarats * rateD)).toDouble();

      recEntries.add({
        'id': roughEntry.memoRecDetID?.toString() ?? '',
        'detId': roughEntry.memoIssueDetID?.toString() ?? '',
        'type': roughEntry.type ?? 'ROUGH',
        'invNo': roughEntry.invNo ?? '',
        'quality': roughEntry.qualityCode?.toString() ?? '',
        'shape': roughEntry.shapeCode?.toString() ?? '',
        'color': roughEntry.colorCode?.toString() ?? '',
        'clarity': roughEntry.clarityCode?.toString() ?? '',
        'charni': roughEntry.charniCode?.toString() ?? '',
        'pcs': (roughEntry.pcs ?? 1).toString(),
        'wt': carats.toStringAsFixed(3),
        'rateRs': rateRs.toStringAsFixed(2),
        'amountRs': amtRs.toStringAsFixed(2),
        'rateDollar': rateD.toStringAsFixed(4),
        'amountDollar': amtD.toStringAsFixed(2),
        'penWt': (roughEntry.penCarats ?? 0.0).toString(),
        'recPcs': (roughEntry.recPcs ?? roughEntry.pcs ?? 1).toString(),
        'recWt': recCarats.toStringAsFixed(3),
        'saleWt': saleCarats.toStringAsFixed(3),
        'outWt': outCarats.toStringAsFixed(3),
        'lossWt': lossCarats.toStringAsFixed(3),
        'totalWt': totalCarats.toStringAsFixed(3),
        'rate': rateRs.toStringAsFixed(2),
        'amount': amtRs.toStringAsFixed(2),
        'rough': (roughEntry.roughTypeCode ?? 1).toString(),
        'description': roughEntry.description ?? '',
      });
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
      filteredDataGridSource.value = defaultController.memoRecList.where((memo) {
        if (memo.invoiceDate == null) return false;
        final invoiceDate = DateTime.parse(memo.invoiceDate!);
        return invoiceDate.isAfter(fromDate!) &&
            invoiceDate.isBefore(toDate!.add(const Duration(days: 1)));
      }).toList();
      memoRecDataGridSource.value = filteredDataGridSource;
      _searchKeyBoardFocus.requestFocus();
    } else {
      infoDialog(messageText: 'Please select both From Date and To Date');
    }
  }

  void _removeDateFilter() {
    memoRecDataGridSource.value = defaultController.memoRecList;
    toDateController.clear();
    fromDateController.clear();
    fromDate = null;
    toDate = null;
    _isFiltered.value = false;
  }

  // ==================== MAIN BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isSearch) {
        return _buildSearchView();
      }

      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: _isEnabled ? _handleCancel : null,
        onSearch: () => setState(() => _isSearch = true),
        onExit: () => tabController.closeCurrentTab(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isMobile(context) ? 8 : 16,
              vertical: Responsive.isMobile(context) ? 8 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showHeader) ...[
                  const Header(title: 'Memo Return Entry'),
                  const SizedBox(height: 12),
                ],

                // Card 1: Memo Return Information (Header)
                _buildHeaderCard(),
                const SizedBox(height: 12),

                // Card 2: Item Quick Entry Bar (Single Row)
                _buildQuickEntryCard(),
                const SizedBox(height: 12),

                // Card 3: Memo Return Items Table (Grid)
                _buildItemsTableCard(),
                const SizedBox(height: 12),

                // Card 4: Summary Stat Boxes
                _buildSummaryBoxesCard(),
                const SizedBox(height: 16),

                // Bottom Action Bar (No Print Button)
                _buildBottomActionBar(),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ==================== CARD 1: MEMO RETURN INFORMATION ====================

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
                Icon(Icons.assignment_return_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'MEMO RETURN INFORMATION',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5),
                ),
                if (_isFromEdit) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Editing Return #${selectedMemoRecMstID.value}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final idField = AppTextField(
                  label: 'ID :',
                  controller: idController,
                  enabled: false,
                  prefixIcon: const Icon(Icons.tag_rounded, size: 16),
                );

                final dateField = Focus(
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
                    label: 'Date :',
                    controller: dateController,
                    focusNode: _dateFocus,
                    nextFocusNode: _isFromManagerEnabled ? _fromManagerFocus : _brokerFocus,
                    onFieldSubmitted: (_) {
                      if (_isFromManagerEnabled) {
                        _fromManagerFocus.requestFocus();
                      } else {
                        _brokerFocus.requestFocus();
                      }
                    },
                    enabled: _isEnabled && !_isFromEdit,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                    onTap: (_isEnabled && !_isFromEdit) ? _openDatePicker : null,
                  ),
                );

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
                      _clearEntryInputs();
                    },
                  ),
                );

                final brokerField = Obx(
                  () => AppDropdown<String>(
                    label: 'Broker :',
                    value: _selectedTypeBroker.value.isEmpty ? null : _selectedTypeBroker.value,
                    items: dropdownItemsBroker,
                    focusNode: _brokerFocus,
                    nextFocusNode: _entryFocus,
                    hintText: 'Select Broker',
                    isEnabled: _isEnabled && !_isFromEdit,
                    prefixIcon: const Icon(Icons.handshake_rounded, size: 16),
                    onChanged: (val) {
                      if (val != null) {
                        _selectedTypeBroker.value = val;
                      }
                    },
                  ),
                );

                if (constraints.maxWidth >= 950) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: idField),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: dateField),
                      const SizedBox(width: 10),
                      Expanded(flex: 4, child: fromManagerField),
                      const SizedBox(width: 10),
                      Expanded(flex: 4, child: brokerField),
                    ],
                  );
                } else if (constraints.maxWidth >= 600) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: idField),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: dateField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: fromManagerField),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: brokerField),
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
                      fromManagerField,
                      const SizedBox(height: 10),
                      brokerField,
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

  // ==================== CARD 2: ITEM QUICK ENTRY BAR (SINGLE ROW) ====================

  Widget _buildQuickEntryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'ITEM QUICK ENTRY',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Entry in Row 1 to auto-populate specs, then enter Return Weights in Row 2 and press Enter to add',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                // 1. Entry Dropdown (Auto-fills next fields from selected From Manager's Memo Issue items)
                final entryDropdown = Obx(
                  () => AppDropdown<String>(
                    label: 'Entry * :',
                    value: _selectedEntryId.value.isEmpty ? null : _selectedEntryId.value,
                    items: dropdownItemsEntry,
                    dropdownItems: appDropdownItemsEntry,
                    focusNode: _entryFocus,
                    nextFocusNode: _recPcsFocus,
                    hintText: 'Select Entry',
                    searchHint: 'Search memo items...',
                    isEnabled: _isEnabled,
                    prefixIcon: const Icon(Icons.assignment_outlined, size: 15),
                    onChanged: (val) {
                      if (val != null) {
                        _onEntrySelected(val);
                      }
                    },
                  ),
                );

                // 2. Type (Disabled)
                final typeField = Obx(
                  () => AppTextField(
                    label: 'Type :',
                    controller: TextEditingController(text: _selectedItemType.value),
                    enabled: false,
                  ),
                );

                // 3. Invoice No (Disabled)
                final invoiceField = AppTextField(
                  label: 'Invoice :',
                  controller: invNoItemController,
                  enabled: false,
                );

                // 4. Clarity (Disabled)
                final clarityField = Obx(
                  () => AppTextField(
                    label: 'Clarity :',
                    controller: TextEditingController(
                        text: _selectedClarity.value.isNotEmpty ? getClarityName(_selectedClarity.value) : '-'),
                    enabled: false,
                  ),
                );

                // 5. Charni (Disabled)
                final charniField = Obx(
                  () => AppTextField(
                    label: 'Charni (+/-) :',
                    controller: TextEditingController(
                        text: _selectedCharni.value.isNotEmpty ? getCharniName(_selectedCharni.value) : '-'),
                    enabled: false,
                  ),
                );

                // 6. Quality (Disabled)
                final qualityField = Obx(
                  () => AppTextField(
                    label: 'Quality :',
                    controller: TextEditingController(
                        text: _selectedQuality.value.isNotEmpty ? getQualityName(_selectedQuality.value) : '-'),
                    enabled: false,
                  ),
                );

                // 7. Color (Disabled)
                final colorField = Obx(
                  () => AppTextField(
                    label: 'Color :',
                    controller: TextEditingController(
                        text: _selectedColor.value.isNotEmpty ? getColorName(_selectedColor.value) : '-'),
                    enabled: false,
                  ),
                );

                // 8. Shape (Disabled)
                final shapeField = Obx(
                  () => AppTextField(
                    label: 'Shape :',
                    controller: TextEditingController(
                        text: _selectedShape.value.isNotEmpty ? getShapeName(_selectedShape.value) : '-'),
                    enabled: false,
                  ),
                );

                // 9. Issued Pcs (Disabled)
                final pcsField = AppTextField(
                  label: 'Pc :',
                  controller: pcsController,
                  enabled: false,
                );

                // 10. Issued Wt (Disabled)
                final wtField = AppTextField(
                  label: 'Wt :',
                  controller: wtController,
                  enabled: false,
                );

                // 11. Rate Rs (Disabled)
                final rateRsField = AppTextField(
                  label: 'Rate (₹) :',
                  controller: rateRsController,
                  enabled: false,
                );

                // 12. Amount Rs (Disabled)
                final amountRsField = AppTextField(
                  label: 'Amount (₹) :',
                  controller: amountRsController,
                  enabled: false,
                );

                // 13. Rate Dollar (Disabled)
                final rateDollarField = AppTextField(
                  label: 'Rate (\$) :',
                  controller: rateDollarController,
                  enabled: false,
                );

                // 14. Amount Dollar (Disabled)
                final amountDollarField = AppTextField(
                  label: 'Amount (\$) :',
                  controller: amountDollarController,
                  enabled: false,
                );

                // 15. Pen Wt (Disabled)
                final penWtField = AppTextField(
                  label: 'Pen Wt :',
                  controller: penWtController,
                  enabled: false,
                );

                // 16. Rec Pcs (Editable)
                final recPcsField = AppTextField(
                  label: 'Rec Pcs * :',
                  controller: recPcsController,
                  focusNode: _recPcsFocus,
                  nextFocusNode: _recWtFocus,
                  onFieldSubmitted: (_) => _recWtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                );

                // 17. Rec Wt (Editable)
                final recWtField = AppTextField(
                  label: 'Rec Wt * :',
                  controller: recWtController,
                  focusNode: _recWtFocus,
                  nextFocusNode: _saleWtFocus,
                  onFieldSubmitted: (_) => _saleWtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 18. Sale Wt (Editable)
                final saleWtField = AppTextField(
                  label: 'Sale Wt :',
                  controller: saleWtController,
                  focusNode: _saleWtFocus,
                  nextFocusNode: _outWtFocus,
                  onFieldSubmitted: (_) => _outWtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 19. Out Wt (Editable)
                final outWtField = AppTextField(
                  label: 'Out Wt :',
                  controller: outWtController,
                  focusNode: _outWtFocus,
                  nextFocusNode: _lossWtFocus,
                  onFieldSubmitted: (_) => _lossWtFocus.requestFocus(),
                  enabled: _isEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 20. Loss Wt (Editable)
                final lossWtField = AppTextField(
                  label: 'Loss Wt :',
                  controller: lossWtController,
                  focusNode: _lossWtFocus,
                  onFieldSubmitted: (_) => _addOrUpdateEntry(),
                  enabled: _isEnabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                  ],
                );

                // 21. Total Wt (Disabled, Calculated)
                final totalWtField = AppTextField(
                  label: 'Total Wt :',
                  controller: totalWtItemController,
                  enabled: false,
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
                      onPressed: _isEnabled
                          ? _addOrUpdateEntry
                          : null,
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
                          _entryFocus.requestFocus();
                        },
                      ),
                    ],
                  ],
                );

                // Display in 2 structured rows
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Item Identification & Specs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 200, child: entryDropdown),
                          const SizedBox(width: 8),
                          SizedBox(width: 100, child: typeField),
                          const SizedBox(width: 8),
                          SizedBox(width: 95, child: invoiceField),
                          const SizedBox(width: 8),
                          SizedBox(width: 95, child: clarityField),
                          const SizedBox(width: 8),
                          SizedBox(width: 95, child: charniField),
                          const SizedBox(width: 8),
                          SizedBox(width: 95, child: qualityField),
                          const SizedBox(width: 8),
                          SizedBox(width: 90, child: colorField),
                          const SizedBox(width: 8),
                          SizedBox(width: 95, child: shapeField),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Row 2: Quantities, Rates, Return Weights & Action Buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 60, child: pcsField),
                          const SizedBox(width: 6),
                          SizedBox(width: 75, child: wtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: rateRsField),
                          const SizedBox(width: 6),
                          SizedBox(width: 90, child: amountRsField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: rateDollarField),
                          const SizedBox(width: 6),
                          SizedBox(width: 90, child: amountDollarField),
                          const SizedBox(width: 6),
                          SizedBox(width: 75, child: penWtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 75, child: recPcsField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: recWtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: saleWtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: outWtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: lossWtField),
                          const SizedBox(width: 6),
                          SizedBox(width: 85, child: totalWtField),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: actionButtons,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CARD 3: ITEMS TABLE CARD ====================

  Widget _buildItemsTableCard() {
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
            Row(
              children: [
                Icon(Icons.format_list_bulleted_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'MEMO RETURN ITEMS LIST (${recEntries.length})',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (recEntries.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '23 Columns (Horizontal Scroll)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      if (_itemsTableScrollController.hasClients) {
                        _itemsTableScrollController.animateTo(
                          (_itemsTableScrollController.offset - 350).clamp(0.0, _itemsTableScrollController.position.maxScrollExtent),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      if (_itemsTableScrollController.hasClients) {
                        _itemsTableScrollController.animateTo(
                          (_itemsTableScrollController.offset + 350).clamp(0.0, _itemsTableScrollController.position.maxScrollExtent),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            if (recEntries.isEmpty)
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
                    Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.textMuted),
                    const SizedBox(height: 6),
                    Text('No return items added yet',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('Select an Entry from dropdown, enter Rec Wt / Sale Wt / Loss Wt, and press Enter to add',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const double minTableWidth = 2080.0;
                  final double tableWidth = constraints.maxWidth > minTableWidth
                      ? constraints.maxWidth
                      : minTableWidth;

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                      },
                    ),
                    child: Scrollbar(
                      controller: _itemsTableScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      thickness: 10,
                      radius: const Radius.circular(5),
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _itemsTableScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: tableWidth,
                            child: Table(
                              border: TableBorder.all(color: AppColors.border, width: 1),
                              columnWidths: const {
                                0: FixedColumnWidth(50),   // Srno
                                1: FixedColumnWidth(110),  // Entry / DetId
                                2: FixedColumnWidth(95),   // Type
                                3: FixedColumnWidth(90),   // InvNo
                                4: FixedColumnWidth(90),   // Clarity
                                5: FixedColumnWidth(90),   // Charni
                                6: FixedColumnWidth(90),   // Quality
                                7: FixedColumnWidth(85),   // Color
                                8: FixedColumnWidth(90),   // Shape
                                9: FixedColumnWidth(55),   // Pc
                                10: FixedColumnWidth(85),  // Wt
                                11: FixedColumnWidth(95),  // Rate Rs
                                12: FixedColumnWidth(115), // Amount Rs
                                13: FixedColumnWidth(95),  // Rate Dollar
                                14: FixedColumnWidth(115), // Amount Dollar
                                15: FixedColumnWidth(85),  // Pen Wt
                                16: FixedColumnWidth(75),  // Rec Pcs
                                17: FixedColumnWidth(90),  // Rec Wt
                                18: FixedColumnWidth(90),  // Sale Wt
                                19: FixedColumnWidth(90),  // Out Wt
                                20: FixedColumnWidth(90),  // Loss Wt
                                21: FixedColumnWidth(95),  // Total Wt
                                22: FixedColumnWidth(85),  // Actions
                              },
                              children: [
                                // Table Header
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  children: [
                                    _buildTableHeaderCell('Srno', align: TextAlign.center),
                                    _buildTableHeaderCell('Entry'),
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
                                    _buildTableHeaderCell('Pen Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Rec Pc', align: TextAlign.right),
                                    _buildTableHeaderCell('Rec Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Sale Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Out Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Loss Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Total Wt', align: TextAlign.right),
                                    _buildTableHeaderCell('Actions', align: TextAlign.center),
                                  ],
                                ),
                                // Data Rows
                                for (int i = 0; i < recEntries.length; i++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: _editingEntryIndex == i
                                          ? AppColors.primary.withValues(alpha: 0.12)
                                          : (i % 2 == 0 ? AppColors.surface : AppColors.tableRowAlt),
                                    ),
                                    children: [
                                      _buildTableCell('${i + 1}', align: TextAlign.center),
                                      _buildTableCell('#${recEntries[i]['detId'] ?? '-'}'),
                                      _buildTableCell(recEntries[i]['type']?.toString() ?? 'ROUGH'),
                                      _buildTableCell((recEntries[i]['invNo']?.toString().isNotEmpty ?? false)
                                          ? recEntries[i]['invNo'].toString()
                                          : '-'),
                                      _buildTableCell((recEntries[i]['clarity'] != null &&
                                              recEntries[i]['clarity'].toString().isNotEmpty)
                                          ? getClarityName(recEntries[i]['clarity'])
                                          : '-'),
                                      _buildTableCell((recEntries[i]['charni'] != null &&
                                              recEntries[i]['charni'].toString().isNotEmpty)
                                          ? getCharniName(recEntries[i]['charni'])
                                          : '-'),
                                      _buildTableCell((recEntries[i]['quality'] != null &&
                                              recEntries[i]['quality'].toString().isNotEmpty)
                                          ? getQualityName(recEntries[i]['quality'])
                                          : '-'),
                                      _buildTableCell((recEntries[i]['color'] != null &&
                                              recEntries[i]['color'].toString().isNotEmpty)
                                          ? getColorName(recEntries[i]['color'])
                                          : '-'),
                                      _buildTableCell((recEntries[i]['shape'] != null &&
                                              recEntries[i]['shape'].toString().isNotEmpty)
                                          ? getShapeName(recEntries[i]['shape'])
                                          : '-'),
                                      _buildTableCell(recEntries[i]['pcs']?.toString() ?? '1',
                                          align: TextAlign.right),
                                      _buildTableCell(recEntries[i]['wt']?.toString() ?? '0.000',
                                          align: TextAlign.right),
                                      _buildTableCell('₹ ${recEntries[i]['rateRs'] ?? recEntries[i]['rate'] ?? '0.00'}',
                                          align: TextAlign.right),
                                      _buildTableCell('₹ ${recEntries[i]['amountRs'] ?? recEntries[i]['amount'] ?? '0.00'}',
                                          align: TextAlign.right, isBold: true),
                                      _buildTableCell('\$ ${recEntries[i]['rateDollar'] ?? '0.00'}',
                                          align: TextAlign.right),
                                      _buildTableCell('\$ ${recEntries[i]['amountDollar'] ?? '0.00'}',
                                          align: TextAlign.right, isBold: true),
                                      _buildTableCell(recEntries[i]['penWt']?.toString() ?? '0.000',
                                          align: TextAlign.right),
                                      _buildTableCell(recEntries[i]['recPcs']?.toString() ?? '1',
                                          align: TextAlign.right, isBold: true, color: AppColors.primary),
                                      _buildTableCell(recEntries[i]['recWt']?.toString() ?? '0.000',
                                          align: TextAlign.right, isBold: true, color: AppColors.primary),
                                      _buildTableCell(recEntries[i]['saleWt']?.toString() ?? '0.000',
                                          align: TextAlign.right),
                                      _buildTableCell(recEntries[i]['outWt']?.toString() ?? '0.000',
                                          align: TextAlign.right),
                                      _buildTableCell(recEntries[i]['lossWt']?.toString() ?? '0.000',
                                          align: TextAlign.right,
                                          color: (double.tryParse(recEntries[i]['lossWt']?.toString() ?? '0') ?? 0) > 0
                                              ? AppColors.warning
                                              : null),
                                      _buildTableCell(recEntries[i]['totalWt']?.toString() ?? '0.000',
                                          align: TextAlign.right, isBold: true),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () => _editEntry(i),
                                                borderRadius: BorderRadius.circular(4),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Icon(
                                                    _editingEntryIndex == i
                                                        ? Icons.edit_rounded
                                                        : Icons.edit_outlined,
                                                    size: 15,
                                                    color: _editingEntryIndex == i
                                                        ? AppColors.warning
                                                        : AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              InkWell(
                                                onTap: () => _deleteEntry(i),
                                                borderRadius: BorderRadius.circular(4),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Icon(Icons.delete_outline_rounded,
                                                      size: 15, color: AppColors.danger),
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
                                    _buildTableCell('', isBold: true),
                                    _buildTableCell('$totalPacket', align: TextAlign.right, isBold: true),
                                    _buildTableCell(totalWt.toStringAsFixed(3), align: TextAlign.right, isBold: true),
                                    _buildTableCell('₹ ${totalRateRs.toStringAsFixed(2)}', align: TextAlign.right, isBold: true),
                                    _buildTableCell('₹ ${totalAmountRs.toStringAsFixed(2)}', align: TextAlign.right, isBold: true, color: AppColors.primary),
                                    _buildTableCell('\$ ${totalRateDollar.toStringAsFixed(4)}', align: TextAlign.right, isBold: true),
                                    _buildTableCell('\$ ${totalAmountDollar.toStringAsFixed(2)}', align: TextAlign.right, isBold: true, color: AppColors.primary),
                                    _buildTableCell(totalPenWt.toStringAsFixed(3), align: TextAlign.right, isBold: true),
                                    _buildTableCell('$totalRecPcs', align: TextAlign.right, isBold: true, color: AppColors.primary),
                                    _buildTableCell(totalRecWt.toStringAsFixed(3), align: TextAlign.right, isBold: true, color: AppColors.primary),
                                    _buildTableCell(totalSaleWt.toStringAsFixed(3), align: TextAlign.right, isBold: true),
                                    _buildTableCell(totalOutWt.toStringAsFixed(3), align: TextAlign.right, isBold: true),
                                    _buildTableCell(totalLossWt.toStringAsFixed(3), align: TextAlign.right, isBold: true, color: totalLossWt > 0 ? AppColors.warning : null),
                                    _buildTableCell(totalFinalWt.toStringAsFixed(3), align: TextAlign.right, isBold: true),
                                    _buildTableCell(''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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

  // ==================== CARD 4: SUMMARY STAT BOXES ====================

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
            final issWtBox = _buildStatField('Iss Wt', totalWt.toStringAsFixed(3));
            final recPcsBox = _buildStatField('Rec Pcs', '$totalRecPcs');
            final recWtBox = _buildStatField('Rec Wt', totalRecWt.toStringAsFixed(3));
            final saleWtBox = _buildStatField('Sale Wt', totalSaleWt.toStringAsFixed(3));
            final outWtBox = _buildStatField('Out Wt', totalOutWt.toStringAsFixed(3));
            final lossWtBox = _buildStatField('Loss Wt', totalLossWt.toStringAsFixed(3));
            final totalWtBox = _buildStatField('Total Wt', totalFinalWt.toStringAsFixed(3));
            final amtRsBox = _buildStatField('Amount (Rs)', '₹ ${totalRecAmountRs.toStringAsFixed(2)}');
            final amtDBox = _buildStatField('Amount (\$)', '\$ ${totalRecAmountDollar.toStringAsFixed(2)}');

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                packetBox,
                issWtBox,
                recPcsBox,
                recWtBox,
                saleWtBox,
                outWtBox,
                lossWtBox,
                totalWtBox,
                amtRsBox,
                amtDBox,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatField(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
          const SizedBox(width: 8),
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
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.textPrimary,
          ),
          textAlign: align,
        ),
      ),
    );
  }

  // ==================== BOTTOM ACTION BAR (NO PRINT OPTION) ====================

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
                      _entryFocus.requestFocus();
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
          AppButton(
            text: 'Delete',
            icon: Icons.delete_outline_rounded,
            variant: AppButtonVariant.danger,
            onPressed: (_isFromEdit && _isEnabled) ? _handleDelete : null,
          ),
          AppButton(
            text: 'Cancel',
            icon: Icons.cancel_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _isEnabled ? _handleCancel : null,
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
            onPressed: () => setState(() => _isSearch = true),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH VIEW ====================

  Widget _buildSearchView() {
    return KeyboardListener(
      focusNode: _searchKeyBoardFocus,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          final int currentIndex = _dataGridController.selectedIndex;
          final int totalRows = memoRecDataGridSource.length;

          if (event.logicalKey == LogicalKeyboardKey.enter) {
            final DataGridRow? selectedRow = _dataGridController.selectedRow;
            if (selectedRow != null) {
              final id = selectedRow.getCells()[0].value;
              _selectMemoById(id);
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (currentIndex < totalRows - 1) {
              _dataGridController.selectedIndex = currentIndex + 1;
              _dataGridController.scrollToRow((currentIndex + 1).toDouble());
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (currentIndex > 0) {
              _dataGridController.selectedIndex = currentIndex - 1;
              _dataGridController.scrollToRow((currentIndex - 1).toDouble());
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyE ||
              event.logicalKey == LogicalKeyboardKey.escape) {
            setState(() => _isSearch = false);
          } else if (event.logicalKey == LogicalKeyboardKey.keyR && _isFiltered.value) {
            _removeDateFilter();
          } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            _applyDateFilter();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                const Header(title: 'Memo Return Search'),
                const SizedBox(height: 12),
              ],

              // Filter Controls Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fromDateField = AppTextField(
                      label: 'From Date',
                      controller: fromDateController,
                      readOnly: true,
                      prefixIcon: Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            fromDate = picked;
                            fromDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                            if (toDate != null) _applyDateFilter();
                          });
                        }
                      },
                    );

                    final toDateField = AppTextField(
                      label: 'To Date',
                      controller: toDateController,
                      readOnly: true,
                      prefixIcon: Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: toDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            toDate = picked;
                            toDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                            if (fromDate != null) _applyDateFilter();
                          });
                        }
                      },
                    );

                    final searchBtn = AppButton(
                      text: 'Search (F)',
                      icon: Icons.search_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: _applyDateFilter,
                    );

                    final resetBtn = _isFiltered.value
                        ? AppButton(
                            text: 'Reset (R)',
                            icon: Icons.refresh_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: _removeDateFilter,
                          )
                        : null;

                    final backBtn = AppButton(
                      text: 'Back to Entry (Esc)',
                      icon: Icons.arrow_back_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => setState(() => _isSearch = false),
                    );

                    return Row(
                      children: [
                        Expanded(child: fromDateField),
                        const SizedBox(width: 12),
                        Expanded(child: toDateField),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              searchBtn,
                              if (resetBtn != null) ...[
                                const SizedBox(width: 8),
                                resetBtn,
                              ],
                              const SizedBox(width: 8),
                              backBtn,
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Table of Memos
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Obx(
                      () => memoRecDataGridSource.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
                                  const SizedBox(height: 8),
                                  Text('No Memo Return records found',
                                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : AppDataGrid(
                              source: MemoReceiveDataGridSource(memoRecDataGridSource),
                              controller: _dataGridController,
                              selectionMode: SelectionMode.single,
                              onSelectionChanged: (addedRows, removedRows) {
                                if (addedRows.isNotEmpty) {
                                  final int id = addedRows.first.getCells()[0].value;
                                  _selectMemoById(id);
                                }
                              },
                              columns: [
                                GridColumn(
                                  columnName: 'ID',
                                  label: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'Date',
                                  label: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'Party',
                                  label: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Party', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'Broker',
                                  label: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Broker', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'Tot Wt',
                                  label: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Tot Wt', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'Tot Amt Rs',
                                  label: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Tot Amt (₹)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ),
                                ),
                              ],
                              tableSummaryRows: [
                                GridTableSummaryRow(
                                  showSummaryInRow: false,
                                  title: 'Total',
                                  columns: [
                                    const GridSummaryColumn(
                                      name: 'SumTotWt',
                                      columnName: 'Tot Wt',
                                      summaryType: GridSummaryType.sum,
                                    ),
                                    const GridSummaryColumn(
                                      name: 'SumTotAmt',
                                      columnName: 'Tot Amt Rs',
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
        ),
      ),
    );
  }
}
