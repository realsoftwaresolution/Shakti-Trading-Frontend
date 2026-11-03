import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_datagrid.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_item_model.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_mst_model.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InternalStockTransferFormScreen extends StatefulWidget {
  final bool showHeader;

  const InternalStockTransferFormScreen({super.key, this.showHeader = false});

  @override
  InternalStockTransferFormScreenState createState() =>
      InternalStockTransferFormScreenState();
}

class InternalStockTransferFormScreenState extends State<InternalStockTransferFormScreen> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frminternalstocktransferform',
        'frminternalstocktransfer',
        'frminternaltransferform',
        'frminternaltransfer',
        'internal stock transfer',
        'internal transfer',
      ]);
  final DefaultController defaultController = Get.find<DefaultController>();
  final TabControllerX _tabController = Get.isRegistered<TabControllerX>()
      ? Get.find<TabControllerX>()
      : Get.put(TabControllerX());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchFromDateController =
      TextEditingController();
  final TextEditingController _searchToDateController = TextEditingController();

  DateTime? _searchFromDate;
  DateTime? _searchToDate;
  final RxBool _isDateFiltered = false.obs;

  // Search view toggle
  bool _isSearch = false;

  // Focus Nodes
  final FocusNode _idFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _fromManagerFocus = FocusNode();
  final FocusNode _toManagerFocus = FocusNode();
  final FocusNode _addFocus = FocusNode();
  final FocusNode _saveFocus = FocusNode();

  // Selected State
  final Rx<int?> _selectedFromManagerId = Rx<int?>(null);
  int? get selectedFromManagerId => _selectedFromManagerId.value;
  final Rx<int?> _selectedToManagerId = Rx<int?>(null);
  int? get selectedToManagerId => _selectedToManagerId.value;
  DateTime _selectedDate = DateTime.now();

  // To Man options dynamically loaded based on From Man's allowed issue
  final RxList<UserModel> _toManagerUsers = <UserModel>[].obs;
  List<UserModel> get toManagerUsers => _toManagerUsers;
  final RxBool _isLoadingToManagers = false.obs;

  // Form edit state
  bool _isEnabled = false;
  bool _isFromEdit = false;
  bool get isEnabled => _isEnabled;
  bool get isFromEdit => _isFromEdit;

  Future<void> loadTransferById(dynamic id) => _loadTransferById(id);

  final RxBool _isLoadingUsers = false.obs;
  Worker? _userListWorker;
  Worker? _transferWorker;

  // Table items & DataGridSource
  final List<InternalStockTransferItemModel> _allItems = [];
  final List<InternalStockTransferItemModel> _displayItems = [];
  late InternalStockTransferDataGridSource _gridSource;
  final DataGridController _dataGridController = DataGridController();



  bool get isCurrentUserTypeUser {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'USER' || !defaultController.isAdmin;
  }

  bool get isCurrentUserTypeAdmin {
    final grp = defaultController.currentUserGrp.value.trim().toUpperCase();
    return grp == 'ADMIN' || grp == 'SUPERADMIN' || defaultController.isAdmin;
  }

  bool get _isFromManagerEnabled {
    if (isCurrentUserTypeUser) {
      return false;
    }
    return true;
  }

  UserModel? get selectedFromManagerUser {
    final id = _selectedFromManagerId.value;
    if (id == null || id <= 0) return null;
    return defaultController.userModelList.firstWhereOrNull(
      (u) => u.counterMstId == id,
    );
  }

  double getMaxAllowedIssueWt(InternalStockTransferItemModel item) {
    final stock = item.stockWt;
    final manager = selectedFromManagerUser;
    if (manager == null) return stock;

    final plusType = manager.allowPlusType?.trim().toUpperCase();
    final plusVal = manager.allowPlusValue ?? 0.0;

    if (plusVal <= 0.0 || plusType == null || plusType.isEmpty) {
      return stock;
    }

    if (plusType == 'WT') {
      return stock + plusVal;
    } else if (plusType == 'PER') {
      return stock + (stock * (plusVal / 100.0));
    }

    return stock;
  }

  double getMinAllowedIssueWt(InternalStockTransferItemModel item) {
    final stock = item.stockWt;
    final manager = selectedFromManagerUser;
    if (manager == null) return 0.0;

    final minusType = manager.allowMinusType?.trim().toUpperCase();
    final minusVal = manager.allowMinusValue ?? 0.0;

    if (minusVal <= 0.0 || minusType == null || minusType.isEmpty) {
      return 0.0;
    }

    if (minusType == 'WT') {
      final min = stock - minusVal;
      return min < 0.0 ? 0.0 : min;
    } else if (minusType == 'PER') {
      final min = stock - (stock * (minusVal / 100.0));
      return min < 0.0 ? 0.0 : min;
    }

    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);

    _gridSource = InternalStockTransferDataGridSource(
      initialItems: _displayItems,
      isEnabled: _isEnabled,
      getMaxAllowedIssueWt: (item) => getMaxAllowedIssueWt(item),
      getMinAllowedIssueWt: (item) => getMinAllowedIssueWt(item),
      onValidationWarning: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      },
      onRowChanged: (item) {
        if (mounted) setState(() {});
      },
    );

    _userListWorker = ever(defaultController.userModelList, (_) {
      if (mounted) {
        _initFromManager();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadMasterData();

      if (defaultController.userModelList.isEmpty) {
        _isLoadingUsers.value = true;
        await defaultController.getUserData();
        _isLoadingUsers.value = false;
      }
      _initFromManager();
    });
  }

  void _loadMasterData() {
    if (defaultController.roughModel.isEmpty) {
      defaultController.getRoughData();
    }
    if (defaultController.polishTypeModelList.isEmpty) {
      defaultController.getPolishTypeData();
    }
    if (defaultController.qualityModelList.isEmpty) {
      defaultController.getQualityData();
    }
    if (defaultController.charniModelList.isEmpty) {
      defaultController.getCharniData();
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
  }

  void _clearTableItems() {
    for (var item in _allItems) {
      item.dispose();
    }
    _allItems.clear();
    _applyTableFilter();
  }

  Future<void> _fetchCombinedPurchaseData({dynamic fromUserId}) async {
    if (fromUserId == null || fromUserId == 0) {
      _clearTableItems();
      return;
    }
    final list = await defaultController.getInternalStockTransferCombinedData(
      fromUserId: fromUserId,
    );
    for (var item in _allItems) {
      item.dispose();
    }
    _allItems.clear();
    if (list.isNotEmpty) {
      _allItems.addAll(list);
    }
    _applyTableFilter();
  }

  void _applyTableFilter() {
    final query = _searchController.text.trim().toLowerCase();
    _displayItems.clear();
    if (query.isEmpty) {
      _displayItems.addAll(_allItems);
    } else {
      _displayItems.addAll(
        _allItems.where((item) {
          final type = _gridSource.resolveTypeName(item).toLowerCase();
          final inv = (item.invoiceNo ?? '').toLowerCase();
          final src = item.source.toLowerCase();
          final quality = _gridSource.resolveQuality(item).toLowerCase();
          final charni = _gridSource.resolveCharni(item).toLowerCase();
          final shape = _gridSource.resolveShape(item).toLowerCase();
          final color = _gridSource.resolveColor(item).toLowerCase();
          final clarity = _gridSource.resolveClarity(item).toLowerCase();

          return type.contains(query) ||
              inv.contains(query) ||
              src.contains(query) ||
              quality.contains(query) ||
              charni.contains(query) ||
              shape.contains(query) ||
              color.contains(query) ||
              clarity.contains(query);
        }),
      );
    }
    if (mounted) {
      _gridSource.updateItems(_displayItems);
    }
  }

  @override
  void dispose() {
    _userListWorker?.dispose();
    _transferWorker?.dispose();
    _idController.dispose();
    _dateController.dispose();
    _searchController.dispose();
    _searchFromDateController.dispose();
    _searchToDateController.dispose();
    _idFocus.dispose();
    _dateFocus.dispose();
    _fromManagerFocus.dispose();
    _toManagerFocus.dispose();
    _addFocus.dispose();
    _saveFocus.dispose();
    for (var item in _allItems) {
      item.dispose();
    }
    super.dispose();
  }

  /// Initialize From Man based on user type (USER vs ADMIN)
  void _initFromManager() {
    if (isCurrentUserTypeUser) {
      final currentUserId = defaultController.currentUserId.value;
      _selectedFromManagerId.value = currentUserId > 0 ? currentUserId : null;
      if (_selectedFromManagerId.value != null &&
          _selectedFromManagerId.value! > 0) {
        _loadToManagersFor(_selectedFromManagerId.value!);
        _fetchCombinedPurchaseData(fromUserId: _selectedFromManagerId.value!);
      } else {
        _clearTableItems();
      }
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
          _toManagerUsers.clear();
          _clearTableItems();
        }
      }
    }
  }

  /// Loads all users allowed issue from the selected From Man, plus loggedIn user
  Future<void> _loadToManagersFor(int fromUserId) async {
    if (fromUserId <= 0) return;
    _isLoadingToManagers.value = true;
    final Set<int> allowedIds = <int>{};

    try {
      final targets = await defaultController.getTransferTargets(fromUserId);
      if (targets != null && targets.isNotEmpty) {
        for (var t in targets) {
          final id = int.tryParse((t['userId'] ??
                  t['CounterMstID'] ??
                  t['UserId'] ??
                  t['id'] ??
                  '')
              .toString());
          if (id != null && id > 0) {
            allowedIds.add(id);
          }
        }
      }
    } catch (e) {
      log('getTransferTargets error: $e');
    }

    final currentUserId = defaultController.currentUserId.value;
    if (currentUserId > 0) {
      allowedIds.remove(currentUserId);
    }
    allowedIds.remove(fromUserId);

    final List<UserModel> list = [];
    for (var id in allowedIds) {
      final matched = defaultController.userModelList.firstWhereOrNull(
        (u) => u.counterMstId == id,
      );
      if (matched != null) {
        list.add(matched);
      } else {
        list.add(UserModel(
          counterMstId: id,
          userName: 'User #$id',
          loginName: 'user_$id',
        ));
      }
    }

    list.sort((a, b) => (a.userName ?? a.loginName ?? '')
        .toLowerCase()
        .compareTo((b.userName ?? b.loginName ?? '').toLowerCase()));

    _toManagerUsers.value = list;
    _isLoadingToManagers.value = false;

    if (_selectedToManagerId.value != null &&
        !allowedIds.contains(_selectedToManagerId.value)) {
      _selectedToManagerId.value = null;
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
        icon: const Icon(Icons.person_rounded, size: 16),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _buildToManagerDropdownItems() {
    return _toManagerUsers.where((u) => u.counterMstId != null).map((u) {
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

  List<AppDropdownItem<int>> _buildToManagerAppDropdownItems() {
    return _toManagerUsers.where((u) => u.counterMstId != null).map((u) {
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
        icon: const Icon(Icons.person_pin_rounded, size: 16),
      );
    }).toList();
  }

  /// Action button: Add entry
  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    final hasBranch = defaultController.effectiveBranchCode > 0;
    final isDesiCode4 = defaultController.effectiveDesiCode == 4;
    if (!hasBranch || !isDesiCode4) {
      infoDialog(
        messageText:
            'Cannot add entry: Only users with a branch and designation code 4 are permitted to add entries.',
      );
      return;
    }

    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      _idController.clear();
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      _selectedToManagerId.value = null;
    });

    _gridSource.setShowCheckbox(true);
    _gridSource.setEnabled(true);
    _initFromManager();

    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isFromManagerEnabled) {
          _fromManagerFocus.requestFocus();
        } else {
          _toManagerFocus.requestFocus();
        }
      });
    }
  }

  /// Action button: Cancel entry
  void _handleCancel() {
    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      _isSearch = false;
      _idController.clear();
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      _selectedToManagerId.value = null;
      if (!isCurrentUserTypeUser) {
        _selectedFromManagerId.value = null;
        _toManagerUsers.clear();
        _clearTableItems();
      }
    });
    _gridSource.setShowCheckbox(true);
    _gridSource.setEnabled(false);
    _gridSource.toggleSelectAll(false);
    _initFromManager();
  }

  /// Compares whether a combined stock item matches a internal stock transfer detail item
  bool _isSameTransferItem(
      InternalStockTransferItemModel a, InternalStockTransferItemModel b) {
    if (a.source.toLowerCase() != b.source.toLowerCase()) {
      return false;
    }

    if (a.source.toLowerCase() == 'rough') {
      final invA = (a.invoiceNo ?? '').trim().toLowerCase();
      final invB = (b.invoiceNo ?? '').trim().toLowerCase();
      if (invA != invB) return false;

      if (a.roughTypeCode != null && b.roughTypeCode != null) {
        if (a.roughTypeCode != b.roughTypeCode) return false;
      }

      final qA = a.roughQualityCode;
      final qB = b.roughQualityCode;
      if (qA != null && qB != null && qA != qB) return false;

      final cA = a.roughCharniCode ?? a.charniCode;
      final cB = b.roughCharniCode ?? b.charniCode;
      if (cA != null && cB != null && cA != cB) return false;

      return true;
    } else {
      // Polish
      if (a.polishTypeCode != null && b.polishTypeCode != null) {
        if (a.polishTypeCode != b.polishTypeCode) return false;
      }

      if (a.shapeCode != null && b.shapeCode != null) {
        if (a.shapeCode != b.shapeCode) return false;
      }

      if (a.colorCode != null && b.colorCode != null) {
        if (a.colorCode != b.colorCode) return false;
      }

      if (a.clarityCode != null && b.clarityCode != null) {
        if (a.clarityCode != b.clarityCode) return false;
      }

      final cA = a.charniCode ?? a.roughCharniCode;
      final cB = b.charniCode ?? b.roughCharniCode;
      if (cA != null && cB != null && cA != cB) return false;

      return true;
    }
  }

  /// Load a single internal stock transfer by its ID via GET /internal-stock-transfer/<ID>
  /// and then fetch combined stock items and merge with the existing transfer details.
  Future<void> _loadTransferById(dynamic id) async {
    if (id == null || id.toString().trim().isEmpty) return;
    final InternalStockTransferMstModel? transfer =
        await defaultController.getInternalStockTransferById(id);
    if (transfer == null) return;

    List<InternalStockTransferItemModel> combinedList = [];
    if (transfer.fromCrId != null && transfer.fromCrId! > 0) {
      combinedList = await defaultController.getInternalStockTransferCombinedData(
        companyCodeParam: transfer.companyCode,
        fromUserId: transfer.fromCrId,
        excludeId: id,
      );
    }

    final Set<InternalStockTransferItemModel> matchedDetails = {};
    for (var cItem in combinedList) {
      InternalStockTransferItemModel? matched;
      for (var dItem in transfer.items) {
        if (!matchedDetails.contains(dItem) &&
            _isSameTransferItem(cItem, dItem)) {
          matched = dItem;
          matchedDetails.add(dItem);
          break;
        }
      }

      if (matched != null) {
        cItem.isSelected = false;
        cItem.issuePc = matched.issuePc;
        cItem.issueWt = matched.issueWt;
        cItem.issueRate = matched.issueRate > 0.0
            ? matched.issueRate
            : (matched.stockRateRs > 0.0 ? matched.stockRateRs : cItem.stockRateRs);
        cItem.issueAmt = matched.issueAmt > 0.0
            ? matched.issueAmt
            : (cItem.issueWt * cItem.issueRate);
        cItem.diffWt = matched.diffWt > 0.0 ? matched.diffWt : cItem.issueWt;
        cItem.diffRate = matched.diffRate;
        cItem.diffAmt = matched.diffAmt;
        cItem.issuePcController.text = matched.issuePc.toString();
        cItem.issueWtController.text = matched.issueWt > 0.0
            ? matched.issueWt.toStringAsFixed(3)
            : '0.000';
        cItem.updateCalculations();
      } else {
        cItem.isSelected = false;
        cItem.issuePc = 0;
        cItem.issueWt = 0.0;
        cItem.issuePcController.text = '0';
        cItem.issueWtController.text = '0.000';
        cItem.updateCalculations();
      }
    }

    // Include any transfer items that were not found in current combined stock
    for (var dItem in transfer.items) {
      if (!matchedDetails.contains(dItem)) {
        dItem.isSelected = true;
        dItem.issuePcController.text = dItem.issuePc.toString();
        dItem.issueWtController.text = dItem.issueWt > 0.0
            ? dItem.issueWt.toStringAsFixed(3)
            : '0.000';
        dItem.updateCalculations();
        combinedList.add(dItem);
      }
    }

    setState(() {
      _isSearch = false;
      _isFromEdit = true;
      _isEnabled = false;
      _idController.text =
          transfer.internalStockTransferMstID?.toString() ?? id.toString();

      if (transfer.transferDate != null && transfer.transferDate!.isNotEmpty) {
        final parsed = DateTime.tryParse(transfer.transferDate!);
        if (parsed != null) {
          _selectedDate = parsed;
        } else if (transfer.transferDate!.contains('-') &&
            transfer.transferDate!.split('-').first.length == 4) {
          final p = transfer.transferDate!.split('-');
          _selectedDate =
              DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        }
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      }

      _selectedFromManagerId.value = transfer.fromCrId;
      if (transfer.fromCrId != null && transfer.fromCrId! > 0) {
        _loadToManagersFor(transfer.fromCrId!);
      }
      _selectedToManagerId.value = transfer.toCrId;

      for (var old in _allItems) {
        old.dispose();
      }
      _allItems.clear();
      _displayItems.clear();

      final listToDisplay =
          combinedList.isNotEmpty ? combinedList : transfer.items;
      _allItems.addAll(listToDisplay);
      _displayItems.addAll(listToDisplay);

      _gridSource.setShowCheckbox(false);
      _gridSource.updateItems(_displayItems);
      _gridSource.setEnabled(false);
    });
  }

  /// Action button: Delete entry via DELETE /internal-stock-transfer/<ID>
  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    final idStr = _idController.text.trim();
    if (!_isFromEdit || idStr.isEmpty) return;

    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete Internal Stock Transfer #$idStr?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        Get.back();
        final ok = await defaultController.deleteInternalStockTransferData(id: idStr);
        if (ok) {
          _handleCancel();
        }
      },
    );
  }

  /// Action button: Save entry
  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;

    // Collect candidate items for saving (items where issueWt > 0, or selected items)
    final itemsWithIssue = _allItems.where((i) => i.issueWt > 0.0).toList();
    final candidateItems = itemsWithIssue.isNotEmpty
        ? itemsWithIssue
        : _allItems.where((i) => i.isSelected).toList();

    final compCode = defaultController.companyCode.value != 0
        ? defaultController.companyCode.value
        : 3;
    final totalStockPc = candidateItems.fold<int>(0, (sum, i) => sum + i.stockPc);
    final totalStockWt = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.stockWt).toStringAsFixed(3));
    final totalRateDollar = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.stockRateDollar).toStringAsFixed(2));
    final totalRateRs = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.stockRateRs).toStringAsFixed(2));
    final totalAmtDollar = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.stockAmtDollar).toStringAsFixed(2));
    final totalAmtRs = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.stockAmtRs).toStringAsFixed(2));

    final totalIssuePc = candidateItems.fold<int>(0, (sum, i) => sum + i.issuePc);
    final totalIssueWt = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.issueWt).toStringAsFixed(3));
    final totalIssueRate = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.issueRate).toStringAsFixed(2));
    final totalIssueAmt = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.issueAmt).toStringAsFixed(2));

    final totalDiffWt = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.diffWt).toStringAsFixed(3));
    final totalDiffRate = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.diffRate).toStringAsFixed(2));
    final totalDiffAmt = double.parse(
        candidateItems.fold<double>(0.0, (sum, i) => sum + i.diffAmt).toStringAsFixed(2));

    final String formattedTransferDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final candidateSerializedItems = candidateItems.map((i) => i.toSaveJson(
      type: _gridSource.resolveTypeName(i),
      quality: _gridSource.resolveQuality(i),
      charni: _gridSource.resolveCharni(i),
      shape: _gridSource.resolveShape(i),
      color: _gridSource.resolveColor(i),
      clarity: _gridSource.resolveClarity(i),
    )).toList();

    // Build payload to print on click of save button (strictly matches InternalStockTransferMst and InternalStockTransferDet, no duplicate keys)
    final payloadToPrint = {
      'CompanyCode': compCode,
      'FromCrId': _selectedFromManagerId.value,
      'ToCrId': _selectedToManagerId.value,
      'TransferDate': formattedTransferDate,
      'TotalItems': candidateItems.length,
      'TotalStockPc': totalStockPc,
      'TotalStockWt': totalStockWt,
      'TotalRateDollar': totalRateDollar,
      'TotalRateRs': totalRateRs,
      'TotalAmtDollar': totalAmtDollar,
      'TotalAmtRs': totalAmtRs,
      'TotalIssuePc': totalIssuePc,
      'TotalIssueWt': totalIssueWt,
      'TotalIssueRate': totalIssueRate,
      'TotalIssueAmt': totalIssueAmt,
      'TotalDiffWt': totalDiffWt,
      'TotalDiffRate': totalDiffRate,
      'TotalDiffAmt': totalDiffAmt,
      'items': candidateSerializedItems,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final formattedPayload = encoder.convert(payloadToPrint);
    debugPrint('======================================================================');
    debugPrint('🚀 [INTERNAL STOCK TRANSFER SAVE] PAYLOAD ON CLICK ON SAVE BUTTON:');
    debugPrint('======================================================================');
    for (var line in formattedPayload.split('\n')) {
      debugPrint(line);
    }
    debugPrint('======================================================================');
    log('Internal Stock Transfer Save Payload: $formattedPayload');

    final hasBranch = defaultController.effectiveBranchCode > 0;
    final isDesiCode4 = defaultController.effectiveDesiCode == 4;
    if (!hasBranch || !isDesiCode4) {
      infoDialog(
        messageText:
            'Cannot save: Only users with a branch and designation code 4 are permitted to add/save entries.',
      );
      return;
    }

    if (_selectedFromManagerId.value == null) {
      infoDialog(messageText: 'Please select From Man');
      return;
    }

    if (_selectedToManagerId.value == null) {
      infoDialog(messageText: 'Please select To Man');
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      infoDialog(messageText: 'Please select Date');
      return;
    }

    // Row-wise check: Issue Wt is required for selected rows
    final checkedWithZero = _allItems.where((i) => i.isSelected && i.issueWt <= 0.0).toList();
    if (checkedWithZero.isNotEmpty) {
      final name = _gridSource.resolveTypeName(checkedWithZero.first);
      infoDialog(
        messageText:
            'Issue Wt is required for selected item ($name). Please enter an Issue Wt greater than 0.',
      );
      return;
    }

    // Only include rows where issueWt > 0 (rows with 0 or empty issueWt are NOT passed into the API)
    final itemsToSave = _allItems.where((i) => i.issueWt > 0.0).toList();
    if (itemsToSave.isEmpty) {
      infoDialog(
        messageText:
            'Please enter Issue Wt (> 0) for at least one item to save internal stock transfer.',
      );
      return;
    }

    // Validate min and max allowed issue Wt for each row to save
    for (var item in itemsToSave) {
      final maxAllowed = getMaxAllowedIssueWt(item);
      final minAllowed = getMinAllowedIssueWt(item);
      final name = _gridSource.resolveTypeName(item);

      if (item.issueWt > maxAllowed) {
        infoDialog(
          messageText:
              'Issue Wt (${item.issueWt.toStringAsFixed(3)}) cannot exceed max allowed (${maxAllowed.toStringAsFixed(3)}) for $name.',
        );
        return;
      }

      if (minAllowed > 0.0 && item.issueWt < minAllowed) {
        infoDialog(
          messageText:
              'Issue Wt (${item.issueWt.toStringAsFixed(3)}) cannot be less than min allowed (${minAllowed.toStringAsFixed(3)}) for $name.',
        );
        return;
      }
    }

    final itemsToSaveSerialized = itemsToSave.map((i) => i.toSaveJson(
      type: _gridSource.resolveTypeName(i),
      quality: _gridSource.resolveQuality(i),
      charni: _gridSource.resolveCharni(i),
      shape: _gridSource.resolveShape(i),
      color: _gridSource.resolveColor(i),
      clarity: _gridSource.resolveClarity(i),
    )).toList();

    final bool success;
    if (_isFromEdit) {
      final mstId = _idController.text.trim();
      success = await defaultController.updateInternalStockTransferData(
        id: mstId,
        fromUserId: _selectedFromManagerId.value!,
        toUserId: _selectedToManagerId.value!,
        transferDate: formattedTransferDate,
        date: _dateController.text.trim(),
        items: itemsToSave,
        serializedItems: itemsToSaveSerialized,
      );
    } else {
      success = await defaultController.saveInternalStockTransferData(
        fromUserId: _selectedFromManagerId.value!,
        toUserId: _selectedToManagerId.value!,
        transferDate: formattedTransferDate,
        date: _dateController.text.trim(),
        items: itemsToSave,
        serializedItems: itemsToSaveSerialized,
      );
    }

    if (success) {
      setState(() {
        _isEnabled = false;
        _isFromEdit = false;
        _idController.clear();
        _selectedToManagerId.value = null;
        if (!isCurrentUserTypeUser) {
          _selectedFromManagerId.value = null;
          _toManagerUsers.clear();
          _clearTableItems();
        }
      });

      _gridSource.setShowCheckbox(true);
      _gridSource.setEnabled(false);
      _gridSource.toggleSelectAll(false);
      if (isCurrentUserTypeUser && _selectedFromManagerId.value != null) {
        _fetchCombinedPurchaseData(fromUserId: _selectedFromManagerId.value);
      }
    }
  }

  void _exitScreen() {
    _tabController.closeCurrentTab();
  }

  Future<void> _openDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }

    if (_isEnabled) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _saveFocus.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (widget.showHeader)
            Header(
              title:
                  _isSearch ? 'Internal Stock Transfer Search' : 'Internal Stock Transfer',
            ),
          Expanded(
            child: _isSearch ? _buildSearchView() : _buildFormView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 10 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Form Card with single row: id, from, to and date
            _buildFormCard(),
            const SizedBox(height: 10),

            // DataTable Card
            Expanded(
              child: _buildDataTableCard(),
            ),
            const SizedBox(height: 10),

            // Action buttons row at the bottom
            _buildActionButtonsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'INTERNAL STOCK TRANSFER INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 768;

                // 1. Id Field
                final idField = AppTextField(
                  label: 'Id',
                  controller: _idController,
                  focusNode: _idFocus,
                  enabled: !_isEnabled && !_isFromEdit,
                  hintText: _isEnabled ? 'Auto Generated' : 'Search ID...',
                  prefixIcon: const Icon(Icons.tag_rounded, size: 16),
                  onFieldSubmitted: (val) {
                    final trimmed = val.trim();
                    if (trimmed.isNotEmpty) {
                      _loadTransferById(trimmed);
                    } else if (_isFromManagerEnabled) {
                      _fromManagerFocus.requestFocus();
                    } else {
                      _toManagerFocus.requestFocus();
                    }
                  },
                );

                // 2. From Man Dropdown
                final fromManagerField = Obx(
                  () => AppDropdown<int>(
                    label: 'From Man',
                    value: _selectedFromManagerId.value,
                    items: _buildFromManagerDropdownItems(),
                    dropdownItems: _buildFromManagerAppDropdownItems(),
                    focusNode: _fromManagerFocus,
                    nextFocusNode: _toManagerFocus,
                    isEnabled: _isEnabled && _isFromManagerEnabled && !_isFromEdit,
                    hintText: 'Select From Man',
                    searchHint: 'Search manager...',
                    prefixIcon: const Icon(Icons.person_rounded, size: 16),
                    onChanged: (val) {
                      _selectedFromManagerId.value = val;
                      if (val != null && val > 0) {
                        _loadToManagersFor(val);
                        _fetchCombinedPurchaseData(fromUserId: val);
                      } else {
                        _toManagerUsers.clear();
                        _selectedToManagerId.value = null;
                        _clearTableItems();
                      }
                    },
                  ),
                );

                // 3. To Man Dropdown
                final toManagerField = Obx(
                  () => AppDropdown<int>(
                    label: 'To Man',
                    value: _selectedToManagerId.value,
                    items: _buildToManagerDropdownItems(),
                    dropdownItems: _buildToManagerAppDropdownItems(),
                    focusNode: _toManagerFocus,
                    nextFocusNode: _dateFocus,
                    isEnabled: _isEnabled &&
                        _selectedFromManagerId.value != null &&
                        !_isFromEdit,
                    hintText: _selectedFromManagerId.value == null
                        ? 'Select From Man first'
                        : (_isLoadingToManagers.value
                            ? 'Loading allowed users...'
                            : 'Select To Man'),
                    searchHint: 'Search manager...',
                    prefixIcon: const Icon(Icons.person_pin_rounded, size: 16),
                    onChanged: (val) {
                      _selectedToManagerId.value = val;
                    },
                  ),
                );

                // 4. Date Field
                final dateField = Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                      if (_isEnabled) {
                        _openDatePicker();
                      }
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AppTextField(
                    label: 'Date',
                    controller: _dateController,
                    focusNode: _dateFocus,
                    readOnly: true,
                    enabled: _isEnabled,
                    prefixIcon:
                        const Icon(Icons.calendar_today_rounded, size: 16),
                    onTap: _isEnabled ? _openDatePicker : null,
                  ),
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: idField,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: fromManagerField,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: toManagerField,
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: dateField,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: idField),
                          const SizedBox(width: 10),
                          Expanded(child: dateField),
                        ],
                      ),
                      const SizedBox(height: 10),
                      fromManagerField,
                      const SizedBox(height: 10),
                      toManagerField,
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

  Widget _buildActionButtonsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!_isEnabled)
              AppButton(
                text: 'Add',
                icon: Icons.add_circle_outline_rounded,
                focusNode: _addFocus,
                onPressed: () => _enableFields(),
              ),
            if (_isFromEdit && !_isEnabled)
              AppButton(
                text: 'Edit',
                variant: AppButtonVariant.outline,
                icon: Icons.edit_note_rounded,
                onPressed: () {
                  setState(() => _isEnabled = true);
                  _gridSource.setEnabled(true);
                },
              ),
            if (_isEnabled)
              AppButton(
                text: 'Save',
                icon: Icons.save_rounded,
                focusNode: _saveFocus,
                isLoading: defaultController.isLoading.value,
                onPressed: _handleSave,
              ),
            if (_isFromEdit)
              Obx(
                () => AppButton(
                  text: 'Delete',
                  variant: AppButtonVariant.danger,
                  icon: Icons.delete_outline_rounded,
                  isLoading:
                      defaultController.isDeleteLoadingInternalStockTransfer.value,
                  onPressed: _handleDelete,
                ),
              ),
            if (_isEnabled || _isFromEdit)
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
                defaultController.getInternalStockTransferList(force: true);
              },
            ),
            AppButton(
              text: 'Exit',
              variant: AppButtonVariant.secondary,
              icon: Icons.exit_to_app_rounded,
              onPressed: _exitScreen,
            ),
          ],
        ),
      ),
    );
  }

  List<GridColumn> _buildGridColumns() {
    final isDark = AppColors.isDark;
    final yellowHeaderBg =
        isDark ? const Color(0xFF78350F) : const Color(0xFFFEF08A);
    final yellowHeaderText =
        isDark ? const Color(0xFFFEF08A) : const Color(0xFF713F12);

    return [
      // 1. Checkbox Select Column
      if (_gridSource.showCheckbox)
        GridColumn(
          columnName: 'select',
          width: 48,
          allowSorting: false,
          allowFiltering: false,
          label: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _gridSource.isAllSelected
                    ? true
                    : (_gridSource.hasSomeSelected ? null : false),
                tristate: true,
                activeColor: AppColors.primary,
                side: BorderSide(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                onChanged: _isEnabled
                    ? (val) {
                        _gridSource.toggleSelectAll(val ?? false);
                        setState(() {});
                      }
                    : null,
              ),
            ),
          ),
        ),

      // 2. Source (Rough / Polish)
      AppDataGrid.buildColumn(
        columnName: 'source',
        labelText: 'Source',
        width: 75,
        alignment: Alignment.center,
      ),

      // 3. Type (Rough Type / Polish Type name as per source)
      AppDataGrid.buildColumn(
        columnName: 'type',
        labelText: 'Type',
        width: 130,
        alignment: Alignment.centerLeft,
      ),

      // 4. Inv No
      AppDataGrid.buildColumn(
        columnName: 'invoiceNo',
        labelText: 'Inv No',
        width: 85,
        alignment: Alignment.centerLeft,
      ),
      // 11. Quality
      AppDataGrid.buildColumn(
        columnName: 'quality',
        labelText: 'Quality',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 12. Charni
      AppDataGrid.buildColumn(
        columnName: 'charni',
        labelText: 'Charni',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 13. Shape
      AppDataGrid.buildColumn(
        columnName: 'shape',
        labelText: 'Shape',
        width: 90,
        alignment: Alignment.centerLeft,
      ),

      // 14. Color
      AppDataGrid.buildColumn(
        columnName: 'color',
        labelText: 'Color',
        width: 80,
        alignment: Alignment.centerLeft,
      ),

      // 15. Clarity
      AppDataGrid.buildColumn(
        columnName: 'clarity',
        labelText: 'Clarity',
        alignment: Alignment.centerLeft,
      ),


      // 7. Rate $
      AppDataGrid.buildColumn(
        columnName: 'rateDollar',
        labelText: 'Rate \$',
        width: 90,
        alignment: Alignment.centerRight,
      ),

      // 8. Rate Rs
      AppDataGrid.buildColumn(
        columnName: 'rateRs',
        labelText: 'Rate ₹',
        alignment: Alignment.centerRight,
      ),

      // 9. Amount $
      AppDataGrid.buildColumn(
        columnName: 'amtDollar',
        labelText: 'Amount \$',
        alignment: Alignment.centerRight,
      ),

      // 10. Amount Rs
      AppDataGrid.buildColumn(
        columnName: 'amtRs',
        labelText: 'Amount ₹',
        alignment: Alignment.centerRight,
      ),


// 5. Stock Pc
      AppDataGrid.buildColumn(
        columnName: 'stockPc',
        labelText: 'Stock Pc',
        width: 100,
        alignment: Alignment.centerRight,
      ),

      // 6. Stock Wt
      AppDataGrid.buildColumn(
        columnName: 'stockWt',
        labelText: 'Stock Wt',
        width: 100,
        alignment: Alignment.centerRight,
      ),
      // 16. Issue Pc (Editable Textbox, Yellow Header highlight)
      GridColumn(
        columnName: 'issuePc',
        width: 80,
        allowSorting: true,
        allowFiltering: true,
        label: Container(
          color: yellowHeaderBg,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            'Iss Pc',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: yellowHeaderText,
            ),
          ),
        ),
      ),

      // 17. Issue Wt (Editable Textbox, Yellow Header highlight)
      GridColumn(
        columnName: 'issueWt',
        width: 90,
        allowSorting: true,
        allowFiltering: true,
        label: Container(
          color: yellowHeaderBg,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            'Iss Wt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: yellowHeaderText,
            ),
          ),
        ),
      ),

      // 18. Issue Rate
      AppDataGrid.buildColumn(
        columnName: 'issueRate',
        labelText: 'Iss Rate',
        alignment: Alignment.centerRight,
      ),

      // 19. Issue Amt
      AppDataGrid.buildColumn(
        columnName: 'issueAmt',
        labelText: 'Iss Amt',
        alignment: Alignment.centerRight,
      ),

      // 20. Diff Wt
      AppDataGrid.buildColumn(
        columnName: 'diffWt',
        labelText: 'Diff Wt',
        width: 85,
        alignment: Alignment.centerRight,
      ),

      // 21. Diff Rate
      AppDataGrid.buildColumn(
        columnName: 'diffRate',
        labelText: 'Diff Rate',
        width: 95,
        alignment: Alignment.centerRight,
      ),

      // 22. Diff Amt
      AppDataGrid.buildColumn(
        columnName: 'diffAmt',
        labelText: 'Diff Amt',
        width: 95,
        alignment: Alignment.centerRight,
      ),
    ];
  }

  Widget _buildDataTableCard() {
    final selectedCount = _allItems.where((i) => i.isSelected).length;
    final totalStockPc = _allItems.fold(0, (sum, i) => sum + i.stockPc);
    final totalStockWt = _allItems.fold(0.0, (sum, i) => sum + i.stockWt);
    final totalIssuePc = _allItems.fold(0, (sum, i) => sum + i.issuePc);
    final totalIssueWt = _allItems.fold(0.0, (sum, i) => sum + i.issueWt);
    final totalIssueAmt = _allItems.fold(0.0, (sum, i) => sum + i.issueAmt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Controls Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COMBINED PURCHASE / STOCK ITEMS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_displayItems.length} items',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Search Filter Box
                        SizedBox(
                          width: isCompact ? 160 : 220,
                          height: 32,
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search items...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 16),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        _searchController.clear();
                                        _applyTableFilter();
                                      },
                                      child: const Icon(Icons.clear, size: 14),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.primary),
                              ),
                            ),
                            onChanged: (_) => _applyTableFilter(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Refresh button
                        InkWell(
                          onTap: () {
                            if (_selectedFromManagerId.value != null &&
                                _selectedFromManagerId.value! > 0) {
                              _fetchCombinedPurchaseData(
                                fromUserId: _selectedFromManagerId.value,
                              );
                            } else {
                              infoDialog(
                                messageText:
                                    'Please select From Man first to load items',
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 15,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reload',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.borderLight),

          // The Data Grid Table
          Expanded(
            child: Obx(() {
              final isLoading = defaultController.isLoadingInternalStockTransfer.value;
              final hasFromMan = _selectedFromManagerId.value != null &&
                  _selectedFromManagerId.value! > 0;

              return Stack(
                children: [
                  AppDataGrid(
                    controller: _dataGridController,
                    source: _gridSource,
                    columns: _buildGridColumns(),
                    rowHeight: 25,
                    headerRowHeight: 25,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    showSortNumbers: false,
                    allowFiltering: true,
                    allowColumnsResizing: true,
                    selectionMode: SelectionMode.none,
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        showSummaryInRow: false,
                        position: GridTableSummaryRowPosition.bottom,
                        columns: const <GridSummaryColumn>[
                          GridSummaryColumn(
                            name: 'total_title',
                            columnName: 'source',
                            summaryType: GridSummaryType.count,
                          ),
                          GridSummaryColumn(
                            name: 'stockPc_sum',
                            columnName: 'stockPc',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'stockWt_sum',
                            columnName: 'stockWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'amtDollar_sum',
                            columnName: 'amtDollar',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'amtRs_sum',
                            columnName: 'amtRs',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issuePc_sum',
                            columnName: 'issuePc',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issueWt_sum',
                            columnName: 'issueWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'issueAmt_sum',
                            columnName: 'issueAmt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'diffWt_sum',
                            columnName: 'diffWt',
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: 'diffAmt_sum',
                            columnName: 'diffAmt',
                            summaryType: GridSummaryType.sum,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.white.withValues(alpha: 0.65),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Loading stock items...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!hasFromMan)
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Select "From Man" to load stock items',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_displayItems.isEmpty)
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No stock items found for selected manager',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),

          // Bottom Summary Stat Bar
          Divider(height: 1, color: AppColors.borderLight),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: selectedCount > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Selected: $selectedCount of ${_allItems.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedCount > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildQuickStat(
                      'Stock',
                      '$totalStockPc Pc | ${totalStockWt.toStringAsFixed(3)} Wt',
                    ),
                    _buildQuickStat(
                      'Issue',
                      '$totalIssuePc Pc | ${totalIssueWt.toStringAsFixed(3)} Wt',
                      highlight: true,
                    ),
                    _buildQuickStat(
                      'Issue Amt',
                      '₹${NumberFormat('#,##0.00').format(totalIssueAmt)}',
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: AppTextField(
                  label: 'From Date :',
                  controller: _searchFromDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchFromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _searchFromDate = picked;
                        _searchFromDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
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
                  controller: _searchToDateController,
                  readOnly: true,
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 16),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchToDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _searchToDate = picked;
                        _searchToDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Show',
                icon: Icons.filter_alt_rounded,
                onPressed: () {
                  setState(() {
                    _isDateFiltered.value = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Clear Filter',
                variant: AppButtonVariant.outline,
                icon: Icons.clear_all_rounded,
                onPressed: () {
                  setState(() {
                    _searchFromDate = null;
                    _searchToDate = null;
                    _searchFromDateController.clear();
                    _searchToDateController.clear();
                    _isDateFiltered.value = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Refresh',
                variant: AppButtonVariant.outline,
                icon: Icons.refresh_rounded,
                onPressed: () =>
                    defaultController.getInternalStockTransferList(force: true),
              ),
              const Spacer(),
              AppButton(
                text: 'Back to Form',
                variant: AppButtonVariant.secondary,
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  setState(() {
                    _isSearch = false;
                  });
                },
              ),
            ],
          ),
        ),

        // Search Data Grid
        Expanded(
          child: Obx(() {
            if (defaultController.isLoadingInternalStockTransferList.value) {
              return const Center(child: CircularProgressIndicator());
            }

            var list = defaultController.internalStockTransferList;
            if (_isDateFiltered.value) {
              list = list.where((item) {
                if (item.transferDate == null) return false;
                final dt = DateTime.tryParse(item.transferDate!);
                if (dt == null) return true;
                if (_searchFromDate != null &&
                    dt.isBefore(_searchFromDate!)) {
                  return false;
                }
                if (_searchToDate != null &&
                    dt.isAfter(
                        _searchToDate!.add(const Duration(days: 1)))) {
                  return false;
                }
                return true;
              }).toList().obs;
            }

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'No internal stock transfer records found.',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            final searchSource = InternalStockTransferSearchDataGridSource(
              list: list,
              onSelect: (item) => _loadTransferById(item.internalStockTransferMstID),
            );

            return AppDataGrid(
              source: searchSource,
              columns: _buildSearchGridColumns(),
              allowSorting: true,
              allowFiltering: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              onCellDoubleTap: (details) {
                if (details.rowColumnIndex.rowIndex <= 0) return;
                final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
                final rows = searchSource.effectiveRows;
                if (dataRowIndex >= 0 && dataRowIndex < rows.length) {
                  final row = rows[dataRowIndex];
                  final idCell = row
                      .getCells()
                      .firstWhereOrNull((c) => c.columnName == 'ID');
                  if (idCell?.value != null) {
                    _loadTransferById(idCell!.value);
                  }
                }
              },
            );
          }),
        ),
      ],
    );
  }

  List<GridColumn> _buildSearchGridColumns() {
    return [
      GridColumn(
        columnName: 'ID',
        width: 80,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'Date',
        width: 110,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'FromMan',
        width: 160,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('From Man',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'ToMan',
        width: 160,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('To Man',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'Items',
        width: 80,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'StockWt',
        width: 110,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Stock Wt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'IssueWt',
        width: 110,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Iss Wt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      GridColumn(
        columnName: 'IssueAmt',
        width: 130,
        label: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text('Iss Amt ₹',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    ];
  }
}
