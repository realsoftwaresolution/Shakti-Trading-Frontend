import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/company/company_datagrid.dart';
import 'package:real_web_rough_entry_system/company/company_model.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CompanyFormScreen extends StatefulWidget {
  final bool showHeader;

  const CompanyFormScreen({super.key, this.showHeader = false});

  @override
  CompanyFormScreenState createState() => CompanyFormScreenState();
}

class CompanyFormScreenState extends State<CompanyFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DefaultController defaultController = Get.find<DefaultController>();
  final DataGridController _dataGridController = DataGridController();

  late CompanyDataGridSource _companySource;
  Worker? _listWorker;

  // Controllers - Basic Information & Contact
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _webController = TextEditingController();

  // Controllers - Tax & Legal Identification
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _cstController = TextEditingController();
  final TextEditingController _tinController = TextEditingController();

  // Controllers - Banking & Financial Details
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _bankAddController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accNoController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();
  final TextEditingController _finalAmtController = TextEditingController();
  final TextEditingController _memoInvoicePrefixController = TextEditingController();
  final TextEditingController _memoInvoiceSuffixController = TextEditingController();
  final TextEditingController _invoicePrefixController = TextEditingController();
  final TextEditingController _invoiceSuffixController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _sortIdController = TextEditingController();

  // Search Filter Controller
  final TextEditingController _searchFilterController = TextEditingController();

  // Focus Nodes - Basic Info
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _faxFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _webFocus = FocusNode();

  // Focus Nodes - Tax & Legal
  final FocusNode _gstFocus = FocusNode();
  final FocusNode _cstFocus = FocusNode();
  final FocusNode _tinFocus = FocusNode();

  // Focus Nodes - Banking & Financial
  final FocusNode _bankFocus = FocusNode();
  final FocusNode _branchFocus = FocusNode();
  final FocusNode _accNoFocus = FocusNode();
  final FocusNode _ifscFocus = FocusNode();
  final FocusNode _bankAddFocus = FocusNode();
  final FocusNode _insuranceFocus = FocusNode();
  final FocusNode _finalAmtFocus = FocusNode();
  final FocusNode _memoInvoicePrefixFocus = FocusNode();
  final FocusNode _memoInvoiceSuffixFocus = FocusNode();
  final FocusNode _invoicePrefixFocus = FocusNode();
  final FocusNode _invoiceSuffixFocus = FocusNode();
  final FocusNode _fromDateFocus = FocusNode();
  final FocusNode _toDateFocus = FocusNode();
  final FocusNode _sortIdFocus = FocusNode();

  // State
  final RxInt _selectedCompanyCode = 0.obs;
  final RxInt _selectedCompanyMstID = 0.obs;
  final RxBool _isActive = true.obs;
  bool _isEnabled = false;
  bool _isFromEdit = false;

  final RxList<CompanyMstModel> companyGridList = <CompanyMstModel>[].obs;

  @override
  void initState() {
    super.initState();
    companyGridList.value = List<CompanyMstModel>.from(defaultController.companyModelList);
    _companySource = CompanyDataGridSource(companyGridList);

    _listWorker = ever(defaultController.companyModelList, (list) {
      if (mounted) {
        _filterCompanies(_searchFilterController.text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getCompanyData();
    });

    // Auto capitalize GST
    _gstController.addListener(() {
      final text = _gstController.text.toUpperCase();
      if (_gstController.text != text) {
        _gstController.value = _gstController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    // Auto capitalize IFSC
    _ifscController.addListener(() {
      final text = _ifscController.text.toUpperCase();
      if (_ifscController.text != text) {
        _ifscController.value = _ifscController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _listWorker?.dispose();

    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _webController.dispose();
    _gstController.dispose();
    _cstController.dispose();
    _tinController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _bankAddController.dispose();
    _ifscController.dispose();
    _accNoController.dispose();
    _insuranceController.dispose();
    _finalAmtController.dispose();
    _memoInvoicePrefixController.dispose();
    _memoInvoiceSuffixController.dispose();
    _invoicePrefixController.dispose();
    _invoiceSuffixController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _sortIdController.dispose();
    _searchFilterController.dispose();

    _nameFocus.dispose();
    _addressFocus.dispose();
    _mobileFocus.dispose();
    _phoneFocus.dispose();
    _faxFocus.dispose();
    _emailFocus.dispose();
    _webFocus.dispose();
    _gstFocus.dispose();
    _cstFocus.dispose();
    _tinFocus.dispose();
    _bankFocus.dispose();
    _branchFocus.dispose();
    _accNoFocus.dispose();
    _ifscFocus.dispose();
    _bankAddFocus.dispose();
    _insuranceFocus.dispose();
    _finalAmtFocus.dispose();
    _memoInvoicePrefixFocus.dispose();
    _memoInvoiceSuffixFocus.dispose();
    _invoicePrefixFocus.dispose();
    _invoiceSuffixFocus.dispose();
    _fromDateFocus.dispose();
    _toDateFocus.dispose();
    _sortIdFocus.dispose();

    super.dispose();
  }

  void _filterCompanies(String query) {
    if (query.trim().isEmpty) {
      companyGridList.value = List<CompanyMstModel>.from(defaultController.companyModelList);
    } else {
      final q = query.toLowerCase().trim();
      companyGridList.value = defaultController.companyModelList.where((c) {
        final name = (c.companyName ?? '').toLowerCase();
        final code = (c.companyCode?.toString() ?? c.companyMstID?.toString() ?? '').toLowerCase();
        final mobile = (c.mobileNo ?? '').toLowerCase();
        final email = (c.email ?? '').toLowerCase();
        final gst = (c.gstNo ?? '').toLowerCase();
        final address = (c.address ?? '').toLowerCase();
        final bank = (c.bankName ?? '').toLowerCase();
        return name.contains(q) ||
            code.contains(q) ||
            mobile.contains(q) ||
            email.contains(q) ||
            gst.contains(q) ||
            address.contains(q) ||
            bank.contains(q);
      }).toList();
    }
    _companySource.updateDataSource(companyGridList);
  }

  Future<void> _enableFields({bool needFocus = true}) async {
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      _selectedCompanyCode.value = 0;
      _selectedCompanyMstID.value = 0;
      _codeController.clear();
      _nameController.clear();
      _addressController.clear();
      _mobileController.clear();
      _phoneController.clear();
      _faxController.clear();
      _emailController.clear();
      _webController.clear();
      _gstController.clear();
      _cstController.clear();
      _tinController.clear();
      _bankController.clear();
      _branchController.clear();
      _bankAddController.clear();
      _ifscController.clear();
      _accNoController.clear();
      _insuranceController.clear();
      _finalAmtController.text = 'Standard';
      _memoInvoicePrefixController.clear();
      _memoInvoiceSuffixController.clear();
      _invoicePrefixController.clear();
      _invoiceSuffixController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _sortIdController.clear();
      _isActive.value = true;
    });

    try {
      final next = await defaultController.getNextCompanyCode();
      if (next != null && mounted) {
        final dynamic nextCode = next['nextCompanyCode'] ?? next['CompanyCode'] ?? next['code'];
        final dynamic nextSort = next['nextSortID'] ?? next['SortID'] ?? next['sortId'];
        if (nextCode != null) {
          _codeController.text = nextCode.toString();
        }
        if (nextSort != null) {
          _sortIdController.text = nextSort.toString();
        }
      }
    } catch (_) {}

    if (_codeController.text.isEmpty && mounted) {
      if (defaultController.companyModelList.isEmpty) {
        _codeController.text = '1';
        _sortIdController.text = '1';
      } else {
        final lastCode = defaultController.companyModelList
            .map((e) => e.companyCode ?? e.companyMstID ?? 0)
            .fold(0, (max, v) => v > max ? v : max);
        _codeController.text = (lastCode + 1).toString();
        _sortIdController.text = (lastCode + 1).toString();
      }
    }

    if (needFocus && mounted) {
      Future.delayed(const Duration(milliseconds: 60), () {
        _nameFocus.requestFocus();
      });
    }
  }

  void _clearFormFields() {
    _codeController.clear();
    _nameController.clear();
    _addressController.clear();
    _mobileController.clear();
    _phoneController.clear();
    _faxController.clear();
    _emailController.clear();
    _webController.clear();
    _gstController.clear();
    _cstController.clear();
    _tinController.clear();
    _bankController.clear();
    _branchController.clear();
    _bankAddController.clear();
    _ifscController.clear();
    _accNoController.clear();
    _insuranceController.clear();
    _finalAmtController.clear();
    _memoInvoicePrefixController.clear();
    _memoInvoiceSuffixController.clear();
    _invoicePrefixController.clear();
    _invoiceSuffixController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _sortIdController.clear();

    setState(() {
      _isEnabled = false;
      _isFromEdit = false;
      _selectedCompanyCode.value = 0;
      _selectedCompanyMstID.value = 0;
      _isActive.value = true;
    });
    _dataGridController.selectedIndex = -1;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    if (!_isEnabled) return;
    DateTime initial = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        if (controller.text.contains('-')) {
          initial = DateTime.parse(controller.text);
        } else if (controller.text.contains('/')) {
          final parts = controller.text.split('/');
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              initial = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else {
              initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
        }
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_isEnabled) return;

    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      infoDialog(messageText: 'Please enter Company Name');
      _nameFocus.requestFocus();
      return;
    }

    final int? sortId = int.tryParse(_sortIdController.text.trim());

    if (_isFromEdit) {
      final dynamic targetId = _selectedCompanyMstID.value != 0
          ? _selectedCompanyMstID.value
          : _selectedCompanyCode.value;

      if (targetId == 0 || targetId == null) {
        errorDialog(messageText: 'Unable to identify Company record to update');
        return;
      }

      await defaultController.updateCompanyData(
        id: targetId,
        name: name,
        address: _addressController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        phone: _phoneController.text.trim(),
        fax: _faxController.text.trim(),
        email: _emailController.text.trim(),
        web: _webController.text.trim(),
        gstNo: _gstController.text.trim(),
        cstNo: _cstController.text.trim(),
        tinNo: _tinController.text.trim(),
        bank: _bankController.text.trim(),
        branch: _branchController.text.trim(),
        bankAdd: _bankAddController.text.trim(),
        ifsc: _ifscController.text.trim(),
        accNo: _accNoController.text.trim(),
        insurance: _insuranceController.text.trim(),
        finalAmt: _finalAmtController.text.trim(),
        memoInvoicePrefix: _memoInvoicePrefixController.text.trim(),
        memoInvoiceSuffix: _memoInvoiceSuffixController.text.trim(),
        invoicePrefix: _invoicePrefixController.text.trim(),
        invoiceSuffix: _invoiceSuffixController.text.trim(),
        fromDate: _fromDateController.text.trim(),
        toDate: _toDateController.text.trim(),
        sortId: sortId,
        active: _isActive.value,
      );
    } else {
      await defaultController.addCompanyData(
        name: name,
        address: _addressController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        phone: _phoneController.text.trim(),
        fax: _faxController.text.trim(),
        email: _emailController.text.trim(),
        web: _webController.text.trim(),
        gstNo: _gstController.text.trim(),
        cstNo: _cstController.text.trim(),
        tinNo: _tinController.text.trim(),
        bank: _bankController.text.trim(),
        branch: _branchController.text.trim(),
        bankAdd: _bankAddController.text.trim(),
        ifsc: _ifscController.text.trim(),
        accNo: _accNoController.text.trim(),
        insurance: _insuranceController.text.trim(),
        finalAmt: _finalAmtController.text.trim(),
        memoInvoicePrefix: _memoInvoicePrefixController.text.trim(),
        memoInvoiceSuffix: _memoInvoiceSuffixController.text.trim(),
        invoicePrefix: _invoicePrefixController.text.trim(),
        invoiceSuffix: _invoiceSuffixController.text.trim(),
        fromDate: _fromDateController.text.trim(),
        toDate: _toDateController.text.trim(),
        sortId: sortId,
        active: _isActive.value,
      );
    }

    await defaultController.getCompanyData();
    _clearFormFields();
    _filterCompanies(_searchFilterController.text);
  }

  Future<void> _handleDelete() async {
    if (!_isFromEdit) return;

    final dynamic targetId = _selectedCompanyMstID.value != 0
        ? _selectedCompanyMstID.value
        : _selectedCompanyCode.value;

    if (targetId == 0 || targetId == null) return;

    await defaultController.deleteCompanyData(id: targetId);
    await defaultController.getCompanyData();
    _clearFormFields();
    _filterCompanies(_searchFilterController.text);
  }

  void _loadCompanyFromRow(DataGridRow row) {
    final item = _companySource.findModelFromRow(row);
    if (item != null) {
      _loadFromModel(item);
      return;
    }

    final dynamic cellVal = row.getCells()[0].value;
    final companyEntry = defaultController.companyModelList.firstWhere(
      (entry) => entry.companyCode == cellVal || entry.companyMstID == cellVal,
      orElse: () => CompanyMstModel(),
    );

    final id = companyEntry.companyMstID ?? companyEntry.companyCode;
    if (id != null && id != 0) {
      _loadFromModel(companyEntry);
    }
  }

  void _loadFromModel(CompanyMstModel item) {
    final int code = item.companyCode ?? item.companyMstID ?? 0;
    _selectedCompanyCode.value = item.companyCode ?? code;
    _selectedCompanyMstID.value = item.companyMstID ?? code;

    _codeController.text = code != 0 ? code.toString() : '';
    _nameController.text = item.companyName ?? '';
    _sortIdController.text = item.sortID != null ? item.sortID.toString() : '';
    _addressController.text = item.address ?? '';
    _mobileController.text = item.mobileNo ?? '';
    _phoneController.text = item.phone ?? '';
    _faxController.text = item.fax ?? '';
    _emailController.text = item.email ?? '';
    _webController.text = item.webSite ?? '';
    _gstController.text = item.gstNo ?? '';
    _cstController.text = item.cstNo ?? '';
    _tinController.text = item.tinNo ?? '';
    _bankController.text = item.bankName ?? '';
    _branchController.text = item.branchName ?? '';
    _bankAddController.text = item.bankAddress ?? '';
    _ifscController.text = item.ifscCode ?? '';
    _accNoController.text = item.bankAcNo ?? '';
    _insuranceController.text = item.insurance ?? '';
    _finalAmtController.text = item.invCode ?? '';
    _memoInvoicePrefixController.text = item.memoInvoicePrefix ?? '';
    _memoInvoiceSuffixController.text = item.memoInvoiceSuffix ?? '';
    _invoicePrefixController.text = item.invoicePrefix ?? '';
    _invoiceSuffixController.text = item.invoiceSuffix ?? '';
    _fromDateController.text = item.fromDate ?? '';
    _toDateController.text = item.toDate ?? '';
    _isActive.value = item.active ?? true;

    setState(() {
      _isFromEdit = true;
      _isEnabled = true;
    });

    _nameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppKeyboardShortcutHandler(
        onAdd: (!_isEnabled && !_isFromEdit) ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: (_isEnabled || _isFromEdit) ? _clearFormFields : null,
        onExit: () => tabController.closeCurrentTab(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader) const Header(title: 'Company Master'),
              Expanded(
                child: _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== MAIN FORM VIEW ====================
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 10.0 : 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 1: Basic Information & Contact
            _buildBasicInfoCard(),

            const SizedBox(height: 16),

            // Card 2: Tax & Legal Identification
            _buildTaxIdentificationCard(),

            const SizedBox(height: 16),

            // Card 3: Banking Details & Financial Period
            _buildBankingFinancialCard(),

            const SizedBox(height: 16),

            // Action Bar
            _buildActionBar(),

            const SizedBox(height: 16),

            // Embedded Directory Card
            _buildDirectoryCard(),
          ],
        ),
      ),
    );
  }

  // ==================== CARD 1: BASIC INFORMATION ====================
  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_isFromEdit) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final codeWidget = SizedBox(
                  width: constraints.maxWidth >= 1000 ? 100 : (constraints.maxWidth >= 650 ? 90 : 85),
                  child: AppTextField(
                    label: 'Code',
                    controller: _codeController,
                    enabled: false,
                    hintText: 'Auto',
                  ),
                );

                final nameWidget = AppTextField(
                  label: 'Company Name *',
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocusNode: _addressFocus,
                  enabled: _isEnabled,
                  hintText: 'Enter Company Name',
                );

                final activeWidget = Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _isActive.value,
                        activeColor: AppColors.primary,
                        onChanged: _isEnabled
                            ? (val) {
                                setState(() {
                                  _isActive.value = val ?? true;
                                });
                              }
                            : null,
                      ),
                      const Text(
                        'Active',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );

                final addressWidget = AppTextField(
                  label: 'Address',
                  controller: _addressController,
                  focusNode: _addressFocus,
                  nextFocusNode: _mobileFocus,
                  enabled: _isEnabled,
                  hintText: 'Street / Building Address',
                );

                final mobileWidget = AppTextField(
                  label: 'Mobile No',
                  controller: _mobileController,
                  focusNode: _mobileFocus,
                  nextFocusNode: _phoneFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.phone,
                  hintText: 'Mobile Number',
                );

                final phoneWidget = AppTextField(
                  label: 'Phone No',
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocusNode: _faxFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.phone,
                  hintText: 'Telephone',
                );

                final faxWidget = AppTextField(
                  label: 'Fax',
                  controller: _faxController,
                  focusNode: _faxFocus,
                  nextFocusNode: _emailFocus,
                  enabled: _isEnabled,
                  hintText: 'Fax Number',
                );

                final emailWidget = AppTextField(
                  label: 'Email ID',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocusNode: _webFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'example@company.com',
                );

                final websiteWidget = AppTextField(
                  label: 'Website',
                  controller: _webController,
                  focusNode: _webFocus,
                  nextFocusNode: _gstFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.url,
                  hintText: 'www.example.com',
                );

                if (constraints.maxWidth >= 1000) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          codeWidget,
                          const SizedBox(width: 12),
                          Expanded(flex: 5, child: nameWidget),
                          const SizedBox(width: 12),
                          activeWidget,
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: addressWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: mobileWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: phoneWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: faxWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: emailWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: websiteWidget),
                        ],
                      ),
                    ],
                  );
                } else if (constraints.maxWidth >= 650) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          codeWidget,
                          const SizedBox(width: 12),
                          Expanded(child: nameWidget),
                          const SizedBox(width: 12),
                          activeWidget,
                        ],
                      ),
                      const SizedBox(height: 12),
                      addressWidget,
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: mobileWidget),
                          const SizedBox(width: 12),
                          Expanded(child: phoneWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: faxWidget),
                          const SizedBox(width: 12),
                          Expanded(child: emailWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      websiteWidget,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          codeWidget,
                          const SizedBox(width: 10),
                          Expanded(child: nameWidget),
                        ],
                      ),
                      const SizedBox(height: 8),
                      activeWidget,
                      const SizedBox(height: 12),
                      addressWidget,
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: mobileWidget),
                          const SizedBox(width: 10),
                          Expanded(child: phoneWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: faxWidget),
                          const SizedBox(width: 10),
                          Expanded(child: emailWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      websiteWidget,
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

  // ==================== CARD 2: TAX & LEGAL IDENTIFICATION ====================
  Widget _buildTaxIdentificationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Tax & Legal Identification',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final gstWidget = AppTextField(
                  label: 'GST No',
                  controller: _gstController,
                  focusNode: _gstFocus,
                  nextFocusNode: _cstFocus,
                  enabled: _isEnabled,
                  hintText: '24AAAAA0000A1Z5',
                );

                final cstWidget = AppTextField(
                  label: 'CST No',
                  controller: _cstController,
                  focusNode: _cstFocus,
                  nextFocusNode: _tinFocus,
                  enabled: _isEnabled,
                  hintText: 'CST12345',
                );

                final tinWidget = AppTextField(
                  label: 'TIN No',
                  controller: _tinController,
                  focusNode: _tinFocus,
                  nextFocusNode: _memoInvoicePrefixFocus,
                  enabled: _isEnabled,
                  hintText: 'TIN12345',
                );

                if (constraints.maxWidth >= 950) {
                  return Row(
                    children: [
                      Expanded(child: gstWidget),
                      const SizedBox(width: 12),
                      Expanded(child: cstWidget),
                      const SizedBox(width: 12),
                      Expanded(child: tinWidget),
                    ],
                  );
                } else if (constraints.maxWidth >= 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: gstWidget),
                          const SizedBox(width: 12),
                          Expanded(child: cstWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      tinWidget,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      gstWidget,
                      const SizedBox(height: 12),
                      cstWidget,
                      const SizedBox(height: 12),
                      tinWidget,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildMemoNoFormatRow(),
            const SizedBox(height: 12),
            _buildInvoiceNoFormatRow(),
          ],
        ),
      ),
    );
  }

  /// Memo Issue No format: MemoInvoicePrefix + running no (0001 ...) + MemoInvoiceSuffix.
  /// Changing prefix/suffix restarts numbering from 0001.
  Widget _buildMemoNoFormatRow() => _buildNoFormatRow(
        prefixLabel: 'Memo Prefix',
        suffixLabel: 'Memo Suffix',
        previewLabel: 'Memo No preview: ',
        prefixController: _memoInvoicePrefixController,
        suffixController: _memoInvoiceSuffixController,
        prefixFocus: _memoInvoicePrefixFocus,
        suffixFocus: _memoInvoiceSuffixFocus,
        nextFocus: _invoicePrefixFocus,
        prefixHint: 'ML/',
        suffixHint: '/AK2000',
      );

  /// Polish Sale Invoice No format: InvoicePrefix + running no (0001 ...) + InvoiceSuffix.
  Widget _buildInvoiceNoFormatRow() => _buildNoFormatRow(
        prefixLabel: 'Invoice Prefix',
        suffixLabel: 'Invoice Suffix',
        previewLabel: 'Invoice No preview: ',
        prefixController: _invoicePrefixController,
        suffixController: _invoiceSuffixController,
        prefixFocus: _invoicePrefixFocus,
        suffixFocus: _invoiceSuffixFocus,
        nextFocus: _bankFocus,
        prefixHint: 'INV/',
        suffixHint: '/26-27',
      );

  /// Prefix + Suffix fields with a live "0001" preview.
  Widget _buildNoFormatRow({
    required String prefixLabel,
    required String suffixLabel,
    required String previewLabel,
    required TextEditingController prefixController,
    required TextEditingController suffixController,
    required FocusNode prefixFocus,
    required FocusNode suffixFocus,
    required FocusNode nextFocus,
    required String prefixHint,
    required String suffixHint,
  }) {
    final prefixWidget = AppTextField(
      label: prefixLabel,
      controller: prefixController,
      focusNode: prefixFocus,
      nextFocusNode: suffixFocus,
      enabled: _isEnabled,
      hintText: prefixHint,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
    );

    final suffixWidget = AppTextField(
      label: suffixLabel,
      controller: suffixController,
      focusNode: suffixFocus,
      nextFocusNode: nextFocus,
      enabled: _isEnabled,
      hintText: suffixHint,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
    );

    final preview = AnimatedBuilder(
      animation: Listenable.merge([prefixController, suffixController]),
      builder: (context, _) {
        final memoNo =
            '${prefixController.text.trim()}0001${suffixController.text.trim()}';
        return Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.isDark ? AppColors.borderLight : AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(previewLabel,
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              Flexible(
                child: Text(
                  memoNo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: prefixWidget),
              const SizedBox(width: 12),
              Expanded(child: suffixWidget),
              const SizedBox(width: 12),
              Expanded(child: preview),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            prefixWidget,
            const SizedBox(height: 12),
            suffixWidget,
            const SizedBox(height: 12),
            preview,
          ],
        );
      },
    );
  }

  // ==================== CARD 3: BANKING DETAILS & FINANCIAL PERIOD ====================
  Widget _buildBankingFinancialCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Banking Details & Financial Period',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bankWidget = AppTextField(
                  label: 'Bank Name',
                  controller: _bankController,
                  focusNode: _bankFocus,
                  nextFocusNode: _branchFocus,
                  enabled: _isEnabled,
                  hintText: 'Bank Name',
                );

                final branchWidget = AppTextField(
                  label: 'Branch Name',
                  controller: _branchController,
                  focusNode: _branchFocus,
                  nextFocusNode: _accNoFocus,
                  enabled: _isEnabled,
                  hintText: 'Branch',
                );

                final accountNoWidget = AppTextField(
                  label: 'Account No',
                  controller: _accNoController,
                  focusNode: _accNoFocus,
                  nextFocusNode: _ifscFocus,
                  enabled: _isEnabled,
                  hintText: 'A/C Number',
                );

                final ifscWidget = AppTextField(
                  label: 'IFSC Code',
                  controller: _ifscController,
                  focusNode: _ifscFocus,
                  nextFocusNode: _bankAddFocus,
                  enabled: _isEnabled,
                  hintText: 'IFSC Code',
                );

                final bankAddressWidget = AppTextField(
                  label: 'Bank Address',
                  controller: _bankAddController,
                  focusNode: _bankAddFocus,
                  nextFocusNode: _insuranceFocus,
                  enabled: _isEnabled,
                  hintText: 'Bank Branch Address',
                );

                final insuranceWidget = AppTextField(
                  label: 'Insurance',
                  controller: _insuranceController,
                  focusNode: _insuranceFocus,
                  nextFocusNode: _finalAmtFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.number,
                  hintText: '100000',
                );

                final finalAmtWidget = AppTextField(
                  label: 'Final Amt / Inv Code',
                  controller: _finalAmtController,
                  focusNode: _finalAmtFocus,
                  nextFocusNode: _fromDateFocus,
                  enabled: _isEnabled,
                  hintText: 'Standard',
                );

                final fromDateWidget = AppTextField(
                  label: 'From Date',
                  controller: _fromDateController,
                  focusNode: _fromDateFocus,
                  nextFocusNode: _toDateFocus,
                  enabled: _isEnabled,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    onPressed: _isEnabled ? () => _selectDate(context, _fromDateController) : null,
                  ),
                  onTap: _isEnabled ? () => _selectDate(context, _fromDateController) : null,
                );

                final toDateWidget = AppTextField(
                  label: 'To Date',
                  controller: _toDateController,
                  focusNode: _toDateFocus,
                  nextFocusNode: _sortIdFocus,
                  enabled: _isEnabled,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    onPressed: _isEnabled ? () => _selectDate(context, _toDateController) : null,
                  ),
                  onTap: _isEnabled ? () => _selectDate(context, _toDateController) : null,
                );

                final sortIdWidget = AppTextField(
                  label: 'Sort ID',
                  controller: _sortIdController,
                  focusNode: _sortIdFocus,
                  enabled: _isEnabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: '1',
                );

                if (constraints.maxWidth >= 1050) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 2, child: bankWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: branchWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: accountNoWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: ifscWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: bankAddressWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(flex: 2, child: insuranceWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: finalAmtWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: fromDateWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: toDateWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: sortIdWidget),
                        ],
                      ),
                    ],
                  );
                } else if (constraints.maxWidth >= 650) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: bankWidget),
                          const SizedBox(width: 12),
                          Expanded(child: branchWidget),
                          const SizedBox(width: 12),
                          Expanded(child: accountNoWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(flex: 1, child: ifscWidget),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: bankAddressWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: insuranceWidget),
                          const SizedBox(width: 12),
                          Expanded(child: finalAmtWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: fromDateWidget),
                          const SizedBox(width: 12),
                          Expanded(child: toDateWidget),
                          const SizedBox(width: 12),
                          SizedBox(width: 120, child: sortIdWidget),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bankWidget,
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: branchWidget),
                          const SizedBox(width: 10),
                          Expanded(child: accountNoWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ifscWidget,
                      const SizedBox(height: 12),
                      bankAddressWidget,
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: insuranceWidget),
                          const SizedBox(width: 10),
                          Expanded(child: finalAmtWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: fromDateWidget),
                          const SizedBox(width: 10),
                          Expanded(child: toDateWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      sortIdWidget,
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

  // ==================== BOTTOM ACTION BAR ====================
  Widget _buildActionBar() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 8.0 : 16.0,
          vertical: 12.0,
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Add Button
            AppButton(
              text: 'Add',
              icon: Icons.add_rounded,
              onPressed: (!_isEnabled && !_isFromEdit) ? () => _enableFields() : null,
            ),

            // Save / Update Button
            Obx(
              () => AppButton(
                text: _isFromEdit ? 'Update' : 'Save',
                icon: Icons.save_rounded,
                isLoading: defaultController.isLoading.value,
                onPressed: _isEnabled ? _handleSave : null,
              ),
            ),

            // Delete Button
            Obx(
              () => AppButton(
                text: 'Delete',
                icon: Icons.delete_outline_rounded,
                variant: AppButtonVariant.danger,
                isLoading: defaultController.isDeleteLoading.value,
                onPressed: (_isEnabled && _isFromEdit) ? _handleDelete : null,
              ),
            ),

            // Cancel Button
            AppButton(
              text: 'Cancel',
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: (_isEnabled || _isFromEdit) ? _clearFormFields : null,
            ),

            // Exit Button
            AppButton(
              text: 'Exit',
              icon: Icons.exit_to_app_rounded,
              variant: AppButtonVariant.outline,
              onPressed: () => tabController.closeCurrentTab(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMBEDDED DIRECTORY CARD ====================
  Widget _buildDirectoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 550;
                final titleWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        'Company Directory (${companyGridList.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                );

                final filterWidget = SizedBox(
                  width: isNarrow ? double.infinity : 260,
                  child: AppTextField(
                    label: 'Quick Filter',
                    controller: _searchFilterController,
                    hintText: 'Filter name, code, mobile...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    onChanged: _filterCompanies,
                  ),
                );

                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titleWidget,
                          const SizedBox(height: 10),
                          filterWidget,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          titleWidget,
                          filterWidget,
                        ],
                      );
              },
            ),
            const Divider(height: 20),
            SizedBox(
              height: 340,
              child: _buildDataGridWidget(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DATAGRID COMPONENT ====================
  Widget _buildDataGridWidget() {
    return AppDataGrid(
      controller: _dataGridController,
      source: _companySource,
      allowSorting: true,
      allowMultiColumnSorting: true,
      showSortNumbers: true,
      allowFiltering: true,
      allowColumnsResizing: true,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'Code',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Name',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Mobile',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Email',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'GST No',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text('GST No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Bank',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text('Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Sort ID',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Sort ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        GridColumn(
          columnName: 'Active',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
      rowHeight: 30,
      headerRowHeight: 36,
      selectionMode: SelectionMode.single,
      onSelectionChanged: (addedRows, _) {
        if (addedRows.isNotEmpty) {
          _loadCompanyFromRow(addedRows.first);
        }
      },
      columnWidthMode: ColumnWidthMode.auto,
      frozenColumnsCount: 1,
    );
  }
}
