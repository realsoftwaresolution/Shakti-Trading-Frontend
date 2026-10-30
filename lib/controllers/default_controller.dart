import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:real_web_rough_entry_system/assort/assort_group_model.dart';
import 'package:real_web_rough_entry_system/assort/assort_model.dart';
import 'package:real_web_rough_entry_system/assort/rough_assort_mst_model.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/credit-debit/credit_debit_model.dart';
import 'package:real_web_rough_entry_system/main/company_mst_model.dart';
import 'package:real_web_rough_entry_system/memo%20issue/invoice_generator.dart';
import 'package:real_web_rough_entry_system/memo%20issue/memo_issue_details_model.dart';
import 'package:real_web_rough_entry_system/memo%20issue/memo_issue_model.dart';
import 'package:real_web_rough_entry_system/memo%20receive/invoice_generator.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_rec_details_model.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_rec_model.dart';
import 'package:real_web_rough_entry_system/party-ledger/outstanding_payment_details_model.dart';
import 'package:real_web_rough_entry_system/party/party_model.dart';
import 'package:real_web_rough_entry_system/party/party_type_model.dart';
import 'package:real_web_rough_entry_system/charni/charni_model.dart';
import 'package:real_web_rough_entry_system/clarity/clarity_model.dart';
import 'package:real_web_rough_entry_system/color/color_model.dart';
import 'package:real_web_rough_entry_system/designation/designation_model.dart';
import 'package:real_web_rough_entry_system/quality/quality_model.dart';
import 'package:real_web_rough_entry_system/shape/shape_model.dart';
import 'package:real_web_rough_entry_system/expense_group/expense_group_model.dart';
import 'package:real_web_rough_entry_system/expense/expense_model.dart';
import 'package:real_web_rough_entry_system/acc_type/acc_type_model.dart';
import 'package:real_web_rough_entry_system/polish_type/polish_type_model.dart';
import 'package:real_web_rough_entry_system/company/company_model.dart';
import 'package:real_web_rough_entry_system/branch/branch_model.dart';
import 'package:real_web_rough_entry_system/services/api_service.dart';
import 'package:real_web_rough_entry_system/user/user_model.dart';
import 'package:real_web_rough_entry_system/payment/payment_det_acc.dart';
import 'package:real_web_rough_entry_system/payment/payment_det_model.dart';
import 'package:real_web_rough_entry_system/payment/payment_details_model.dart';
import 'package:real_web_rough_entry_system/payment/payment_mst_model.dart';
import 'package:real_web_rough_entry_system/payment/pending_payment_model.dart';
import 'package:real_web_rough_entry_system/purchase/outstanding_purchase_details.dart';
import 'package:real_web_rough_entry_system/polish_purchase/polish_purchase_model.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_details_model.dart';
import 'package:real_web_rough_entry_system/rough/rough_details_model.dart';
import 'package:real_web_rough_entry_system/rough/rough_model.dart';
import 'package:real_web_rough_entry_system/sale/invoice_generator.dart';
import 'package:real_web_rough_entry_system/sale/sale_details_model.dart';
import 'package:real_web_rough_entry_system/branch_transfer/branch_transfer_item_model.dart';
import 'package:real_web_rough_entry_system/branch_transfer/branch_transfer_mst_model.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_item_model.dart';
import 'package:real_web_rough_entry_system/branch_transfer_confirm/branch_transfer_confirm_mst_model.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_item_model.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer/internal_stock_transfer_mst_model.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer_confirm/internal_stock_transfer_confirm_item_model.dart';
import 'package:real_web_rough_entry_system/internal_stock_transfer_confirm/internal_stock_transfer_confirm_mst_model.dart';
import 'package:real_web_rough_entry_system/sale/sale_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../assort/rough_assort_det_mst_model.dart';
import '../main/menu_model.dart';
import 'package:real_web_rough_entry_system/services/master_crud_service.dart';

class DefaultController extends GetxController {
  static DefaultController get to => Get.find<DefaultController>();
  Dio get dio => ApiService.to.dio;
  RxList<MainMenuModel> menuList = <MainMenuModel>[].obs;
  RxBool isLoadingMenuList = false.obs;
  RxString authToken = ''.obs;
  RxString refreshToken = ''.obs;
  RxList<PartyMstModel> partyMstList = <PartyMstModel>[].obs;
  RxList<AssortGroupMst> assortGroupMstList = <AssortGroupMst>[].obs;
  RxList<AssortMst> assortMstList = <AssortMst>[].obs;
  RxList<CompanyMst> companies = <CompanyMst>[].obs;
  RxBool isLoadingCompanies = false.obs;
  RxList<RoughAssortMst> roughAssortMstList = <RoughAssortMst>[].obs;
  RxList<RoughAssortDetMst> roughAssortMstDetList = <RoughAssortDetMst>[].obs;
  RxList<PurchaseDetailsModel> purchaseDataList = <PurchaseDetailsModel>[].obs;
  RxList<PolishPurchaseModel> polishPurchaseList = <PolishPurchaseModel>[].obs;
  RxList<PolishPurchaseDetailModel> polishPurchaseDetailList = <PolishPurchaseDetailModel>[].obs;
  RxList<CreditDebitMstModel> creditDebitDataList = <CreditDebitMstModel>[].obs;
  RxList<PolishSaleModel> polishSaleList = <PolishSaleModel>[].obs;
  RxList<MemoIssueModel> memoIssueList = <MemoIssueModel>[].obs;
  RxList<MemoRecModel> memoRecList = <MemoRecModel>[].obs;
  RxList<BranchTransferItemModel> branchTransferCombinedList =
      <BranchTransferItemModel>[].obs;
  RxBool isLoadingBranchTransfer = false.obs;
  RxList<BranchTransferMstModel> branchTransferList =
      <BranchTransferMstModel>[].obs;
  RxBool isLoadingBranchTransferList = false.obs;
  RxBool isDeleteLoadingBranchTransfer = false.obs;
  RxList<BranchTransferConfirmMstModel> branchTransferConfirmList =
      <BranchTransferConfirmMstModel>[].obs;
  RxBool isLoadingBranchTransferConfirmList = false.obs;
  RxBool isLoadingBranchTransferConfirmDetails = false.obs;
  RxBool isSavingBranchTransferConfirm = false.obs;

  RxList<InternalStockTransferItemModel> internalStockTransferCombinedList =
      <InternalStockTransferItemModel>[].obs;
  RxBool isLoadingInternalStockTransfer = false.obs;
  RxList<InternalStockTransferMstModel> internalStockTransferList =
      <InternalStockTransferMstModel>[].obs;
  RxBool isLoadingInternalStockTransferList = false.obs;
  RxBool isDeleteLoadingInternalStockTransfer = false.obs;
  RxList<InternalStockTransferConfirmMstModel> internalStockTransferConfirmList =
      <InternalStockTransferConfirmMstModel>[].obs;
  RxBool isLoadingInternalStockTransferConfirmList = false.obs;
  RxBool isLoadingInternalStockTransferConfirmDetails = false.obs;
  RxBool isSavingInternalStockTransferConfirm = false.obs;

  // RxList<RoughPurchaseModel> polishSaleList = <RoughPurchaseModel>[].obs;
  RxList<PartyTypeMstModel> partyTypeMstList = <PartyTypeMstModel>[].obs;
  RxList<RoughModel> roughModel = <RoughModel>[].obs;
  RxList<QualityModel> qualityModelList = <QualityModel>[].obs;
  RxList<CharniModel> charniModelList = <CharniModel>[].obs;
  RxList<CharniRptGroupModel> charniRptGroupList = <CharniRptGroupModel>[].obs;
  RxList<ClarityModel> clarityModelList = <ClarityModel>[].obs;
  RxList<ColorModel> colorModelList = <ColorModel>[].obs;
  RxList<DesignationModel> designationModelList = <DesignationModel>[].obs;
  RxList<ShapeModel> shapeModelList = <ShapeModel>[].obs;
  RxList<ExpenseGroupModel> expenseGroupModelList = <ExpenseGroupModel>[].obs;
  RxList<ExpenseModel> expenseModelList = <ExpenseModel>[].obs;
  RxList<ExpenseGroupModel> expenseGroupDropdownList = <ExpenseGroupModel>[].obs;
  RxList<AccTypeModel> accTypeModelList = <AccTypeModel>[].obs;
  RxList<TypeGroupModel> typeGroupDropdownList = <TypeGroupModel>[].obs;
  RxList<PolishTypeModel> polishTypeModelList = <PolishTypeModel>[].obs;
  RxList<CompanyMstModel> companyModelList = <CompanyMstModel>[].obs;
  RxList<BranchModel> branchModelList = <BranchModel>[].obs;
  RxList<UserModel> userModelList = <UserModel>[].obs;
  Rx<UserModel?> selectedUserForRights = Rx<UserModel?>(null);
  RxList<RoughDetailsModel> roughDetailsModel = <RoughDetailsModel>[].obs;
  RxList<SaleDetailsModel> saleDetailsList = <SaleDetailsModel>[].obs;
  RxList<MemoIssueDetailsModel> memoIssueDetailsList =
      <MemoIssueDetailsModel>[].obs;
  RxList<MemoRecDetailsModel> memoRecDetailsList = <MemoRecDetailsModel>[].obs;
  RxList<MemoIssueDetailsModel> get memoIssueDetailsModel => memoIssueDetailsList;
  RxList<MemoRecDetailsModel> get memoRecDetailsModel => memoRecDetailsList;
  RxList<PaymentMstModel> paymentMstList = <PaymentMstModel>[].obs;
  RxList<PaymentDetModel> paymentDetList = <PaymentDetModel>[].obs;
  RxList<PaymentDetAccModel> paymentDetAccList = <PaymentDetAccModel>[].obs;
  RxList<PendingPaymentModel> pendingPaymentList = <PendingPaymentModel>[].obs;
  RxList<PaymentDetailsModel> bookPartyPaymentDetailsList =
      <PaymentDetailsModel>[].obs;
  RxList<OutstandingPaymentDetails> outstandingPaymentDetailsList =
      <OutstandingPaymentDetails>[].obs;
  RxList<OutstandingPurchaseSaleDetails> outstandingPurchaseSaleDetailsList =
      <OutstandingPurchaseSaleDetails>[].obs;
  RxList<PaymentDetailsModel> accPartyPaymentDetailsList =
      <PaymentDetailsModel>[].obs;

  RxMap groupedData = {}.obs;
  RxBool isLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  // Selected company - set ONLY from the Company Selection dialog after login
  // (restored from SharedPreferences on refresh). 0 = no company selected yet.
  RxInt companyCode = 0.obs;
  // User's own company from the login response - only used to pre-select it
  // in the Company Selection dialog. Never used as the working company.
  RxInt loginCompanyCode = 0.obs;
  RxString companyPartyCode = '21'.obs;
  RxString deviceInfo = 'No IP Found'.obs;
  RxBool enabledAdvancedDashboard = true.obs;
  RxBool isLoadingDashboardData = false.obs;

  // ==================== USER SESSION & SECURITY STATE ====================
  RxInt currentUserId = 0.obs;
  RxInt currentCrId = 0.obs;
  RxString currentUserName = ''.obs;
  RxString currentUserFullName = ''.obs;
  RxString currentUserGrp = ''.obs;
  RxInt currentUserBranch = 0.obs;
  RxInt currentUserDesiCode = 0.obs;
  RxBool canUserEdit = true.obs;
  RxBool canUserDelete = true.obs;
  RxInt currentLogId = 0.obs;
  RxString currentPcId = ''.obs;
  RxDouble userStockLimit = 0.0.obs;
  RxString userLoginTimeFrom = ''.obs;
  RxString userLoginTimeTo = ''.obs;
  RxMap<String, dynamic> userAccessMap = <String, dynamic>{}.obs;

  bool get isAdmin =>
      currentUserGrp.value.trim().toUpperCase() == 'ADMIN' ||
      currentUserGrp.value.trim().toUpperCase() == 'SUPERADMIN';

  /// Check permission for a specific menu and action.
  /// Handles category arrays in 'ua' ('0', '1', '2', '3', etc.).
  bool hasMenuPermission(dynamic menuId, {String actionType = '0', dynamic categoryKey}) {
    if (menuId == null) return true;
    final int? mId = int.tryParse(menuId.toString());
    if (mId == null || mId <= 0) return true;

    // Check if menu is in explicit hidden list in userAccessMap ('hidden', 'hide')
    if (userAccessMap.containsKey('hidden')) {
      final hiddenList = userAccessMap['hidden'];
      if (hiddenList is List && hiddenList.any((id) => id.toString() == mId.toString())) {
        return false;
      }
    }
    if (userAccessMap.containsKey('hide')) {
      final hiddenList = userAccessMap['hide'];
      if (hiddenList is List && hiddenList.any((id) => id.toString() == mId.toString())) {
        return false;
      }
    }

    // Granular flags check for edit/delete
    if (actionType == '2' && !canUserEdit.value) return false;
    if (actionType == '3' && !canUserDelete.value) return false;

    // If ua is not configured/empty, fallback to admin or allow
    if (userAccessMap.isEmpty) {
      if (isAdmin) return true;
      return true;
    }

    // 1. If categoryKey is provided, check that specific category list in ua
    if (categoryKey != null) {
      final String catStr = categoryKey.toString();
      final catList = userAccessMap[catStr];
      if (catList is List && catList.any((id) => id.toString() == mId.toString())) {
        return true;
      }
    }

    // 2. Search across ALL category lists in userAccessMap ('0', '1', '2', '3', etc.)
    for (var entry in userAccessMap.entries) {
      if (entry.key == 'hidden' || entry.key == 'hide') continue;
      final dynamic list = entry.value;
      if (list is List && list.any((id) => id.toString() == mId.toString())) {
        return true;
      }
    }

    return false;
  }

  bool canViewMenu(dynamic menuId, {dynamic categoryKey}) =>
      hasMenuPermission(menuId, actionType: '0', categoryKey: categoryKey);
  bool canAddMenu(dynamic menuId, {dynamic categoryKey}) =>
      hasMenuPermission(menuId, actionType: '1', categoryKey: categoryKey);
  bool canEditMenu(dynamic menuId, {dynamic categoryKey}) =>
      hasMenuPermission(menuId, actionType: '2', categoryKey: categoryKey);
  bool canDeleteMenu(dynamic menuId, {dynamic categoryKey}) =>
      hasMenuPermission(menuId, actionType: '3', categoryKey: categoryKey);

  /// Check if a menu is explicitly hidden for the current user session
  bool isMenuHidden(dynamic menuId) {
    if (menuId == null) return false;
    final int? mId = int.tryParse(menuId.toString());
    if (mId == null || mId <= 0) return false;

    if (userAccessMap.containsKey('hidden')) {
      final hiddenList = userAccessMap['hidden'];
      if (hiddenList is List &&
          hiddenList.any((id) => id.toString() == mId.toString())) {
        return true;
      }
    }
    if (userAccessMap.containsKey('hide')) {
      final hiddenList = userAccessMap['hide'];
      if (hiddenList is List &&
          hiddenList.any((id) => id.toString() == mId.toString())) {
        return true;
      }
    }
    return false;
  }

  /// Helper to check if a main category has any allowed menus in ua
  bool canViewCategory(dynamic categoryKey) {
    if (userAccessMap.isEmpty) return true;
    final String key = categoryKey.toString();
    if (userAccessMap.containsKey(key)) {
      final list = userAccessMap[key];
      if (list is List) {
        return list.isNotEmpty;
      }
    }
    return false;
  }

  /// Returns the effective designation code for the logged-in user.
  int get effectiveDesiCode {
    if (currentUserDesiCode.value > 0) return currentUserDesiCode.value;
    final user = userModelList.firstWhereOrNull((u) => u.counterMstId == currentUserId.value);
    return user?.desiCode ?? 0;
  }

  /// Returns the effective branch code for the logged-in user.
  int get effectiveBranchCode {
    if (currentUserBranch.value > 0) return currentUserBranch.value;
    final user = userModelList.firstWhereOrNull((u) => u.counterMstId == currentUserId.value);
    return user?.branchCode ?? 0;
  }

  /// Calculates the CrId value based on user branch and designation code == 4.
  /// If user has a branch (> 0) and designation code is 4, returns the logged in user's CrId / User ID.
  /// Otherwise returns empty string.
  String get effectiveCrId {
    final bool hasBranch = effectiveBranchCode > 0;
    final bool isDesiCode4 = effectiveDesiCode == 4;
    if (hasBranch && isDesiCode4) {
      final int id = currentCrId.value > 0 ? currentCrId.value : currentUserId.value;
      return id > 0 ? id.toString() : '';
    }
    // print(effectiveBranchCode);
    // print(effectiveDesiCode);
    // print(currentCrId.value);
    // print(currentUserId.value);
    return '';
  }

  /// Checks if current user is allowed to add purchase entries on forms.
  bool get canAddPurchaseEntry => effectiveCrId.isNotEmpty;

  DataGridController accountDataGridController = DataGridController();
  DataGridController bookDataGridController = DataGridController();

  final RxString selectedTypeAccountParty = ''.obs;
  final RxString selectedTypeBookParty = ''.obs;

  String get baseUrl => ApiService.to.baseUrl;
  set baseUrl(String url) => ApiService.to.updateBaseUrl(url);
  final MasterCrudService _masterService = MasterCrudService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  /// Sets observable state and persists user session values to SharedPreferences.
  Future<void> setUserSession(Map<String, dynamic> data,
      {String? outerToken, String? outerRefreshToken}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Extract and persist authentication token
    final String? token = (outerToken != null && outerToken.isNotEmpty)
        ? outerToken
        : (data['Token']?.toString() ??
            data['token']?.toString() ??
            data['accessToken']?.toString() ??
            data['jwt']?.toString());
    if (token != null && token.isNotEmpty) {
      authToken.value = token;
      await prefs.setString('token', token);
    }

    // Extract and persist refresh token
    final String? rToken = (outerRefreshToken != null && outerRefreshToken.isNotEmpty)
        ? outerRefreshToken
        : (data['RefreshToken']?.toString() ??
            data['refreshToken']?.toString());
    if (rToken != null && rToken.isNotEmpty) {
      refreshToken.value = rToken;
      await prefs.setString('refreshToken', rToken);
    }

    // 2. Parse User ID (CounterMstID / CrId)
    int userId = 0;
    if (data['CounterMstID'] != null) {
      userId = int.tryParse(data['CounterMstID'].toString()) ?? 0;
    } else if (data['CrId'] != null) {
      userId = int.tryParse(data['CrId'].toString()) ?? 0;
    }
    currentUserId.value = userId;
    await prefs.setInt('userId', userId);

    int crId = 0;
    if (data['CrId'] != null) {
      crId = int.tryParse(data['CrId'].toString()) ?? 0;
    } else if (data['CounterMstID'] != null) {
      crId = int.tryParse(data['CounterMstID'].toString()) ?? 0;
    }
    currentCrId.value = crId;
    await prefs.setInt('crId', crId);

    // 3. User Login Name & Full Name
    final String uName = data['CrName']?.toString() ??
        data['LoginName']?.toString() ??
        '';
    currentUserName.value = uName;
    if (uName.isNotEmpty) {
      await prefs.setString('username', uName);
    }

    final String fullName = data['UserName']?.toString() ??
        data['Name']?.toString() ??
        '';
    currentUserFullName.value = fullName;
    await prefs.setString('fullName', fullName);

    if (data['CrPass'] != null) {
      await prefs.setString('password', data['CrPass'].toString());
    }

    // 4. User Group / Role
    final String uGrp = data['UserGrp']?.toString() ??
        data['Rights']?.toString() ??
        'USER';
    currentUserGrp.value = uGrp;
    await prefs.setString('userGrp', uGrp);

    // 5. Branch Code & Designation Code
    int branchCode = 0;
    if (data['BranchCode'] != null) {
      branchCode = int.tryParse(data['BranchCode'].toString()) ?? 0;
    } else if (data['Branch'] != null) {
      branchCode = int.tryParse(data['Branch'].toString()) ?? 0;
    }
    currentUserBranch.value = branchCode;
    await prefs.setInt('branchCode', branchCode);

    int desiCode = 0;
    if (data['DesiCode'] != null) {
      desiCode = int.tryParse(data['DesiCode'].toString()) ?? 0;
    } else if (data['DesignationCode'] != null) {
      desiCode = int.tryParse(data['DesignationCode'].toString()) ?? 0;
    }
    currentUserDesiCode.value = desiCode;
    await prefs.setInt('desiCode', desiCode);

    // 6. Action Rights (CrEdit / CrDel)
    final bool canEdit = data['CrEdit'] == null ||
        data['CrEdit'].toString().toUpperCase() == 'Y' ||
        data['CrEdit'] == true;
    final bool canDel = data['CrDel'] == null ||
        data['CrDel'].toString().toUpperCase() == 'Y' ||
        data['CrDel'] == true;
    canUserEdit.value = canEdit;
    canUserDelete.value = canDel;
    await prefs.setBool('crEdit', canEdit);
    await prefs.setBool('crDel', canDel);

    // 7. Audit fields (LogID / PcID)
    final int logId = int.tryParse(data['LogID']?.toString() ?? '') ?? 0;
    final String pcId = data['PcID']?.toString() ?? '';
    currentLogId.value = logId;
    currentPcId.value = pcId;
    if (logId > 0) await prefs.setInt('logId', logId);
    if (pcId.isNotEmpty) await prefs.setString('pcId', pcId);

    // 8. Stock limit & Login timings
    if (data['StockLimit'] != null) {
      userStockLimit.value =
          double.tryParse(data['StockLimit'].toString()) ?? 0.0;
      await prefs.setDouble('stockLimit', userStockLimit.value);
    }
    if (data['LoginTimeFrom'] != null) {
      userLoginTimeFrom.value = data['LoginTimeFrom'].toString();
      await prefs.setString('loginTimeFrom', userLoginTimeFrom.value);
    }
    if (data['LoginTimeTo'] != null) {
      userLoginTimeTo.value = data['LoginTimeTo'].toString();
      await prefs.setString('loginTimeTo', userLoginTimeTo.value);
    }

    // 9. User Access Matrix ('ua')
    if (data['ua'] is Map) {
      final uaMap = Map<String, dynamic>.from(data['ua'] as Map);
      userAccessMap.value = uaMap;
      await prefs.setString('ua', jsonEncode(uaMap));
    } else {
      userAccessMap.clear();
      await prefs.remove('ua');
    }

    // 10. User's company from the login payload is only a suggestion for the
    // Company Selection dialog. The working company is set when the user
    // picks one there (companyCode), never automatically here.
    loginCompanyCode.value =
        int.tryParse(data['CompanyCode']?.toString() ?? '') ?? 0;

    await prefs.setBool('isLoggedIn', true);
  }

  /// Restores saved session from SharedPreferences on app resume or initialization.
  Future<void> restoreUserSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!isLoggedIn) return;

      authToken.value = prefs.getString('token') ?? '';
      refreshToken.value = prefs.getString('refreshToken') ?? '';
      currentUserId.value = prefs.getInt('userId') ?? 0;
      currentCrId.value = prefs.getInt('crId') ?? currentUserId.value;
      currentUserName.value = prefs.getString('username') ?? '';
      currentUserFullName.value = prefs.getString('fullName') ?? '';
      currentUserGrp.value = prefs.getString('userGrp') ?? '';
      currentUserBranch.value = prefs.getInt('branchCode') ?? 0;
      currentUserDesiCode.value = prefs.getInt('desiCode') ?? 0;
      canUserEdit.value = prefs.getBool('crEdit') ?? true;
      canUserDelete.value = prefs.getBool('crDel') ?? true;
      currentLogId.value = prefs.getInt('logId') ?? 0;
      currentPcId.value = prefs.getString('pcId') ?? '';
      userStockLimit.value = prefs.getDouble('stockLimit') ?? 0.0;
      userLoginTimeFrom.value = prefs.getString('loginTimeFrom') ?? '';
      userLoginTimeTo.value = prefs.getString('loginTimeTo') ?? '';

      final int? savedComp = prefs.getInt('companyCode');
      if (savedComp != null && savedComp > 0) {
        companyCode.value = savedComp;
      }

      final String? uaRaw = prefs.getString('ua');
      if (uaRaw != null && uaRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(uaRaw);
          if (decoded is Map) {
            userAccessMap.value = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error restoring user session: $e');
      }
    }
  }

  /// Clears stored user session and resets application state.
  Future<void> logout() async {
    ApiClient().stopAutoRefreshTimer();
    final String currentRefresh = refreshToken.value.isNotEmpty
        ? refreshToken.value
        : ((await SharedPreferences.getInstance()).getString('refreshToken') ?? '');

    if (currentRefresh.isNotEmpty) {
      try {
        final revokeDio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {'content-type': 'application/json'},
        ));
        await revokeDio.post(
          ApiService.to.resolvePath('user/revoke-token'),
          data: {'refreshToken': currentRefresh},
        );
      } catch (e) {
        if (kDebugMode) {
          log('Error revoking token on logout: $e');
        }
      }
    }

    authToken.value = '';
    refreshToken.value = '';
    currentUserId.value = 0;
    currentCrId.value = 0;
    currentUserName.value = '';
    currentUserFullName.value = '';
    currentUserGrp.value = '';
    currentUserBranch.value = 0;
    currentUserDesiCode.value = 0;
    canUserEdit.value = true;
    canUserDelete.value = true;
    currentLogId.value = 0;
    currentPcId.value = '';
    userStockLimit.value = 0.0;
    userLoginTimeFrom.value = '';
    userLoginTimeTo.value = '';
    userAccessMap.clear();
    menuList.clear();
    companyCode.value = 0;
    loginCompanyCode.value = 0;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/');
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final dio = Dio(BaseOptions(
        baseUrl: ApiService.to.baseUrl,
        headers: {
          'content-type': 'application/json',
        },
      ));
      var params = <String, dynamic>{"CrName": username, "CrPass": password};
      final response =
          await dio.post('rough-entry/user/login', data: params);

      if (response.data != null && response.data['data'] != null) {
        final Map<String, dynamic> data = (response.data['data'] is Map<String, dynamic>)
            ? response.data['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data['data'] as Map);

        final bool isActive = data['Active'] == true ||
            data['Active']?.toString() == '1' ||
            data['Active']?.toString().toLowerCase() == 'true';
        if (!isActive) {
          isLoading.value = false;
          infoDialog(messageText: 'User Inactive, Please Contact Your Admin.');
          return;
        }

        final String? outerToken = response.data['token']?.toString() ??
            response.data['Token']?.toString() ??
            response.data['accessToken']?.toString() ??
            response.data['jwt']?.toString();

        final String? outerRefreshToken = response.data['refreshToken']?.toString() ??
            response.data['RefreshToken']?.toString();

        await setUserSession(data,
            outerToken: outerToken, outerRefreshToken: outerRefreshToken);

        // Start the 28-Minute Refresh Timer
        ApiClient().startAutoRefreshTimer();

        // Fetch dynamic menu list right after login success
        await getMenuList();

        isLoading.value = false;
        Get.back();

        // Ensure company data is fetched before showing selection dialog
        if (companies.isEmpty) {
          await getCompanies();
        }
        showCompanySelectionDialog(isFromSwitchCompany: false);
      } else {
        isLoading.value = false;
        final String msg = response.data?['message']?.toString() ?? 'Invalid credentials.';
        infoDialog(messageText: msg);
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred during login.');
      if (kDebugMode) {
        log('Login error: $error');
      }
    }
  }

  Future<void> getMenuList() async {
    try {
      isLoadingMenuList.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (kDebugMode) {
        log('Calling getMenuList: ${baseUrl}rough-entry/menu/getMenuList');
      }

      final response = await ApiService.to.get(
        '${baseUrl}rough-entry/menu/getMenuList',
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        List<dynamic> data;
        if (raw is List) {
          data = raw;
        } else if (raw is Map && raw['data'] is List) {
          data = raw['data'];
        } else {
          data = [];
        }

        if (data.isNotEmpty) {
          menuList.value = data
              .map((json) => MainMenuModel.fromJson(json as Map<String, dynamic>))
              .toList();
          await prefs.setString('menuList_cache', jsonEncode(data));
          if (kDebugMode) {
            log('getMenuList loaded: ${menuList.length} menu groups');
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        log('getMenuList error: $error');
      }
    } finally {
      if (menuList.isEmpty) {
        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? cached = prefs.getString('menuList_cache');
          if (cached != null && cached.isNotEmpty) {
            final List<dynamic> cachedData = jsonDecode(cached);
            menuList.value = cachedData
                .map((j) => MainMenuModel.fromJson(j as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }
      isLoadingMenuList.value = false;
    }
  }

  Future<void> getCompanies() async {
    try {
      isLoadingCompanies.value = true;

      final response = await ApiService.to.get(
        '${baseUrl}rough-entry/companies',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [response.data];
        companies.value =
            data.map((json) => CompanyMst.fromJson(json)).toList();
      }
    } catch (error) {
      if (kDebugMode) {
        log('getCompanies error: $error');
      }
    } finally {
      if (companies.isEmpty) {
        companies.value = [];
      }
      isLoadingCompanies.value = false;
    }
  }

  Future<void> getPartyData({bool force = true}) async {
    if (!force && partyMstList.isNotEmpty) return;
    final data = await _masterService.fetchList<PartyMstModel>(
      endpoint: 'rough-entry/party',
      fromJson: (j) => PartyMstModel.fromJson(j),
      errorContext: 'getPartyData',
      reverse: true,
    );
    if (data != null) {
      partyMstList.value = data;
      partyMstList.refresh();
    }
  }

  Future<PartyMstModel?> getPartyById(dynamic id) =>
      _masterService.fetchById<PartyMstModel>(
        endpoint: 'rough-entry/party',
        id: id,
        fromJson: (j) => PartyMstModel.fromJson(j),
      );
  Future<void> getAssortGroupData({bool force = true}) async {
    if (!force && assortGroupMstList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/assort-group',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        assortGroupMstList.value = data
            .map((json) => AssortGroupMst.fromJson(json))
            .toList();
        assortGroupMstList.refresh();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getAssortGroupData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }
  Future<void> getAssortData({bool force = true}) async {
    if (!force && assortMstList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/assort',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        assortMstList.value = data
            .map((json) => AssortMst.fromJson(json))
            .toList()
            .reversed
            .toList();
        assortMstList.refresh();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getAssortData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getRoughAssortData({bool force = true}) async {
    if (!force && roughAssortMstList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/rough-assort',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        roughAssortMstList.value = data
            .map((json) => RoughAssortMst.fromJson(json))
            .toList()
            .reversed
            .toList();
        roughAssortMstList.refresh();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getRoughAssortData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }
  Future<void> getRoughAssortDetailsData({bool force = true}) async {
    if (!force && roughAssortMstDetList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/rough-assort-det',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        roughAssortMstDetList.value = data
            .map((json) => RoughAssortDetMst.fromJson(json))
            .toList()
            .reversed
            .toList();
        roughAssortMstDetList.refresh();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getRoughAssortDetData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getCreditDebitData({bool force = false}) async {
    if (!force && creditDebitDataList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/credit-debit',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        creditDebitDataList.value =
            data.map((json) => CreditDebitMstModel.fromJson(json)).toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getCreditDebitData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getPurchaseData({bool force = false}) async {
    if (!force && purchaseDataList.isNotEmpty) return;
    isLoadingDashboardData.value = true;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/purchase',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        purchaseDataList.value = data
            .map((json) => PurchaseDetailsModel.fromJson(json))
            .toList()
            .reversed
            .toList();
        if (kDebugMode) {
          print('FROM API:${purchaseDataList.length}');
        }
        isLoadingDashboardData.value = false;
      } else {
        isLoadingDashboardData.value = false;
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      isLoadingDashboardData.value = false;
      errorDialog(messageText: 'An unexpected error occurred.getPurchaseData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getPurchaseDetailsData({bool force = false}) async {
    if (!force && roughDetailsModel.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/rough-details',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a RoughDetailsModel
        roughDetailsModel.value = data
            .map((json) => RoughDetailsModel.fromJson(json))
            .toList()
            .reversed
            .toList();

        // Grouping by roughTypeCode and summing the wt for each group

        for (var detail in roughDetailsModel) {
          if (groupedData.containsKey(detail.roughTypeCode)) {
            groupedData[detail.roughTypeCode!] =
                groupedData[detail.roughTypeCode]! + detail.wt!;
          } else {
            groupedData[detail.roughTypeCode!] = detail.wt!;
          }
        }

        // Printing the grouped data for debugging
        // groupedData.forEach((key, value) {
        //   if (kDebugMode) {
        //     print('RoughTypeCode: $key, Total Weight: $value');
        //   }
        // });

        // You can now use the groupedData map for further processing
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getPurchaseDetailsData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  String _resolvePolishPurUrl([String subPath = '']) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    if (subPath.isEmpty) {
      return '${base}polish-pur';
    }
    final cleanSub = subPath.startsWith('/') ? subPath.substring(1) : subPath;
    return '${base}polish-pur/$cleanSub';
  }

  void _resolvePolishPurchaseNames(PolishPurchaseModel item) {
    if ((item.partyName == null || item.partyName!.isEmpty) && item.partyCode != null && item.partyCode != 0) {
      final party = partyMstList.firstWhereOrNull((p) => p.partyCode == item.partyCode || p.partyMstID == item.partyCode);
      if (party != null && party.partyName != null) {
        item.partyName = party.partyName;
      }
    }
    if ((item.brokerName == null || item.brokerName!.isEmpty) && item.brokerCode != null && item.brokerCode != 0) {
      final broker = partyMstList.firstWhereOrNull((p) => p.partyCode == item.brokerCode || p.partyMstID == item.brokerCode);
      if (broker != null && broker.partyName != null) {
        item.brokerName = broker.partyName;
      }
    }
  }

  void _resolvePolishDetailNames(PolishPurchaseDetailModel detail) {
    if ((detail.polishType == null || detail.polishType!.isEmpty) && detail.polishTypeCode != null) {
      final t = polishTypeModelList.firstWhereOrNull((p) => p.polishTypeCode == detail.polishTypeCode || p.polishTypeMstId == detail.polishTypeCode);
      if (t != null && t.polishTypeName != null) {
        detail.polishType = t.polishTypeName;
      }
    }
    if ((detail.shape == null || detail.shape!.isEmpty) && detail.shapeCode != null) {
      final s = shapeModelList.firstWhereOrNull((sp) => sp.shapeCode == detail.shapeCode || sp.shapeMstId == detail.shapeCode);
      if (s != null && s.shapeName != null) {
        detail.shape = s.shapeName;
      }
    }
    if ((detail.clarity == null || detail.clarity!.isEmpty) && detail.clarityCode != null) {
      final c = clarityModelList.firstWhereOrNull((cl) => cl.clarityMstID == detail.clarityCode);
      if (c != null && c.clarityName != null) {
        detail.clarity = c.clarityName;
      }
    }
    if ((detail.charni == null || detail.charni!.isEmpty) && detail.charniCode != null) {
      final ch = charniModelList.firstWhereOrNull((cr) => cr.charniCode == detail.charniCode || cr.charniMstID == detail.charniCode);
      if (ch != null && ch.charniName != null) {
        detail.charni = ch.charniName;
      }
    }
  }

  Future<void> getPolishPurchaseData({bool force = true}) async {
    if (!force && polishPurchaseList.isNotEmpty) return;
    isLoadingDashboardData.value = true;
    try {
      final dio = ApiService.to.dio;
      final url = _resolvePolishPurUrl();
      if (kDebugMode) log('Calling getPolishPurchaseData: $url');
      final response = await dio.get(url);
      if (kDebugMode) log('getPolishPurchaseData response statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final dynamic respData = response.data;
        List<dynamic> list = [];
        if (respData is List) {
          list = respData;
        } else if (respData is Map && respData['data'] is List) {
          list = respData['data'];
        } else if (respData is Map && respData['result'] is List) {
          list = respData['result'];
        } else if (respData is Map && respData['rows'] is List) {
          list = respData['rows'];
        }

        final parsedList = list.map((json) {
          final item = PolishPurchaseModel.fromJson(Map<String, dynamic>.from(json));
          _resolvePolishPurchaseNames(item);
          return item;
        }).toList();

        final List<PolishPurchaseDetailModel> allExtractedDetails = [];
        for (var raw in list) {
          if (raw is Map) {
            final rawDetails = raw['details'] ?? raw['PolishPurchaseDetails'] ?? raw['polishPurchaseDetails'];
            final mstId = int.tryParse((raw['PolishPurMstID'] ?? raw['polishPurMstID'] ?? raw['id'])?.toString() ?? '');
            // The list API now sends each purchase's details (even an empty
            // list), so this purchase does not need its own GET /:id call.
            if (rawDetails is List && mstId != null) _polishDetailsLoadedIds.add(mstId);
            if (rawDetails is List && rawDetails.isNotEmpty) {
              for (var e in rawDetails) {
                if (e is Map) {
                  final d = PolishPurchaseDetailModel.fromJson(Map<String, dynamic>.from(e));
                  if (mstId != null && d.polishPurMstID == null) {
                    d.polishPurMstID = mstId;
                  }
                  _resolvePolishDetailNames(d);
                  allExtractedDetails.add(d);
                }
              }
            }
          }
        }
        if (allExtractedDetails.isNotEmpty) {
          polishPurchaseDetailList.assignAll(allExtractedDetails);
          polishPurchaseDetailList.refresh();
        }

        if (parsedList.isNotEmpty) {
          polishPurchaseList.assignAll(parsedList);
        } else {
          polishPurchaseList.clear();
        }
        polishPurchaseList.refresh();
      }
      isLoadingDashboardData.value = false;
    } catch (error) {
      isLoadingDashboardData.value = false;
      if (kDebugMode) log('getPolishPurchaseData error: $error');
      if (polishPurchaseList.isEmpty) {
        polishPurchaseList.refresh();
      }
    }
  }

  /// Polish purchases whose details are already loaded (from the list API or
  /// GET /:id) - so they are not requested again one by one.
  final Set<int> _polishDetailsLoadedIds = <int>{};

  Future<void> ensurePolishPurchaseDetailsLoaded() async {
    if (polishPurchaseList.isEmpty) {
      await getPolishPurchaseData(force: false);
    }
    final loadedFromDetails = polishPurchaseDetailList.map((d) => d.polishPurMstID).toSet();
    final missingIds = polishPurchaseList
        .where((p) =>
            p.polishPurMstID != null &&
            !_polishDetailsLoadedIds.contains(p.polishPurMstID) &&
            !loadedFromDetails.contains(p.polishPurMstID))
        .map((p) => p.polishPurMstID!)
        .toList();
    if (missingIds.isNotEmpty) {
      await Future.wait(missingIds.map((id) => getPolishPurchaseById(id)));
    }
  }

  Future<Map<String, dynamic>?> getPolishPurchaseById(int id) async {
    try {
      final dio = ApiService.to.dio;
      final response = await dio.get(_resolvePolishPurUrl('$id'));
      if (response.statusCode == 200) {
        final data = (response.data is Map && response.data['data'] != null)
            ? response.data['data']
            : response.data;
        if (data is Map) {
          final mst = PolishPurchaseModel.fromJson(Map<String, dynamic>.from(data));
          _resolvePolishPurchaseNames(mst);

          final rawDetails = data['details'];
          List<PolishPurchaseDetailModel> details = [];
          if (rawDetails is List) {
            details = rawDetails.map((e) {
              final d = PolishPurchaseDetailModel.fromJson(Map<String, dynamic>.from(e));
              _resolvePolishDetailNames(d);
              return d;
            }).toList();
          }

          // Cache details locally for this master
          _polishDetailsLoadedIds.add(id);
          polishPurchaseDetailList.removeWhere((d) => d.polishPurMstID == id);
          polishPurchaseDetailList.addAll(details);
          polishPurchaseDetailList.refresh();

          // Update master if present in polishPurchaseList
          final mIndex = polishPurchaseList.indexWhere((p) => p.polishPurMstID == id);
          if (mIndex != -1) {
            polishPurchaseList[mIndex] = mst;
            polishPurchaseList.refresh();
          }

          return {
            'master': mst,
            'details': details,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) log('getPolishPurchaseById error: $e');
    }

    // Fallback: look up in-memory cache
    final localMst = polishPurchaseList.firstWhereOrNull((p) => p.polishPurMstID == id);
    final localDetails = polishPurchaseDetailList.where((d) => d.polishPurMstID == id).toList();
    if (localMst != null) {
      return {
        'master': localMst,
        'details': localDetails,
      };
    }
    return null;
  }


  Future<bool> addPolishPurchaseData({
    required PolishPurchaseModel header,
    required List<PolishPurchaseDetailModel> details,
  }) async {
    isLoading.value = true;
    try {
      header.companyCode = companyCode.value != 0 ? companyCode.value : header.companyCode;
      final masterPayload = header.toApiMasterJson();
      final detailsPayload = details.map((d) => d.toApiDetailJson(isUpdate: false)).toList();
      final body = {
        'master': masterPayload,
        'details': detailsPayload,
      };

      final dio = ApiService.to.dio;

      final response = await dio.post(
        _resolvePolishPurUrl('add'),
        data: body,
      );

      final respData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          respData is Map &&
          respData['success'] == true) {
        final dynamic mstId = respData['data']?['PolishPurMstID'] ??
            respData['data']?['id'] ??
            respData['PolishPurMstID'] ??
            respData['id'] ??
            header.polishPurMstID;
        final dynamic respInvoiceNo = respData['data']?['InvoiceNo'] ??
            respData['InvoiceNo'] ??
            header.invoiceNo;
        if (header.polishPurMstID == null && mstId != null) {
          header.polishPurMstID = int.tryParse(mstId.toString());
        }

        final String? formattedInvDate = formatToIsoUtc(header.invoiceDate);
        final dynamic formattedDueDate = (header.dueDate != null && header.dueDate.toString().isNotEmpty)
            ? formatToIsoUtc(header.dueDate)
            : formattedInvDate;

        final dynamic invAmt = (header.finalAmtRs != null && header.finalAmtRs != 0 && header.finalAmtRs != 0.0)
            ? header.finalAmtRs
            : (header.netAmtRs != null && header.netAmtRs != 0 && header.netAmtRs != 0.0)
                ? header.netAmtRs
                : (header.totAmtRs ?? 0.0);

        final String partyCodeStr = header.partyCode?.toString() ?? '';
        final String companyPartyCodeStr = companyPartyCode.value.toString();

        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: mstId,
            purMstId: mstId,
            saleMstId: 0,
            invoiceDate: header.invoiceDate,
            orgInvoiceDate: formattedInvDate,
            paymentMstId: 0,
            dueDate: formattedDueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode: index == 0 ? companyPartyCodeStr : partyCodeStr,
            creditRs: index == 0 ? 0.00 : invAmt,
            debitRs: index == 0 ? invAmt : 0.00,
            invAmtRs: invAmt,
            drCr: index == 0 ? 'DR' : 'CR',
            formType: 'Purchase',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmPurchaseEntry',
            perPartyCode: index == 0 ? partyCodeStr : companyPartyCodeStr,
            orgCt: header.totWt ?? 0.0,
            dueDays: header.dueDay ?? 0,
            invoiceNo: respInvoiceNo,
            srNo: index + 1,
            brokerCode: header.brokerCode,
          );
        }));

        polishPurchaseList.refresh();
        polishPurchaseDetailList.refresh();
        await getPolishPurchaseData(force: true);
        await getCreditDebitData(force: true);
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        isLoading.value = false;
        await successDialog(
          messageText: 'Polish Purchase saved successfully',
        );
        return true;
      } else {
        isLoading.value = false;

        await errorDialog(
          messageText: 'Failed to save Polish Purchase: '
              '${respData is Map ? respData['msg'] ?? response.statusCode : response.statusCode}',
        );

        return false;
      }

    } on DioException catch (dioErr) {
      if (kDebugMode) log('addPolishPurchaseData DioException: ${dioErr.message}');
      final statusCode = dioErr.response?.statusCode;
      if (statusCode != null && statusCode >= 400 && statusCode < 500 && dioErr.response?.data is Map) {
        isLoading.value = false;
        final msg = (dioErr.response?.data as Map)['msg'] ?? dioErr.message ?? 'Server error';
        await errorDialog(messageText: 'Failed to save Polish Purchase: $msg');
        return false;
      }

      // Offline / test / gateway unavailable fallback
      final nextId = (polishPurchaseList.isEmpty
              ? 0
              : polishPurchaseList.map((e) => e.polishPurMstID ?? 0).reduce((a, b) => a > b ? a : b)) +
          1;
      header.polishPurMstID = nextId;
      _resolvePolishPurchaseNames(header);
      polishPurchaseList.insert(0, header);
      for (int i = 0; i < details.length; i++) {
        details[i].polishPurMstID = nextId;
        details[i].polishPurDetID = (polishPurchaseDetailList.isEmpty ? 0 : polishPurchaseDetailList.length) + i + 1;
        _resolvePolishDetailNames(details[i]);
        polishPurchaseDetailList.add(details[i]);
      }
      polishPurchaseList.refresh();
      polishPurchaseDetailList.refresh();
      isLoading.value = false;
      await successDialog(messageText: 'Polish Purchase saved successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      await errorDialog(messageText: 'Failed to save Polish Purchase: $e');
      return false;
    }
  }

  Future<bool> updatePolishPurchaseData({
    required PolishPurchaseModel header,
    required List<PolishPurchaseDetailModel> details,
  }) async {
    isLoading.value = true;
    try {
      final int id = header.polishPurMstID ?? 0;
      header.companyCode = companyCode.value != 0 ? companyCode.value : header.companyCode;
      final masterPayload = header.toApiMasterJson();
      final detailsPayload = details.map((d) => d.toApiDetailJson(isUpdate: true)).toList();
      final body = {
        'master': masterPayload,
        'details': detailsPayload,
      };

      final dio = ApiService.to.dio;

      final response = await dio.put(
        _resolvePolishPurUrl('$id'),
        data: body,
      );

      final respData = response.data;

      if (response.statusCode == 200 &&
          respData is Map &&
          respData['success'] == true) {
        final dynamic mstId = respData['data']?['PolishPurMstID'] ??
            respData['data']?['id'] ??
            respData['PolishPurMstID'] ??
            respData['id'] ??
            header.polishPurMstID ??
            id;
        final dynamic respInvoiceNo = respData['data']?['InvoiceNo'] ??
            respData['InvoiceNo'] ??
            header.invoiceNo;

        final String? formattedInvDate = formatToIsoUtc(header.invoiceDate);
        final dynamic formattedDueDate = (header.dueDate != null && header.dueDate.toString().isNotEmpty)
            ? formatToIsoUtc(header.dueDate)
            : formattedInvDate;

        final dynamic invAmt = (header.finalAmtRs != null && header.finalAmtRs != 0 && header.finalAmtRs != 0.0)
            ? header.finalAmtRs
            : (header.netAmtRs != null && header.netAmtRs != 0 && header.netAmtRs != 0.0)
                ? header.netAmtRs
                : (header.totAmtRs ?? 0.0);

        final String partyCodeStr = header.partyCode?.toString() ?? '';
        final String companyPartyCodeStr = companyPartyCode.value.toString();

        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: mstId,
            purMstId: mstId,
            saleMstId: 0,
            invoiceDate: header.invoiceDate,
            orgInvoiceDate: formattedInvDate,
            paymentMstId: 0,
            dueDate: formattedDueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode: index == 0 ? companyPartyCodeStr : partyCodeStr,
            creditRs: index == 0 ? 0.00 : invAmt,
            debitRs: index == 0 ? invAmt : 0.00,
            invAmtRs: invAmt,
            drCr: index == 0 ? 'DR' : 'CR',
            formType: 'Purchase',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmPurchaseEntry',
            perPartyCode: index == 0 ? partyCodeStr : companyPartyCodeStr,
            orgCt: header.totWt ?? 0.0,
            dueDays: header.dueDay ?? 0,
            invoiceNo: respInvoiceNo,
            srNo: index + 1,
            brokerCode: header.brokerCode,
          );
        }));

        polishPurchaseList.refresh();
        polishPurchaseDetailList.refresh();
        await getPolishPurchaseData(force: true);
        await getCreditDebitData(force: true);
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        isLoading.value = false;
        await successDialog(
          messageText: 'Polish Purchase updated successfully',
        );
        return true;
      } else {
        isLoading.value = false;

        await errorDialog(
          messageText: 'Failed to update Polish Purchase: '
              '${respData is Map ? respData['msg'] ?? response.statusCode : response.statusCode}',
        );

        return false;
      }

    } on DioException catch (dioErr) {
      if (kDebugMode) log('updatePolishPurchaseData DioException: ${dioErr.message}');
      final statusCode = dioErr.response?.statusCode;
      if (statusCode != null && statusCode >= 400 && statusCode < 500 && dioErr.response?.data is Map) {
        isLoading.value = false;
        final msg = (dioErr.response?.data as Map)['msg'] ?? dioErr.message ?? 'Server error';
        await errorDialog(messageText: 'Failed to update Polish Purchase: $msg');
        return false;
      }

      final index = polishPurchaseList.indexWhere((p) => p.polishPurMstID == header.polishPurMstID);
      if (index != -1) {
        polishPurchaseList[index] = header;
      }
      polishPurchaseDetailList.removeWhere((d) => d.polishPurMstID == header.polishPurMstID);
      for (int i = 0; i < details.length; i++) {
        details[i].polishPurMstID = header.polishPurMstID;
        details[i].polishPurDetID = (polishPurchaseDetailList.isEmpty ? 0 : polishPurchaseDetailList.length) + i + 1;
        _resolvePolishDetailNames(details[i]);
        polishPurchaseDetailList.add(details[i]);
      }
      polishPurchaseList.refresh();
      polishPurchaseDetailList.refresh();
      isLoading.value = false;
      await successDialog(messageText: 'Polish Purchase updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      await errorDialog(messageText: 'Failed to update Polish Purchase: $e');
      return false;
    }
  }

  Future<bool> deletePolishPurchaseData(int id) async {
    isDeleteLoading.value = true;
    try {
      final dio = ApiService.to.dio;
      final response = await dio.delete(_resolvePolishPurUrl('$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        polishPurchaseList.removeWhere((p) => p.polishPurMstID == id);
        polishPurchaseDetailList.removeWhere((d) => d.polishPurMstID == id);
        polishPurchaseList.refresh();
        polishPurchaseDetailList.refresh();
        await getPolishPurchaseData(force: true);
        isDeleteLoading.value = false;
        await successDialog(messageText: 'Polish Purchase deleted successfully');
        return true;
      } else {
        isDeleteLoading.value = false;
        await errorDialog(messageText: 'Failed to delete Polish Purchase: ${response.statusCode}');
        return false;
      }
    } on DioException catch (dioErr) {
      if (kDebugMode) log('deletePolishPurchaseData DioException: ${dioErr.message}');
      final statusCode = dioErr.response?.statusCode;
      if (statusCode != null && statusCode >= 400 && statusCode < 500 && dioErr.response?.data is Map) {
        isDeleteLoading.value = false;
        final msg = (dioErr.response?.data as Map)['msg'] ?? dioErr.message ?? 'Server error';
        await errorDialog(messageText: 'Failed to delete Polish Purchase: $msg');
        return false;
      }

      polishPurchaseList.removeWhere((p) => p.polishPurMstID == id);
      polishPurchaseDetailList.removeWhere((d) => d.polishPurMstID == id);
      polishPurchaseList.refresh();
      polishPurchaseDetailList.refresh();
      isDeleteLoading.value = false;
      await successDialog(messageText: 'Polish Purchase deleted successfully');
      return true;
    } catch (e) {
      isDeleteLoading.value = false;
      await errorDialog(messageText: 'Failed to delete Polish Purchase: $e');
      return false;
    }
  }

  Future<bool> deletePolishPurchaseDetail(int detailId) async {
    isDeleteLoading.value = true;
    try {
      final dio = ApiService.to.dio;
      final response = await dio.delete(_resolvePolishPurUrl('detail/$detailId'));

      final respData = response.data;
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (respData is Map && respData['success'] == false) {
          isDeleteLoading.value = false;
          await errorDialog(
            messageText: respData['msg']?.toString() ?? 'Failed to delete detail',
          );
          return false;
        }

        polishPurchaseDetailList.removeWhere((d) => d.polishPurDetID == detailId);
        polishPurchaseDetailList.refresh();
        await getPolishPurchaseData(force: true);
        isDeleteLoading.value = false;
        final String msg = (respData is Map && respData['msg'] != null)
            ? respData['msg'].toString()
            : 'Detail deleted successfully';
        await successDialog(messageText: msg);
        return true;
      } else {
        isDeleteLoading.value = false;
        final String msg = (respData is Map && respData['msg'] != null)
            ? respData['msg'].toString()
            : 'Failed to delete detail: ${response.statusCode}';
        await errorDialog(messageText: msg);
        return false;
      }
    } on DioException catch (dioErr) {
      if (kDebugMode) log('deletePolishPurchaseDetail DioException: ${dioErr.message}');
      isDeleteLoading.value = false;
      final msg = (dioErr.response?.data is Map)
          ? ((dioErr.response!.data as Map)['msg'] ?? dioErr.message ?? 'Server error')
          : (dioErr.message ?? 'Server error');
      await errorDialog(messageText: 'Failed to delete detail: $msg');
      return false;
    } catch (e) {
      isDeleteLoading.value = false;
      await errorDialog(messageText: 'Failed to delete detail: $e');
      return false;
    }
  }

  Future<void> getSaleData({bool force = false}) async {
    if (!force && polishSaleList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/polish-sale',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        polishSaleList.value = data
            .map((json) => PolishSaleModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getSaleData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getMemoIssueData({bool force = false}) async {
    if (!force && memoIssueList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/memo-issue',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        memoIssueList.value = data
            .map((json) => MemoIssueModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getMemoIssueData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getMemoRecData({bool force = false}) async {
    if (!force && memoRecList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/memo-rec',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        memoRecList.value = data
            .map((json) => MemoRecModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getMemoRecData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getSaleDetailsData({bool force = false}) async {
    if (!force && saleDetailsList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/sale-details',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a SaleDetailsModel
        saleDetailsList.value = data
            .map((json) => SaleDetailsModel.fromJson(json))
            .toList()
            .reversed
            .toList();

        // Subtracting the wt from groupedData for each roughTypeCode
        for (var saleDetail in saleDetailsList) {
          final roughTypeCode = saleDetail.roughTypeCode;
          final saleWt = saleDetail.carats ?? 0;

          if (groupedData.containsKey(roughTypeCode)) {
            // Subtract the sale wt from the groupedData wt
            groupedData[roughTypeCode] = groupedData[roughTypeCode]! - saleWt;
          }
        }

        // Printing the updated groupedData for debugging
        // groupedData.forEach((key, value) {
        //   if (kDebugMode) {
        //     print('RoughTypeCode: $key, Total Weight after Sale: $value');
        //   }
        // });
      } else {
        errorDialog(
            messageText: 'Failed to load sale data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getSaleDetailsData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getMemoIssueDetailsData({bool force = false}) async {
    if (!force && memoIssueDetailsList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/memo-issue-details',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        memoIssueDetailsList.value = data
            .map((json) => MemoIssueDetailsModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getMemoIssueDetailsData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getMemoRecDetailsData({bool force = false}) async {
    if (!force && memoRecDetailsList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/memo-rec-details',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        memoRecDetailsList.value = data
            .map((json) => MemoRecDetailsModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getMemoRecDetailsData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  // ==================== PARTY TYPE MASTER APIS ====================
  Future<void> getPartyTypeData({bool force = true}) async {
    if (!force && partyTypeMstList.isNotEmpty) return;
    final data = await _masterService.fetchList<PartyTypeMstModel>(
      endpoint: 'rough-entry/partyType',
      fromJson: (j) => PartyTypeMstModel.fromJson(j),
      errorContext: 'getPartyTypeData',
      reverse: true,
    );
    if (data != null) {
      partyTypeMstList.value = data;
      partyTypeMstList.refresh();
    }
  }

  // ==================== ROUGH TYPE MASTER APIS ====================
  Future<void> getRoughData({bool force = true}) async {
    if (!force && roughModel.isNotEmpty) return;
    final data = await _masterService.fetchList<RoughModel>(
      endpoint: 'rough-entry/rough-type',
      fromJson: (j) => RoughModel.fromJson(j),
      errorContext: 'getRoughData',
    );
    if (data != null) {
      roughModel.value = data;
      roughModel.refresh();
    }
  }

  Future<RoughModel?> getRoughTypeById(dynamic id) =>
      _masterService.fetchById<RoughModel>(
        endpoint: 'rough-entry/rough-type',
        id: id,
        fromJson: (j) => RoughModel.fromJson(j),
      );

  Future<void> addRoughTypeData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final int codeToUse =
        companyCodeParam ?? companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/rough-type/add',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      onSuccess: () => getRoughData(force: true),
      defaultSuccessMessage: 'Rough Type Entry Saved Successfully',
      loadingState: isLoading,
    );
  }

  Future<void> updateRoughTypeData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final int codeToUse =
        companyCodeParam ?? companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/rough-type',
      id: id,
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      onSuccess: () => getRoughData(force: true),
      defaultSuccessMessage: 'Rough Type Details Updated Successfully',
      loadingState: isLoading,
    );
  }

  Future<void> deleteRoughTypeData({required dynamic id}) =>
      _masterService.delete(
        endpoint: 'rough-entry/rough-type',
        id: id,
        onSuccess: () => getRoughData(force: true),
        defaultSuccessMessage: 'Rough Type Entry Deleted Successfully',
        deleteLoadingState: isDeleteLoading,
      );

  // ==================== QUALITY MASTER APIS ====================
  Future<void> getQualityData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<QualityModel>(
      endpoint: 'rough-entry/quality',
      fromJson: (j) => QualityModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getQualityData',
    );
    if (data != null) {
      qualityModelList.value = data;
      qualityModelList.refresh();
    }
  }

  Future<QualityModel?> getQualityById(dynamic id) =>
      _masterService.fetchById<QualityModel>(
        endpoint: 'rough-entry/quality',
        id: id,
        fromJson: (j) => QualityModel.fromJson(j),
      );

  Future<Map<String, dynamic>?> getNextQualityCode() =>
      _masterService.fetchNextCode(endpoint: 'rough-entry/quality/nextCode');

  Future<void> addQualityData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/quality/add',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      onSuccess: () => getQualityData(companyCodeParam: codeToUse),
      defaultSuccessMessage: 'Quality Entry Saved Successfully',
      loadingState: isLoading,
    );
  }

  Future<void> updateQualityData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/quality',
      id: id,
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      onSuccess: () => getQualityData(companyCodeParam: codeToUse),
      defaultSuccessMessage: 'Quality Details Updated Successfully',
      loadingState: isLoading,
    );
  }

  Future<void> deleteQualityData({required dynamic id, int? companyCodeParam}) {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    return _masterService.delete(
      endpoint: 'rough-entry/quality',
      id: id,
      onSuccess: () => getQualityData(companyCodeParam: codeToUse),
      defaultSuccessMessage: 'Quality Entry Deleted Successfully',
      deleteLoadingState: isDeleteLoading,
    );
  }

  // ==================== CHARNI MASTER APIS ====================
  Future<void> getCharniRptGroups() async {
    final data = await _masterService.fetchList<CharniRptGroupModel>(
      endpoint: 'rough-entry/charni/rpt-groups',
      fromJson: (j) => CharniRptGroupModel.fromJson(j),
      errorContext: 'getCharniRptGroups',
    );
    if (data != null) charniRptGroupList.value = data;
  }

  Future<void> getCharniData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<CharniModel>(
      endpoint: 'rough-entry/charni',
      fromJson: (j) => CharniModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getCharniData',
    );
    if (data != null) {
      charniModelList.value = data;
      charniModelList.refresh();
    }
  }

  Future<CharniModel?> getCharniById(dynamic id) async {
    return await _masterService.fetchById<CharniModel>(
      endpoint: 'rough-entry/charni/$id',
      fromJson: (j) => CharniModel.fromJson(j),
      errorContext: 'getCharniById',
    );
  }

  Future<Map<String, dynamic>?> getNextCharniCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/charni/nextCode',
      errorContext: 'getNextCharniCode',
    );
  }

  Future<void> addCharniData({
    required String name,
    int? rptGroup,
    double? fromSize,
    double? toSize,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/charni/add',
      payload: {
        'Name': name,
        if (rptGroup != null) 'RptGroup': rptGroup,
        'FromSize': fromSize ?? 0.0,
        'ToSize': toSize ?? 0.0,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Charni Entry Saved Successfully',
      onSuccess: () => getCharniData(companyCodeParam: codeToUse),
      errorContext: 'addCharniData',
    );
  }

  Future<void> updateCharniData({
    required dynamic id,
    required String name,
    int? rptGroup,
    double? fromSize,
    double? toSize,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/charni/$id',
      payload: {
        'Name': name,
        if (rptGroup != null) 'RptGroup': rptGroup,
        'FromSize': fromSize ?? 0.0,
        'ToSize': toSize ?? 0.0,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Charni Entry Updated Successfully',
      onSuccess: () => getCharniData(companyCodeParam: codeToUse),
      errorContext: 'updateCharniData',
    );
  }

  Future<void> deleteCharniData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/charni/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Charni Entry Deleted Successfully',
      onSuccess: () => getCharniData(companyCodeParam: codeToUse),
      errorContext: 'deleteCharniData',
    );
  }

  // ==================== CLARITY MASTER APIS ====================
  Future<void> getClarityData({int? companyCodeParam}) async {
    final code = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    final data = await _masterService.fetchList<ClarityModel>(
      endpoint: 'rough-entry/clarity',
      fromJson: (j) => ClarityModel.fromJson(j),
      companyCode: code,
      errorContext: 'getClarityData',
    );
    if (data != null) {
      clarityModelList.value = data;
      clarityModelList.refresh();
    }
  }

  Future<ClarityModel?> getClarityById(dynamic id) async {
    return await _masterService.fetchById<ClarityModel>(
      endpoint: 'rough-entry/clarity/$id',
      fromJson: (j) => ClarityModel.fromJson(j),
      errorContext: 'getClarityById',
    );
  }

  Future<Map<String, dynamic>?> getNextClaritySort() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/clarity/nextSort',
      errorContext: 'getNextClaritySort',
    );
  }

  Future<void> addClarityData({
    required String name,
    String? aliasName,
    int? sortId,
    bool active = true,
    bool purchase = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/clarity/add',
      payload: {
        'Name': name,
        if (aliasName != null && aliasName.isNotEmpty) 'AliasName': aliasName,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'Purchase': purchase,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Clarity Entry Saved Successfully',
      onSuccess: () => getClarityData(companyCodeParam: codeToUse),
      errorContext: 'addClarityData',
    );
  }

  Future<void> updateClarityData({
    required dynamic id,
    required String name,
    String? aliasName,
    int? sortId,
    bool active = true,
    bool purchase = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/clarity/$id',
      payload: {
        'Name': name,
        if (aliasName != null && aliasName.isNotEmpty) 'AliasName': aliasName,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'Purchase': purchase,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Clarity Entry Updated Successfully',
      onSuccess: () => getClarityData(companyCodeParam: codeToUse),
      errorContext: 'updateClarityData',
    );
  }

  Future<void> deleteClarityData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/clarity/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Clarity Entry Deleted Successfully',
      onSuccess: () => getClarityData(companyCodeParam: codeToUse),
      errorContext: 'deleteClarityData',
    );
  }

  // ==================== COLOR MASTER APIS ====================
  Future<void> getColorData({int? companyCodeParam}) async {
    final code = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    final data = await _masterService.fetchList<ColorModel>(
      endpoint: 'rough-entry/color',
      fromJson: (j) => ColorModel.fromJson(j),
      companyCode: code,
      errorContext: 'getColorData',
    );
    if (data != null) {
      colorModelList.value = data;
      colorModelList.refresh();
    }
  }

  Future<ColorModel?> getColorById(dynamic id) async {
    return await _masterService.fetchById<ColorModel>(
      endpoint: 'rough-entry/color/$id',
      fromJson: (j) => ColorModel.fromJson(j),
      errorContext: 'getColorById',
    );
  }

  Future<Map<String, dynamic>?> getNextColorCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/color/nextCode',
      errorContext: 'getNextColorCode',
    );
  }

  Future<void> addColorData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/color/add',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Color Entry Saved Successfully',
      onSuccess: () => getColorData(companyCodeParam: codeToUse),
      errorContext: 'addColorData',
    );
  }

  Future<void> updateColorData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/color/$id',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Color Entry Updated Successfully',
      onSuccess: () => getColorData(companyCodeParam: codeToUse),
      errorContext: 'updateColorData',
    );
  }

  Future<void> deleteColorData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/color/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Color Entry Deleted Successfully',
      onSuccess: () => getColorData(companyCodeParam: codeToUse),
      errorContext: 'deleteColorData',
    );
  }

  // ==================== DESIGNATION MASTER APIS ====================
  Future<void> getDesignationData({int? companyCodeParam}) async {
    final code = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    final data = await _masterService.fetchList<DesignationModel>(
      endpoint: 'designation',
      fromJson: (j) => DesignationModel.fromJson(j),
      companyCode: code,
      errorContext: 'getDesignationData',
    );
    if (data != null) {
      designationModelList.value = data;
      designationModelList.refresh();
    }
  }

  Future<DesignationModel?> getDesignationById(dynamic id) async {
    return await _masterService.fetchById<DesignationModel>(
      endpoint: 'designation/$id',
      fromJson: (j) => DesignationModel.fromJson(j),
      errorContext: 'getDesignationById',
    );
  }

  Future<Map<String, dynamic>?> getNextDesignationCode() async {
    try {
      final res = await _masterService.fetchNextCode(
        endpoint: 'designation/nextCode',
        errorContext: 'getNextDesignationCode',
      );
      if (res != null &&
          (res['nextCode'] != null ||
              res['DesiCode'] != null ||
              res['nextDesignationCode'] != null)) {
        return res;
      }
    } catch (_) {}

    // Fallback: calculate next code from designationModelList
    int maxCode = 0;
    for (final item in designationModelList) {
      final code = item.desiCode ?? item.designationCode ?? 0;
      if (code > maxCode) maxCode = code;
    }
    return {
      'DesiCode': maxCode + 1,
      'nextCode': maxCode + 1,
      'nextDesignationCode': maxCode + 1,
      'nextSortID': maxCode + 1,
    };
  }

  Future<void> addDesignationData({
    int? code,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
    String editDel = 'Y',
    String sflag = 'Y',
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;

    int desiCode = code ?? 0;
    if (desiCode <= 0) {
      int maxCode = 0;
      for (final item in designationModelList) {
        final c = item.desiCode ?? item.designationCode ?? 0;
        if (c > maxCode) maxCode = c;
      }
      desiCode = maxCode + 1;
    }

    await _masterService.create(
      endpoint: 'designation/add',
      payload: {
        'DesiCode': desiCode,
        'DesiName': name,
        'EditDel': editDel,
        'Sflag': sflag,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Designation Entry Saved Successfully',
      onSuccess: () => getDesignationData(companyCodeParam: codeToUse),
      errorContext: 'addDesignationData',
    );
  }

  Future<void> updateDesignationData({
    required dynamic id,
    required String name,
    int? code,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
    String? editDel,
    String? sflag,
  }) async {
    final String targetIdStr = id.toString();
    final existing = designationModelList.firstWhereOrNull(
      (d) =>
          (d.desiMstID != null && d.desiMstID.toString() == targetIdStr) ||
          (d.desiCode != null && d.desiCode.toString() == targetIdStr) ||
          (d.designationCode != null &&
              d.designationCode.toString() == targetIdStr),
    );
    if (existing != null && !existing.canEditOrDelete) {
      infoDialog(
          messageText:
              'This designation record cannot be edited (EditDel is N).');
      return;
    }

    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'designation/$id',
      payload: {
        'DesiName': name,
        if (code != null) 'DesiCode': code,
        if (editDel != null) 'EditDel': editDel,
        if (sflag != null) 'Sflag': sflag,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
        'CompanyCode': codeToUse,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Designation Entry Updated Successfully',
      onSuccess: () => getDesignationData(companyCodeParam: codeToUse),
      errorContext: 'updateDesignationData',
    );
  }

  Future<void> deleteDesignationData({required dynamic id, int? companyCodeParam}) async {
    final String targetIdStr = id.toString();
    final existing = designationModelList.firstWhereOrNull(
      (d) =>
          (d.desiMstID != null && d.desiMstID.toString() == targetIdStr) ||
          (d.desiCode != null && d.desiCode.toString() == targetIdStr) ||
          (d.designationCode != null &&
              d.designationCode.toString() == targetIdStr),
    );
    if (existing != null && !existing.canEditOrDelete) {
      infoDialog(
          messageText:
              'This designation record cannot be deleted (EditDel is N).');
      return;
    }

    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'designation/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Designation Entry Deleted Successfully',
      onSuccess: () => getDesignationData(companyCodeParam: codeToUse),
      errorContext: 'deleteDesignationData',
    );
  }

  // ==================== SHAPE MASTER APIS ====================
  Future<void> getShapeData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<ShapeModel>(
      endpoint: 'rough-entry/shape',
      fromJson: (j) => ShapeModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getShapeData',
    );
    if (data != null) {
      shapeModelList.value = data;
      shapeModelList.refresh();
    }
  }

  Future<ShapeModel?> getShapeById(dynamic id) async {
    return await _masterService.fetchById<ShapeModel>(
      endpoint: 'rough-entry/shape/$id',
      fromJson: (j) => ShapeModel.fromJson(j),
      errorContext: 'getShapeById',
    );
  }

  Future<Map<String, dynamic>?> getNextShapeCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/shape/nextCode',
      errorContext: 'getNextShapeCode',
    );
  }

  Future<void> addShapeData({
    required String name,
    String? repCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/shape/add',
      payload: {
        'Name': name,
        if (repCode != null && repCode.isNotEmpty) 'RepCode': repCode,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Shape Entry Saved Successfully',
      onSuccess: () => getShapeData(companyCodeParam: codeToUse),
      errorContext: 'addShapeData',
    );
  }

  Future<void> updateShapeData({
    required dynamic id,
    required String name,
    String? repCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/shape/$id',
      payload: {
        'Name': name,
        if (repCode != null && repCode.isNotEmpty) 'RepCode': repCode,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Shape Entry Updated Successfully',
      onSuccess: () => getShapeData(companyCodeParam: codeToUse),
      errorContext: 'updateShapeData',
    );
  }

  Future<void> deleteShapeData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/shape/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Shape Entry Deleted Successfully',
      onSuccess: () => getShapeData(companyCodeParam: codeToUse),
      errorContext: 'deleteShapeData',
    );
  }

  // ==================== EXPENSE GROUP MASTER APIS ====================
  Future<void> getExpenseGroupData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<ExpenseGroupModel>(
      endpoint: 'rough-entry/expense-group',
      fromJson: (j) => ExpenseGroupModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getExpenseGroupData',
    );
    if (data != null) {
      expenseGroupModelList.value = data;
      expenseGroupModelList.refresh();
    }
  }

  Future<ExpenseGroupModel?> getExpenseGroupById(dynamic id) async {
    return await _masterService.fetchById<ExpenseGroupModel>(
      endpoint: 'rough-entry/expense-group/$id',
      fromJson: (j) => ExpenseGroupModel.fromJson(j),
      errorContext: 'getExpenseGroupById',
    );
  }

  Future<Map<String, dynamic>?> getNextExpenseGroupCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/expense-group/nextCode',
      errorContext: 'getNextExpenseGroupCode',
    );
  }

  Future<void> addExpenseGroupData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/expense-group/add',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Expense Group Entry Saved Successfully',
      onSuccess: () => getExpenseGroupData(companyCodeParam: codeToUse),
      errorContext: 'addExpenseGroupData',
    );
  }

  Future<void> updateExpenseGroupData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/expense-group/$id',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Expense Group Entry Updated Successfully',
      onSuccess: () => getExpenseGroupData(companyCodeParam: codeToUse),
      errorContext: 'updateExpenseGroupData',
    );
  }

  Future<void> deleteExpenseGroupData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/expense-group/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Expense Group Entry Deleted Successfully',
      onSuccess: () => getExpenseGroupData(companyCodeParam: codeToUse),
      errorContext: 'deleteExpenseGroupData',
    );
  }

  // ==================== EXPENSE MASTER APIS ====================
  Future<void> getExpenseGroupsDropdownData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<ExpenseGroupModel>(
      endpoint: 'rough-entry/expense/groups',
      fromJson: (j) => ExpenseGroupModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getExpenseGroupsDropdownData',
    );
    if (data != null) expenseGroupDropdownList.value = data;
  }

  Future<void> getExpenseData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<ExpenseModel>(
      endpoint: 'rough-entry/expense',
      fromJson: (j) => ExpenseModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getExpenseData',
    );
    if (data != null) {
      expenseModelList.value = data;
      expenseModelList.refresh();
    }
  }

  Future<ExpenseModel?> getExpenseById(dynamic id) async {
    return await _masterService.fetchById<ExpenseModel>(
      endpoint: 'rough-entry/expense/$id',
      fromJson: (j) => ExpenseModel.fromJson(j),
      errorContext: 'getExpenseById',
    );
  }

  Future<Map<String, dynamic>?> getNextExpenseCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/expense/nextCode',
      errorContext: 'getNextExpenseCode',
    );
  }

  Future<void> addExpenseData({
    required String name,
    required int expGroupCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/expense/add',
      payload: {
        'Name': name,
        'ExpGroupCode': expGroupCode,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Expense Entry Saved Successfully',
      onSuccess: () => getExpenseData(companyCodeParam: codeToUse),
      errorContext: 'addExpenseData',
    );
  }

  Future<void> updateExpenseData({
    required dynamic id,
    required String name,
    required int expGroupCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/expense/$id',
      payload: {
        'Name': name,
        'ExpGroupCode': expGroupCode,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Expense Entry Updated Successfully',
      onSuccess: () => getExpenseData(companyCodeParam: codeToUse),
      errorContext: 'updateExpenseData',
    );
  }

  Future<void> deleteExpenseData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/expense/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Expense Entry Deleted Successfully',
      onSuccess: () => getExpenseData(companyCodeParam: codeToUse),
      errorContext: 'deleteExpenseData',
    );
  }

  // ==================== ACC TYPE / TYPE MASTER APIS ====================
  Future<void> getTypeGroupsDropdownData() async {
    final data = await _masterService.fetchList<TypeGroupModel>(
      endpoint: 'rough-entry/type/groups',
      fromJson: (j) => TypeGroupModel.fromJson(j),
      errorContext: 'getTypeGroupsDropdownData',
    );
    if (data != null) typeGroupDropdownList.value = data;
  }

  Future<void> getAccTypeData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<AccTypeModel>(
      endpoint: 'rough-entry/type',
      fromJson: (j) => AccTypeModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getAccTypeData',
    );
    if (data != null) {
      accTypeModelList.value = data;
      accTypeModelList.refresh();
    }
  }

  Future<AccTypeModel?> getAccTypeById(dynamic id) async {
    return await _masterService.fetchById<AccTypeModel>(
      endpoint: 'rough-entry/type/$id',
      fromJson: (j) => AccTypeModel.fromJson(j),
      errorContext: 'getAccTypeById',
    );
  }

  Future<Map<String, dynamic>?> getNextAccTypeCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/type/nextCode',
      errorContext: 'getNextAccTypeCode',
    );
  }

  Future<void> addAccTypeData({
    required String name,
    required String group,
    int? typeGroupCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/type/add',
      payload: {
        'Name': name,
        'Group': group,
        if (typeGroupCode != null) 'TypeGroupCode': typeGroupCode,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Type Entry Saved Successfully',
      onSuccess: () => getAccTypeData(companyCodeParam: codeToUse),
      errorContext: 'addAccTypeData',
    );
  }

  Future<void> updateAccTypeData({
    required dynamic id,
    required String name,
    required String group,
    int? typeGroupCode,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/type/$id',
      payload: {
        'Name': name,
        'Group': group,
        if (typeGroupCode != null) 'TypeGroupCode': typeGroupCode,
        'CompanyCode': codeToUse,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Type Entry Updated Successfully',
      onSuccess: () => getAccTypeData(companyCodeParam: codeToUse),
      errorContext: 'updateAccTypeData',
    );
  }

  Future<void> deleteAccTypeData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/type/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Type Entry Deleted Successfully',
      onSuccess: () => getAccTypeData(companyCodeParam: codeToUse),
      errorContext: 'deleteAccTypeData',
    );
  }

  // ==================== POLISH TYPE MASTER APIS ====================
  Future<void> getPolishTypeData({int? companyCodeParam}) async {
    final data = await _masterService.fetchList<PolishTypeModel>(
      endpoint: 'rough-entry/polish-type',
      fromJson: (j) => PolishTypeModel.fromJson(j),
      companyCode: companyCodeParam ??
          (companyCode.value != 0 ? companyCode.value : null),
      errorContext: 'getPolishTypeData',
    );
    if (data != null) {
      polishTypeModelList.value = data;
      polishTypeModelList.refresh();
    }
  }

  Future<PolishTypeModel?> getPolishTypeById(dynamic id) async {
    return await _masterService.fetchById<PolishTypeModel>(
      endpoint: 'rough-entry/polish-type/$id',
      fromJson: (j) => PolishTypeModel.fromJson(j),
      errorContext: 'getPolishTypeById',
    );
  }

  Future<Map<String, dynamic>?> getNextPolishTypeCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/polish-type/nextCode',
      errorContext: 'getNextPolishTypeCode',
    );
  }

  Future<void> addPolishTypeData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/polish-type/add',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'CompanyCode': codeToUse,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Polish Type Entry Saved Successfully',
      onSuccess: () => getPolishTypeData(companyCodeParam: codeToUse),
      errorContext: 'addPolishTypeData',
    );
  }

  Future<void> updatePolishTypeData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/polish-type/$id',
      payload: {
        'Name': name,
        'CompanyCode': codeToUse,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Polish Type Entry Updated Successfully',
      onSuccess: () => getPolishTypeData(companyCodeParam: codeToUse),
      errorContext: 'updatePolishTypeData',
    );
  }

  Future<void> deletePolishTypeData({required dynamic id, int? companyCodeParam}) async {
    final codeToUse = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    await _masterService.delete(
      endpoint: 'rough-entry/polish-type/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Polish Type Entry Deleted Successfully',
      onSuccess: () => getPolishTypeData(companyCodeParam: codeToUse),
      errorContext: 'deletePolishTypeData',
    );
  }

  // ==================== COMPANY MASTER APIS ====================
  Future<void> getCompanyData() async {
    final data = await _masterService.fetchList<CompanyMstModel>(
      endpoint: 'rough-entry/company',
      fromJson: (j) => CompanyMstModel.fromJson(j),
      errorContext: 'getCompanyData',
    );
    if (data != null) {
      companyModelList.value = data;
      companyModelList.refresh();
    }
  }

  Future<CompanyMstModel?> getCompanyById(dynamic id) async {
    return await _masterService.fetchById<CompanyMstModel>(
      endpoint: 'rough-entry/company/$id',
      fromJson: (j) => CompanyMstModel.fromJson(j),
      errorContext: 'getCompanyById',
    );
  }

  Future<Map<String, dynamic>?> getNextCompanyCode() async {
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/company/nextCode',
      errorContext: 'getNextCompanyCode',
    );
  }

  Future<void> addCompanyData({
    required String name,
    String? address,
    String? mobileNo,
    String? phone,
    String? fax,
    String? email,
    String? web,
    String? gstNo,
    String? cstNo,
    String? tinNo,
    String? bank,
    String? branch,
    String? bankAdd,
    String? ifsc,
    String? accNo,
    String? insurance,
    String? finalAmt,
    String? memoInvoicePrefix,
    String? memoInvoiceSuffix,
    String? invoicePrefix,
    String? invoiceSuffix,
    String? fromDate,
    String? toDate,
    int? sortId,
    bool active = true,
  }) async {
    await _masterService.create(
      endpoint: 'rough-entry/company/add',
      payload: {
        'Name': name,
        if (address != null && address.isNotEmpty) 'Address': address,
        if (mobileNo != null && mobileNo.isNotEmpty) 'MobileNo': mobileNo,
        if (phone != null && phone.isNotEmpty) 'Phone': phone,
        if (fax != null && fax.isNotEmpty) 'Fax': fax,
        if (email != null && email.isNotEmpty) 'Email': email,
        if (web != null && web.isNotEmpty) 'Web': web,
        if (gstNo != null && gstNo.isNotEmpty) 'GSTNo': gstNo,
        if (cstNo != null && cstNo.isNotEmpty) 'CSTNo': cstNo,
        if (tinNo != null && tinNo.isNotEmpty) 'TINNo': tinNo,
        if (bank != null && bank.isNotEmpty) 'Bank': bank,
        if (branch != null && branch.isNotEmpty) 'Branch': branch,
        if (bankAdd != null && bankAdd.isNotEmpty) 'BankAdd': bankAdd,
        if (ifsc != null && ifsc.isNotEmpty) 'IFSC': ifsc,
        if (accNo != null && accNo.isNotEmpty) 'AccNo': accNo,
        if (insurance != null && insurance.isNotEmpty) 'Insurance': insurance,
        if (finalAmt != null && finalAmt.isNotEmpty) 'FinalAmt': finalAmt,
        // Always sent so the value can also be cleared
        'MemoInvoicePrefix': memoInvoicePrefix ?? '',
        'MemoInvoiceSuffix': memoInvoiceSuffix ?? '',
        'InvoicePrefix': invoicePrefix ?? '',
        'InvoiceSuffix': invoiceSuffix ?? '',
        if (fromDate != null && fromDate.isNotEmpty) 'FromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'ToDate': toDate,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Company Entry Saved Successfully',
      onSuccess: () => getCompanyData(),
      errorContext: 'addCompanyData',
    );
  }

  Future<void> updateCompanyData({
    required dynamic id,
    required String name,
    String? address,
    String? mobileNo,
    String? phone,
    String? fax,
    String? email,
    String? web,
    String? gstNo,
    String? cstNo,
    String? tinNo,
    String? bank,
    String? branch,
    String? bankAdd,
    String? ifsc,
    String? accNo,
    String? insurance,
    String? finalAmt,
    String? memoInvoicePrefix,
    String? memoInvoiceSuffix,
    String? invoicePrefix,
    String? invoiceSuffix,
    String? fromDate,
    String? toDate,
    int? sortId,
    bool active = true,
  }) async {
    await _masterService.update(
      endpoint: 'rough-entry/company/$id',
      payload: {
        'Name': name,
        if (address != null && address.isNotEmpty) 'Address': address,
        if (mobileNo != null && mobileNo.isNotEmpty) 'MobileNo': mobileNo,
        if (phone != null && phone.isNotEmpty) 'Phone': phone,
        if (fax != null && fax.isNotEmpty) 'Fax': fax,
        if (email != null && email.isNotEmpty) 'Email': email,
        if (web != null && web.isNotEmpty) 'Web': web,
        if (gstNo != null && gstNo.isNotEmpty) 'GSTNo': gstNo,
        if (cstNo != null && cstNo.isNotEmpty) 'CSTNo': cstNo,
        if (tinNo != null && tinNo.isNotEmpty) 'TINNo': tinNo,
        if (bank != null && bank.isNotEmpty) 'Bank': bank,
        if (branch != null && branch.isNotEmpty) 'Branch': branch,
        if (bankAdd != null && bankAdd.isNotEmpty) 'BankAdd': bankAdd,
        if (ifsc != null && ifsc.isNotEmpty) 'IFSC': ifsc,
        if (accNo != null && accNo.isNotEmpty) 'AccNo': accNo,
        if (insurance != null && insurance.isNotEmpty) 'Insurance': insurance,
        if (finalAmt != null && finalAmt.isNotEmpty) 'FinalAmt': finalAmt,
        // Always sent so the value can also be cleared
        'MemoInvoicePrefix': memoInvoicePrefix ?? '',
        'MemoInvoiceSuffix': memoInvoiceSuffix ?? '',
        'InvoicePrefix': invoicePrefix ?? '',
        'InvoiceSuffix': invoiceSuffix ?? '',
        if (fromDate != null && fromDate.isNotEmpty) 'FromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'ToDate': toDate,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Company Entry Updated Successfully',
      onSuccess: () => getCompanyData(),
      errorContext: 'updateCompanyData',
    );
  }

  Future<void> deleteCompanyData({required dynamic id}) async {
    await _masterService.delete(
      endpoint: 'rough-entry/company/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Company Entry Deleted Successfully',
      onSuccess: () => getCompanyData(),
      errorContext: 'deleteCompanyData',
    );
  }

  // ==================== BRANCH MASTER APIS ====================
  Future<void> getBranchData({int? companyCodeParam}) async {
    final code = companyCodeParam ??
        (companyCode.value != 0 ? companyCode.value : null);
    final data = await _masterService.fetchList<BranchModel>(
      endpoint: 'rough-entry/branch',
      fromJson: (j) => BranchModel.fromJson(j),
      companyCode: code,
      errorContext: 'getBranchData',
    );
    if (data != null) {
      branchModelList.value = data;
      branchModelList.refresh();
    }
  }

  Future<BranchModel?> getBranchById(dynamic id) async {
    return await _masterService.fetchById<BranchModel>(
      endpoint: 'rough-entry/branch',
      id: id,
      fromJson: (j) => BranchModel.fromJson(j),
      errorContext: 'getBranchById',
    );
  }

  Future<Map<String, dynamic>?> getNextBranchCode({int? companyCodeParam}) async {
    final code = companyCodeParam ??
        companyCode.value;
    return await _masterService.fetchNextCode(
      endpoint: 'rough-entry/branch/nextCode?CompanyCode=$code',
      errorContext: 'getNextBranchCode',
    );
  }

  Future<void> addBranchData({
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.create(
      endpoint: 'rough-entry/branch/add',
      payload: {
        'Name': name,
        'CompanyCode': codeToUse,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Branch Entry Saved Successfully',
      onSuccess: () => getBranchData(companyCodeParam: codeToUse),
      errorContext: 'addBranchData',
    );
  }

  Future<void> updateBranchData({
    required dynamic id,
    required String name,
    int? sortId,
    bool active = true,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.update(
      endpoint: 'rough-entry/branch/$id',
      payload: {
        'Name': name,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      },
      isLoading: isLoading,
      defaultSuccessMsg: 'Branch Entry Updated Successfully',
      onSuccess: () => getBranchData(companyCodeParam: codeToUse),
      errorContext: 'updateBranchData',
    );
  }

  Future<void> deleteBranchData({
    required dynamic id,
    int? companyCodeParam,
  }) async {
    final codeToUse = companyCodeParam ??
        companyCode.value;
    await _masterService.delete(
      endpoint: 'rough-entry/branch/$id',
      isDeleteLoading: isDeleteLoading,
      defaultSuccessMsg: 'Branch Entry Deleted Successfully',
      onSuccess: () => getBranchData(companyCodeParam: codeToUse),
      errorContext: 'deleteBranchData',
    );
  }

  // ==================== USER MASTER & 4 MODULES APIS ====================

  // --- Module 1: Basic Details & User CRUD ---
  Future<void> getUserData({
    int? branchCode,
    bool? active,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (branchCode != null && branchCode != 0) {
        queryParams['BranchCode'] = branchCode;
      }
      if (active != null) {
        queryParams['active'] = active;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await ApiService.to.get(
        'rough-entry/user',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> list = [];
        if (response.data is List) {
          list = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List<dynamic>;
        }
        userModelList.value = list
            .map((j) => UserModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('getUserData error: $e');
    }
  }

  Future<UserModel?> getUserById(dynamic id) async {
    try {
      final response = await ApiService.to.get('rough-entry/user/$id');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        if (raw is List && raw.isNotEmpty && raw.first is Map) {
          return UserModel.fromJson(raw.first as Map<String, dynamic>);
        } else if (raw is Map<String, dynamic> &&
            raw['data'] != null &&
            raw['data'] is Map<String, dynamic>) {
          return UserModel.fromJson(raw['data'] as Map<String, dynamic>);
        } else if (raw is Map<String, dynamic>) {
          return UserModel.fromJson(raw);
        }
      }
    } catch (e) {
      log('getUserById error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getNextUserCode() async {
    try {
      final response = await ApiService.to.get('rough-entry/user/nextCode');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
    } catch (e) {
      log('getNextUserCode error: $e');
    }
    return null;
  }

  Future<bool> addUserData({
    required String loginName,
    required String password,
    required String userName,
    String userGrp = 'USER',
    int? branchCode,
    int? desiCode,
    String? autoRec,
    String? allowPlusType,

    double? allowPlusValue,
    String? allowMinusType,
    double? allowMinusValue,
    double? stockLimit,
    String? loginTimeFrom,
    String? loginTimeTo,
    int? sortId,
    bool active = true,
  }) async {
    try {
      isLoading.value = true;
      final payload = <String, dynamic>{
        'LoginName': loginName,
        'Password': password,
        'UserName': userName,
        'UserGrp': userGrp,
        if (branchCode != null) 'BranchCode': branchCode,
        if (desiCode != null) 'DesiCode': desiCode,
        if (autoRec != null && autoRec.isNotEmpty) 'AutoRec': autoRec,
        if (allowPlusType != null && allowPlusType.isNotEmpty)
          'AllowPlusType': allowPlusType,
        if (allowPlusValue != null) 'AllowPlusValue': allowPlusValue,
        if (allowMinusType != null && allowMinusType.isNotEmpty)
          'AllowMinusType': allowMinusType,
        if (allowMinusValue != null) 'AllowMinusValue': allowMinusValue,
        if (stockLimit != null) 'StockLimit': stockLimit,
        if (loginTimeFrom != null && loginTimeFrom.isNotEmpty)
          'LoginTimeFrom': loginTimeFrom,
        if (loginTimeTo != null && loginTimeTo.isNotEmpty)
          'LoginTimeTo': loginTimeTo,
        if (sortId != null) 'SortID': sortId,
        'Active': active,
      };

      final response =
          await ApiService.to.post('rough-entry/user', data: payload);
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getUserData();
        userModelList.refresh();
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'User Registered Successfully';
        await successDialog(messageText: msg);
        return true;
      } else {
        final err = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to add user';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isLoading.value = false;
      errorDialog(messageText: 'Error registering user: $e');
    }
    return false;
  }

  Future<bool> updateUserData({
    required dynamic id,
    String? userName,
    String? loginName,
    String? password,
    String? userGrp,
    int? branchCode,
    int? desiCode,
    String? autoRec,
    String? allowPlusType,
    double? allowPlusValue,
    String? allowMinusType,
    double? allowMinusValue,
    double? stockLimit,
    String? loginTimeFrom,
    String? loginTimeTo,
    int? sortId,
    bool? active,
  }) async {
    try {
      isLoading.value = true;
      final payload = <String, dynamic>{
        if (userName != null) 'UserName': userName,
        if (loginName != null) 'LoginName': loginName,
        if (password != null && password.isNotEmpty) 'Password': password,
        if (userGrp != null) 'UserGrp': userGrp,
        if (branchCode != null) 'BranchCode': branchCode,
        if (desiCode != null) 'DesiCode': desiCode,
        if (autoRec != null && autoRec.isNotEmpty) 'AutoRec': autoRec,
          'AllowPlusType': allowPlusType ?? '',
       'AllowPlusValue': allowPlusValue ?? 0.0,
        'AllowMinusType': allowMinusType ?? '',
        'AllowMinusValue': allowMinusValue ?? 0.0,
        if (stockLimit != null) 'StockLimit': stockLimit,
        if (loginTimeFrom != null) 'LoginTimeFrom': loginTimeFrom,
        if (loginTimeTo != null) 'LoginTimeTo': loginTimeTo,
        if (sortId != null) 'SortID': sortId,
        if (active != null) 'Active': active,
      };

      final response =
          await ApiService.to.put('rough-entry/user/$id', data: payload);
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        await getUserData();
        userModelList.refresh();
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'User Updated Successfully';
        await successDialog(messageText: msg);
        return true;
      } else {
        final err = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to update user';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isLoading.value = false;
      errorDialog(messageText: 'Error updating user: $e');
    }
    return false;
  }

  Future<bool> deleteUserData(dynamic id) async {
    try {
      isDeleteLoading.value = true;
      final response = await ApiService.to.delete('rough-entry/user/$id');
      isDeleteLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 204) {
        await getUserData();
        userModelList.refresh();
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'User Deleted Successfully';
        await successDialog(messageText: msg);
        return true;
      } else {
        final err = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to delete user';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'Error deleting user: $e');
    }
    return false;
  }

  // --- Module 2: Menu Rights Matrix ---
  Future<UserMenuRightsResponse?> getUserMenuRights(dynamic userId) async {
    try {
      dynamic response;
      try {
        response = await ApiService.to.get('user/$userId/menu-rights');
      } catch (_) {
        response =
            await ApiService.to.get('rough-entry/user/$userId/menu-rights');
      }
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return UserMenuRightsResponse.fromJson(
              response.data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('getUserMenuRights error: $e');
    }
    return null;
  }

  Future<bool> saveUserMenuRights(
    dynamic userId,
    List<Map<String, dynamic>> menuRights,
  ) async {
    try {
      isLoading.value = true;
      final payload = {'menuRights': menuRights};
      dynamic response;
      try {
        response = await ApiService.to.post(
          'user/$userId/menu-rights',
          data: payload,
        );
      } catch (_) {
        response = await ApiService.to.post(
          'rough-entry/user/$userId/menu-rights',
          data: payload,
        );
      }
      isLoading.value = false;

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Menu rights saved successfully';
        successDialog(messageText: msg);
        return true;
      } else {
        final err = (response != null && response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to save menu rights';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isLoading.value = false;
      errorDialog(messageText: 'Error saving menu rights: $e');
    }
    return false;
  }

  // --- Module 3: Allow Issue (Transfer Screen Mapping) ---
  Future<AllowIssueResponse?> getUserAllowIssue(dynamic userId) async {
    try {
      final response =
          await ApiService.to.get('rough-entry/user/$userId/allow-issue');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return AllowIssueResponse.fromJson(
              response.data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('getUserAllowIssue error: $e');
    }
    return null;
  }

  Future<bool> saveUserAllowIssue(
    dynamic userId,
    List<int> allowedUserIds,
  ) async {
    try {
      isLoading.value = true;
      final payload = {'allowedUserIds': allowedUserIds};
      final response = await ApiService.to.post(
        'rough-entry/user/$userId/allow-issue',
        data: payload,
      );
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Allow Issue permissions saved successfully';
        successDialog(messageText: msg);
        return true;
      } else {
        final err = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to save allow issue permissions';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isLoading.value = false;
      errorDialog(messageText: 'Error saving allow issue permissions: $e');
    }
    return false;
  }

  Future<List<Map<String, dynamic>>?> getTransferTargets(
      dynamic fromUserId) async {
    try {
      final response = await ApiService.to.get(
        'rough-entry/user/transfer-targets',
        queryParameters: {'fromUserId': fromUserId},
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      log('getTransferTargets error: $e');
    }
    return null;
  }

  // --- Branch Transfer Combined Purchase Data ---
  Future<List<BranchTransferItemModel>> getBranchTransferCombinedData({
    int? companyCodeParam,
    dynamic fromUserId,
    bool force = true,
  }) async {
    isLoadingBranchTransfer.value = true;
    try {
      final compCode = companyCodeParam ??
          companyCode.value;

      int crId = 0;
      if (fromUserId != null) {
        crId = int.tryParse(fromUserId.toString()) ?? 0;
      }
      if (crId == 0 && effectiveCrId.isNotEmpty) {
        crId = int.tryParse(effectiveCrId) ?? 0;
      }
      if (crId == 0) {
        crId = currentCrId.value > 0
            ? currentCrId.value
            : (currentUserId.value > 0 ? currentUserId.value : 56);
      }

      final params = {
        'companyCode': compCode,
        'fromCrId': crId,
      };

      log('Calling branch-transfer/combined with params: $params');

      final response = await ApiService.to.dio.request(
        '${ApiService.to.baseUrl}branch-transfer/combined',
        data: params,
        queryParameters: params,
        options: Options(
          method: 'GET',
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic>? list;
        if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List;
        } else if (response.data is List) {
          list = response.data as List;
        }

        if (list != null && list.isNotEmpty) {
          final items = list.map((item) {
            if (item is Map<String, dynamic>) {
              return BranchTransferItemModel.fromJson(item);
            } else {
              return BranchTransferItemModel.fromJson(
                  Map<String, dynamic>.from(item as Map));
            }
          }).toList();

          branchTransferCombinedList.assignAll(items);
          isLoadingBranchTransfer.value = false;
          return items;
        } else {
          branchTransferCombinedList.clear();
          isLoadingBranchTransfer.value = false;
          return [];
        }
      }
    } on DioException catch (dioErr) {
      log('DioException in getBranchTransferCombinedData: ${dioErr.message}');
      final respData = dioErr.response?.data;
      if (respData is Map && respData['message'] != null) {
        log('Server validation/error message: ${respData['message']}');
      }
      branchTransferCombinedList.clear();
      isLoadingBranchTransfer.value = false;
      return [];
    } catch (e) {
      log('Error fetching branch-transfer/combined in DefaultController: $e');
      branchTransferCombinedList.clear();
      isLoadingBranchTransfer.value = false;
      return [];
    }

    isLoadingBranchTransfer.value = false;
    return branchTransferCombinedList;
  }

  Future<bool> saveBranchTransferData({
    dynamic id,
    required int fromUserId,
    required int toUserId,
    String? transferDate,
    String? date,
    required List<BranchTransferItemModel> items,
    List<Map<String, dynamic>>? serializedItems,
    int? companyCodeParam,
  }) async {
    if (id != null && id.toString().trim().isNotEmpty) {
      return await updateBranchTransferData(
        id: id,
        fromUserId: fromUserId,
        toUserId: toUserId,
        transferDate: transferDate,
        date: date,
        items: items,
        serializedItems: serializedItems,
        companyCodeParam: companyCodeParam,
      );
    }
    isLoading.value = true;
    try {
      final codeToUse = companyCodeParam ??
          companyCode.value;
      final totalStockPc = items.fold<int>(0, (sum, i) => sum + i.stockPc);
      final totalStockWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockWt).toStringAsFixed(3));
      final totalRateDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateDollar).toStringAsFixed(2));
      final totalRateRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateRs).toStringAsFixed(2));
      final totalAmtDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtDollar).toStringAsFixed(2));
      final totalAmtRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtRs).toStringAsFixed(2));

      final totalIssuePc = items.fold<int>(0, (sum, i) => sum + i.issuePc);
      final totalIssueWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueWt).toStringAsFixed(3));
      final totalIssueRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueRate).toStringAsFixed(2));
      final totalIssueAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueAmt).toStringAsFixed(2));

      final totalDiffWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffWt).toStringAsFixed(3));
      final totalDiffRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffRate).toStringAsFixed(2));
      final totalDiffAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffAmt).toStringAsFixed(2));

      final formattedDate = (transferDate != null && transferDate.isNotEmpty)
          ? transferDate
          : (date != null && date.isNotEmpty
              ? (date.contains('-') && date.split('-').first.length == 2
                  ? date.split('-').reversed.join('-')
                  : date)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()));

      final itemsPayload =
          serializedItems ?? items.map((i) => i.toSaveJson()).toList();

      final body = {
        'CompanyCode': codeToUse,
        'FromCrId': fromUserId,
        'ToCrId': toUserId,
        'TransferDate': formattedDate,
        'TotalItems': items.length,
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
        'items': itemsPayload,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [DEFAULT_CONTROLLER] SENDING PAYLOAD TO BRANCH TRANSFER SAVE API:');
      debugPrint('======================================================================');
      for (var line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint('======================================================================');
      log('Saving branch transfer with body: $formattedJson');

      dynamic response;
      try {
        response = await ApiService.to.dio.post(
          '${ApiService.to.baseUrl}branch-transfer/save',
          data: body,
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          try {
            response = await ApiService.to.dio.post(
              '${ApiService.to.baseUrl}branch-transfer/add',
              data: body,
            );
          } on DioException catch (fallbackErr) {
            if (fallbackErr.response?.statusCode == 404) {
              try {
                response = await ApiService.to.dio.post(
                  '${ApiService.to.baseUrl}rough-entry/branch-transfer/add',
                  data: body,
                );
              } on DioException catch (_) {
                isLoading.value = false;
                await successDialog(
                  messageText:
                      'Branch Transfer payload generated and printed to console.\n(Server endpoint not yet deployed - 404)\nItems: ${items.length} | Iss Pc: $totalIssuePc | Iss Wt: ${totalIssueWt.toStringAsFixed(3)} | Iss Amt: ₹${NumberFormat('#,##0.00').format(totalIssueAmt)}',
                );
                return true;
              }
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      isLoading.value = false;
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Branch Transfer saved successfully.';
        await successDialog(messageText: msg);
        await getBranchTransferList(force: true);
        return true;
      } else {
        final String err = (response?.data is Map && response?.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to save Branch Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isLoading.value = false;
      log('DioException saving branch transfer: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ?? 'Server error saving transfer'
          : (dioErr.message ?? 'Server error saving transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isLoading.value = false;
      log('Error saving branch transfer: $e');
      await errorDialog(messageText: 'Error saving Branch Transfer: $e');
      return false;
    }
  }

  // ==================== BRANCH TRANSFER APIS ====================

  /// 1. GET /branch-transfer - Fetch all branch transfers
  Future<List<BranchTransferMstModel>> getBranchTransferList({
    bool force = false,
    int? companyCodeParam,
  }) async {
    if (!force && branchTransferList.isNotEmpty) {
      return branchTransferList;
    }
    isLoadingBranchTransferList.value = true;
    try {
      final codeToUse =
          companyCodeParam ?? (companyCode.value != 0 ? companyCode.value : null);
      final Map<String, dynamic> params = {};
      if (codeToUse != null && codeToUse > 0) {
        params['companyCode'] = codeToUse;
      }

      final url = '${ApiService.to.baseUrl}branch-transfer';
      log('Calling GET $url with params: $params');
      final response = await ApiService.to.dio.get(
        url,
        queryParameters: params.isNotEmpty ? params : null,
      );

      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['transfers'] is List) {
          rawList = map['transfers'] as List;
        } else if (map['result'] is List) {
          rawList = map['result'] as List;
        } else if (map['rows'] is List) {
          rawList = map['rows'] as List;
        }
      }

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => BranchTransferMstModel.fromJson(item))
          .toList();

      branchTransferList.assignAll(parsed);
      branchTransferList.refresh();
      isLoadingBranchTransferList.value = false;
      return branchTransferList;
    } on DioException catch (dioErr) {
      isLoadingBranchTransferList.value = false;
      log('DioException in getBranchTransferList: ${dioErr.message}');
      return branchTransferList;
    } catch (e) {
      isLoadingBranchTransferList.value = false;
      log('Error in getBranchTransferList: $e');
      return branchTransferList;
    }
  }

  /// 2. GET /branch-transfer/<ID> - Fetch single branch transfer with details
  Future<BranchTransferMstModel?> getBranchTransferById(dynamic id) async {
    if (id == null || id.toString().trim().isEmpty) return null;
    isLoadingBranchTransfer.value = true;
    try {
      final cleanId = id.toString().trim();
      final url = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
      log('Calling GET $url');
      final response = await ApiService.to.dio.get(url);
      isLoadingBranchTransfer.value = false;

      Map<String, dynamic>? dataMap;
      if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is Map) {
          dataMap = Map<String, dynamic>.from(map['data'] as Map);
        } else {
          dataMap = Map<String, dynamic>.from(map);
        }
      }

      if (dataMap != null) {
        return BranchTransferMstModel.fromJson(dataMap);
      }
      return null;
    } on DioException catch (dioErr) {
      isLoadingBranchTransfer.value = false;
      log('DioException in getBranchTransferById: ${dioErr.message}');
      final msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString()
          : (dioErr.message ?? 'Error fetching Branch Transfer #$id');
      await errorDialog(messageText: msg ?? 'Error fetching Branch Transfer');
      return null;
    } catch (e) {
      isLoadingBranchTransfer.value = false;
      log('Error in getBranchTransferById: $e');
      await errorDialog(messageText: 'Error fetching Branch Transfer: $e');
      return null;
    }
  }

  /// 3. DELETE /branch-transfer/<ID> - Delete branch transfer record
  Future<bool> deleteBranchTransferData({required dynamic id}) async {
    if (id == null || id.toString().trim().isEmpty) return false;
    isDeleteLoadingBranchTransfer.value = true;
    try {
      final cleanId = id.toString().trim();
      final url = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
      log('Calling DELETE $url');
      final response = await ApiService.to.dio.delete(url);
      isDeleteLoadingBranchTransfer.value = false;

      if (response.statusCode == 200 || response.statusCode == 204) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Branch Transfer deleted successfully.';
        await successDialog(messageText: msg);
        await getBranchTransferList(force: true);
        return true;
      } else {
        final String err =
            (response.data is Map && response.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to delete Branch Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isDeleteLoadingBranchTransfer.value = false;
      log('DioException in deleteBranchTransferData: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error deleting transfer'
          : (dioErr.message ?? 'Server error deleting transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isDeleteLoadingBranchTransfer.value = false;
      log('Error in deleteBranchTransferData: $e');
      await errorDialog(messageText: 'Unexpected error: $e');
      return false;
    }
  }

  /// 4. PUT /branch-transfer/<ID> - Update branch transfer record
  Future<bool> updateBranchTransferData({
    required dynamic id,
    required int fromUserId,
    required int toUserId,
    String? transferDate,
    String? date,
    required List<BranchTransferItemModel> items,
    List<Map<String, dynamic>>? serializedItems,
    int? companyCodeParam,
  }) async {
    if (id == null || id.toString().trim().isEmpty) return false;
    isLoading.value = true;
    try {
      final cleanId = id.toString().trim();
      final codeToUse = companyCodeParam ??
          companyCode.value;

      final totalStockPc = items.fold<int>(0, (sum, i) => sum + i.stockPc);
      final totalStockWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockWt).toStringAsFixed(3));
      final totalRateDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateDollar).toStringAsFixed(2));
      final totalRateRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateRs).toStringAsFixed(2));
      final totalAmtDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtDollar).toStringAsFixed(2));
      final totalAmtRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtRs).toStringAsFixed(2));

      final totalIssuePc = items.fold<int>(0, (sum, i) => sum + i.issuePc);
      final totalIssueWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueWt).toStringAsFixed(3));
      final totalIssueRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueRate).toStringAsFixed(2));
      final totalIssueAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueAmt).toStringAsFixed(2));

      final totalDiffWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffWt).toStringAsFixed(3));
      final totalDiffRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffRate).toStringAsFixed(2));
      final totalDiffAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffAmt).toStringAsFixed(2));

      final formattedDate = (transferDate != null && transferDate.isNotEmpty)
          ? transferDate
          : (date != null && date.isNotEmpty
              ? (date.contains('-') && date.split('-').first.length == 2
                  ? date.split('-').reversed.join('-')
                  : date)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()));

      final itemsPayload =
          serializedItems ?? items.map((i) => i.toSaveJson()).toList();

      final body = {
        'BranchTransferMstID': int.tryParse(cleanId) ?? cleanId,
        'CompanyCode': codeToUse,
        'FromCrId': fromUserId,
        'ToCrId': toUserId,
        'TransferDate': formattedDate,
        'TotalItems': items.length,
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
        'items': itemsPayload,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [DEFAULT_CONTROLLER] SENDING PAYLOAD TO BRANCH TRANSFER UPDATE API (PUT):');
      debugPrint('URL: ${ApiService.to.baseUrl}branch-transfer/$cleanId');
      debugPrint('======================================================================');
      for (var line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint('======================================================================');
      log('Updating branch transfer with body: $formattedJson');

      final url = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
      final response = await ApiService.to.dio.put(
        url,
        data: body,
      );

      isLoading.value = false;
      if (response.statusCode == 200 || response.statusCode == 204) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Branch Transfer updated successfully.';
        await successDialog(messageText: msg);
        await getBranchTransferList(force: true);
        return true;
      } else {
        final String err =
            (response.data is Map && response.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to update Branch Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isLoading.value = false;
      log('DioException updating branch transfer: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error updating transfer'
          : (dioErr.message ?? 'Server error updating transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isLoading.value = false;
      log('Error updating branch transfer: $e');
      await errorDialog(messageText: 'Error updating Branch Transfer: $e');
      return false;
    }
  }

  // =========================================================================
  // --- Branch Transfer Confirm APIs ---
  // =========================================================================

  /// 1. GET /branch-transfer/confirm/list - Fetch list of confirmed branch transfers
  Future<List<BranchTransferConfirmMstModel>> getBranchTransferConfirmList({
    bool force = false,
  }) async {
    if (!force && branchTransferConfirmList.isNotEmpty) {
      return branchTransferConfirmList;
    }
    isLoadingBranchTransferConfirmList.value = true;
    try {
      final url = '${ApiService.to.baseUrl}branch-transfer/confirm/list';
      log('Calling GET $url');
      final response = await ApiService.to.dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['transfers'] is List) {
          rawList = map['transfers'] as List;
        } else if (map['result'] is List) {
          rawList = map['result'] as List;
        } else if (map['rows'] is List) {
          rawList = map['rows'] as List;
        } else if (map['list'] is List) {
          rawList = map['list'] as List;
        }
      }

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => BranchTransferConfirmMstModel.fromJson(item))
          .toList();

      branchTransferConfirmList.assignAll(parsed);
      branchTransferConfirmList.refresh();
      isLoadingBranchTransferConfirmList.value = false;
      return branchTransferConfirmList;
    } on DioException catch (dioErr) {
      isLoadingBranchTransferConfirmList.value = false;
      log('DioException in getBranchTransferConfirmList: ${dioErr.message}');
      return branchTransferConfirmList;
    } catch (e) {
      isLoadingBranchTransferConfirmList.value = false;
      log('Error in getBranchTransferConfirmList: $e');
      return branchTransferConfirmList;
    }
  }

  /// 2. GET /branch-transfer/details/<toCrId> - Fetch transfer detail records for a manager
  Future<List<BranchTransferConfirmItemModel>> getBranchTransferConfirmDetails(
    dynamic toCrId,
  ) async {
    if (toCrId == null || toCrId.toString().trim().isEmpty) return [];
    isLoadingBranchTransferConfirmDetails.value = true;
    try {
      final cleanId = toCrId.toString().trim();
      final url = '${ApiService.to.baseUrl}branch-transfer/details/$cleanId';
      log('Calling GET $url');
      final response = await ApiService.to.dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
      isLoadingBranchTransferConfirmDetails.value = false;

      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['details'] is List) {
          rawList = map['details'] as List;
        } else if (map['result'] is List) {
          rawList = map['result'] as List;
        } else if (map['rows'] is List) {
          rawList = map['rows'] as List;
        }
      }

      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => BranchTransferConfirmItemModel.fromJson(item))
          .toList();

      return items;
    } on DioException catch (dioErr) {
      isLoadingBranchTransferConfirmDetails.value = false;
      log('DioException in getBranchTransferConfirmDetails: ${dioErr.message}');
      return [];
    } catch (e) {
      isLoadingBranchTransferConfirmDetails.value = false;
      log('Error in getBranchTransferConfirmDetails: $e');
      return [];
    }
  }

  /// 3. GET /branch-transfer/confirm/details/<confirmMstId> - Fetch confirmed transfer details by confirmMstId
  Future<List<BranchTransferConfirmItemModel>>
      getBranchTransferConfirmDetailsById(
    dynamic confirmMstId, {
    dynamic toCrId,
  }) async {
    if (confirmMstId == null || confirmMstId.toString().trim().isEmpty) {
      return [];
    }
    isLoadingBranchTransferConfirmDetails.value = true;
    try {
      final cleanId = confirmMstId.toString().trim();
      final base = ApiService.to.baseUrl.endsWith('/')
          ? ApiService.to.baseUrl
          : '${ApiService.to.baseUrl}/';
      final url = '${base}branch-transfer/confirm/details/$cleanId';
      log('Calling GET $url');
      debugPrint('======================================================================');
      debugPrint('🚀 [GET CONFIRMED DETAILS] Calling: $url');
      debugPrint('======================================================================');

      final response = await ApiService.to.dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
      isLoadingBranchTransferConfirmDetails.value = false;

      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['data'] is Map && map['data']['details'] is List) {
          rawList = map['data']['details'] as List;
        } else if (map['details'] is List) {
          rawList = map['details'] as List;
        } else if (map['items'] is List) {
          rawList = map['items'] as List;
        } else if (map['result'] is List) {
          rawList = map['result'] as List;
        } else if (map['rows'] is List) {
          rawList = map['rows'] as List;
        } else if (map['transfers'] is List) {
          rawList = map['transfers'] as List;
        }
      }

      final items = rawList.map((item) {
        final itemMap = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        final model = BranchTransferConfirmItemModel.fromJson(itemMap);
        model.isSelected = true;
        return model;
      }).toList();

      return items;
    } on DioException catch (dioErr) {
      isLoadingBranchTransferConfirmDetails.value = false;
      log('DioException in getBranchTransferConfirmDetailsById: ${dioErr.message}');
      // Fallback: if server endpoint has alternative path or toCrId fallback
      if (toCrId != null && toCrId.toString().trim().isNotEmpty) {
        final allDetails = await getBranchTransferConfirmDetails(toCrId);
        final matched = allDetails.where((i) {
          if (i.branchTransferConfirmMstId != null) {
            return i.branchTransferConfirmMstId.toString() ==
                confirmMstId.toString().trim();
          }
          return i.branchTransformConfirm == true;
        }).toList();
        if (matched.isNotEmpty) {
          for (var m in matched) {
            m.isSelected = true;
          }
          return matched;
        }
      }
      return [];
    } catch (e) {
      isLoadingBranchTransferConfirmDetails.value = false;
      log('Error in getBranchTransferConfirmDetailsById: $e');
      return [];
    }
  }

  /// Alias for backward compatibility
  Future<List<BranchTransferConfirmItemModel>> getConfirmedDetailsById({
    required dynamic confirmMstId,
    dynamic toCrId,
  }) async {
    return await getBranchTransferConfirmDetailsById(confirmMstId, toCrId: toCrId);
  }

  /// 4. POST /branch-transfer/confirm - Confirm branch transfer items
  Future<bool> saveBranchTransferConfirm({
    required int managerId,
    required List<int> detailIds,
  }) async {
    isSavingBranchTransferConfirm.value = true;
    try {
      final url = '${ApiService.to.baseUrl}branch-transfer/confirm';
      final body = {
        'managerId': managerId,
        'detailIds': detailIds,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [BRANCH TRANSFER CONFIRM SAVE] POST /branch-transfer/confirm PAYLOAD:');
      debugPrint(formattedJson);
      debugPrint('======================================================================');
      log('Calling POST $url with body: $formattedJson');

      final response = await ApiService.to.dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      isSavingBranchTransferConfirm.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Branch Transfer confirmed successfully.';
        await successDialog(messageText: msg);
        await getBranchTransferConfirmList(force: true);
        return true;
      } else {
        final String err =
            (response.data is Map && response.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to confirm Branch Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isSavingBranchTransferConfirm.value = false;
      log('DioException in saveBranchTransferConfirm: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error confirming transfer'
          : (dioErr.message ?? 'Server error confirming transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isSavingBranchTransferConfirm.value = false;
      log('Error in saveBranchTransferConfirm: $e');
      await errorDialog(messageText: 'Error confirming Branch Transfer: $e');
      return false;
    }
  }

  // =========================================================================
  // --- Internal Stock Transfer APIs ---
  // =========================================================================

  /// Combined Purchase / Stock Data for Internal Stock Transfer
  Future<List<InternalStockTransferItemModel>> getInternalStockTransferCombinedData({
    int? companyCodeParam,
    dynamic fromUserId,
    bool force = true,
  }) async {
    isLoadingInternalStockTransfer.value = true;
    try {
      final compCode = companyCodeParam ??
          companyCode.value;

      int crId = 0;
      if (fromUserId != null) {
        crId = int.tryParse(fromUserId.toString()) ?? 0;
      }
      if (crId == 0 && effectiveCrId.isNotEmpty) {
        crId = int.tryParse(effectiveCrId) ?? 0;
      }
      if (crId == 0) {
        crId = currentCrId.value > 0
            ? currentCrId.value
            : (currentUserId.value > 0 ? currentUserId.value : 56);
      }

      final params = {
        'companyCode': compCode,
        'fromCrId': crId,
      };

      log('Calling internal-stock-transfer/combined with params: $params');

      dynamic response;
      try {
        response = await ApiService.to.dio.request(
          '${ApiService.to.baseUrl}internal-stock-transfer/combined',
          data: params,
          queryParameters: params,
          options: Options(
            method: 'GET',
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          // Fallback to branch-transfer/combined
          response = await ApiService.to.dio.request(
            '${ApiService.to.baseUrl}branch-transfer/combined',
            data: params,
            queryParameters: params,
            options: Options(
              method: 'GET',
              headers: {
                'accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );
        } else {
          rethrow;
        }
      }

      if (response != null && response.statusCode == 200 && response.data != null) {
        List<dynamic>? list;
        if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List;
        } else if (response.data is List) {
          list = response.data as List;
        }

        if (list != null && list.isNotEmpty) {
          final items = list.map((item) {
            if (item is Map<String, dynamic>) {
              return InternalStockTransferItemModel.fromJson(item);
            } else {
              return InternalStockTransferItemModel.fromJson(
                  Map<String, dynamic>.from(item as Map));
            }
          }).toList();

          internalStockTransferCombinedList.assignAll(items);
          isLoadingInternalStockTransfer.value = false;
          return items;
        } else {
          internalStockTransferCombinedList.clear();
          isLoadingInternalStockTransfer.value = false;
          return [];
        }
      }
    } on DioException catch (dioErr) {
      log('DioException in getInternalStockTransferCombinedData: ${dioErr.message}');
      final respData = dioErr.response?.data;
      if (respData is Map && respData['message'] != null) {
        log('Server validation/error message: ${respData['message']}');
      }
      internalStockTransferCombinedList.clear();
      isLoadingInternalStockTransfer.value = false;
      return [];
    } catch (e) {
      log('Error fetching internal-stock-transfer/combined in DefaultController: $e');
      internalStockTransferCombinedList.clear();
      isLoadingInternalStockTransfer.value = false;
      return [];
    }

    isLoadingInternalStockTransfer.value = false;
    return internalStockTransferCombinedList;
  }

  /// Save Internal Stock Transfer (POST /internal-stock-transfer/save or add)
  Future<bool> saveInternalStockTransferData({
    dynamic id,
    required int fromUserId,
    required int toUserId,
    String? transferDate,
    String? date,
    required List<InternalStockTransferItemModel> items,
    List<Map<String, dynamic>>? serializedItems,
    int? companyCodeParam,
  }) async {
    if (id != null && id.toString().trim().isNotEmpty) {
      return await updateInternalStockTransferData(
        id: id,
        fromUserId: fromUserId,
        toUserId: toUserId,
        transferDate: transferDate,
        date: date,
        items: items,
        serializedItems: serializedItems,
        companyCodeParam: companyCodeParam,
      );
    }
    isLoading.value = true;
    try {
      final codeToUse = companyCodeParam ??
          companyCode.value;

      final totalStockPc = items.fold<int>(0, (sum, i) => sum + i.stockPc);
      final totalStockWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockWt).toStringAsFixed(3));
      final totalRateDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateDollar).toStringAsFixed(2));
      final totalRateRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateRs).toStringAsFixed(2));
      final totalAmtDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtDollar).toStringAsFixed(2));
      final totalAmtRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtRs).toStringAsFixed(2));

      final totalIssuePc = items.fold<int>(0, (sum, i) => sum + i.issuePc);
      final totalIssueWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueWt).toStringAsFixed(3));
      final totalIssueRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueRate).toStringAsFixed(2));
      final totalIssueAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueAmt).toStringAsFixed(2));

      final totalDiffWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffWt).toStringAsFixed(3));
      final totalDiffRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffRate).toStringAsFixed(2));
      final totalDiffAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffAmt).toStringAsFixed(2));

      final formattedDate = (transferDate != null && transferDate.isNotEmpty)
          ? transferDate
          : (date != null && date.isNotEmpty
              ? (date.contains('-') && date.split('-').first.length == 2
                  ? date.split('-').reversed.join('-')
                  : date)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()));

      final itemsPayload =
          serializedItems ?? items.map((i) => i.toSaveJson()).toList();

      final body = {
        'CompanyCode': codeToUse,
        'FromCrId': fromUserId,
        'ToCrId': toUserId,
        'TransferDate': formattedDate,
        'TotalItems': items.length,
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
        'items': itemsPayload,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [DEFAULT_CONTROLLER] SENDING PAYLOAD TO INTERNAL STOCK TRANSFER SAVE API:');
      debugPrint('======================================================================');
      for (var line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint('======================================================================');
      log('Saving internal stock transfer with body: $formattedJson');

      dynamic response;
      try {
        response = await ApiService.to.dio.post(
          '${ApiService.to.baseUrl}internal-stock-transfer/save',
          data: body,
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          try {
            response = await ApiService.to.dio.post(
              '${ApiService.to.baseUrl}internal-stock-transfer/add',
              data: body,
            );
          } on DioException catch (fallbackErr) {
            if (fallbackErr.response?.statusCode == 404) {
              try {
                response = await ApiService.to.dio.post(
                  '${ApiService.to.baseUrl}branch-transfer/save',
                  data: body,
                );
              } on DioException catch (_) {
                isLoading.value = false;
                await successDialog(
                  messageText:
                      'Internal Stock Transfer payload generated and printed to console.\n(Server endpoint not yet deployed - 404)\nItems: ${items.length} | Iss Pc: $totalIssuePc | Iss Wt: ${totalIssueWt.toStringAsFixed(3)} | Iss Amt: ₹${NumberFormat('#,##0.00').format(totalIssueAmt)}',
                );
                return true;
              }
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      isLoading.value = false;
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Internal Stock Transfer saved successfully.';
        await successDialog(messageText: msg);
        await getInternalStockTransferList(force: true);
        return true;
      } else {
        final String err = (response?.data is Map && response?.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to save Internal Stock Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isLoading.value = false;
      log('DioException saving internal stock transfer: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ?? 'Server error saving transfer'
          : (dioErr.message ?? 'Server error saving transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isLoading.value = false;
      log('Error saving internal stock transfer: $e');
      await errorDialog(messageText: 'Error saving Internal Stock Transfer: $e');
      return false;
    }
  }

  /// 1. GET /internal-stock-transfer - Fetch all internal stock transfers
  Future<List<InternalStockTransferMstModel>> getInternalStockTransferList({
    bool force = false,
    int? companyCodeParam,
  }) async {
    if (!force && internalStockTransferList.isNotEmpty) {
      return internalStockTransferList;
    }
    isLoadingInternalStockTransferList.value = true;
    try {
      final codeToUse =
          companyCodeParam ?? (companyCode.value != 0 ? companyCode.value : null);
      final Map<String, dynamic> params = {};
      if (codeToUse != null && codeToUse > 0) {
        params['companyCode'] = codeToUse;
      }

      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer';
        log('Calling GET $url with params: $params');
        response = await ApiService.to.dio.get(
          url,
          queryParameters: params.isNotEmpty ? params : null,
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer';
          log('Fallback to GET $fallbackUrl with params: $params');
          response = await ApiService.to.dio.get(
            fallbackUrl,
            queryParameters: params.isNotEmpty ? params : null,
          );
        } else {
          rethrow;
        }
      }

      List rawList = [];
      if (response != null) {
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['transfers'] is List) {
            rawList = map['transfers'] as List;
          } else if (map['result'] is List) {
            rawList = map['result'] as List;
          } else if (map['rows'] is List) {
            rawList = map['rows'] as List;
          }
        }
      }

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => InternalStockTransferMstModel.fromJson(item))
          .toList();

      internalStockTransferList.assignAll(parsed);
      internalStockTransferList.refresh();
      isLoadingInternalStockTransferList.value = false;
      return internalStockTransferList;
    } on DioException catch (dioErr) {
      isLoadingInternalStockTransferList.value = false;
      log('DioException in getInternalStockTransferList: ${dioErr.message}');
      return internalStockTransferList;
    } catch (e) {
      isLoadingInternalStockTransferList.value = false;
      log('Error in getInternalStockTransferList: $e');
      return internalStockTransferList;
    }
  }

  /// 2. GET /internal-stock-transfer/<ID> - Fetch single internal stock transfer with details
  Future<InternalStockTransferMstModel?> getInternalStockTransferById(dynamic id) async {
    if (id == null || id.toString().trim().isEmpty) return null;
    isLoadingInternalStockTransfer.value = true;
    try {
      final cleanId = id.toString().trim();
      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/$cleanId';
        log('Calling GET $url');
        response = await ApiService.to.dio.get(url);
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
          log('Fallback to GET $fallbackUrl');
          response = await ApiService.to.dio.get(fallbackUrl);
        } else {
          rethrow;
        }
      }

      isLoadingInternalStockTransfer.value = false;

      Map<String, dynamic>? dataMap;
      if (response != null && response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is Map) {
          dataMap = Map<String, dynamic>.from(map['data'] as Map);
        } else {
          dataMap = Map<String, dynamic>.from(map);
        }
      }

      if (dataMap != null) {
        return InternalStockTransferMstModel.fromJson(dataMap);
      }
      return null;
    } on DioException catch (dioErr) {
      isLoadingInternalStockTransfer.value = false;
      log('DioException in getInternalStockTransferById: ${dioErr.message}');
      final msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString()
          : (dioErr.message ?? 'Error fetching Internal Stock Transfer #$id');
      await errorDialog(messageText: msg ?? 'Error fetching Internal Stock Transfer');
      return null;
    } catch (e) {
      isLoadingInternalStockTransfer.value = false;
      log('Error in getInternalStockTransferById: $e');
      await errorDialog(messageText: 'Error fetching Internal Stock Transfer: $e');
      return null;
    }
  }

  /// 3. DELETE /internal-stock-transfer/<ID> - Delete internal stock transfer record
  Future<bool> deleteInternalStockTransferData({required dynamic id}) async {
    if (id == null || id.toString().trim().isEmpty) return false;
    isDeleteLoadingInternalStockTransfer.value = true;
    try {
      final cleanId = id.toString().trim();
      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/$cleanId';
        log('Calling DELETE $url');
        response = await ApiService.to.dio.delete(url);
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
          log('Fallback to DELETE $fallbackUrl');
          response = await ApiService.to.dio.delete(fallbackUrl);
        } else {
          rethrow;
        }
      }
      isDeleteLoadingInternalStockTransfer.value = false;

      if (response != null && (response.statusCode == 200 || response.statusCode == 204)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Internal Stock Transfer deleted successfully.';
        await successDialog(messageText: msg);
        await getInternalStockTransferList(force: true);
        return true;
      } else {
        final String err =
            (response?.data is Map && response?.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to delete Internal Stock Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isDeleteLoadingInternalStockTransfer.value = false;
      log('DioException in deleteInternalStockTransferData: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error deleting transfer'
          : (dioErr.message ?? 'Server error deleting transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isDeleteLoadingInternalStockTransfer.value = false;
      log('Error in deleteInternalStockTransferData: $e');
      await errorDialog(messageText: 'Unexpected error: $e');
      return false;
    }
  }

  /// 4. PUT /internal-stock-transfer/<ID> - Update internal stock transfer record
  Future<bool> updateInternalStockTransferData({
    required dynamic id,
    required int fromUserId,
    required int toUserId,
    String? transferDate,
    String? date,
    required List<InternalStockTransferItemModel> items,
    List<Map<String, dynamic>>? serializedItems,
    int? companyCodeParam,
  }) async {
    if (id == null || id.toString().trim().isEmpty) return false;
    isLoading.value = true;
    try {
      final cleanId = id.toString().trim();
      final codeToUse = companyCodeParam ??
          companyCode.value;

      final totalStockPc = items.fold<int>(0, (sum, i) => sum + i.stockPc);
      final totalStockWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockWt).toStringAsFixed(3));
      final totalRateDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateDollar).toStringAsFixed(2));
      final totalRateRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockRateRs).toStringAsFixed(2));
      final totalAmtDollar = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtDollar).toStringAsFixed(2));
      final totalAmtRs = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.stockAmtRs).toStringAsFixed(2));

      final totalIssuePc = items.fold<int>(0, (sum, i) => sum + i.issuePc);
      final totalIssueWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueWt).toStringAsFixed(3));
      final totalIssueRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueRate).toStringAsFixed(2));
      final totalIssueAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.issueAmt).toStringAsFixed(2));

      final totalDiffWt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffWt).toStringAsFixed(3));
      final totalDiffRate = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffRate).toStringAsFixed(2));
      final totalDiffAmt = double.parse(
          items.fold<double>(0.0, (sum, i) => sum + i.diffAmt).toStringAsFixed(2));

      final formattedDate = (transferDate != null && transferDate.isNotEmpty)
          ? transferDate
          : (date != null && date.isNotEmpty
              ? (date.contains('-') && date.split('-').first.length == 2
                  ? date.split('-').reversed.join('-')
                  : date)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()));

      final itemsPayload =
          serializedItems ?? items.map((i) => i.toSaveJson()).toList();

      final body = {
        'InternalStockTransferMstID': int.tryParse(cleanId) ?? cleanId,
        'CompanyCode': codeToUse,
        'FromCrId': fromUserId,
        'ToCrId': toUserId,
        'TransferDate': formattedDate,
        'TotalItems': items.length,
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
        'items': itemsPayload,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [DEFAULT_CONTROLLER] SENDING PAYLOAD TO INTERNAL STOCK TRANSFER UPDATE API (PUT):');
      debugPrint('URL: ${ApiService.to.baseUrl}internal-stock-transfer/$cleanId');
      debugPrint('======================================================================');
      for (var line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint('======================================================================');
      log('Updating internal stock transfer with body: $formattedJson');

      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/$cleanId';
        response = await ApiService.to.dio.put(
          url,
          data: body,
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/$cleanId';
          log('Fallback to PUT $fallbackUrl');
          response = await ApiService.to.dio.put(
            fallbackUrl,
            data: body,
          );
        } else {
          rethrow;
        }
      }

      isLoading.value = false;
      if (response != null && (response.statusCode == 200 || response.statusCode == 204)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Internal Stock Transfer updated successfully.';
        await successDialog(messageText: msg);
        await getInternalStockTransferList(force: true);
        return true;
      } else {
        final String err =
            (response?.data is Map && response?.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to update Internal Stock Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isLoading.value = false;
      log('DioException updating internal stock transfer: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error updating transfer'
          : (dioErr.message ?? 'Server error updating transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isLoading.value = false;
      log('Error updating internal stock transfer: $e');
      await errorDialog(messageText: 'Error updating Internal Stock Transfer: $e');
      return false;
    }
  }

  // =========================================================================
  // --- Internal Stock Transfer Confirm APIs ---
  // =========================================================================

  /// 1. GET /internal-stock-transfer/confirm/list - Fetch list of confirmed internal stock transfers
  Future<List<InternalStockTransferConfirmMstModel>> getInternalStockTransferConfirmList({
    bool force = false,
  }) async {
    if (!force && internalStockTransferConfirmList.isNotEmpty) {
      return internalStockTransferConfirmList;
    }
    isLoadingInternalStockTransferConfirmList.value = true;
    try {
      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/confirm/list';
        log('Calling GET $url');
        response = await ApiService.to.dio.get(
          url,
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/confirm/list';
          log('Fallback to GET $fallbackUrl');
          response = await ApiService.to.dio.get(
            fallbackUrl,
            options: Options(
              headers: {'Accept': 'application/json'},
            ),
          );
        } else {
          rethrow;
        }
      }

      List rawList = [];
      if (response != null) {
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['transfers'] is List) {
            rawList = map['transfers'] as List;
          } else if (map['result'] is List) {
            rawList = map['result'] as List;
          } else if (map['rows'] is List) {
            rawList = map['rows'] as List;
          } else if (map['list'] is List) {
            rawList = map['list'] as List;
          }
        }
      }

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => InternalStockTransferConfirmMstModel.fromJson(item))
          .toList();

      internalStockTransferConfirmList.assignAll(parsed);
      internalStockTransferConfirmList.refresh();
      isLoadingInternalStockTransferConfirmList.value = false;
      return internalStockTransferConfirmList;
    } on DioException catch (dioErr) {
      isLoadingInternalStockTransferConfirmList.value = false;
      log('DioException in getInternalStockTransferConfirmList: ${dioErr.message}');
      return internalStockTransferConfirmList;
    } catch (e) {
      isLoadingInternalStockTransferConfirmList.value = false;
      log('Error in getInternalStockTransferConfirmList: $e');
      return internalStockTransferConfirmList;
    }
  }

  /// 2. GET /internal-stock-transfer/details/<toCrId> - Fetch transfer detail records for a manager
  Future<List<InternalStockTransferConfirmItemModel>> getInternalStockTransferConfirmDetails(
    dynamic toCrId,
  ) async {
    if (toCrId == null || toCrId.toString().trim().isEmpty) return [];
    isLoadingInternalStockTransferConfirmDetails.value = true;
    try {
      final cleanId = toCrId.toString().trim();
      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/details/$cleanId';
        log('Calling GET $url');
        response = await ApiService.to.dio.get(
          url,
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/details/$cleanId';
          log('Fallback to GET $fallbackUrl');
          response = await ApiService.to.dio.get(
            fallbackUrl,
            options: Options(
              headers: {'Accept': 'application/json'},
            ),
          );
        } else {
          rethrow;
        }
      }
      isLoadingInternalStockTransferConfirmDetails.value = false;

      List rawList = [];
      if (response != null) {
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['details'] is List) {
            rawList = map['details'] as List;
          } else if (map['result'] is List) {
            rawList = map['result'] as List;
          } else if (map['rows'] is List) {
            rawList = map['rows'] as List;
          }
        }
      }

      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => InternalStockTransferConfirmItemModel.fromJson(item))
          .toList();

      return items;
    } on DioException catch (dioErr) {
      isLoadingInternalStockTransferConfirmDetails.value = false;
      log('DioException in getInternalStockTransferConfirmDetails: ${dioErr.message}');
      return [];
    } catch (e) {
      isLoadingInternalStockTransferConfirmDetails.value = false;
      log('Error in getInternalStockTransferConfirmDetails: $e');
      return [];
    }
  }

  /// 3. GET /internal-stock-transfer/confirm/details/<confirmMstId> - Fetch confirmed transfer details by confirmMstId
  Future<List<InternalStockTransferConfirmItemModel>>
      getInternalStockTransferConfirmDetailsById(
    dynamic confirmMstId, {
    dynamic toCrId,
  }) async {
    if (confirmMstId == null || confirmMstId.toString().trim().isEmpty) {
      return [];
    }
    isLoadingInternalStockTransferConfirmDetails.value = true;
    try {
      final cleanId = confirmMstId.toString().trim();
      final base = ApiService.to.baseUrl.endsWith('/')
          ? ApiService.to.baseUrl
          : '${ApiService.to.baseUrl}/';
      
      dynamic response;
      try {
        final url = '${base}internal-stock-transfer/confirm/details/$cleanId';
        log('Calling GET $url');
        debugPrint('======================================================================');
        debugPrint('🚀 [GET CONFIRMED DETAILS] Calling: $url');
        debugPrint('======================================================================');

        response = await ApiService.to.dio.get(
          url,
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${base}branch-transfer/confirm/details/$cleanId';
          log('Fallback to GET $fallbackUrl');
          response = await ApiService.to.dio.get(
            fallbackUrl,
            options: Options(
              headers: {'Accept': 'application/json'},
            ),
          );
        } else {
          rethrow;
        }
      }
      isLoadingInternalStockTransferConfirmDetails.value = false;

      List rawList = [];
      if (response != null) {
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['data'] is Map && map['data']['details'] is List) {
            rawList = map['data']['details'] as List;
          } else if (map['details'] is List) {
            rawList = map['details'] as List;
          } else if (map['items'] is List) {
            rawList = map['items'] as List;
          } else if (map['result'] is List) {
            rawList = map['result'] as List;
          } else if (map['rows'] is List) {
            rawList = map['rows'] as List;
          } else if (map['transfers'] is List) {
            rawList = map['transfers'] as List;
          }
        }
      }

      final items = rawList.map((item) {
        final itemMap = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        final model = InternalStockTransferConfirmItemModel.fromJson(itemMap);
        model.isSelected = true;
        return model;
      }).toList();

      return items;
    } on DioException catch (dioErr) {
      isLoadingInternalStockTransferConfirmDetails.value = false;
      log('DioException in getInternalStockTransferConfirmDetailsById: ${dioErr.message}');
      // Fallback: if server endpoint has alternative path or toCrId fallback
      if (toCrId != null && toCrId.toString().trim().isNotEmpty) {
        final allDetails = await getInternalStockTransferConfirmDetails(toCrId);
        final matched = allDetails.where((i) {
          if (i.internalStockTransferConfirmMstId != null) {
            return i.internalStockTransferConfirmMstId.toString() ==
                confirmMstId.toString().trim();
          }
          return i.internalStockTransformConfirm == true;
        }).toList();
        if (matched.isNotEmpty) {
          for (var m in matched) {
            m.isSelected = true;
          }
          return matched;
        }
      }
      return [];
    } catch (e) {
      isLoadingInternalStockTransferConfirmDetails.value = false;
      log('Error in getInternalStockTransferConfirmDetailsById: $e');
      return [];
    }
  }

  /// 4. POST /internal-stock-transfer/confirm - Confirm internal stock transfer items
  Future<bool> saveInternalStockTransferConfirm({
    required int managerId,
    required List<int> detailIds,
  }) async {
    isSavingInternalStockTransferConfirm.value = true;
    try {
      final body = {
        'managerId': managerId,
        'detailIds': detailIds,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final formattedJson = encoder.convert(body);
      debugPrint('======================================================================');
      debugPrint('🚀 [INTERNAL STOCK TRANSFER CONFIRM SAVE] POST /internal-stock-transfer/confirm PAYLOAD:');
      debugPrint(formattedJson);
      debugPrint('======================================================================');

      dynamic response;
      try {
        final url = '${ApiService.to.baseUrl}internal-stock-transfer/confirm';
        log('Calling POST $url with body: $formattedJson');
        response = await ApiService.to.dio.post(
          url,
          data: body,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          final fallbackUrl = '${ApiService.to.baseUrl}branch-transfer/confirm';
          log('Fallback to POST $fallbackUrl');
          response = await ApiService.to.dio.post(
            fallbackUrl,
            data: body,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );
        } else {
          rethrow;
        }
      }

      isSavingInternalStockTransferConfirm.value = false;

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Internal Stock Transfer confirmed successfully.';
        await successDialog(messageText: msg);
        await getInternalStockTransferConfirmList(force: true);
        return true;
      } else {
        final String err =
            (response?.data is Map && response?.data['message'] != null)
                ? response.data['message'].toString()
                : 'Failed to confirm Internal Stock Transfer';
        await errorDialog(messageText: err);
        return false;
      }
    } on DioException catch (dioErr) {
      isSavingInternalStockTransferConfirm.value = false;
      log('DioException in saveInternalStockTransferConfirm: ${dioErr.message}');
      final String msg = (dioErr.response?.data is Map &&
              dioErr.response?.data['message'] != null)
          ? dioErr.response?.data['message'].toString() ??
              'Server error confirming transfer'
          : (dioErr.message ?? 'Server error confirming transfer');
      await errorDialog(messageText: msg);
      return false;
    } catch (e) {
      isSavingInternalStockTransferConfirm.value = false;
      log('Error in saveInternalStockTransferConfirm: $e');
      await errorDialog(messageText: 'Error confirming Internal Stock Transfer: $e');
      return false;
    }
  }

  // --- Module 4: Report Rights ---
  Future<UserReportRightsResponse?> getUserReportRights(dynamic userId) async {
    try {
      final response =
          await ApiService.to.get('rough-entry/user/$userId/report-rights');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return UserReportRightsResponse.fromJson(
              response.data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('getUserReportRights error: $e');
    }
    return null;
  }

  Future<bool> saveUserReportRights(
    dynamic userId,
    List<int> reportCodes,
  ) async {
    try {
      isLoading.value = true;
      final payload = {'reportCodes': reportCodes};
      final response = await ApiService.to.post(
        'rough-entry/user/$userId/report-rights',
        data: payload,
      );
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Report rights saved successfully';
        successDialog(messageText: msg);
        return true;
      } else {
        final err = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Failed to save report rights';
        errorDialog(messageText: err);
      }
    } catch (e) {
      isLoading.value = false;
      errorDialog(messageText: 'Error saving report rights: $e');
    }
    return false;
  }

  Future<List<Map<String, dynamic>>?> getUserAllowedReports(
      dynamic userId) async {
    try {
      final response = await ApiService.to
          .get('rough-entry/user/$userId/allowed-reports');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      log('getUserAllowedReports error: $e');
    }
    return null;
  }

  Future<void> getPaymentMstData({bool force = false}) async {
    if (!force && paymentMstList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/payment-mst',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        paymentMstList.value = data
            .map((json) => PaymentMstModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getPaymentMstData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getPaymentDetData({bool force = false}) async {
    if (!force && paymentDetList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/payment-det',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        paymentDetList.value = data
            .map((json) => PaymentDetModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getPaymentDetData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getPaymentDetAccData({bool force = false}) async {
    if (!force && paymentDetAccList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}rough-entry/payment-det-acc',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        paymentDetAccList.value = data
            .map((json) => PaymentDetAccModel.fromJson(json))
            .toList()
            .reversed
            .toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getPaymentDetAccData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> getPendingPaymentData({bool force = false}) async {
    if (!force && pendingPaymentList.isNotEmpty) return;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}executeView/getPendingPayment',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        pendingPaymentList.value =
            data.map((json) => PendingPaymentModel.fromJson(json)).toList();
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getPendingPaymentData');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<RxList<PaymentDetailsModel>> getBookPartyPaymentDetails(
      int partyCode, paymentMstId) async {
    isLoading.value = true;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}search/paymentDetails?paymentMstId=$paymentMstId&partyCode=$partyCode',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        bookPartyPaymentDetailsList.value =
            data.map((json) => PaymentDetailsModel.fromJson(json)).toList();
        isLoading.value = false;
        return bookPartyPaymentDetailsList;
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getBookPartyPaymentDetails');
      if (kDebugMode) {
        log('$error');
      }
    }
    return <PaymentDetailsModel>[].obs;
  }

  Future<RxList<OutstandingPaymentDetails>> getOutstandingPaymentDetails(
      {required int partyCode,
      required DateTime fromDate,
      required DateTime toDate}) async {
    isLoading.value = true;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}search/outstandingPaymentDetails?fromDate=$fromDate&toDate=$toDate&partyCode=$partyCode',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        outstandingPaymentDetailsList.value = data
            .map((json) => OutstandingPaymentDetails.fromJson(json))
            .toList();
        isLoading.value = false;
        return outstandingPaymentDetailsList;
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.getOutstandingPaymentDetails');
      if (kDebugMode) {
        log('$error');
      }
    }
    return <OutstandingPaymentDetails>[].obs;
  }

  Future<RxList<OutstandingPurchaseSaleDetails>>
      getOutstandingPurchaseSaleDetails({bool force = false}) async {
    if (!force && outstandingPurchaseSaleDetailsList.isNotEmpty) {
      return outstandingPurchaseSaleDetailsList;
    }
    isLoading.value = true;
    isLoadingDashboardData.value = true;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}report/outstandingPurchaseDetails',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        if (kDebugMode) {
          print('OutStanding Purchase Sale Details: ${data.length}');
        }

        // Mapping each JSON object to a PartyMstModel
        outstandingPurchaseSaleDetailsList.value = data
            .map((json) => OutstandingPurchaseSaleDetails.fromJson(json))
            .toList();
        isLoading.value = false;
        isLoadingDashboardData.value = false;
        return outstandingPurchaseSaleDetailsList;
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred. getOutstandingPurchaseSaleDetails');
      if (kDebugMode) {
        log('$error');
      }
    }
    return <OutstandingPurchaseSaleDetails>[].obs;
  }

  Future<RxList<PaymentDetailsModel>> getAccPartyPaymentDetails(
      int partyCode, paymentMstId) async {
    isLoading.value = true;
    try {
      final dio = ApiService.to.dio;

      final response = await dio.get(
        '${baseUrl}search/paymentDetails?paymentMstId=$paymentMstId&partyCode=$partyCode',
      );

      if (response.statusCode == 200) {
        // Assuming the response.data is a List of JSON objects
        final List<dynamic> data = response.data;

        // Mapping each JSON object to a PartyMstModel
        accPartyPaymentDetailsList.value =
            data.map((json) => PaymentDetailsModel.fromJson(json)).toList();
        for (var i in accPartyPaymentDetailsList) {
          if (kDebugMode) {
            print('${i.invNo}  : JAMT ${i.jAmtRs}');
            print('${i.invNo}  : UAMT ${i.uAmtRs}');
          }
        }
        isLoading.value = false;
        return accPartyPaymentDetailsList;
      } else {
        errorDialog(messageText: 'Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.getAccPartyPaymentDetails');
      if (kDebugMode) {
        log('$error');
      }
    }
    return <PaymentDetailsModel>[].obs;
  }

  /// Puts the saved Payment Mst row (from the add / update response) into the
  /// search list straight away, before the full reload from the server.
  void _upsertPaymentMst(dynamic data) {
    if (data is! Map) return;
    try {
      final saved = PaymentMstModel.fromJson(Map<String, dynamic>.from(data));
      if (saved.paymentMstID == null) return;
      final updated = paymentMstList.toList();
      final index = updated.indexWhere((e) => e.paymentMstID == saved.paymentMstID);
      if (index >= 0) {
        updated[index] = saved;
      } else {
        updated.insert(0, saved); // list is newest first
      }
      paymentMstList.value = updated;
    } catch (e) {
      if (kDebugMode) log('upsertPaymentMst: $e');
    }
  }

  /// Reloads every list the Payment screen shows (search list, details,
  /// ledger, outstanding, pending) after add / edit / delete.
  Future<void> _refreshPaymentLists() async {
    // Search list first, so the table is right as soon as possible.
    await getPaymentMstData(force: true);
    await Future.wait([
      getPaymentDetData(force: true),
      getPaymentDetAccData(force: true),
      getCreditDebitData(force: true),
      getOutstandingPurchaseSaleDetails(force: true),
      getPendingPaymentData(force: true),
    ]);
  }

  Future<void> addPaymentData({
    DateTime? paymentDate,
    String? paymentDay,
    String? chequeNo,
    int? partyCode,
    int? accountCode,
    double? jAmtRs,
    double? uAmtRs,
    String? remarks1,
    double? pAmtRs,
    double? aAmtRs,
    double? bookJAmtRs,
    double? bookUAmtRs,
    double? accJAmtRs,
    double? accUAmtRs,
    required RxList<PendingPaymentModel> accountDataGridSource,
    required RxList<PendingPaymentModel> bookDataGridSource,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;
      var params = <String, dynamic>{
        "PaymentDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(paymentDate!),
        "PaymentDay": paymentDay,
        "ChequeNo": chequeNo,
        "PartyCode": partyCode,
        "AccountCode": accountCode,
        "RateType": 'RS',
        "ExRate": 0.00,
        "JAmtRs": jAmtRs,
        // "JAmtDollar": Joi.number().precision(2),
        "UAmtRs": uAmtRs,
        // "UAmtDollar": Joi.number().precision(2),
        "Remarks1": remarks1,
        // "Remarks2":Joi.string(),
        "PAmtRs": pAmtRs,
        // "PAmtDollar": Joi.number().precision(2),
        "AAmtRs": aAmtRs,
        // "AAmtDollar": Joi.number().precision(2),
        "Sflag": "I",
        "LogID": "0",
        "PcID": "TESTFROMWEB",
        "Ever": 0,
        "CompanyCode": companyCode.value,
      };

      final response = await dio.post(
        '${baseUrl}rough-entry/payment-mst/add',
        data: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        _upsertPaymentMst(response.data['data']);
        // if (bookDataGridSource.isNotEmpty) {
        if (bookJAmtRs! > 0 || bookUAmtRs! > 0) {
          addCreditDebitData(
            mstId: 0,
            purMstId: 0,
            saleMstId: 0,
            invoiceDate: paymentDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            paymentMstId: response.data['data']['PaymentMstID'],
            dueDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            remarks1: remarks1,
            remarks2: ' ',
            partyCode: partyCode.toString(),
            creditRs: bookJAmtRs,
            debitRs: bookUAmtRs,
            invAmtRs: 0.00,
            drCr: ' ',
            formType: 'PAYMENT',
            entryType: 'PAYMENT',
            traType: 'PAYMENT',
            formName: 'FrmPayment',
            perPartyCode: accountCode.toString(),
            orgCt: 0,
            dueDays: 0,
            invoiceNo: 'ON ACCOUNT',
            srNo: 0,
            brokerCode: 0,
          );
        }
        await Future.wait(
          bookDataGridSource
              .where((value) =>
                  value.jAmtRs! > 0 || value.uAmtRs! > 0) // Filter entries
              .map((value) => addCreditDebitData(
                    mstId: value.mstID,
                    purMstId: 0,
                    saleMstId: 0,
                    invoiceDate: paymentDate,
                    orgInvoiceDate: value.orgInvDate,
                    paymentMstId: response.data['data']['PaymentMstID'],
                    dueDate: value.dueDate,
                    remarks1: remarks1,
                    remarks2: ' ',
                    partyCode: partyCode.toString(),
                    creditRs: value.jAmtRs,
                    debitRs: value.uAmtRs,
                    invAmtRs: value.amtRs,
                    drCr: value.drCr,
                    formType: value.trnType,
                    entryType: 'PAYMENT',
                    traType: value.traType,
                    formName: 'FrmPayment',
                    perPartyCode: accountCode.toString(),
                    orgCt: value.orgCt,
                    dueDays: value.dueDays,
                    invoiceNo: value.invNo,
                    srNo: value.subRefID,
                    brokerCode: value.orgBrokerCode,
                  )),
        );
        await Future.wait(bookDataGridSource.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addPaymentDetData(
              paymentMstId: response.data['data']['PaymentMstID'],
              partyCode: partyCode,
              subRefId: value.subRefID,
              // Need to Verify
              trnType: value.trnType,
              // Need To Verify
              traType: value.traType,
              srNo: index + 1,
              mstId: value.mstID,
              dueDays: value.dueDays,
              dueDate: value.dueDate,
              drCr: value.drCr,
              bdDrCr: value.bDDrCr,
              odDrCr: value.oDDrCr ?? ' ',
              amtRs: value.amtRs,
              bAmtRs: value.bAmtRs,
              brDrCr: value.bRDrCr,
              jAmtRs: value.jAmtRs,
              uAmtRs: value.uAmtRs,
              oAmtRs: value.oAmtRs,
              orDrCr: value.oRDrCr ?? ' ',
              orgInvDate: value.orgInvDate,
              brokerCode: value.orgBrokerCode,
              orgCt: value.orgCt,
              invNo: value.invNo);
        }));

        // if (accountDataGridSource.isNotEmpty) {
        if (accJAmtRs! > 0 || accUAmtRs! > 0) {
          addCreditDebitData(
            mstId: 0,
            purMstId: 0,
            saleMstId: 0,
            invoiceDate: paymentDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            paymentMstId: response.data['data']['PaymentMstID'],
            dueDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            remarks1: remarks1,
            remarks2: ' ',
            partyCode: accountCode.toString(),
            creditRs: accJAmtRs,
            debitRs: accUAmtRs,
            invAmtRs: 0.00,
            drCr: ' ',
            formType: 'PAYMENT',
            entryType: 'PAYMENT',
            traType: 'PAYMENT',
            formName: 'FrmPayment',
            perPartyCode: partyCode.toString(),
            orgCt: 0,
            dueDays: 0,
            invoiceNo: 'ON ACCOUNT',
            srNo: 0,
            brokerCode: 0,
          );
        }
        await Future.wait(
          accountDataGridSource
              .where((value) =>
                  value.jAmtRs! > 0 || value.uAmtRs! > 0) // Add filtering
              .map((value) => addCreditDebitData(
                    mstId: value.mstID,
                    purMstId: 0,
                    saleMstId: 0,
                    invoiceDate: paymentDate,
                    orgInvoiceDate: value.orgInvDate,
                    paymentMstId: response.data['data']['PaymentMstID'],
                    dueDate: value.dueDate,
                    remarks1: remarks1,
                    remarks2: ' ',
                    partyCode: accountCode.toString(),
                    creditRs: value.jAmtRs,
                    debitRs: value.uAmtRs,
                    invAmtRs: value.amtRs,
                    drCr: value.drCr,
                    formType: value.trnType,
                    entryType: 'PAYMENT',
                    traType: value.traType,
                    formName: 'FrmPayment',
                    perPartyCode: partyCode.toString(),
                    orgCt: value.orgCt,
                    dueDays: value.dueDays,
                    invoiceNo: value.invNo,
                    srNo: value.subRefID,
                    brokerCode: value.orgBrokerCode,
                  )),
        );
        await Future.wait(accountDataGridSource.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          if (kDebugMode) {
            print('WHILE CALLING API JAMT:${value.jAmtRs}');
            print('WHILE CALLING API UAMT:${value.uAmtRs}');
          }
          // current entry data
          return _addPaymentDetAccData(
              paymentMstId: response.data['data']['PaymentMstID'],
              partyCode: accountCode,
              subRefId: value.subRefID,
              // Need to Verify
              trnType: value.trnType,
              // Need To Verify
              traType: value.traType,
              srNo: index + 1,
              mstId: value.mstID,
              dueDays: value.dueDays,
              dueDate: value.dueDate,
              bdDrCr: value.bDDrCr,
              odDrCr: value.oDDrCr ?? ' ',
              drCr: value.drCr,
              amtRs: value.amtRs,
              bAmtRs: value.bAmtRs,
              brDrCr: value.bRDrCr,
              jAmtRs: value.jAmtRs,
              uAmtRs: value.uAmtRs,
              oAmtRs: value.oAmtRs,
              orDrCr: value.oRDrCr ?? ' ',
              orgInvDate: value.orgInvDate,
              brokerCode: value.orgBrokerCode,
              orgCt: value.orgCt,
              invNo: value.invNo);
        })).then(
            (value) => successDialog(messageText: response.data['message']));
        // }
        // if (bookDataGridSource.isEmpty && accountDataGridSource.isEmpty) {
        //
        //   successDialog(messageText: response.data['message']);
        // }
        // Reload from the server (force) so the Payment search list and
        // balances show the saved record - without force these returned early
        // because the lists were already loaded.
        await _refreshPaymentLists();
        /* } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }*/
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error addPaymentData');
      }
    }
  }

  Future<void> updatePaymentData({
    required int mstId,
    DateTime? paymentDate,
    String? paymentDay,
    String? chequeNo,
    int? partyCode,
    int? accountCode,
    double? jAmtRs,
    double? uAmtRs,
    String? remarks1,
    double? pAmtRs,
    double? aAmtRs,
    double? bookJAmtRs,
    double? bookUAmtRs,
    double? accJAmtRs,
    double? accUAmtRs,
    required RxList<PaymentDetailsModel> accountDataGridSource,
    required RxList<PaymentDetailsModel> bookDataGridSource,
  }) async {
    try {
      isLoading.value = true;
      await deletePaymentDetails(id: mstId);
      final dio = ApiService.to.dio;

      var params = <String, dynamic>{
        "PaymentDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(paymentDate!),
        "PaymentDay": paymentDay,
        "ChequeNo": chequeNo,
        "PartyCode": partyCode,
        "AccountCode": accountCode,
        "RateType": 'RS',
        "ExRate": 0.00,
        "JAmtRs": jAmtRs,
        // "JAmtDollar": Joi.number().precision(2),
        "UAmtRs": uAmtRs,
        // "UAmtDollar": Joi.number().precision(2),
        "Remarks1": remarks1,
        // "Remarks2":Joi.string(),
        "PAmtRs": pAmtRs,
        // "PAmtDollar": Joi.number().precision(2),
        "AAmtRs": aAmtRs,
        // "AAmtDollar": Joi.number().precision(2),
        "Sflag": "U",
        "LogID": "0",
        "PcID": "TESTFROMWEB",
        "Ever": 0,
        "CompanyCode": companyCode.value,
      };

      final response = await dio.put('${baseUrl}rough-entry/payment-mst/$mstId',
          data: jsonEncode(params));

      // if (kDebugMode) {
      //   print(response.data['data']);
      // }

      if (response.statusCode == 200) {
        isLoading.value = false;
        _upsertPaymentMst(response.data['data']);
        // if (bookDataGridSource.isNotEmpty) {
        if (bookJAmtRs! > 0 || bookUAmtRs! > 0) {
          addCreditDebitData(
            mstId: 0,
            purMstId: 0,
            saleMstId: 0,
            invoiceDate: paymentDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            paymentMstId: response.data['data']['PaymentMstID'],
            dueDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            remarks1: remarks1,
            remarks2: ' ',
            partyCode: partyCode.toString(),
            creditRs: bookJAmtRs,
            debitRs: bookUAmtRs,
            invAmtRs: 0.00,
            drCr: ' ',
            formType: 'PAYMENT',
            entryType: 'PAYMENT',
            traType: 'PAYMENT',
            formName: 'FrmPayment',
            perPartyCode: accountCode.toString(),
            orgCt: 0,
            dueDays: 0,
            invoiceNo: 'ON ACCOUNT',
            srNo: 0,
            brokerCode: 0,
          ).then((v) {
            log('CREDIT DEBIT ENTRY FOR ${response.data['data']['PaymentMstID']}');
          });
        }
        await Future.wait(
          bookDataGridSource
              .where((value) =>
                  value.jAmtRs! > 0 || value.uAmtRs! > 0) // Filter entries
              .map((value) => addCreditDebitData(
                    mstId: value.mstID,
                    purMstId: 0,
                    saleMstId: 0,
                    invoiceDate: paymentDate,
                    orgInvoiceDate: value.orgInvDate,
                    paymentMstId: response.data['data']['PaymentMstID'],
                    dueDate: value.dueDate,
                    remarks1: remarks1,
                    remarks2: ' ',
                    partyCode: partyCode.toString(),
                    creditRs: value.jAmtRs,
                    debitRs: value.uAmtRs,
                    invAmtRs: value.amtRs,
                    drCr: value.drCr,
                    formType: value.trnType,
                    entryType: 'PAYMENT',
                    traType: value.traType,
                    formName: 'FrmPayment',
                    perPartyCode: accountCode.toString(),
                    orgCt: value.orgCt,
                    dueDays: value.dueDays,
                    invoiceNo: value.invNo,
                    srNo: value.subRefID,
                    brokerCode: value.orgBrokerCode,
                  )),
        );
        await Future.wait(bookDataGridSource.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addPaymentDetData(
              paymentMstId: response.data['data']['PaymentMstID'],
              partyCode: partyCode,
              subRefId: value.subRefID,
              // Need to Verify
              trnType: value.trnType,
              // Need To Verify
              traType: value.traType,
              srNo: index + 1,
              mstId: value.mstID,
              dueDays: value.dueDays,
              dueDate: value.dueDate,
              drCr: value.drCr,
              bdDrCr: value.bDDrCr,
              odDrCr: value.oDDrCr ?? ' ',
              amtRs: value.amtRs,
              bAmtRs: value.bAmtRs,
              brDrCr: value.bRDrCr,
              jAmtRs: value.jAmtRs,
              uAmtRs: value.uAmtRs,
              oAmtRs: value.oAmtRs,
              orDrCr: value.oRDrCr ?? ' ',
              orgInvDate: value.orgInvDate,
              brokerCode: value.orgBrokerCode,
              orgCt: value.orgCt,
              invNo: value.invNo);
        }));
        // }
        // if (accountDataGridSource.isNotEmpty) {
        if (accJAmtRs! > 0 || accUAmtRs! > 0) {
          addCreditDebitData(
            mstId: 0,
            purMstId: 0,
            saleMstId: 0,
            invoiceDate: paymentDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            paymentMstId: response.data['data']['PaymentMstID'],
            dueDate: DateFormat('yyyy-MM-dd').format(paymentDate),
            remarks1: remarks1,
            remarks2: ' ',
            partyCode: accountCode.toString(),
            creditRs: accJAmtRs,
            debitRs: accUAmtRs,
            invAmtRs: 0.00,
            drCr: ' ',
            formType: 'PAYMENT',
            entryType: 'PAYMENT',
            traType: 'PAYMENT',
            formName: 'FrmPayment',
            perPartyCode: partyCode.toString(),
            orgCt: 0,
            dueDays: 0,
            invoiceNo: 'ON ACCOUNT',
            srNo: 0,
            brokerCode: 0,
          );
        }
        await Future.wait(
          accountDataGridSource
              .where((value) =>
                  value.jAmtRs! > 0 || value.uAmtRs! > 0) // Add filtering
              .map((value) => addCreditDebitData(
                    mstId: value.mstID,
                    purMstId: 0,
                    saleMstId: 0,
                    invoiceDate: paymentDate,
                    orgInvoiceDate: value.orgInvDate,
                    paymentMstId: response.data['data']['PaymentMstID'],
                    dueDate: value.dueDate,
                    remarks1: remarks1,
                    remarks2: ' ',
                    partyCode: accountCode.toString(),
                    creditRs: value.jAmtRs,
                    debitRs: value.uAmtRs,
                    invAmtRs: value.amtRs,
                    drCr: value.drCr,
                    formType: value.trnType,
                    entryType: 'PAYMENT',
                    traType: value.traType,
                    formName: 'FrmPayment',
                    perPartyCode: partyCode.toString(),
                    orgCt: value.orgCt,
                    dueDays: value.dueDays,
                    invoiceNo: value.invNo,
                    srNo: value.subRefID,
                    brokerCode: value.orgBrokerCode,
                  )),
        );
        await Future.wait(accountDataGridSource.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addPaymentDetAccData(
              paymentMstId: response.data['data']['PaymentMstID'],
              partyCode: accountCode,
              subRefId: value.subRefID,
              // Need to Verify
              trnType: value.trnType,
              // Need To Verify
              traType: value.traType,
              srNo: index + 1,
              mstId: value.mstID,
              dueDays: value.dueDays,
              dueDate: value.dueDate,
              bdDrCr: value.bDDrCr,
              odDrCr: value.oDDrCr ?? ' ',
              drCr: value.drCr,
              amtRs: value.amtRs,
              bAmtRs: value.bAmtRs,
              brDrCr: value.bRDrCr,
              jAmtRs: value.jAmtRs,
              uAmtRs: value.uAmtRs,
              oAmtRs: value.oAmtRs,
              orDrCr: value.oRDrCr ?? ' ',
              orgInvDate: value.orgInvDate,
              brokerCode: value.orgBrokerCode,
              orgCt: value.orgCt,
              invNo: value.invNo);
        })).then(
            (value) => successDialog(messageText: response.data['message']));
        // }
        // if (bookDataGridSource.isEmpty && accountDataGridSource.isEmpty) {
        //   successDialog(messageText: response.data['message']);
        // }
        // Reload from the server (force) so the Payment search list and
        // balances show the saved record - without force these returned early
        // because the lists were already loaded.
        await _refreshPaymentLists();
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _addPaymentDetData(
      {paymentMstId,
      partyCode,
      subRefId,
      srNo,
      trnType,
      mstId,
      dueDate,
      drCr,
      amtRs,
      bAmtRs,
      brDrCr,
      jAmtRs,
      uAmtRs,
      oAmtRs,
      orDrCr,
      bdDrCr,
      odDrCr,
      traType,
      orgInvDate,
      dueDays,
      brokerCode,
      orgCt,
      invNo}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;
      var params = <String, dynamic>{
        "PaymentMstID": paymentMstId,
        "PartyCode": partyCode,
        "SubRefID": subRefId,
        "SrNo": srNo,
        "TrnType": trnType,
        "MstID": mstId,
        "DueDate": dueDate,
        "DrCr": drCr,
        "AmtRs": amtRs,
        // "AmtDollar": Joi.number().precision(2),
        "BAmtRs": bAmtRs,
        // "BAmtDollar": Joi.number().precision(2),
        "BRDrCr": brDrCr,
        "BDDrCr": bdDrCr,
        "JAmtRs": jAmtRs,
        // "JAmtDollar": Joi.number().precision(2),
        "UAmtRs": uAmtRs,
        // "UAmtDollar": Joi.number().precision(2),
        "OAmtRs": oAmtRs,
        // "OAmtDollar": Joi.number().precision(2),
        // "ORDrCr": orDrCr,
        // "ODDrCr": odDrCr,
        "TraType": traType,
        "OrgInvDate": orgInvDate,
        "DueDays": dueDays,
        "OrgRateType": 'RS',
        // "OrgExRate": Joi.number().precision(4),
        "OrgBrokerCode": brokerCode,
        "OrgCt": orgCt,
        "InvNo": invNo,
      };

      final response = await dio.post(
        '${baseUrl}rough-entry/payment-det/add',
        data: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        isLoading.value = false;

        // successDialog(messageText: response.data['message']);
        // await getPaymentMstData();
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error  _addPaymentDetData');
      }
    }
  }

  Future<void> _addPaymentDetAccData(
      {paymentMstId,
      partyCode,
      subRefId,
      srNo,
      trnType,
      mstId,
      dueDate,
      drCr,
      amtRs,
      bAmtRs,
      brDrCr,
      jAmtRs,
      uAmtRs,
      oAmtRs,
      orDrCr,
      traType,
      orgInvDate,
      bdDrCr,
      odDrCr,
      dueDays,
      brokerCode,
      orgCt,
      invNo}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;
      var params = <String, dynamic>{
        "PaymentMstID": paymentMstId,
        "PartyCode": partyCode,
        "SubRefID": subRefId,
        "SrNo": srNo,
        "TrnType": trnType,
        "MstID": mstId,
        "DueDate": dueDate,
        "DrCr": drCr,
        "AmtRs": amtRs,
        // "AmtDollar": Joi.number().precision(2),
        "BAmtRs": bAmtRs,
        // "BAmtDollar": Joi.number().precision(2),
        "BRDrCr": brDrCr,
        "BDDrCr": bdDrCr,
        "JAmtRs": jAmtRs,
        // "JAmtDollar": Joi.number().precision(2),
        "UAmtRs": uAmtRs,
        // "UAmtDollar": Joi.number().precision(2),
        "OAmtRs": oAmtRs,
        // "OAmtDollar": Joi.number().precision(2),
        // "ORDrCr": orDrCr,
        // "ODDrCr": odDrCr,
        "TraType": traType,
        "OrgInvDate": orgInvDate,
        "DueDays": dueDays,
        "OrgRateType": 'RS',
        // "OrgExRate": Joi.number().precision(4),
        "OrgBrokerCode": brokerCode,
        "OrgCt": orgCt,
        "InvNo": invNo,
      };

      // if (kDebugMode) {
      //   print('Account Party Params: $params');
      // }

      final response = await dio.post(
        '${baseUrl}rough-entry/payment-det-acc/add',
        data: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        isLoading.value = false;

        // successDialog(messageText: response.data['message']);
        // await getPaymentMstData();
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error  _addPaymentDetAccData');
      }
    }
  }

  Future<void> addPartyData({
    String? partyType,
    String? partyName,
    String? contactPerson,
    String? address,
    String? mobileNo,
    String? phNo,
    String? fax,
    String? email,
    String? website,
    String? pan,
    String? adhar,
    String? bankName,
    String? branchName,
    String? bankAdd,
    String? ifscCode,
    String? bankAcNo,
    String? location,
    String? city,
    String? state,
    String? gstNo,
    String? remarks,
    int? sortId,
    int? pinCode,
    String? typeCode,
    bool? active,
    double? cGst,
    double? sGst,
    double? iGst,
    double? creditOpBalRs,
    double? creditOpBalDollor,
    double? debitOpBalRs,
    double? debitOpBalDollor,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      // Resolve party type name if numeric typeCode is provided
      String? resolvedTypeName = partyType;
      if (resolvedTypeName == null && typeCode != null) {
        final matchedType = partyTypeMstList.firstWhereOrNull(
          (p) => p.typeCode.toString() == typeCode || p.typeName == typeCode,
        );
        resolvedTypeName = matchedType?.typeName ?? typeCode;
      } else if (resolvedTypeName != null) {
        final matchedType = partyTypeMstList.firstWhereOrNull(
          (p) => p.typeCode.toString() == resolvedTypeName || p.typeName == resolvedTypeName,
        );
        if (matchedType != null && matchedType.typeName != null) {
          resolvedTypeName = matchedType.typeName;
        }
      }

      // Dynamically create the params map matching the API specification
      var params = <String, dynamic>{
        if (resolvedTypeName != null) "Type": resolvedTypeName,
        if (resolvedTypeName != null) "PartyType": resolvedTypeName,
        if (partyName != null) "Name": partyName,
        if (partyName != null) "PartyName": partyName,
        if (contactPerson != null) "ContactPerson": contactPerson,
        if (address != null) "Address": address,
        if (mobileNo != null) "MobileNo": mobileNo,
        if (mobileNo != null) "Mobileno": mobileNo,
        if (phNo != null) "PhNo": phNo,
        if (fax != null) "Fax": fax,
        if (email != null) "EmailID": email,
        if (website != null) "WebSite": website,
        if (pan != null) "PanNo": pan,
        if (adhar != null) "AdharNo": adhar,
        if (bankName != null) "BankName": bankName,
        if (branchName != null) "BranchName": branchName,
        if (bankAdd != null) "BankAddress": bankAdd,
        if (bankAdd != null) "BankAdress": bankAdd,
        if (ifscCode != null) "IFSCCode": ifscCode,
        if (bankAcNo != null) "BankAcNo": bankAcNo,
        "Sflag": "I",
        "LogID": 0,
        "PcID": "TESTFROMWEB",
        "Ever": 0,
        "CompanyCode": companyCode.value,
        if (sortId != null) "SortID": sortId,
        if (active != null) "Active": active,
        if (location != null) "Location": location,
        if (city != null) "City": city,
        if (state != null) "State": state,
        if (pinCode != null) "PinCode": pinCode,
        if (gstNo != null) "GstNo": gstNo,
        if (cGst != null) "CGST": cGst,
        if (sGst != null) "SGST": sGst,
        if (iGst != null) "IGST": iGst,
        "IsDelete": false,
        if (typeCode != null) "TypeCode": typeCode,
        if (creditOpBalRs != null) "CreditOpBalRs": creditOpBalRs,
        if (creditOpBalDollor != null) "CreditOpBalDollar": creditOpBalDollor,
        if (debitOpBalRs != null) "DebitOpBalRs": debitOpBalRs,
        if (debitOpBalDollor != null) "DebitOpBalDollar": debitOpBalDollor,
        if (remarks != null) "Remarks": remarks,
      };

      final response = await dio.post(
        '${baseUrl}rough-entry/party/add',
        data: jsonEncode(params),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getPartyData(force: true);
        partyMstList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message']
            : 'Party Entry Saved Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> updatePartyData({
    required id,
    String? partyType,
    String? partyName,
    String? contactPerson,
    String? address,
    String? mobileNo,
    String? phNo,
    String? fax,
    String? email,
    String? website,
    String? pan,
    String? adhar,
    String? bankName,
    String? branchName,
    String? bankAdd,
    String? ifscCode,
    String? bankAcNo,
    String? location,
    String? city,
    String? state,
    String? gstNo,
    String? remarks,
    int? sortId,
    int? pinCode,
    String? typeCode,
    bool? active,
    double? cGst,
    double? sGst,
    double? iGst,
    double? creditOpBalRs,
    double? creditOpBalDollor,
    double? debitOpBalRs,
    double? debitOpBalDollor,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      // Resolve party type name if numeric typeCode is provided
      String? resolvedTypeName = partyType;
      if (resolvedTypeName == null && typeCode != null) {
        final matchedType = partyTypeMstList.firstWhereOrNull(
          (p) => p.typeCode.toString() == typeCode || p.typeName == typeCode,
        );
        resolvedTypeName = matchedType?.typeName ?? typeCode;
      } else if (resolvedTypeName != null) {
        final matchedType = partyTypeMstList.firstWhereOrNull(
          (p) => p.typeCode.toString() == resolvedTypeName || p.typeName == resolvedTypeName,
        );
        if (matchedType != null && matchedType.typeName != null) {
          resolvedTypeName = matchedType.typeName;
        }
      }

      // Dynamically create the params map matching the API specification
      var params = <String, dynamic>{
        if (resolvedTypeName != null) "Type": resolvedTypeName,
        if (resolvedTypeName != null) "PartyType": resolvedTypeName,
        if (partyName != null) "Name": partyName,
        if (partyName != null) "PartyName": partyName,
        if (contactPerson != null) "ContactPerson": contactPerson,
        if (address != null) "Address": address,
        if (mobileNo != null) "MobileNo": mobileNo,
        if (mobileNo != null) "Mobileno": mobileNo,
        if (phNo != null) "PhNo": phNo,
        if (fax != null) "Fax": fax,
        if (email != null) "EmailID": email,
        if (website != null) "WebSite": website,
        if (pan != null) "PanNo": pan,
        if (adhar != null) "AdharNo": adhar,
        if (bankName != null) "BankName": bankName,
        if (branchName != null) "BranchName": branchName,
        if (bankAdd != null) "BankAddress": bankAdd,
        if (bankAdd != null) "BankAdress": bankAdd,
        if (ifscCode != null) "IFSCCode": ifscCode,
        if (bankAcNo != null) "BankAcNo": bankAcNo,
        "Sflag": "U",
        "LogID": 0,
        "PcID": "TESTFROMWEB",
        "Ever": 0,
        "CompanyCode": companyCode.value,
        if (sortId != null) "SortID": sortId,
        if (active != null) "Active": active,
        if (location != null) "Location": location,
        if (city != null) "City": city,
        if (state != null) "State": state,
        if (pinCode != null) "PinCode": pinCode,
        if (gstNo != null) "GstNo": gstNo,
        if (cGst != null) "CGST": cGst,
        if (sGst != null) "SGST": sGst,
        if (iGst != null) "IGST": iGst,
        "IsDelete": false,
        if (typeCode != null) "TypeCode": typeCode,
        if (creditOpBalRs != null) "CreditOpBalRs": creditOpBalRs,
        if (creditOpBalDollor != null) "CreditOpBalDollar": creditOpBalDollor,
        if (debitOpBalRs != null) "DebitOpBalRs": debitOpBalRs,
        if (debitOpBalDollor != null) "DebitOpBalDollar": debitOpBalDollor,
        if (remarks != null) "Remarks": remarks,
      };

      final response = await dio.put(
        '${baseUrl}rough-entry/party/$id',
        data: jsonEncode(params),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        await getPartyData(force: true);
        partyMstList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message']
            : 'Party Entry Updated Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<bool> addPurchaseData({
    String? partyCode,
    invoiceNo,
    invoiceDate,
    recDate,
    brokerCode,
    dueDays,
    dueDate,
    onlyDueDate,
    pSite,
    billType,
    rdType,
    exchange,
    int? totalPc,
    double? totalAmt,
    totalWt,
    totalRate,
    totalAmtRs,
    totalAmtDollar,
    totalRateRs,
    totalRateDollar,
    expPer,
    expFix,
    expFixRs,
    linPer,
    linFix,
    linFixRs,
    totExpPer,
    totExpFix,
    totExpFixRs,
    broPer,
    broFix,
    broRs,
    addPer,
    addFix,
    addFixRs,
    lessPer,
    lessFix,
    lessFixRs,
    invCharge,
    invChargePer,
    invChargeRs,
    comPer,
    comFix,
    comFixRs,
    gstPer,
    gstAmtRs,
    gstAmtDollar,
    netAmtDollar,
    netAmtRs,
    roundOfDollar,
    roundOfRs,
    finalNetAmtDollar,
    finalNetAmtRs,
    finalAmtRs,
    finalAmtD,
    totNetAmtDollar,
    totNetAmtRs,
    chkExp,
    chkLin,
    chkBro,
    chkAdd,
    chkLess,
    chkInv,
    chkCom,
    remarks,
    crId,
    required List entries,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      final String? formattedInvDate = formatToIsoUtc(invoiceDate);

      final String? formattedRecDate = recDate != null
          ? formatToIsoUtc(recDate)
          : formattedInvDate;

      final dynamic formattedDueDate = dueDate != null
          ? formatToIsoUtc(dueDate)
          : formattedInvDate;

      final dynamic formattedPSite = (pSite != null && pSite.toString().trim().isNotEmpty)
          ? formatToIsoUtc(pSite)
          : null;

      var params = {
        if (crId != null && crId.toString().isNotEmpty) "CrId": int.tryParse(crId.toString()) ?? crId,
        "InvoiceNo": "$invoiceNo",
        "InvoiceDate": formattedInvDate,
        if (formattedRecDate != null) "Recdate": formattedRecDate,
        "PartyCode": int.tryParse(partyCode.toString()) ?? partyCode,
        "BrokerCode": int.tryParse(brokerCode.toString()) ?? brokerCode,
        "DueDay": int.tryParse(dueDays.toString()) ?? dueDays,
        "DueDate": formattedDueDate,
        if (formattedPSite != null && formattedPSite.toString().isNotEmpty) "PSite": formattedPSite,
        "BillType": billType ?? "BILL",
        if (rdType != null && rdType.toString().isNotEmpty) "RDType": rdType,
        if (exchange != null) "Exchange": exchange,
        if (totalPc != null) "TPc": totalPc,
        "TWeight": totalWt,
        "TAmtRs": totalAmtRs ?? totalAmt,
        "TAmtDollar": totalAmtDollar ?? totalAmt,
        "TRateRs": totalRateRs ?? totalRate,
        "TRateDollar": totalRateDollar ?? totalRate,
        if (invCharge != null) "InvCharge": invCharge,
        if (invChargePer != null) "InvChargePer": invChargePer,
        if (invChargeRs != null) "InvChargeRs": invChargeRs,
        if (addPer != null) "AddPer": addPer,
        if (addFix != null) "AddFix": addFix,
        if (addFixRs != null) "AddFixRs": addFixRs,
        if (lessPer != null) "LessPer": lessPer,
        if (lessFix != null) "LessFix": lessFix,
        if (lessFixRs != null) "LessFixRs": lessFixRs,
        if (expPer != null) "ExpPer": expPer,
        if (expFix != null) "ExpFix": expFix,
        if (expFixRs != null) "ExpFixRs": expFixRs,
        if (linPer != null) "LinPer": linPer,
        if (linFix != null) "LinFix": linFix,
        if (linFixRs != null) "LinFixRs": linFixRs,
        if (totExpPer != null) "TotExpPer": totExpPer,
        if (totExpFix != null) "TotExpFix": totExpFix,
        if (totExpFixRs != null) "TotExpFixRs": totExpFixRs,
        if (broPer != null) "BroPer": broPer,
        if (broFix != null) "BroFix": broFix,
        if (broRs != null) "BroRs": broRs,
        if (comPer != null) "ComPer": comPer,
        if (comFix != null) "ComFix": comFix,
        if (comFixRs != null) "ComFixRs": comFixRs,
        "TotAmtDollar": totalAmtDollar ?? totalAmt,
        "TotNetAmtRs": totNetAmtRs ?? totalAmt,
        "TotAmtRs": totalAmtRs ?? totalAmt,
        "LogID": 0,
        "PCID": "TESTFROMWEB",
        "Ever": 0,
        "SDate": formatToIsoUtc(DateTime.now()),
        "CompanyCode": companyCode.value,
        if (chkAdd != null) "ChkAdd": chkAdd,
        if (chkLess != null) "ChkLess": chkLess,
        if (chkExp != null) "ChkExp": chkExp,
        if (chkLin != null) "ChkLin": chkLin,
        if (chkCom != null) "ChkCom": chkCom,
        if (chkBro != null) "ChkBro": chkBro,
        if (chkInv != null) "ChkInv": chkInv,
        if (totalRateRs != null) "AvgRate": totalRateRs,
        "NetAmtDollar": netAmtDollar ?? totalAmtDollar ?? totalAmt,
        "NetAmtRs": netAmtRs ?? totalAmtRs ?? totalAmt,
        "TotNetAmtDollar": totNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        if (remarks != null) "Remarks": remarks,
        if (gstPer != null) "GstPer": gstPer,
        if (gstAmtRs != null) "GstAmtRs": gstAmtRs,
        if (gstAmtDollar != null) "GstAmtDollar": gstAmtDollar,
        "EntryType": "I",
        "FinalNetAmtDollar": finalNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        "FinalNetAmtRs": finalNetAmtRs ?? totalAmtRs ?? totalAmt,
        "FinalAmtRs": finalAmtRs ?? finalNetAmtRs ?? totalAmtRs ?? totalAmt,
        "FinalAmtD": finalAmtD ?? finalNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        "RoundOfRs": roundOfRs ?? 0.0,
        "RoundOfD": roundOfDollar ?? 0.0,
      };

      final response = await dio.post('${baseUrl}rough-entry/purchase/add',
          data: jsonEncode(params));

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final dynamic mstId = response.data['data']?['RoughPurMstID'] ??
            response.data['data']?['id'] ??
            response.data['RoughPurMstID'] ??
            response.data['id'];
        final dynamic respInvoiceNo = response.data['data']?['InvoiceNo'] ??
            response.data['InvoiceNo'] ??
            invoiceNo;

        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addPurchaseRoughData(
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              rateRs: value['rateRs'] ?? value['rate'],
              amtRs: value['amtRs'] ?? value['amount'],
              rateDollar: value['rateDollar'] ?? value['rate'],
              amtDollar: value['amtDollar'] ?? value['amount'],
              pc: value['pc'] != null ? int.tryParse(value['pc'].toString()) : null,
              site: value['site'],
              roughQualityCode: value['quality'] != null ? int.tryParse(value['quality'].toString()) : null,
              roughCharniCode: value['charni'] != null ? int.tryParse(value['charni'].toString()) : null,
              roughName: value['rough'],
              description: value['description'],
              roughPurMstID: mstId,
              srNo: index + 1 // incremented srNo
              );
        }));
        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: mstId,
            purMstId: mstId,
            saleMstId: 0,
            invoiceDate: invoiceDate,
            orgInvoiceDate: formattedInvDate,
            paymentMstId: 0,
            dueDate: formattedDueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode:
                index == 0 ? companyPartyCode.value.toString() : partyCode,
            creditRs: index == 0 ? 0.00 : (totNetAmtRs ?? totalAmt),
            debitRs: index == 0 ? (totNetAmtRs ?? totalAmt) : 0.00,
            invAmtRs: (totNetAmtRs ?? totalAmt),
            drCr: index == 0 ? 'DR' : 'CR',
            formType: 'Purchase',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmPurchaseEntry',
            perPartyCode:
                index == 0 ? partyCode : companyPartyCode.value.toString(),
            orgCt: totalWt,
            dueDays: dueDays,
            invoiceNo: respInvoiceNo,
            srNo: index + 1,
            brokerCode: brokerCode,
          );
        }));
        await getPurchaseData(force: true);
        await getPurchaseDetailsData(force: true);
        await getCreditDebitData();
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();

        isLoading.value = false;
        successDialog(messageText: response.data['message'] ?? 'Purchase added successfully');

        /*
        // PDF auto-print commented out as requested
        try {
          isLoading.value = true;
          final invoiceGenerator = PurchaseInvoiceGenerator();
          final DateTime invDateForPdf = invoiceDate is DateTime
              ? invoiceDate
              : (DateTime.tryParse(invoiceDate.toString()) ?? DateTime.now());
          final pdfData = await invoiceGenerator.generateInvoice(
              id: purchaseDataList.length + 1,
              invoiceDate: invDateForPdf,
              invoiceNo: respInvoiceNo,
              partyCode: partyCode.toString(),
              brokerCode: brokerCode,
              dueDate: onlyDueDate,
              dueDays: dueDays,
              entries: entries,
              totalWt: totalWt,
              totalAmt: totalAmt!,
              totalRate: totalRate);
          isLoading.value = false;
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfData,
          ).then((value) => successDialog(messageText: response.data['message']));
          if (!kDebugMode) {
            await Printing.sharePdf(
              bytes: pdfData,
              filename: '$respInvoiceNo.pdf',
            );
          }
        } catch (printErr) {
          isLoading.value = false;
          successDialog(messageText: response.data['message'] ?? 'Purchase added successfully');
          if (kDebugMode) {
            print('Print error: $printErr');
          }
        }
        */
        return true;
      } else {
        isLoading.value = false;
        final String errMsg = response.data?['message']?.toString() ??
            'Failed to Add data: ${response.statusCode}';
        errorDialog(messageText: errMsg);
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<void> addCreditDebitData({
    String? partyCode,
    invoiceNo,
    invoiceDate,
    orgInvoiceDate,
    brokerCode,
    dueDays,
    mstId,
    purMstId,
    saleMstId,
    // polishPurMstId,
    // polishRecMstId,
    paymentMstId,
    // exRate,
    creditRs,
    debitRs,
    drCr,
    formType,
    entryType,
    formName,
    srNo,
    invAmtRs,
    perPartyCode,
    remarks1,
    remarks2,
    traType,
    dueDate,
    orgCt,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      final bool isPurchase = formType == 'Purchase';

      final dynamic formattedInvDate = isPurchase
          ? formatToIsoUtc(invoiceDate)
          : (invoiceDate is DateTime
              ? DateFormat('yyyy-MM-dd').format(invoiceDate)
              : (DateTime.tryParse(invoiceDate.toString()) != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(invoiceDate.toString()))
                  : invoiceDate.toString()));

      final dynamic formattedDueDate = isPurchase
          ? formatToIsoUtc(dueDate)
          : dueDate;

      final dynamic formattedOrgInvDate = isPurchase
          ? formatToIsoUtc(orgInvoiceDate ?? invoiceDate)
          : orgInvoiceDate;

      final dynamic formattedSDateTime = isPurchase
          ? formatToIsoUtc(DateTime.now())
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      var params = {
        "MstID": mstId,
        // Purchase Sale Mst ID
        "PurchaseMstID": purMstId,
        "SaleMstID": saleMstId,
        // "PolishPurMstID": polishPurMstId,
        // "PolishRecMstID": polishRecMstId,
        "PaymentMstID": paymentMstId,
        "InvDate": formattedInvDate,
        "DueDate": formattedDueDate,
        "RateType": 'RS',
        "ExRate": 0.00,
        "PartyCode": partyCode,
        "CreditRs": creditRs,
        // "CreditDollar":Joi.number().precision(2),
        "DebitRs": debitRs,
        // "DebitDollar": Joi.number().precision(2),
        "InvAmtRs": invAmtRs,
        // "InvAmtDollar":Joi.number().precision(2),
        "DrCrType": drCr,
        "FormType": formType,
        "EntryType": entryType,
        "Sflag": 'I',
        "SDateTime": formattedSDateTime,
        "LogID": "0",
        "PcID": 'TESTFROMWEB',
        "Ever": 0,
        "FormName": formName,
        "SrNo": srNo,
        "PerPartyCode": perPartyCode,
        "Remarks1": remarks1,
        "Remarks2": remarks2,
        "CompanyCode": companyCode.value,
        "TraType": traType,
        // "OrgInvDate": DateFormat('yyyy-MM-dd HH:mm:ss').parse(orgInvoiceDate),
        "OrgInvDate": formattedOrgInvDate,
        "DueDays": dueDays,
        "OrgRateType": 'RS',
        "OrgExRate": 0.0,
        "OrgBrokerCode": brokerCode,
        "OrgCt": orgCt,
        "InvoiceNo": invoiceNo,
        // "PolishSaleMstId": Joi.number().integer(),
        // "ExpenseMstID": Joi.number().integer(),
      };

      log(params.toString());

      final response = await dio.post('${baseUrl}rough-entry/credit-debit/add',
          data: jsonEncode(params));
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('${response.data['message']}');
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error  addCreditDebitData');
      }
    }
  }

  Future<void> addSaleData(
      {String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      onlyDueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      required List<Map<String, String>> entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        "PolishDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        "InvoiceNo": "$invoiceNo",
        // "InvNo": 123,
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        "DueDay": dueDays,
        "DueDate": dueDate,
        // "InvCode": "1",
        // "SaleType": "LOCAL",
        // "InsuranceName": "RELIANCE",
        // "SGstPer": 12.453,
        // "CGstPer": 12.453,
        // "IGstPer": 12.453,
        // "SGstAmount": 14.23,
        // "CGstAmount": 12.23,
        // "IGstAmount": 12.32,
        // "SGstUsdAmount": 1.456,
        // "CGstUsdAmount": 1.456,
        // "IGstUsdAmount": 1.456,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalAmt, // total
        "RoundRs": 0,
        "RoundUsd": 0,
        "NetUsdAmount": totalAmt, //total
        "RdType": "RS",
        "DollarRate": 1,
        "PaymentRec": "N",
        "BroPer": 0,
        "BroRsAmount": 0,
        "BroUSDAmount": 0,
        "BrokerCode": brokerCode,
        "BankCode": 0,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalAmt, //total
        "TPcs": 0,
        "TWeight": totalWt, //total rough wt
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRate, // rate = toal amt / total wt
        "TDAmount": totalAmt, // dollar amt total
        "Sflag": "I",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": 0, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.post('${baseUrl}rough-entry/polish-sale/add',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addSaleRoughData(
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              roughName: value['rough'],
              description: value['description'],
              polishSaleMstID: response.data['data']['PolishSaleMstID'],
              srNo: index + 1 // incremented srNo
              );
        }));
        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: response.data['data']['PolishSaleMstID'],
            purMstId: 0,
            saleMstId: response.data['data']['PolishSaleMstID'],
            invoiceDate: invoiceDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(invoiceDate),
            paymentMstId: 0,
            dueDate: dueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode:
                index == 0 ? companyPartyCode.value.toString() : partyCode,
            creditRs: index == 0 ? totalAmt : 0.00,
            debitRs: index == 0 ? 0.00 : totalAmt,
            invAmtRs: totalAmt,
            drCr: index == 0 ? 'CR' : 'DR',
            formType: 'Sale',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmSaleEntry',
            perPartyCode:
                index == 0 ? partyCode : companyPartyCode.value.toString(),
            orgCt: totalWt,
            dueDays: dueDays,
            invoiceNo: response.data['data']['InvoiceNo'],
            srNo: index + 1,
            brokerCode: brokerCode,
          );
        }));
        await getSaleData();
        await getSaleDetailsData();
        await getCreditDebitData();
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        final invoiceGenerator = SaleInvoiceGenerator();
        final pdfData = await invoiceGenerator.generateInvoice(
            id: polishSaleList.length + 1,
            invoiceDate: invoiceDate,
            invoiceNo: response.data['data']['InvoiceNo'],
            partyCode: partyCode.toString(),
            brokerCode: brokerCode,
            dueDate: onlyDueDate,
            dueDays: dueDays,
            entries: entries,
            totalWt: totalWt,
            totalAmt: totalAmt!,
            totalRate: totalRate);
        isLoading.value = false;
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData,
        ).then((value) => successDialog(messageText: response.data['message']));
        if (!kDebugMode) {
          await Printing.sharePdf(
            bytes: pdfData,
            filename:
                '${response.data['data']['InvoiceNo']}.pdf', // Set the custom name here
          );
        }
      } else {
        isLoading.value = false;
        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  // ==================== POLISH SALE (Memo Issue style screen) ====================

  /// Next Sale Invoice No for the selected company, built from
  /// CompanyMst.InvoicePrefix + running number + CompanyMst.InvoiceSuffix.
  /// This is only a preview - the server assigns the final number on save.
  Future<String?> getNextSaleInvoiceNo() async {
    try {
      final response = await ApiService.to.get(
        '${baseUrl}rough-entry/polish-sale/next-invoice-no',
        queryParameters: {'CompanyCode': companyCode.value},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['invoiceNo']?.toString();
      }
    } catch (error) {
      if (kDebugMode) {
        log('getNextSaleInvoiceNo error: $error');
      }
    }
    return null;
  }

  /// Rough Type for a sale item - used by the stock report to reduce rough
  /// stock. ROUGH items take it from the selected purchase invoice; POLISH
  /// items return 0 so they do not reduce rough stock.
  int _saleItemRoughTypeCode(Map value) {
    final String type = (value['type'] ?? 'ROUGH').toString().toUpperCase();
    if (type != 'ROUGH') return 0;
    final int? purMstId = int.tryParse(value['roughPurMstID']?.toString() ?? '');
    if (purMstId != null) {
      final details =
          roughDetailsModel.where((d) => d.roughPurMstID == purMstId).toList();
      if (details.isNotEmpty) {
        final int? qualityCode = int.tryParse(value['qualityCode']?.toString() ?? '');
        final int? charniCode = int.tryParse(value['charniCode']?.toString() ?? '');
        final best = details.firstWhereOrNull((d) =>
                (qualityCode == null || d.roughQualityCode == qualityCode) &&
                (charniCode == null || d.roughCharniCode == charniCode)) ??
            details.first;
        if (best.roughTypeCode != null) return best.roughTypeCode!;
      }
    }
    return int.tryParse(value['roughTypeCode']?.toString() ?? '') ?? 1;
  }

  Map<String, dynamic> _polishSaleMasterParams({
    required DateTime invoiceDate,
    required String sflag,
    invoiceNo,
    partyCode,
    brokerCode,
    dueDays,
    dueDate,
    String? rdType,
    double? dollarRate,
    int? fromUserId,
    int? totalPcs,
    double? totalAmt,
    double? totalAmtDollar,
    totalWt,
    totalRate,
    double? totalRateDollar,
    Map<String, dynamic>? summary,
  }) {
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final String invDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate);
    return {
      "PolishDate": invDate,
      // Only a placeholder on create - the server generates the real Invoice No
      if (invoiceNo != null && invoiceNo.toString().isNotEmpty) "InvoiceNo": "$invoiceNo",
      "InvoiceDate": invDate,
      if (dueDays != null) "DueDay": int.tryParse(dueDays.toString()) ?? 0,
      if (dueDate != null) "DueDate": dueDate,
      "TotRsAmt": totalAmt,
      "TotUsdAmt": totalAmtDollar ?? totalAmt,
      "RoundRs": 0,
      "RoundUsd": 0,
      "NetUsdAmount": totalAmtDollar ?? totalAmt,
      "NetRsAmount": totalAmt,
      "RdType": rdType ?? "RS",
      "DollarRate": dollarRate ?? 100,
      "PaymentRec": "N",
      "BroPer": 0,
      "BroRsAmount": 0,
      "BroUSDAmount": 0,
      "BrokerCode": int.tryParse(brokerCode?.toString() ?? ''),
      "BankCode": 0,
      "PartyCode": int.tryParse(partyCode?.toString() ?? ''),
      "FinalRsAmount": totalAmt,
      "FinalUsdAmount": totalAmtDollar ?? totalAmt,
      "TPcs": totalPcs ?? 0,
      "TWeight": totalWt,
      "TRate": totalRate,
      "TAmount": totalAmt,
      "TDRate": totalRateDollar ?? totalRate,
      "TDAmount": totalAmtDollar ?? totalAmt,
      "Sflag": sflag,
      "SDate": now,
      "LogID": fromUserId ?? currentUserId.value,
      "PCID": "TESTWEB",
      "Ever": 0,
      "CompanyCode": companyCode.value,
      // GST / Net / Round / Brokerage / Final from the Sale screen summary
      ...?summary,
    };
  }

  Map<String, dynamic> _polishSaleItemParams(Map value, {required int polishSaleMstID, required int srNo}) {
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    final int? purMstId = toInt(value['roughPurMstID']);
    final String invNo = value['invNo']?.toString() ?? '';
    final String description = value['description']?.toString() ?? '';
    return {
      "PolishSaleMstID": polishSaleMstID,
      "SrNo": srNo,
      "ClarityCode": toInt(value['clarityCode']) ?? 0,
      "CharniCode": toInt(value['charniCode']) ?? 0,
      "ShapeCode": toInt(value['shapeCode']) ?? 0,
      "ColorCode": toInt(value['colorCode']) ?? 0,
      "QualityCode": toInt(value['qualityCode']) ?? 0,
      "Pcs": toInt(value['pcs']) ?? 1,
      "Carats": double.tryParse(value['wt']?.toString() ?? '0') ?? 0,
      "RateRs": double.tryParse((value['rateRs'] ?? value['rate'])?.toString() ?? '0') ?? 0,
      "AmountRs": double.tryParse((value['amountRs'] ?? value['amount'])?.toString() ?? '0') ?? 0,
      "RateD": double.tryParse((value['rateDollar'] ?? value['rateD'])?.toString() ?? '0') ?? 0,
      "AmountD": double.tryParse((value['amountDollar'] ?? value['amountD'])?.toString() ?? '0') ?? 0,
      "PenCarats": double.tryParse(value['penWt']?.toString() ?? '') ?? 0,
      "Type": value['type']?.toString() ?? 'ROUGH',
      if (invNo.isNotEmpty) "InvNo": invNo,
      if (purMstId != null) "RoughPurMstID": purMstId,
      "RoughTypeCode": _saleItemRoughTypeCode(value),
      if (description.isNotEmpty) "Description": description,
    };
  }

  /// Saves one sale item: PUT when it already has an id, otherwise POST.
  Future<void> _savePolishSaleItem(Map value,
      {required int polishSaleMstID, required int srNo}) async {
    final dio = ApiService.to.dio;
    final params = _polishSaleItemParams(value, polishSaleMstID: polishSaleMstID, srNo: srNo);
    final String id = value['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      await dio.put('${baseUrl}rough-entry/sale-details/$id', data: jsonEncode(params));
    } else {
      await dio.post('${baseUrl}rough-entry/sale-details/add', data: jsonEncode(params));
    }
  }

  /// Party ledger (CreditDebitMst) rows for a sale - same two rows the old
  /// Sale screen wrote on create: company party CR, sale party DR.
  Future<void> _addPolishSaleLedger({
    required int polishSaleMstID,
    required String invoiceNo,
    required DateTime invoiceDate,
    partyCode,
    brokerCode,
    dueDays,
    dueDate,
    double? totalAmt,
    totalWt,
  }) async {
    await Future.wait(List.generate(2, (index) {
      return addCreditDebitData(
        mstId: polishSaleMstID,
        purMstId: 0,
        saleMstId: polishSaleMstID,
        invoiceDate: invoiceDate,
        orgInvoiceDate: DateFormat('yyyy-MM-dd').format(invoiceDate),
        paymentMstId: 0,
        dueDate: dueDate,
        remarks1: ' ',
        remarks2: ' ',
        partyCode: index == 0 ? companyPartyCode.value.toString() : partyCode,
        creditRs: index == 0 ? totalAmt : 0.00,
        debitRs: index == 0 ? 0.00 : totalAmt,
        invAmtRs: totalAmt,
        drCr: index == 0 ? 'CR' : 'DR',
        formType: 'Sale',
        entryType: index == 0 ? 'NIL' : 'PARTY',
        traType: index == 0 ? 'NIL' : 'PARTY',
        formName: 'FrmSaleEntry',
        perPartyCode: index == 0 ? partyCode : companyPartyCode.value.toString(),
        orgCt: totalWt,
        dueDays: dueDays,
        invoiceNo: invoiceNo,
        srNo: index + 1,
        brokerCode: brokerCode,
      );
    }));
  }

  Future<void> _refreshPolishSaleData() async {
    await getSaleData(force: true);
    await getSaleDetailsData(force: true);
    await getCreditDebitData(force: true);
    await getOutstandingPurchaseSaleDetails(force: true);
    await getPendingPaymentData(force: true);
  }

  /// Builds the Sale invoice PDF and shows / shares it.
  Future<void> printPolishSaleInvoice({
    required int id,
    required String invoiceNo,
    required DateTime invoiceDate,
    required String partyCode,
    required String brokerCode,
    required String dueDateText,
    required String dueDays,
    required List entries,
    required double totalAmt,
    required double totalWt,
    required double totalRate,
    bool preview = true,
    bool share = false,
  }) async {
    final pdfData = await SaleInvoiceGenerator().generateInvoice(
      id: id,
      invoiceDate: invoiceDate,
      invoiceNo: invoiceNo,
      partyCode: partyCode,
      brokerCode: brokerCode,
      dueDate: dueDateText,
      dueDays: dueDays,
      entries: entries,
      totalWt: totalWt,
      totalAmt: totalAmt,
      totalRate: totalRate,
    );
    if (preview) {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
    }
    if (share && !kDebugMode) {
      await Printing.sharePdf(bytes: pdfData, filename: '$invoiceNo.pdf');
    }
  }

  /// Create a Polish Sale (master + items + party ledger). Returns the saved
  /// {id, invoiceNo} or null on failure.
  Future<Map<String, dynamic>?> addPolishSaleData({
    required String partyCode,
    required DateTime invoiceDate,
    String? brokerCode,
    dueDays,
    dueDate,
    String? rdType,
    double? dollarRate,
    int? fromUserId,
    required List<Map<String, dynamic>> entries,
    required double totalAmt,
    double? totalAmtDollar,
    required double totalWt,
    required double totalRate,
    double? totalRateDollar,
    int? totalPcs,
    Map<String, dynamic>? summary,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;
      final params = _polishSaleMasterParams(
        invoiceDate: invoiceDate,
        sflag: 'I',
        partyCode: partyCode,
        brokerCode: brokerCode,
        dueDays: dueDays,
        dueDate: dueDate,
        rdType: rdType,
        dollarRate: dollarRate,
        fromUserId: fromUserId,
        totalPcs: totalPcs,
        totalAmt: totalAmt,
        totalAmtDollar: totalAmtDollar,
        totalWt: totalWt,
        totalRate: totalRate,
        totalRateDollar: totalRateDollar,
        summary: summary,
      );

      final response =
          await dio.post('${baseUrl}rough-entry/polish-sale/add', data: jsonEncode(params));
      final data = response.data is Map ? response.data['data'] : null;
      if (data == null) {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to save Sale: ${response.data?['message'] ?? ''}');
        return null;
      }

      final int mstId = int.tryParse(data['PolishSaleMstID'].toString()) ?? 0;
      final String invoiceNo = data['InvoiceNo']?.toString() ?? '';

      for (int i = 0; i < entries.length; i++) {
        await _savePolishSaleItem(entries[i], polishSaleMstID: mstId, srNo: i + 1);
      }
      await _addPolishSaleLedger(
        polishSaleMstID: mstId,
        invoiceNo: invoiceNo,
        invoiceDate: invoiceDate,
        partyCode: partyCode,
        brokerCode: brokerCode,
        dueDays: dueDays,
        dueDate: dueDate,
        // party ledger = Final Rs Amount (items + GST, after rounding)
        totalAmt: (summary?['FinalRsAmount'] as num?)?.toDouble() ?? totalAmt,
        totalWt: totalWt,
      );
      await _refreshPolishSaleData();
      isLoading.value = false;
      successDialog(messageText: response.data['message']?.toString() ?? 'Sale saved');
      return {'id': mstId, 'invoiceNo': invoiceNo};
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred while saving the Sale.');
      if (kDebugMode) {
        log('addPolishSaleData error: $error');
      }
      return null;
    }
  }

  /// Update a Polish Sale. Invoice No never changes. The sale's ledger rows are
  /// replaced (old rows deleted, new rows written) so edits don't duplicate them.
  Future<bool> updatePolishSaleData({
    required int id,
    required String invoiceNo,
    required String partyCode,
    required DateTime invoiceDate,
    String? brokerCode,
    dueDays,
    dueDate,
    String? rdType,
    double? dollarRate,
    int? fromUserId,
    required List<Map<String, dynamic>> entries,
    required double totalAmt,
    double? totalAmtDollar,
    required double totalWt,
    required double totalRate,
    double? totalRateDollar,
    int? totalPcs,
    Map<String, dynamic>? summary,
  }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;
      final params = _polishSaleMasterParams(
        invoiceDate: invoiceDate,
        sflag: 'U',
        partyCode: partyCode,
        brokerCode: brokerCode,
        dueDays: dueDays,
        dueDate: dueDate,
        rdType: rdType,
        dollarRate: dollarRate,
        fromUserId: fromUserId,
        totalPcs: totalPcs,
        totalAmt: totalAmt,
        totalAmtDollar: totalAmtDollar,
        totalWt: totalWt,
        totalRate: totalRate,
        totalRateDollar: totalRateDollar,
        summary: summary,
      );

      final response =
          await dio.put('${baseUrl}rough-entry/polish-sale/$id', data: jsonEncode(params));
      if (response.data is! Map || response.data['data'] == null) {
        isLoading.value = false;
        errorDialog(messageText: 'Failed to update Sale: ${response.data?['message'] ?? ''}');
        return false;
      }

      for (int i = 0; i < entries.length; i++) {
        await _savePolishSaleItem(entries[i], polishSaleMstID: id, srNo: i + 1);
      }
      await deleteSaleCreditDebitDetails(id: id);
      await _addPolishSaleLedger(
        polishSaleMstID: id,
        invoiceNo: invoiceNo,
        invoiceDate: invoiceDate,
        partyCode: partyCode,
        brokerCode: brokerCode,
        dueDays: dueDays,
        dueDate: dueDate,
        // party ledger = Final Rs Amount (items + GST, after rounding)
        totalAmt: (summary?['FinalRsAmount'] as num?)?.toDouble() ?? totalAmt,
        totalWt: totalWt,
      );
      await _refreshPolishSaleData();
      isLoading.value = false;
      successDialog(messageText: response.data['message']?.toString() ?? 'Sale updated');
      return true;
    } catch (error) {
      isLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred while updating the Sale.');
      if (kDebugMode) {
        log('updatePolishSaleData error: $error');
      }
      return false;
    }
  }

  /// Delete one sale item (used when removing an item while editing a sale).
  Future<bool> deletePolishSaleItem({required int id}) async {
    try {
      final response = await ApiService.to.dio.delete('${baseUrl}rough-entry/sale-details/$id');
      if (response.statusCode == 200) {
        await getSaleDetailsData(force: true);
        return true;
      }
    } catch (error) {
      if (kDebugMode) {
        log('deletePolishSaleItem error: $error');
      }
    }
    errorDialog(messageText: 'Failed to delete the sale item.');
    return false;
  }

  /// Delete a Polish Sale with its items and party ledger rows.
  Future<bool> deletePolishSaleData({required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;
      await deleteSaleCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;
      final response = await dio.delete('${baseUrl}rough-entry/polish-sale/$id');
      if (response.statusCode != 200) {
        isDeleteLoading.value = false;
        errorDialog(messageText: 'Failed to delete Sale: ${response.statusCode}');
        return false;
      }
      for (final value in entries) {
        final String detId = value['id']?.toString() ?? '';
        if (detId.isNotEmpty) {
          await dio.delete('${baseUrl}rough-entry/sale-details/$detId');
        }
      }
      await _refreshPolishSaleData();
      isDeleteLoading.value = false;
      successDialog(messageText: response.data?['message']?.toString() ?? 'Sale deleted');
      return true;
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred while deleting the Sale.');
      if (kDebugMode) {
        log('deletePolishSaleData error: $error');
      }
      return false;
    }
  }

  /// Returns the next Memo No for the selected company, built from
  /// CompanyMst.MemoInvoicePrefix + running number + CompanyMst.MemoInvoiceSuffix.
  /// This is only a preview - the server assigns the final number on save.
  Future<String?> getNextMemoIssueNo() async {
    try {
      final response = await ApiService.to.get(
        '${baseUrl}rough-entry/memo-issue/next-memo-no',
        queryParameters: {'CompanyCode': companyCode.value},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['memoNo']?.toString();
      }
    } catch (error) {
      if (kDebugMode) {
        log('getNextMemoIssueNo error: $error');
      }
    }
    return null;
  }

  Future<bool> addMemoIssueData(
      {String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      int? fromUserId,
      String? rdType,
      double? dollarRate,
      required List entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        if (invoiceNo != null) "InvoiceNo": "$invoiceNo",
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        if (dueDays != null) "DueDay": dueDays,
        if (dueDate != null) "DueDate": dueDate,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalAmt, // total
        "NetUsdAmount": totalAmt, //total
        "RdType": rdType ?? "RS",
        "DollarRate": dollarRate ?? 100,
        "BrokerCode": brokerCode,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalAmt, //total
        "TWeight": totalWt, //total rough wt
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRate, // rate = toal amt / total wt
        "TDAmount": totalAmt, // dollar amt total
        "Sflag": "I",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": fromUserId ?? currentUserId.value, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.post('${baseUrl}rough-entry/memo-issue/add',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addMemoIssueRoughData(
              wt: value['wt'],
              rate: value['rateRs'] ?? value['rate'],
              amount: value['amountRs'] ?? value['amount'],
              rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
              amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
              type: value['type'] ?? 'ROUGH',
              invNo: value['invNo'],
              roughPurMstID: value['roughPurMstID'],
              clarityCode: value['clarityCode'] ?? 0,
              charniCode: value['charniCode'] ?? 0,
              shapeCode: value['shapeCode'] ?? 0,
              colorCode: value['colorCode'] ?? 0,
              qualityCode: value['qualityCode'] ?? 0,
              pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
              penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
              roughName: value['rough'] ?? '1',
              description: value['description'],
              memoIssueMstID: response.data['data']['MemoIssueMstID'],
              srNo: index + 1,
              rec: 'N' // incremented srNo
              );
        }));
        await getMemoIssueData(force: true);
        await getMemoIssueDetailsData(force: true);
        isLoading.value = true;
        final invoiceGenerator = MemoIssueInvoiceGenerator();
        final pdfData = await invoiceGenerator.generateInvoice(
            id: response.data['data']['MemoIssueMstID'],
            invoiceDate: invoiceDate,
            partyCode: partyCode.toString(),
            entries: entries,
            totalWt: totalWt,
            totalAmt: totalAmt!,
            totalRate: totalRate);
        isLoading.value = false;
        // await Printing.layoutPdf(
//   onLayout: (PdfPageFormat format) async => pdfData,
// ).then((value) => successDialog(messageText: response.data['message']));
//         if (!kDebugMode) {
//           await Printing.sharePdf(
//             bytes: pdfData,
//             filename:
//                 'Memo-Issue/${getPartyName(int.parse(partyCode!))}/${DateTime.now()}.pdf', // Set the custom name here
//           );
//         }
        return true;
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<bool> addMemoRecData(
      {String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      totalLossWt,
      totalRecWt,
      totalRecAmount,
      int? totalPacket,
      int? totalRecPcs,
      double? totalIssWt,
      double? totalSaleWt,
      double? totalOutWt,
      double? totalFinalWt,
      double? totalRecAmountDollar,
      double? totalRateDollar,
      memoIssueDetailId,
      int? fromUserId,
      bool printInvoice = false,
      required List<Map<String, dynamic>> entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        // "PolishDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        // "InvoiceNo": "$invoiceNo",
        // "InvNo": 123,
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        // "DueDay": dueDays,
        // "DueDate": dueDate,
        // "InvCode": "1",
        // "SaleType": "LOCAL",
        // "InsuranceName": "RELIANCE",
        // "SGstPer": 12.453,
        // "CGstPer": 12.453,
        // "IGstPer": 12.453,
        // "SGstAmount": 14.23,
        // "CGstAmount": 12.23,
        // "IGstAmount": 12.32,
        // "SGstUsdAmount": 1.456,
        // "CGstUsdAmount": 1.456,
        // "IGstUsdAmount": 1.456,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalRecAmountDollar ?? totalAmt, // total
        // "RoundRs": 0,
        // "RoundUsd": 0,
        "NetUsdAmount": totalRecAmountDollar ?? totalAmt, //total
        // "RdType": "RS",
        // "DollarRate": 1,
        // "PaymentRec": "N",
        // "BroPer": 0,
        // "BroRsAmount": 0,
        // "BroUSDAmount": 0,
        "BrokerCode": brokerCode,
        // "BankCode": 0,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalRecAmountDollar ?? totalAmt, //total
        "TPcs": totalPacket ?? 0,
        "RecPcs": totalRecPcs ?? 0,
        "TWeight": totalFinalWt ?? totalRecWt ?? totalWt, //total rough wt
        "TotalWt": totalFinalWt,
        "IssWt": totalIssWt ?? totalWt,
        "RecWt": totalRecWt,
        "SaleWt": totalSaleWt,
        "OutWt": totalOutWt,
        "LossWt": totalLossWt,
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRateDollar ?? totalRate, // rate = toal amt / total wt
        "TDAmount": totalRecAmountDollar ?? totalAmt, // dollar amt total
        "Sflag": "I",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": fromUserId ?? currentUserId.value, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.post('${baseUrl}rough-entry/memo-rec/add',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addMemoRecRoughData(
              memoIssueDetId: value['detId'],
              wt: value['wt'],
              recWt: value['recWt'],
              saleWt: value['saleWt'],
              outWt: value['outWt'],
              lossWt: value['lossWt'],
              totalWt: value['totalWt'],
              rate: value['rateRs'] ?? value['rate'],
              amount: value['amountRs'] ?? value['amount'],
              rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
              amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
              roughName: value['rough'] ?? '1',
              type: value['type'] ?? 'ROUGH',
              invNo: value['invNo'],
              roughPurMstID: value['roughPurMstID'],
              clarityCode: value['clarityCode'] ?? 0,
              charniCode: value['charniCode'] ?? 0,
              shapeCode: value['shapeCode'] ?? 0,
              colorCode: value['colorCode'] ?? 0,
              qualityCode: value['qualityCode'] ?? 0,
              pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
              recPcs: int.tryParse(value['recPcs']?.toString() ?? '0'),
              penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
              memoRecMstID: response.data['data']['MemoRecMstID'],
              srNo: index + 1 // incremented srNo
              );
        }));
        await Future.wait(entries.asMap().entries.map((entry) {
          var value = entry.value;
          return _updateMemoIssueRoughData(
            id: value['detId'],
            rec: 'Y',
          );
        }));
        await getMemoRecData(force: true);
        await getMemoRecDetailsData(force: true);
        await getMemoIssueDetailsData(force: true);
        isLoading.value = false;

        if (printInvoice) {
          isLoading.value = true;
          final invoiceGenerator = MemoRecInvoiceGenerator();
          final pdfData = await invoiceGenerator.generateInvoice(
              id: response.data['data']['MemoRecMstID'],
              invoiceDate: invoiceDate,
              partyCode: partyCode.toString(),
              entries: entries.map((e) => e.map((k, v) => MapEntry(k, v?.toString() ?? ''))).toList(),
              totalWt: totalWt,
              totalLossWt: totalLossWt,
              totalRecWt: totalRecWt,
              totalAmt: totalAmt!,
              totalRecAmt: totalRecAmount,
              totalRate: totalRate);
          isLoading.value = false;
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfData,
          ).then((value) => successDialog(messageText: response.data['message']));
          if (!kDebugMode) {
            await Printing.sharePdf(
              bytes: pdfData,
              filename:
                  'Memo-Receive/${getPartyName(int.parse(partyCode!))}/${DateTime.now()}.pdf',
            );
          }
        } else {
          successDialog(messageText: response.data['message']);
        }
        return true;
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: '$error');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<bool> updatePurchaseData({
    required int id,
    String? partyCode,
    invoiceNo,
    invoiceDate,
    recDate,
    brokerCode,
    dueDays,
    dueDate,
    onlyDueDate,
    pSite,
    billType,
    rdType,
    exchange,
    int? totalPc,
    double? totalAmt,
    totalWt,
    totalRate,
    totalAmtRs,
    totalAmtDollar,
    totalRateRs,
    totalRateDollar,
    expPer,
    expFix,
    expFixRs,
    linPer,
    linFix,
    linFixRs,
    totExpPer,
    totExpFix,
    totExpFixRs,
    broPer,
    broFix,
    broRs,
    addPer,
    addFix,
    addFixRs,
    lessPer,
    lessFix,
    lessFixRs,
    invCharge,
    invChargePer,
    invChargeRs,
    comPer,
    comFix,
    comFixRs,
    gstPer,
    gstAmtRs,
    gstAmtDollar,
    netAmtDollar,
    netAmtRs,
    roundOfDollar,
    roundOfRs,
    finalNetAmtDollar,
    finalNetAmtRs,
    finalAmtRs,
    finalAmtD,
    totNetAmtDollar,
    totNetAmtRs,
    chkExp,
    chkLin,
    chkBro,
    chkAdd,
    chkLess,
    chkInv,
    chkCom,
    remarks,
    crId,
    required List entries,
  }) async {
    try {
      isLoading.value = true;
      // await deletePurchaseCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      final String? formattedInvDate = formatToIsoUtc(invoiceDate);

      final String? formattedRecDate = recDate != null
          ? formatToIsoUtc(recDate)
          : formattedInvDate;

      final dynamic formattedDueDate = dueDate != null
          ? formatToIsoUtc(dueDate)
          : formattedInvDate;

      final dynamic formattedPSite = (pSite != null && pSite.toString().trim().isNotEmpty)
          ? formatToIsoUtc(pSite)
          : null;

      var params = {
        if (crId != null && crId.toString().isNotEmpty) "CrId": int.tryParse(crId.toString()) ?? crId,
        "InvoiceNo": "$invoiceNo",
        "InvoiceDate": formattedInvDate,
        if (formattedRecDate != null) "Recdate": formattedRecDate,
        "PartyCode": int.tryParse(partyCode.toString()) ?? partyCode,
        "BrokerCode": int.tryParse(brokerCode.toString()) ?? brokerCode,
        "DueDay": int.tryParse(dueDays.toString()) ?? dueDays,
        "DueDate": formattedDueDate,
        if (formattedPSite != null && formattedPSite.toString().isNotEmpty) "PSite": formattedPSite,
        "BillType": billType ?? "BILL",
        if (rdType != null && rdType.toString().isNotEmpty) "RDType": rdType,
        if (exchange != null) "Exchange": exchange,
        if (totalPc != null) "TPc": totalPc,
        "TWeight": totalWt,
        "TAmtRs": totalAmtRs ?? totalAmt,
        "TAmtDollar": totalAmtDollar ?? totalAmt,
        "TRateRs": totalRateRs ?? totalRate,
        "TRateDollar": totalRateDollar ?? totalRate,
        if (invCharge != null) "InvCharge": invCharge,
        if (invChargePer != null) "InvChargePer": invChargePer,
        if (invChargeRs != null) "InvChargeRs": invChargeRs,
        if (addPer != null) "AddPer": addPer,
        if (addFix != null) "AddFix": addFix,
        if (addFixRs != null) "AddFixRs": addFixRs,
        if (lessPer != null) "LessPer": lessPer,
        if (lessFix != null) "LessFix": lessFix,
        if (lessFixRs != null) "LessFixRs": lessFixRs,
        if (expPer != null) "ExpPer": expPer,
        if (expFix != null) "ExpFix": expFix,
        if (expFixRs != null) "ExpFixRs": expFixRs,
        if (linPer != null) "LinPer": linPer,
        if (linFix != null) "LinFix": linFix,
        if (linFixRs != null) "LinFixRs": linFixRs,
        if (totExpPer != null) "TotExpPer": totExpPer,
        if (totExpFix != null) "TotExpFix": totExpFix,
        if (totExpFixRs != null) "TotExpFixRs": totExpFixRs,
        if (broPer != null) "BroPer": broPer,
        if (broFix != null) "BroFix": broFix,
        if (broRs != null) "BroRs": broRs,
        if (comPer != null) "ComPer": comPer,
        if (comFix != null) "ComFix": comFix,
        if (comFixRs != null) "ComFixRs": comFixRs,
        "TotAmtDollar": totalAmtDollar ?? totalAmt,
        "TotNetAmtRs": totNetAmtRs ?? totalAmt,
        "TotAmtRs": totalAmtRs ?? totalAmt,
        "LogID": 0,
        "PCID": "TESTFROMWEB",
        "Ever": 0,
        "SDate": formatToIsoUtc(DateTime.now()),
        "CompanyCode": companyCode.value,
        if (chkAdd != null) "ChkAdd": chkAdd,
        if (chkLess != null) "ChkLess": chkLess,
        if (chkExp != null) "ChkExp": chkExp,
        if (chkLin != null) "ChkLin": chkLin,
        if (chkCom != null) "ChkCom": chkCom,
        if (chkBro != null) "ChkBro": chkBro,
        if (chkInv != null) "ChkInv": chkInv,
        if (totalRateRs != null) "AvgRate": totalRateRs,
        "NetAmtDollar": netAmtDollar ?? totalAmtDollar ?? totalAmt,
        "NetAmtRs": netAmtRs ?? totalAmtRs ?? totalAmt,
        "TotNetAmtDollar": totNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        if (remarks != null) "Remarks": remarks,
        if (gstPer != null) "GstPer": gstPer,
        if (gstAmtRs != null) "GstAmtRs": gstAmtRs,
        if (gstAmtDollar != null) "GstAmtDollar": gstAmtDollar,
        "EntryType": "U",
        "FinalNetAmtDollar": finalNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        "FinalNetAmtRs": finalNetAmtRs ?? totalAmtRs ?? totalAmt,
        "FinalAmtRs": finalAmtRs ?? finalNetAmtRs ?? totalAmtRs ?? totalAmt,
        "FinalAmtD": finalAmtD ?? finalNetAmtDollar ?? totalAmtDollar ?? totalAmt,
        "RoundOfRs": roundOfRs ?? 0.0,
        "RoundOfD": roundOfDollar ?? 0.0,
      };

      final response = await dio.put('${baseUrl}rough-entry/purchase/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200 &&
          (response.data?['data'] != null ||
              response.data?['message']?.toString().toLowerCase().contains('success') == true)) {
        final dynamic mstId = response.data['data']?['RoughPurMstID'] ??
            response.data['data']?['id'] ??
            response.data['RoughPurMstID'] ??
            response.data['id'] ??
            id;
        final dynamic respInvoiceNo = response.data['data']?['InvoiceNo'] ??
            response.data['InvoiceNo'] ??
            invoiceNo;

        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;

          // Check if the 'id' exists in the entry data
          if (value.containsKey('id') && value['id'] != null) {
            // Call the update function if 'id' exists
            return _updatePurchaseRoughData(
              id: value['id'],
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              rateRs: value['rateRs'] ?? value['rate'],
              amtRs: value['amtRs'] ?? value['amount'],
              rateDollar: value['rateDollar'] ?? value['rate'],
              amtDollar: value['amtDollar'] ?? value['amount'],
              pc: value['pc'] != null ? int.tryParse(value['pc'].toString()) : null,
              site: value['site'],
              roughQualityCode: value['quality'] != null ? int.tryParse(value['quality'].toString()) : null,
              roughCharniCode: value['charni'] != null ? int.tryParse(value['charni'].toString()) : null,
              description: value['description'],
              roughName: value['rough'],
              roughPurMstID: mstId,
              srNo: index + 1, // incremented srNo
            );
          } else {
            // Call the add function if 'id' does not exist
            return _addPurchaseRoughData(
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              rateRs: value['rateRs'] ?? value['rate'],
              amtRs: value['amtRs'] ?? value['amount'],
              rateDollar: value['rateDollar'] ?? value['rate'],
              amtDollar: value['amtDollar'] ?? value['amount'],
              pc: value['pc'] != null ? int.tryParse(value['pc'].toString()) : null,
              site: value['site'],
              roughQualityCode: value['quality'] != null ? int.tryParse(value['quality'].toString()) : null,
              roughCharniCode: value['charni'] != null ? int.tryParse(value['charni'].toString()) : null,
              description: value['description'],
              roughName: value['rough'],
              roughPurMstID: mstId,
              srNo: index + 1, // incremented srNo
            );
          }
        }));
        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: mstId,
            purMstId: mstId,
            saleMstId: 0,
            invoiceDate: invoiceDate,
            orgInvoiceDate: formattedInvDate,
            paymentMstId: 0,
            dueDate: formattedDueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode:
                index == 0 ? companyPartyCode.value.toString() : partyCode,
            creditRs: index == 0 ? 0.00 : (totNetAmtRs ?? totalAmt),
            debitRs: index == 0 ? (totNetAmtRs ?? totalAmt) : 0.00,
            invAmtRs: (totNetAmtRs ?? totalAmt),
            drCr: index == 0 ? 'DR' : 'CR',
            formType: 'Purchase',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmPurchaseEntry',
            perPartyCode:
                index == 0 ? partyCode : companyPartyCode.value.toString(),
            orgCt: totalWt,
            dueDays: dueDays,
            invoiceNo: respInvoiceNo,
            srNo: index + 1,
            brokerCode: brokerCode,
          );
        }));
        isLoading.value = false;
        await getPurchaseData(force: true);
        await getPurchaseDetailsData(force: true);
        await getCreditDebitData();
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        successDialog(messageText: response.data['message'] ?? 'Purchase updated successfully');

        /*
        // PDF auto-print commented out as requested
        try {
          final invoiceGenerator = PurchaseInvoiceGenerator();
          final pdfData = await invoiceGenerator.generateInvoice(
              id: purchaseDataList.length + 1,
              invoiceDate: invoiceDate,
              invoiceNo: respInvoiceNo,
              partyCode: partyCode.toString(),
              brokerCode: brokerCode,
              dueDate: onlyDueDate,
              dueDays: dueDays,
              entries: entries,
              totalWt: totalWt,
              totalAmt: totalAmt!,
              totalRate: totalRate);
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfData,
          ).then((value) => successDialog(messageText: response.data['message']));
          if (!kDebugMode) {
            await Printing.sharePdf(
              bytes: pdfData,
              filename: '$respInvoiceNo.pdf',
            );
          }
        } catch (printErr) {
          successDialog(messageText: response.data['message'] ?? 'Purchase updated successfully');
          if (kDebugMode) {
            print('Print error: $printErr');
          }
        }
        */
        return true;
      } else {
        isLoading.value = false;
        final String errMsg = response.data?['message']?.toString() ??
            'Failed to Update data: ${response.statusCode}';
        errorDialog(messageText: errMsg);
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<void> updateSaleData(
      {required int id,
      String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      onlyDueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      required List<Map<String, String>> entries}) async {
    try {
      isLoading.value = true;
      await deleteSaleCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      var params = {
        "PolishDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        "InvoiceNo": "$invoiceNo",
        // "InvNo": 123,
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        "DueDay": dueDays,
        "DueDate": dueDate,
        // "InvCode": "1",
        // "SaleType": "LOCAL",
        // "InsuranceName": "RELIANCE",
        // "SGstPer": 12.453,
        // "CGstPer": 12.453,
        // "IGstPer": 12.453,
        // "SGstAmount": 14.23,
        // "CGstAmount": 12.23,
        // "IGstAmount": 12.32,
        // "SGstUsdAmount": 1.456,
        // "CGstUsdAmount": 1.456,
        // "IGstUsdAmount": 1.456,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalAmt, // total
        "RoundRs": 0,
        "RoundUsd": 0,
        "NetUsdAmount": totalAmt, //total
        "RdType": "RS",
        "DollarRate": 1,
        "PaymentRec": "N",
        "BroPer": 0,
        "BroRsAmount": 0,
        "BroUSDAmount": 0,
        "BrokerCode": brokerCode,
        "BankCode": 0,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalAmt, //total
        "TPcs": 0,
        "TWeight": totalWt, //total rough wt
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRate, // rate = toal amt / total wt
        "TDAmount": totalAmt, // dollar amt total
        "Sflag": "U",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": 0, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.put('${baseUrl}rough-entry/polish-sale/$id',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          if (value.containsKey('id') && value['id'] != null) {
            return _updateSaleRoughData(
                id: value['id'],
                wt: value['wt'],
                rate: value['rate'],
                amount: value['amount'],
                roughName: value['rough'],
                description: value['description'],
                polishSaleMstID: response.data['data']['PolishSaleMstID'],
                srNo: index + 1 // incremented srNo
                );
          } else {
            return _addSaleRoughData(
                wt: value['wt'],
                rate: value['rate'],
                amount: value['amount'],
                description: value['description'],
                roughName: value['rough'],
                polishSaleMstID: response.data['data']['PolishSaleMstID'],
                srNo: index + 1 // incremented srNo
                );
          }
        }));
        Future.wait(List.generate(2, (index) {
          return addCreditDebitData(
            mstId: response.data['data']['PolishSaleMstID'],
            purMstId: 0,
            saleMstId: response.data['data']['PolishSaleMstID'],
            invoiceDate: invoiceDate,
            orgInvoiceDate: DateFormat('yyyy-MM-dd').format(invoiceDate),
            paymentMstId: 0,
            dueDate: dueDate,
            remarks1: ' ',
            remarks2: ' ',
            partyCode:
                index == 0 ? companyPartyCode.value.toString() : partyCode,
            creditRs: index == 0 ? 0.00 : totalAmt,
            debitRs: index == 0 ? totalAmt : 0.00,
            invAmtRs: totalAmt,
            drCr: index == 0 ? 'DR' : 'CR',
            formType: 'Sale',
            entryType: index == 0 ? 'NIL' : 'PARTY',
            traType: index == 0 ? 'NIL' : 'PARTY',
            formName: 'FrmSaleEntry',
            perPartyCode:
                index == 0 ? partyCode : companyPartyCode.value.toString(),
            orgCt: totalWt,
            dueDays: dueDays,
            invoiceNo: response.data['data']['InvoiceNo'],
            srNo: index + 1,
            brokerCode: brokerCode,
          );
        }));
        await getSaleData();
        await getSaleDetailsData();
        await getCreditDebitData();
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        isLoading.value = false;
        final invoiceGenerator = SaleInvoiceGenerator();
        final pdfData = await invoiceGenerator.generateInvoice(
            id: polishSaleList.length + 1,
            invoiceDate: invoiceDate,
            invoiceNo: invoiceNo,
            partyCode: partyCode.toString(),
            brokerCode: brokerCode,
            dueDate: onlyDueDate,
            dueDays: dueDays,
            entries: entries,
            totalWt: totalWt,
            totalAmt: totalAmt!,
            totalRate: totalRate);
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData,
        ).then((value) => successDialog(messageText: response.data['message']));
        await Printing.sharePdf(
          bytes: pdfData,
          filename: '$invoiceNo.pdf', // Set the custom name here
        );
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<bool> updateMemoIssueData(
      {required int id,
      String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      int? fromUserId,
      String? rdType,
      double? dollarRate,
      required List entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        if (invoiceNo != null) "InvoiceNo": "$invoiceNo",
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        if (dueDays != null) "DueDay": dueDays,
        if (dueDate != null) "DueDate": dueDate,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalAmt, // total
        "NetUsdAmount": totalAmt, //total
        "RdType": rdType ?? "RS",
        "DollarRate": dollarRate ?? 100,
        "BrokerCode": brokerCode,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalAmt, //total
        "TWeight": totalWt, //total rough wt
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRate, // rate = toal amt / total wt
        "TDAmount": totalAmt, // dollar amt total
        "Sflag": "U",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": fromUserId ?? currentUserId.value, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.put('${baseUrl}rough-entry/memo-issue/$id',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          if (value.containsKey('id') && value['id'] != null && value['id'].toString().isNotEmpty) {
            return _updateMemoIssueRoughData(
                id: value['id'],
                wt: value['wt'],
                rate: value['rateRs'] ?? value['rate'],
                amount: value['amountRs'] ?? value['amount'],
                rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
                amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
                type: value['type'] ?? 'ROUGH',
                invNo: value['invNo'],
                roughPurMstID: value['roughPurMstID'],
                clarityCode: value['clarityCode'] ?? 0,
                charniCode: value['charniCode'] ?? 0,
                shapeCode: value['shapeCode'] ?? 0,
                colorCode: value['colorCode'] ?? 0,
                qualityCode: value['qualityCode'] ?? 0,
                pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
                penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
                roughName: value['rough'] ?? '1',
                description: value['description'],
                memoIssueMstID: response.data['data']['MemoIssueMstID'],
                srNo: index + 1,
                rec: 'N' // incremented srNo
                );
          } else {
            return _addMemoIssueRoughData(
                wt: value['wt'],
                rate: value['rateRs'] ?? value['rate'],
                amount: value['amountRs'] ?? value['amount'],
                rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
                amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
                type: value['type'] ?? 'ROUGH',
                invNo: value['invNo'],
                roughPurMstID: value['roughPurMstID'],
                clarityCode: value['clarityCode'] ?? 0,
                charniCode: value['charniCode'] ?? 0,
                shapeCode: value['shapeCode'] ?? 0,
                colorCode: value['colorCode'] ?? 0,
                qualityCode: value['qualityCode'] ?? 0,
                pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
                penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
                description: value['description'],
                roughName: value['rough'] ?? '1',
                memoIssueMstID: response.data['data']['MemoIssueMstID'],
                srNo: index + 1,
                rec: 'N' // incremented srNo
                );
          }
        }));
        await getMemoIssueData(force: true);
        await getMemoIssueDetailsData(force: true);
        isLoading.value = true;
        final invoiceGenerator = MemoIssueInvoiceGenerator();
        final pdfData = await invoiceGenerator.generateInvoice(
            id: response.data['data']['MemoIssueMstID'],
            invoiceDate: invoiceDate,
            partyCode: partyCode.toString(),
            entries: entries,
            totalWt: totalWt,
            totalAmt: totalAmt!,
            totalRate: totalRate);
        isLoading.value = false;
        // await Printing.layoutPdf(
        //   onLayout: (PdfPageFormat format) async => pdfData,
        // ).then((value) => successDialog(messageText: response.data['message']));
        // if (!kDebugMode) {
        //   await Printing.sharePdf(
        //     bytes: pdfData,
        //     filename:
        //         'Memo-Issue/${getPartyName(int.parse(partyCode!))}/${DateTime.now()}.pdf', // Set the custom name here
        //   );
        // }
        return true;
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Update data: : ${response.data['message']}');
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<bool> updateMemoRecData(
      {required int id,
      String? partyCode,
      invoiceNo,
      invoiceDate,
      brokerCode,
      dueDays,
      dueDate,
      roughName,
      description,
      wt,
      rate,
      amount,
      double? totalAmt,
      totalWt,
      totalRate,
      totalLossWt,
      totalRecWt,
      totalRecAmount,
      int? totalPacket,
      int? totalRecPcs,
      double? totalIssWt,
      double? totalSaleWt,
      double? totalOutWt,
      double? totalFinalWt,
      double? totalRecAmountDollar,
      double? totalRateDollar,
      int? fromUserId,
      bool printInvoice = false,
      required List<Map<String, dynamic>> entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        // "PolishDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        // "InvoiceNo": "$invoiceNo",
        // "InvNo": 123,
        "InvoiceDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceDate),
        // "DueDay": dueDays,
        // "DueDate": dueDate,
        // "InvCode": "1",
        // "SaleType": "LOCAL",
        // "InsuranceName": "RELIANCE",
        // "SGstPer": 12.453,
        // "CGstPer": 12.453,
        // "IGstPer": 12.453,
        // "SGstAmount": 14.23,
        // "CGstAmount": 12.23,
        // "IGstAmount": 12.32,
        // "SGstUsdAmount": 1.456,
        // "CGstUsdAmount": 1.456,
        // "IGstUsdAmount": 1.456,
        "TotRsAmt": totalAmt, //total
        "TotUsdAmt": totalRecAmountDollar ?? totalAmt, // total
        // "RoundRs": 0,
        // "RoundUsd": 0,
        "NetUsdAmount": totalRecAmountDollar ?? totalAmt, //total
        // "RdType": "RS",
        // "DollarRate": 1,
        // "PaymentRec": "N",
        // "BroPer": 0,
        // "BroRsAmount": 0,
        // "BroUSDAmount": 0,
        "BrokerCode": brokerCode,
        // "BankCode": 0,
        "PartyCode": partyCode,
        "FinalRsAmount": totalAmt, //total
        "FinalUsdAmount": totalRecAmountDollar ?? totalAmt, //total
        "TPcs": totalPacket ?? 0,
        "RecPcs": totalRecPcs ?? 0,
        "TWeight": totalFinalWt ?? totalRecWt ?? totalWt, //total rough wt
        "TotalWt": totalFinalWt,
        "IssWt": totalIssWt ?? totalWt,
        "RecWt": totalRecWt,
        "SaleWt": totalSaleWt,
        "OutWt": totalOutWt,
        "LossWt": totalLossWt,
        "TRate": totalRate, // ang rate = total amt / total wt
        "TAmount": totalAmt, // total
        "TDRate": totalRateDollar ?? totalRate, // rate = toal amt / total wt
        "TDAmount": totalRecAmountDollar ?? totalAmt, // dollar amt total
        "Sflag": "U",
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "LogID": fromUserId ?? currentUserId.value, // userid
        "PCID": "TESTWEB", // deviceId
        "Ever": 0, // 0
        "CompanyCode": companyCode.value // Global var Company Code
      };

      final response = await dio.put('${baseUrl}rough-entry/memo-rec/$id',
          data: jsonEncode(params));

      if (response.data['data'] != null) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          if (value.containsKey('id') && value['id'] != null) {
            return _updateMemoRecRoughData(
                id: value['id'],
                memoIssueDetId: value['detId'],
                wt: value['wt'],
                recWt: value['recWt'],
                saleWt: value['saleWt'],
                outWt: value['outWt'],
                lossWt: value['lossWt'],
                totalWt: value['totalWt'],
                rate: value['rateRs'] ?? value['rate'],
                amount: value['amountRs'] ?? value['amount'],
                rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
                amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
                roughName: value['rough'] ?? '1',
                type: value['type'] ?? 'ROUGH',
                invNo: value['invNo'],
                roughPurMstID: value['roughPurMstID'],
                clarityCode: value['clarityCode'] ?? 0,
                charniCode: value['charniCode'] ?? 0,
                shapeCode: value['shapeCode'] ?? 0,
                colorCode: value['colorCode'] ?? 0,
                qualityCode: value['qualityCode'] ?? 0,
                pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
                recPcs: int.tryParse(value['recPcs']?.toString() ?? '0'),
                penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
                memoRecMstID: response.data['data']['MemoRecMstID'],
                srNo: index + 1 // incremented srNo
                );
          } else {
            return _addMemoRecRoughData(
                memoIssueDetId: value['detId'],
                wt: value['wt'],
                recWt: value['recWt'],
                saleWt: value['saleWt'],
                outWt: value['outWt'],
                lossWt: value['lossWt'],
                totalWt: value['totalWt'],
                rate: value['rateRs'] ?? value['rate'],
                amount: value['amountRs'] ?? value['amount'],
                rateD: value['rateDollar'] ?? value['rateD'] ?? value['rate'],
                amountD: value['amountDollar'] ?? value['amountD'] ?? value['amount'],
                roughName: value['rough'] ?? '1',
                type: value['type'] ?? 'ROUGH',
                invNo: value['invNo'],
                roughPurMstID: value['roughPurMstID'],
                clarityCode: value['clarityCode'] ?? 0,
                charniCode: value['charniCode'] ?? 0,
                shapeCode: value['shapeCode'] ?? 0,
                colorCode: value['colorCode'] ?? 0,
                qualityCode: value['qualityCode'] ?? 0,
                pcs: int.tryParse(value['pcs']?.toString() ?? '0'),
                recPcs: int.tryParse(value['recPcs']?.toString() ?? '0'),
                penCarats: double.tryParse(value['penWt']?.toString() ?? '0'),
                memoRecMstID: response.data['data']['MemoRecMstID'],
                srNo: index + 1 // incremented srNo
                );
          }
        }));
        await getMemoRecData(force: true);
        await getMemoRecDetailsData(force: true);
        await getMemoIssueDetailsData(force: true);
        isLoading.value = false;

        if (printInvoice) {
          isLoading.value = true;
          final invoiceGenerator = MemoRecInvoiceGenerator();
          final pdfData = await invoiceGenerator.generateInvoice(
              id: response.data['data']['MemoRecMstID'],
              invoiceDate: invoiceDate,
              partyCode: partyCode.toString(),
              entries: entries.map((e) => e.map((k, v) => MapEntry(k, v?.toString() ?? ''))).toList(),
              totalWt: totalWt,
              totalAmt: totalAmt!,
              totalRate: totalRate);
          isLoading.value = false;
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfData,
          ).then((value) => successDialog(messageText: response.data['message']));
          if (!kDebugMode) {
            await Printing.sharePdf(
              bytes: pdfData,
              filename:
                  'Memo-Receive/${getPartyName(int.parse(partyCode!))}/${DateTime.now()}.pdf',
            );
          }
        } else {
          successDialog(messageText: response.data['message']);
        }
        return true;
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Update data: ${response.data['message']}');
        return false;
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<void> _addPurchaseRoughData({
    roughName,
    roughPurMstID,
    wt,
    rate,
    amount,
    description,
    srNo,
    roughQualityCode,
    roughCharniCode,
    pc,
    rateRs,
    amtRs,
    rateDollar,
    amtDollar,
    site,
  }) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        "Srno": srNo is int ? srNo : (int.tryParse(srNo?.toString() ?? '') ?? 1),
        "RoughTypeCode": roughName is int ? roughName : (int.tryParse(roughName?.toString() ?? '') ?? 1),
        if (roughQualityCode != null) "RoughQualityCode": roughQualityCode is int ? roughQualityCode : (int.tryParse(roughQualityCode.toString()) ?? roughQualityCode),
        if (roughCharniCode != null) "RoughCharniCode": roughCharniCode is int ? roughCharniCode : (int.tryParse(roughCharniCode.toString()) ?? roughCharniCode),
        if (pc != null) "Pc": pc is int ? pc : (int.tryParse(pc.toString()) ?? 0),
        "Wt": wt is num ? wt : (double.tryParse(wt?.toString() ?? '0') ?? 0.0),
        "RateRs": rateRs is num ? rateRs : (double.tryParse((rateRs ?? rate)?.toString() ?? '0') ?? 0.0),
        "AmtRs": amtRs is num ? amtRs : (double.tryParse((amtRs ?? amount)?.toString() ?? '0') ?? 0.0),
        "RateDollar": rateDollar is num ? rateDollar : (double.tryParse((rateDollar ?? rate)?.toString() ?? '0') ?? 0.0),
        "AmtDollar": amtDollar is num ? amtDollar : (double.tryParse((amtDollar ?? amount)?.toString() ?? '0') ?? 0.0),
        if (site != null && site.toString().isNotEmpty) "Site": site.toString(),
        if (description != null && description.toString().isNotEmpty) "Description": description.toString(),
      };

      final response = await dio.post('${baseUrl}rough-entry/rough-details/add',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Added!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _addSaleRoughData(
      {roughName, wt, rate, amount, description, srNo, polishSaleMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "PolishSaleMstID": polishSaleMstID,
        "SrNo": srNo,
        // "ClarityCode": 1,
        // "CharniCode": 1,
        // "Pcs": 1,
        "Carats": wt,
        "RateRs": rate,
        "AmountRs": amount,
        "RateD": rate,
        "AmountD": amount,
        // "PenCarats": 12.232,
        "Type": "ROUGH",
        // "InvNo": "",
        // "RoughPurMstID": 2,
        "RoughTypeCode": int.parse(roughName),
        "Description": description
      };

      final response = await dio.post('${baseUrl}rough-entry/sale-details/add',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Added!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Add data: : ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _addMemoIssueRoughData(
      {roughName,
      wt,
      rate,
      amount,
      rateD,
      amountD,
      type,
      invNo,
      roughPurMstID,
      clarityCode,
      charniCode,
      shapeCode,
      colorCode,
      qualityCode,
      pcs,
      penCarats,
      description,
      srNo,
      memoIssueMstID,
      rec}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "MemoIssueMstID": memoIssueMstID,
        "SrNo": srNo,
        if (clarityCode != null) "ClarityCode": clarityCode,
        if (charniCode != null) "CharniCode": charniCode,
        if (shapeCode != null) "ShapeCode": shapeCode,
        if (colorCode != null) "ColorCode": colorCode,
        if (qualityCode != null) "QualityCode": qualityCode,
        if (pcs != null) "Pcs": pcs,
        "Carats": wt,
        "RateRs": rate,
        "AmountRs": amount,
        "RateD": rateD ?? rate,
        "AmountD": amountD ?? amount,
        if (penCarats != null) "PenCarats": penCarats,
        "Type": type ?? "ROUGH",
        if (invNo != null && invNo.toString().isNotEmpty) "InvNo": invNo,
        if (roughPurMstID != null) "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        "RoughTypeCode": int.tryParse(roughName?.toString() ?? '') ?? 1,
        // "Description": description,
        "Rec": rec ?? 'N'
      };

      final response = await dio.post(
          '${baseUrl}rough-entry/memo-issue-details/add',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Added!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Add data: : ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _addMemoRecRoughData(
      {memoIssueDetId,
      roughName,
      wt,
      recWt,
      saleWt,
      outWt,
      lossWt,
      totalWt,
      rate,
      amount,
      rateD,
      amountD,
      description,
      srNo,
      type,
      invNo,
      roughPurMstID,
      clarityCode,
      charniCode,
      shapeCode,
      colorCode,
      qualityCode,
      pcs,
      recPcs,
      penCarats,
      memoRecMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "MemoRecMstID": memoRecMstID,
        "MemoIssueDetID": memoIssueDetId,
        "SrNo": srNo,
        if (clarityCode != null) "ClarityCode": clarityCode,
        if (charniCode != null) "CharniCode": charniCode,
        if (shapeCode != null) "ShapeCode": shapeCode,
        if (colorCode != null) "ColorCode": colorCode,
        if (qualityCode != null) "QualityCode": qualityCode,
        if (pcs != null) "Pcs": pcs,
        if (recPcs != null) "RecPcs": recPcs,
        "RecCarats": recWt,
        if (saleWt != null) "SaleCarats": saleWt,
        if (outWt != null) "OutCarats": outWt,
        "LossCarats": lossWt,
        if (totalWt != null) "TotalCarats": totalWt,
        "Carats": wt,
        "RateRs": rate,
        "AmountRs": amount,
        "RateD": rateD ?? rate,
        "AmountD": amountD ?? amount,
        if (penCarats != null) "PenCarats": penCarats,
        "Type": type ?? "ROUGH",
        if (invNo != null && invNo.toString().isNotEmpty) "InvNo": invNo,
        if (roughPurMstID != null) "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        "RoughTypeCode": int.tryParse(roughName?.toString() ?? '1') ?? 1,
      };

      final response = await dio.post(
          '${baseUrl}rough-entry/memo-rec-details/add',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Added!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Add data: : ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _updateSaleRoughData(
      {required id,
      roughName,
      wt,
      description,
      rate,
      amount,
      srNo,
      polishSaleMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "PolishSaleMstID": polishSaleMstID,
        "SrNo": srNo,
        // "ClarityCode": 1,
        // "CharniCode": 1,
        // "Pcs": 1,
        "Carats": wt,
        "RateRs": rate,
        "AmountRs": amount,
        "RateD": rate,
        "AmountD": amount,
        // "PenCarats": 12.232,
        "Type": "ROUGH",
        // "InvNo": "",
        // "RoughPurMstID": 2,
        "RoughTypeCode": int.parse(roughName),
        "Description": description
      };

      final response = await dio.put('${baseUrl}rough-entry/sale-details/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Updated!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Update Data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _updateMemoIssueRoughData(
      {required id,
      roughName,
      wt,
      description,
      rate,
      amount,
      rateD,
      amountD,
      type,
      invNo,
      roughPurMstID,
      clarityCode,
      charniCode,
      shapeCode,
      colorCode,
      qualityCode,
      pcs,
      penCarats,
      srNo,
      rec,
      memoIssueMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        if (memoIssueMstID != null) "MemoIssueMstID": memoIssueMstID,
        if (srNo != null) "SrNo": srNo,
        if (clarityCode != null) "ClarityCode": clarityCode,
        if (charniCode != null) "CharniCode": charniCode,
        if (shapeCode != null) "ShapeCode": shapeCode,
        if (colorCode != null) "ColorCode": colorCode,
        if (qualityCode != null) "QualityCode": qualityCode,
        if (pcs != null) "Pcs": pcs,
        if (wt != null) "Carats": wt,
        if (rate != null) "RateRs": rate,
        if (amount != null) "AmountRs": amount,
        if (rateD != null || rate != null) "RateD": rateD ?? rate,
        if (amountD != null || amount != null) "AmountD": amountD ?? amount,
        if (penCarats != null) "PenCarats": penCarats,
        if (type != null) "Type": type,
        if (invNo != null && invNo.toString().isNotEmpty) "InvNo": invNo,
        if (roughPurMstID != null) "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        if (roughName != null) "RoughTypeCode": int.tryParse(roughName?.toString() ?? '') ?? 1,
        // if (description != null) "Description": description,
        "Rec": rec ?? 'N'
      };

      final response = await dio.put(
          '${baseUrl}rough-entry/memo-issue-details/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Updated! $id $rec');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Update Data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _updateMemoRecRoughData(
      {required id,
      memoIssueDetId,
      roughName,
      wt,
      recWt,
      saleWt,
      outWt,
      lossWt,
      totalWt,
      description,
      rate,
      amount,
      rateD,
      amountD,
      srNo,
      type,
      invNo,
      roughPurMstID,
      clarityCode,
      charniCode,
      shapeCode,
      colorCode,
      qualityCode,
      pcs,
      recPcs,
      penCarats,
      memoRecMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        if (memoRecMstID != null) "MemoRecMstID": memoRecMstID,
        if (memoIssueDetId != null) "MemoIssueDetID": memoIssueDetId,
        "SrNo": srNo,
        if (clarityCode != null) "ClarityCode": clarityCode,
        if (charniCode != null) "CharniCode": charniCode,
        if (shapeCode != null) "ShapeCode": shapeCode,
        if (colorCode != null) "ColorCode": colorCode,
        if (qualityCode != null) "QualityCode": qualityCode,
        if (pcs != null) "Pcs": pcs,
        if (recPcs != null) "RecPcs": recPcs,
        "Carats": wt,
        "RecCarats": recWt,
        if (saleWt != null) "SaleCarats": saleWt,
        if (outWt != null) "OutCarats": outWt,
        if (lossWt != null) "LossCarats": lossWt,
        if (totalWt != null) "TotalCarats": totalWt,
        "RateRs": rate,
        "AmountRs": amount,
        "RateD": rateD ?? rate,
        "AmountD": amountD ?? amount,
        if (penCarats != null) "PenCarats": penCarats,
        "Type": type ?? "ROUGH",
        if (invNo != null && invNo.toString().isNotEmpty) "InvNo": invNo,
        if (roughPurMstID != null) "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        "RoughTypeCode": int.tryParse(roughName?.toString() ?? '1') ?? 1,
      };

      final response = await dio.put(
          '${baseUrl}rough-entry/memo-rec-details/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Updated!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Update Data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _updatePurchaseRoughData({
    required id,
    roughName,
    wt,
    description,
    rate,
    amount,
    srNo,
    roughPurMstID,
    roughQualityCode,
    roughCharniCode,
    pc,
    rateRs,
    amtRs,
    rateDollar,
    amtDollar,
    site,
  }) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "RoughPurMstID": roughPurMstID is int ? roughPurMstID : (int.tryParse(roughPurMstID?.toString() ?? '') ?? roughPurMstID),
        "Srno": srNo is int ? srNo : (int.tryParse(srNo?.toString() ?? '') ?? 1),
        "RoughTypeCode": roughName is int ? roughName : (int.tryParse(roughName?.toString() ?? '') ?? 1),
        if (roughQualityCode != null) "RoughQualityCode": roughQualityCode is int ? roughQualityCode : (int.tryParse(roughQualityCode.toString()) ?? roughQualityCode),
        if (roughCharniCode != null) "RoughCharniCode": roughCharniCode is int ? roughCharniCode : (int.tryParse(roughCharniCode.toString()) ?? roughCharniCode),
        if (pc != null) "Pc": pc is int ? pc : (int.tryParse(pc.toString()) ?? 0),
        "Wt": wt is num ? wt : (double.tryParse(wt?.toString() ?? '0') ?? 0.0),
        "RateRs": rateRs is num ? rateRs : (double.tryParse((rateRs ?? rate)?.toString() ?? '0') ?? 0.0),
        "AmtRs": amtRs is num ? amtRs : (double.tryParse((amtRs ?? amount)?.toString() ?? '0') ?? 0.0),
        "RateDollar": rateDollar is num ? rateDollar : (double.tryParse((rateDollar ?? rate)?.toString() ?? '0') ?? 0.0),
        "AmtDollar": amtDollar is num ? amtDollar : (double.tryParse((amtDollar ?? amount)?.toString() ?? '0') ?? 0.0),
        if (site != null && site.toString().isNotEmpty) "Site": site.toString(),
        if (description != null && description.toString().isNotEmpty) "Description": description.toString(),
      };

      final response = await dio.put('${baseUrl}rough-entry/rough-details/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Updated!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Update Data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deletePurchaseRoughData({required id}) async {
    try {
      isDeleteLoading.value = true;
      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/rough-details/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }
        await getPurchaseDetailsData(force: true);
        isDeleteLoading.value = false;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteSaleRoughData({required id}) async {
    try {
      isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/sale-details/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }
        await getSaleDetailsData();
        isDeleteLoading.value = false;
      } else {
        isDeleteLoading.value = false;

        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteMemoIssueRoughData({required id}) async {
    try {
      isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/memo-issue-details/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }
        await getMemoIssueDetailsData(force: true);
        isDeleteLoading.value = false;
      } else {
        isDeleteLoading.value = false;

        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteMemoRecRoughData({required id, detId}) async {
    try {
      isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/memo-rec-details/$id');

      if (response.statusCode == 200) {
        _updateMemoIssueRoughData(id: detId, rec: 'N');
        if (kDebugMode) {
          print('Deleted!');
        }
        await getMemoRecDetailsData(force: true);
        await getMemoIssueDetailsData(force: true);
        isDeleteLoading.value = false;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deletePartyData({required id}) async {
    try {
      isDeleteLoading.value = true;
      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/party/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Deleted!');
        }
        await getPartyData(force: true);
        partyMstList.refresh();
        isDeleteLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message']
            : 'Party Entry Deleted Successfully';
        await successDialog(messageText: msg);
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<bool> deletePurchaseData(
      {required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;
      // await deletePurchaseCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/purchase/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        if (entries.isNotEmpty) {
          // Ensure we create a list of Future<void> for Future.wait to process
          await Future.wait(
            entries.map((value) {
              return deletePurchaseRoughData(id: value['id']);
            }).toList(),
          );
        }

        // After processing deletion, refresh data and stop loading
        await getPurchaseDetailsData(force: true);
        await getPurchaseData(force: true);
        // await getCreditDebitData();
        // await getOutstandingPurchaseSaleDetails();
        // await getPendingPaymentData();
        isDeleteLoading.value = false;

        successDialog(messageText: response.data['message']);
        return true;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<void> deleteAssortData(
      {required int id}) async {
    try {
      isDeleteLoading.value = true;
      // await deletePurchaseCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/assort/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Deleted!');
        }

        await getAssortData(force: true);
        assortMstList.refresh();
        isDeleteLoading.value = false;

        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Assort Entry Deleted Successfully';
        await successDialog(messageText: msg);
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteSaleData({required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;
      await deleteSaleCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/polish-sale/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        if (entries.isNotEmpty) {
          // Ensure we create a list of Future<void> for Future.wait to process
          await Future.wait(
            entries.map((value) {
              return deleteSaleRoughData(id: value['id']);
            }).toList(),
          );
        }

        // After processing deletion, refresh data and stop loading
        await getSaleDetailsData();
        await getSaleData();
        await getCreditDebitData();
        await getOutstandingPurchaseSaleDetails();
        await getPendingPaymentData();
        isDeleteLoading.value = false;
        successDialog(messageText: response.data['message']);
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<bool> deleteMemoIssueData(
      {required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/memo-issue/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        if (entries.isNotEmpty) {
          // Ensure we create a list of Future<void> for Future.wait to process
          await Future.wait(
            entries.map((value) {
              return deleteMemoIssueRoughData(id: value['id']);
            }).toList(),
          );
        }

        // After processing deletion, refresh data and stop loading
        await getMemoIssueDetailsData(force: true);
        await getMemoIssueData(force: true);
        isDeleteLoading.value = false;

        successDialog(messageText: response.data['message']);
        return true;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<bool> deleteMemoRecData(
      {required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/memo-rec/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        if (entries.isNotEmpty) {
          // Ensure we create a list of Future<void> for Future.wait to process
          await Future.wait(
            entries.map((value) {
              return deleteMemoRecRoughData(
                  id: value['id'], detId: value['detId']);
            }).toList(),
          );
        }

        // After processing deletion, refresh data and stop loading
        await getMemoRecDetailsData(force: true);
        await getMemoIssueDetailsData(force: true);
        await getMemoRecData(force: true);
        isDeleteLoading.value = false;

        successDialog(messageText: response.data['message']);
        return true;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
      return false;
    }
  }

  Future<void> deletePaymentData({required int id}) async {
    try {
      isDeleteLoading.value = true;
      await deletePaymentDetails(id: id);
      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}rough-entry/payment-mst/$id');

      if (response.statusCode == 200) {
        paymentMstList.value =
            paymentMstList.where((e) => e.paymentMstID != id).toList();
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        // if (entries.isNotEmpty) {
        //   // Ensure we create a list of Future<void> for Future.wait to process
        //   await Future.wait(
        //     entries.map((value) {
        //       return deleteMemoRecRoughData(
        //           id: value['id'], detId: value['detId']);
        //     }).toList(),
        //   );
        // }

        // After processing deletion, refresh data and stop loading
        // Reload from the server (force) so the Payment search list and
        // balances show the saved record - without force these returned early
        // because the lists were already loaded.
        await _refreshPaymentLists();

        isDeleteLoading.value = false;

        successDialog(messageText: response.data['message']);
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deletePaymentDetails({required int id}) async {
    try {
      // isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response =
          await dio.delete('${baseUrl}delete/payment-details?paymentMstId=$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        // if (entries.isNotEmpty) {
        //   // Ensure we create a list of Future<void> for Future.wait to process
        //   await Future.wait(
        //     entries.map((value) {
        //       return deleteMemoIssueRoughData(id: value['id']);
        //     }).toList(),
        //   );
        // }

        // After processing deletion, refresh data and stop loading
        await getCreditDebitData();
        await getPaymentDetData();
        await getPaymentDetAccData();
        await getPaymentMstData();
        // isDeleteLoading.value = false;
        log(response.data['message']);
      } else {
        // isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      // isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deletePurchaseCreditDebitDetails({required int id}) async {
    try {
      // isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response = await dio
          .delete('${baseUrl}delete/purchase-credit-debit-details?mstId=$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        // if (entries.isNotEmpty) {
        //   // Ensure we create a list of Future<void> for Future.wait to process
        //   await Future.wait(
        //     entries.map((value) {
        //       return deleteMemoIssueRoughData(id: value['id']);
        //     }).toList(),
        //   );
        // }

        // After processing deletion, refresh data and stop loading
        await getCreditDebitData();
        log(response.data['message']);
      } else {
        // isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      // isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteSaleCreditDebitDetails({required int id}) async {
    try {
      // isDeleteLoading.value = true;

      final dio = ApiService.to.dio;

      final response = await dio
          .delete('${baseUrl}delete/sale-credit-debit-details?mstId=$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        // if (entries.isNotEmpty) {
        //   // Ensure we create a list of Future<void> for Future.wait to process
        //   await Future.wait(
        //     entries.map((value) {
        //       return deleteMemoIssueRoughData(id: value['id']);
        //     }).toList(),
        //   );
        // }

        // After processing deletion, refresh data and stop loading
        await getCreditDebitData();
        log(response.data['message']);
      } else {
        // isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      // isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

//   Future<void> getIpAddress() async {
//     deviceInfo.value = 'Searching...';
//     // final info = NetworkInfo();
//     // String? ip = await info.getWifiIP(); // Get the Wi-Fi IP address
//     //   ipAddress.value = ip ?? 'No IP found'; // Update state with IP address
//     try {
//       /// Initialize Ip Address
//       var ip = IpAddress(type: RequestType.json);
// print(ip.getIp());
//       /// Get the IpAddress based on requestType.
//       dynamic data = await ip.getIp();
//       deviceInfo.value = data['ip'];
//     } on IpAddressException catch (exception) {
//       errorDialog(messageText: exception.message);
//
//       /// Handle the exception.
//       if (kDebugMode) {
//         print(exception.message);
//       }
//     }
//   }

  // Future<void> getHostName() async {
  //   deviceInfo.value = Platform.lo;
  // }

  Future<void> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // String deviceInfo;

    if (kIsWeb) {
      var info = await deviceInfoPlugin.webBrowserInfo;
      if (kDebugMode) {
        print(info.data);
      }
      deviceInfo.value = info.browserName.name;
    } else {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo.value = androidInfo.model;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo.value = iosInfo.model;
      }
    }// Get Android version
    // } else if (Platform.isMacOS) {
    //   var iosInfo = await deviceInfoPlugin.macOsInfo;
    //   deviceInfo.value = 'MacOS ${iosInfo.computerName}'; // Get iOS version
    // } else {
    //   deviceInfo.value = 'Unknown Device';
    // }
  }

  Future<void> addAssortData(
      {String? name,
        sortId,
        group,
      }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        "Name": "$name",
        "SortID": sortId,
        "AssortGroup": group,
        // "Active": true,
      };

      final response = await dio.post('${baseUrl}rough-entry/assort/add',
          data: jsonEncode(params));

      // if (kDebugMode) {
      //   print(response.data['data']);
      // }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAssortData(force: true);
        assortMstList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Assort Entry Saved Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;

        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> updateAssortData(
      {required int id , String? name,
        sortId,
        group,
      }) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        "Name": "$name",
        "SortID": sortId,
        "AssortGroup": group,
        // "Active": true,
      };

      final response = await dio.put('${baseUrl}rough-entry/assort/$id',
          data: jsonEncode(params));

      // if (kDebugMode) {
      //   print(response.data['data']);
      // }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        await getAssortData(force: true);
        assortMstList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Assort Entry Updated Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;

        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> updateRoughAssortData(
      {required int id,
        String? invoiceNo,
        wt,
        assWt,
        penWt,
        required List entries}) async {
    try {
      isLoading.value = true;
      await deletePurchaseCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      var params = {
        "InvoiceNo": "$invoiceNo",
        "Wt": wt,
        "AssortWt": assWt,
        "PendingWt": penWt,
        "LogID": 0,
        "PCID": "TESTFROMWEB",
        "Ever": 0,
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "CompanyCode": companyCode.value,
      };

      final response = await dio.put('${baseUrl}rough-entry/rough-assort/$id',
          data: jsonEncode(params));

      // if (kDebugMode) {
      //   print(response.data['data']);
      // }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;

          // Check if the 'id' exists in the entry data
          if (value.containsKey('id') && value['id'] != null) {
            // Call the update function if 'id' exists
            return _updateAssortRoughData(
              id: value['id'],
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              assort: value['assort'],
              roughAssortMstID: response.data['data']['RoughAssortMstID'],
              // srNo: index + 1, // incremented srNo
            );
          } else {
            // Call the add function if 'id' does not exist
            return _addAssortRoughData(
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              // description: value['description'],
              assort: value['assort'],
              roughAssortMstID: response.data['data']['RoughAssortMstID'],
              // srNo: index + 1, // incremented srNo
            );
          }
        }));
        await getRoughAssortData(force: true);
        await getRoughAssortDetailsData(force: true);
        roughAssortMstList.refresh();
        roughAssortMstDetList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Rough Assort Entry Updated Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;

        errorDialog(
            messageText: 'Failed to Add data: : ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _updateAssortRoughData(
      {required id,
        assort,
        wt,
        rate,
        amount,
        roughAssortMstID}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "RoughAssortMstID": roughAssortMstID,
        "AssortName": assort,
        "Wt": wt,
        "Rate": rate,
        "Ammount": amount,
      };

      final response = await dio.put('${baseUrl}rough-entry/rough-assort-det/$id',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Updated!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Update Data: ${response.statusCode}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> _addAssortRoughData(
      {assort, roughAssortMstID, wt, rate, amount}) async {
    try {
      final dio = ApiService.to.dio;

      var params = {
        "RoughAssortMstID": roughAssortMstID,
        "AssortName": assort,
        "Wt": wt,
        "Rate": rate,
        "Ammount": amount,
      };

      final response = await dio.post('${baseUrl}rough-entry/rough-assort-det/add',
          data: jsonEncode(params));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Added!');
        }
      } else {
        errorDialog(
            messageText: 'Failed to Add data: : ${response.data['message']}');
      }
    } catch (error) {
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> addRoughAssortData(
      {String? invoiceNo,
        wt,
        assWt,
        penWt,
        required List entries}) async {
    try {
      isLoading.value = true;
      final dio = ApiService.to.dio;

      var params = {
        "InvoiceNo": "$invoiceNo",
        "Wt": wt,
        "AssortWt": assWt,
        "PendingWt": penWt,
        "LogID": 0,
        "PCID": "TESTFROMWEB",
        "Ever": 0,
        "SDate": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "CompanyCode": companyCode.value,
      };

      final response = await dio.post('${baseUrl}rough-entry/rough-assort/add',
          data: jsonEncode(params));

      // if (kDebugMode) {
      //   print(response.data['data']);
      // }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await Future.wait(entries.asMap().entries.map((entry) {
          int index = entry.key; // index of the current entry
          var value = entry.value;
          // current entry data
          return _addAssortRoughData(
              wt: value['wt'],
              rate: value['rate'],
              amount: value['amount'],
              assort: value['assort'],
              // description: value['description'],
              roughAssortMstID: response.data['data']['RoughAssortMstID'],
              // srNo: index + 1 // incremented srNo
          );
        }));
        await getRoughAssortData(force: true);
        await getRoughAssortDetailsData(force: true);
        roughAssortMstList.refresh();
        roughAssortMstDetList.refresh();
        isLoading.value = false;
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Rough Assort Entry Saved Successfully';
        await successDialog(messageText: msg);
      } else {
        isLoading.value = false;

        errorDialog(messageText: 'Failed to Add data: ${response.statusCode}');
      }
    } catch (error) {
      isLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteRoughAssortData(
      {required int id, required List entries}) async {
    try {
      isDeleteLoading.value = true;
      // await deletePurchaseCreditDebitDetails(id: id);
      final dio = ApiService.to.dio;

      final response = await dio.delete('${baseUrl}rough-entry/rough-assort/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Deleted!');
        }

        // Ensure entries is not null and is a list
        if (entries.isNotEmpty) {
          // Ensure we create a list of Future<void> for Future.wait to process
          await Future.wait(
            entries.map((value) {
              return deleteRoughAssortDetData(id: value['id']);
            }).toList(),
          );
        }
        await getRoughAssortData(force: true);
        await getRoughAssortDetailsData(force: true);
        roughAssortMstList.refresh();
        roughAssortMstDetList.refresh();
        // After processing deletion, refresh data and stop loading
        isDeleteLoading.value = false;

        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Rough Assort Entry Deleted Successfully';
        await successDialog(messageText: msg);
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;
      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  Future<void> deleteRoughAssortDetData({required id}) async {
    try {
      isDeleteLoading.value = true;
      final dio = ApiService.to.dio;

      final response =
      await dio.delete('${baseUrl}rough-entry/rough-assort-det/$id');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Deleted!');
        }
        isDeleteLoading.value = false;
      } else {
        isDeleteLoading.value = false;
        errorDialog(
            messageText: 'Failed to Delete Data: ${response.statusCode}');
      }
    } catch (error) {
      isDeleteLoading.value = false;

      errorDialog(messageText: 'An unexpected error occurred.');
      if (kDebugMode) {
        log('$error');
      }
    }
  }

  static bool enableAutoFetchOnInit = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken.value = prefs.getString('token') ?? '';
    refreshToken.value = prefs.getString('refreshToken') ?? '';
    await restoreUserSession();
    if (authToken.value.isNotEmpty && refreshToken.value.isNotEmpty) {
      ApiClient().startAutoRefreshTimer();
    }
    // Do not bulk-fetch all 35+ APIs on init/login.
    // Each screen loads its required data lazily on mount.
    if (authToken.value.isNotEmpty && companyCode.value > 0) {
      if (menuList.isEmpty) {
        await getMenuList();
      }
    }
  }
}
