import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/components/app_button.dart';
import 'package:real_web_rough_entry_system/common/components/app_data_grid.dart';
import 'package:real_web_rough_entry_system/common/components/app_dropdown.dart';
import 'package:real_web_rough_entry_system/common/components/app_shortcuts.dart';
import 'package:real_web_rough_entry_system/common/components/app_text_field.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/header.dart';
import 'package:real_web_rough_entry_system/party/party_datagrid.dart';
import 'package:real_web_rough_entry_system/party/party_model.dart';
import 'package:real_web_rough_entry_system/responsive.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PartyForm extends StatefulWidget {
  final bool showHeader;

  const PartyForm({super.key, this.showHeader = false});

  @override
  PartyFormState createState() => PartyFormState();
}

class PartyFormState extends State<PartyForm> {
  /// Add / Edit / Delete rights of this screen (from the user's menu rights)
  ScreenRights get _rights => defaultController.screenRights(const [
        'frmpartyform',
        'party',
      ]);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DefaultController defaultController = Get.find<DefaultController>();
  final DataGridController _dataGridController = DataGridController();

  // Controllers - Basic Info
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Controllers - Contact & Communication
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();

  // Controllers - Tax & Legal
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _cgstController = TextEditingController();
  final TextEditingController _sgstController = TextEditingController();
  final TextEditingController _igstController = TextEditingController();

  // Controllers - Banking & Accounts
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _bankAddressController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _sortIdController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _creditControllerDollor = TextEditingController();
  final TextEditingController _debitController = TextEditingController();
  final TextEditingController _debitControllerDollor = TextEditingController();

  // Search filter controller
  final TextEditingController _searchFilterController = TextEditingController();

  // Focus Nodes
  final FocusNode _typeFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _contactPersonFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _websiteFocus = FocusNode();
  final FocusNode _panFocus = FocusNode();
  final FocusNode _aadharFocus = FocusNode();
  final FocusNode _cgstFocus = FocusNode();
  final FocusNode _sgstFocus = FocusNode();
  final FocusNode _igstFocus = FocusNode();
  final FocusNode _faxFocus = FocusNode();
  final FocusNode _bankFocus = FocusNode();
  final FocusNode _branchFocus = FocusNode();
  final FocusNode _bankAddressFocus = FocusNode();
  final FocusNode _ifscFocus = FocusNode();
  final FocusNode _accountNoFocus = FocusNode();
  final FocusNode _creditFocus = FocusNode();
  final FocusNode _creditDollarFocus = FocusNode();
  final FocusNode _debitFocus = FocusNode();
  final FocusNode _debitDollarFocus = FocusNode();
  final FocusNode _sortIdFocus = FocusNode();

  // State
  final RxString _selectedType = ''.obs;
  final RxInt selectedPartyMstID = 0.obs;
  bool _isActive = true;
  bool _isEnabled = false;
  bool _isFromEdit = false;
  bool _isSearchMode = false;

  RxList<PartyMstModel> partyGridList = <PartyMstModel>[].obs;
  Worker? _listWorker;

  @override
  void initState() {
    super.initState();
    partyGridList.value = List.of(defaultController.partyMstList);

    _listWorker = ever(defaultController.partyMstList, (list) {
      if (mounted) {
        partyGridList.value = List.of(list);
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      defaultController.getPartyData(force: true);
      defaultController.getPartyTypeData(force: true);
    });

    // Auto capitalize PAN
    _panController.addListener(() {
      final text = _panController.text.toUpperCase();
      if (_panController.text != text) {
        _panController.value = _panController.value.copyWith(
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
    _contactPersonController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _mobileNoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _faxController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _bankAddressController.dispose();
    _ifscController.dispose();
    _accountNoController.dispose();
    _sortIdController.dispose();
    _creditController.dispose();
    _creditControllerDollor.dispose();
    _debitController.dispose();
    _debitControllerDollor.dispose();
    _searchFilterController.dispose();

    _typeFocus.dispose();
    _nameFocus.dispose();
    _contactPersonFocus.dispose();
    _locationFocus.dispose();
    _addressFocus.dispose();
    _mobileFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _websiteFocus.dispose();
    _panFocus.dispose();
    _aadharFocus.dispose();
    _cgstFocus.dispose();
    _sgstFocus.dispose();
    _igstFocus.dispose();
    _faxFocus.dispose();
    _bankFocus.dispose();
    _branchFocus.dispose();
    _bankAddressFocus.dispose();
    _ifscFocus.dispose();
    _accountNoFocus.dispose();
    _creditFocus.dispose();
    _creditDollarFocus.dispose();
    _debitFocus.dispose();
    _debitDollarFocus.dispose();
    _sortIdFocus.dispose();

    super.dispose();
  }

  void _filterParties(String query) {
    if (query.trim().isEmpty) {
      partyGridList.value = List.of(defaultController.partyMstList);
    } else {
      final q = query.toLowerCase().trim();
      partyGridList.value = defaultController.partyMstList.where((p) {
        final name = (p.partyName ?? '').toLowerCase();
        final code = (p.partyCode?.toString() ?? '').toLowerCase();
        final contact = (p.contactPerson ?? '').toLowerCase();
        final city = (p.city ?? '').toLowerCase();
        return name.contains(q) || code.contains(q) || contact.contains(q) || city.contains(q);
      }).toList();
    }
  }

  void _enableFields({bool needFocus = true}) {
    if (!_rights.canAdd) {
      infoDialog(messageText: 'You do not have permission to add a new entry here.');
      return;
    }
    setState(() {
      _isEnabled = true;
      _isFromEdit = false;
      if (defaultController.partyMstList.isEmpty) {
        _codeController.text = '1';
      } else {
        _codeController.text = (defaultController.partyMstList.reversed.last.partyCode! + 1).toString();
      }
    });

    if (needFocus) {
      Future.delayed(const Duration(milliseconds: 60), () {
        _typeFocus.requestFocus();
      });
    }
  }

  void _clearFormFields() {
    _codeController.clear();
    _nameController.clear();
    _contactPersonController.clear();
    _locationController.clear();
    _addressController.clear();
    _mobileNoController.clear();
    _phoneController.clear();
    _emailController.clear();
    _websiteController.clear();
    _faxController.clear();
    _panController.clear();
    _aadharController.clear();
    _cgstController.clear();
    _sgstController.clear();
    _igstController.clear();
    _bankController.clear();
    _branchController.clear();
    _bankAddressController.clear();
    _ifscController.clear();
    _accountNoController.clear();
    _sortIdController.clear();
    _creditController.clear();
    _creditControllerDollor.clear();
    _debitController.clear();
    _debitControllerDollor.clear();

    setState(() {
      _selectedType.value = '';
      _isActive = true;
      _isEnabled = false;
      _isFromEdit = false;
      selectedPartyMstID.value = 0;
    });
  }

  Future<void> _handleSave() async {
    if (!_rights.canSave(_isFromEdit)) {
      infoDialog(messageText: 'You do not have permission to save this entry.');
      return;
    }
    if (!_isEnabled) return;

    if (_nameController.text.trim().isEmpty) {
      infoDialog(messageText: 'Please enter Party Name');
      _nameFocus.requestFocus();
      return;
    }
    if (_selectedType.value.isEmpty) {
      infoDialog(messageText: 'Please select Party Type');
      _typeFocus.requestFocus();
      return;
    }

    final selectedTypeItem = defaultController.partyTypeMstList.firstWhereOrNull(
      (p) => p.typeCode.toString() == _selectedType.value,
    );
    final String? resolvedPartyTypeName = selectedTypeItem?.typeName ?? (_selectedType.value.isEmpty ? null : _selectedType.value);

    if (_isFromEdit) {
      await defaultController.updatePartyData(
        id: selectedPartyMstID.value,
        partyName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        partyType: resolvedPartyTypeName,
        typeCode: _selectedType.value.isEmpty ? null : _selectedType.value,
        contactPerson: _contactPersonController.text.trim().isEmpty ? null : _contactPersonController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        mobileNo: _mobileNoController.text.trim().isEmpty ? null : _mobileNoController.text.trim(),
        phNo: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        fax: _faxController.text.trim().isEmpty ? null : _faxController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        pan: _panController.text.trim().isEmpty ? null : _panController.text.trim(),
        adhar: _aadharController.text.trim().isEmpty ? null : _aadharController.text.trim(),
        bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
        branchName: _branchController.text.trim().isEmpty ? null : _branchController.text.trim(),
        bankAdd: _bankAddressController.text.trim().isEmpty ? null : _bankAddressController.text.trim(),
        ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
        bankAcNo: _accountNoController.text.trim().isEmpty ? null : _accountNoController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        city: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        state: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        sortId: _sortIdController.text.trim().isEmpty ? null : int.tryParse(_sortIdController.text.trim()),
        active: _isActive,
        cGst: _cgstController.text.trim().isEmpty ? null : double.tryParse(_cgstController.text.trim()),
        sGst: _sgstController.text.trim().isEmpty ? null : double.tryParse(_sgstController.text.trim()),
        iGst: _igstController.text.trim().isEmpty ? null : double.tryParse(_igstController.text.trim()),
        creditOpBalRs: _creditController.text.trim().isEmpty ? 0.00 : double.tryParse(_creditController.text.trim()),
        creditOpBalDollor: _creditControllerDollor.text.trim().isEmpty ? null : double.tryParse(_creditControllerDollor.text.trim()),
        debitOpBalRs: _debitController.text.trim().isEmpty ? 0.00 : double.tryParse(_debitController.text.trim()),
        debitOpBalDollor: _debitControllerDollor.text.trim().isEmpty ? null : double.tryParse(_debitControllerDollor.text.trim()),
      );
    } else {
      await defaultController.addPartyData(
        partyName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        partyType: resolvedPartyTypeName,
        typeCode: _selectedType.value.isEmpty ? null : _selectedType.value,
        contactPerson: _contactPersonController.text.trim().isEmpty ? null : _contactPersonController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        mobileNo: _mobileNoController.text.trim().isEmpty ? null : _mobileNoController.text.trim(),
        phNo: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        fax: _faxController.text.trim().isEmpty ? null : _faxController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        pan: _panController.text.trim().isEmpty ? null : _panController.text.trim(),
        adhar: _aadharController.text.trim().isEmpty ? null : _aadharController.text.trim(),
        bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
        branchName: _branchController.text.trim().isEmpty ? null : _branchController.text.trim(),
        bankAdd: _bankAddressController.text.trim().isEmpty ? null : _bankAddressController.text.trim(),
        ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
        bankAcNo: _accountNoController.text.trim().isEmpty ? null : _accountNoController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        city: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        state: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        sortId: _sortIdController.text.trim().isEmpty ? null : int.tryParse(_sortIdController.text.trim()),
        active: _isActive,
        cGst: _cgstController.text.trim().isEmpty ? null : double.tryParse(_cgstController.text.trim()),
        sGst: _sgstController.text.trim().isEmpty ? null : double.tryParse(_sgstController.text.trim()),
        iGst: _igstController.text.trim().isEmpty ? null : double.tryParse(_igstController.text.trim()),
        creditOpBalRs: _creditController.text.trim().isEmpty ? 0.00 : double.tryParse(_creditController.text.trim()),
        creditOpBalDollor: _creditControllerDollor.text.trim().isEmpty ? null : double.tryParse(_creditControllerDollor.text.trim()),
        debitOpBalRs: _debitController.text.trim().isEmpty ? 0.00 : double.tryParse(_debitController.text.trim()),
        debitOpBalDollor: _debitControllerDollor.text.trim().isEmpty ? null : double.tryParse(_debitControllerDollor.text.trim()),
      );
    }

    await defaultController.getPartyData(force: true);
    _clearFormFields();
    partyGridList.value = List.of(defaultController.partyMstList);
  }

  Future<void> _handleDelete() async {
    if (!_rights.canDelete) {
      infoDialog(messageText: 'You do not have permission to delete here.');
      return;
    }
    if (!_isFromEdit || selectedPartyMstID.value == 0) return;
    await defaultController.deletePartyData(id: selectedPartyMstID.value);
    await defaultController.getPartyData(force: true);
    _clearFormFields();
    partyGridList.value = List.of(defaultController.partyMstList);
  }

  void _loadPartyFromRow(DataGridRow row) {
    final dynamic cellVal = row.getCells()[0].value;
    final partyEntry = defaultController.partyMstList.firstWhere(
      (entry) => entry.partyCode == cellVal || entry.partyMstID == cellVal,
      orElse: () => PartyMstModel(),
    );

    final id = partyEntry.partyMstID ?? partyEntry.partyCode;
    if (id != null && id != 0) {
      selectedPartyMstID.value = id;
      _codeController.text = partyEntry.partyCode?.toString() ?? partyEntry.partyMstID.toString();
      _nameController.text = partyEntry.partyName ?? '';
      _contactPersonController.text = partyEntry.contactPerson ?? '';
      _locationController.text = partyEntry.location ?? partyEntry.city ?? '';
      _addressController.text = partyEntry.address ?? '';
      _mobileNoController.text = partyEntry.mobileno ?? '';
      _emailController.text = partyEntry.emailID ?? '';
      _websiteController.text = partyEntry.webSite ?? '';
      _cgstController.text = partyEntry.cGST?.toString() ?? '';
      _igstController.text = partyEntry.iGST?.toString() ?? '';
      _sgstController.text = partyEntry.sGST?.toString() ?? '';
      _phoneController.text = partyEntry.phNo ?? '';
      _faxController.text = partyEntry.fax ?? '';
      _panController.text = partyEntry.panNo ?? '';
      _aadharController.text = partyEntry.adharNo ?? '';
      _bankController.text = partyEntry.bankName ?? '';
      _branchController.text = partyEntry.branchName ?? '';
      _bankAddressController.text = partyEntry.bankAdress ?? '';
      _ifscController.text = partyEntry.iFSCCode ?? '';
      _accountNoController.text = partyEntry.bankAcNo ?? '';
      _sortIdController.text = partyEntry.sortID?.toString() ?? '';
      _creditController.text = partyEntry.creditOpBalRs?.toString() ?? '';
      _creditControllerDollor.text = partyEntry.creditOpBalDollar?.toString() ?? '';
      _debitController.text = partyEntry.debitOpBalRs?.toString() ?? '';
      _debitControllerDollor.text = partyEntry.debitOpBalDollar?.toString() ?? '';
      _isActive = partyEntry.active ?? true;

      String typeVal = '';
      if (partyEntry.typeCode != null) {
        final match = defaultController.partyTypeMstList.firstWhereOrNull(
          (p) => p.typeCode == partyEntry.typeCode,
        );
        if (match != null) {
          typeVal = match.typeCode.toString();
        }
      }
      if (typeVal.isEmpty && partyEntry.partyType != null && partyEntry.partyType!.isNotEmpty) {
        final match = defaultController.partyTypeMstList.firstWhereOrNull(
          (p) => p.typeName?.trim().toLowerCase() == partyEntry.partyType?.trim().toLowerCase(),
        );
        if (match != null && match.typeCode != null) {
          typeVal = match.typeCode.toString();
        }
      }
      _selectedType.value = typeVal;

      setState(() {
        _isFromEdit = true;
        _isEnabled = true;
        _isSearchMode = false;
      });

      _nameFocus.requestFocus();
    }
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    return defaultController.partyTypeMstList.map((partyType) {
      return DropdownMenuItem<String>(
        value: partyType.typeCode.toString(),
        child: Text(
          partyType.typeName ?? '',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = AppColors.isDark;
      return AppKeyboardShortcutHandler(
        onAdd: !_isEnabled ? () => _enableFields() : null,
        onSave: _isEnabled ? _handleSave : null,
        onDelete: (_isEnabled && _isFromEdit) ? _handleDelete : null,
        onCancel: (_isEnabled || _isFromEdit) ? _clearFormFields : null,
        onExit: () => tabController.closeCurrentTab(),
        onSearch: () {
          setState(() {
            _isSearchMode = !_isSearchMode;
          });
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              if (widget.showHeader)
                Header(title: _isSearchMode ? 'Party Master Search' : 'Party Master Entry'),
              Expanded(
                child: _isSearchMode ? _buildSearchView() : _buildFormView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== SEARCH / DEDICATED DATAGRID VIEW ====================
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
              final isNarrow = constraints.maxWidth < 650;
              final searchField = AppTextField(
                label: 'Search Party',
                controller: _searchFilterController,
                hintText: 'Search by party name, code, contact, city...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                onChanged: _filterParties,
              );

              final actionButtons = Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  AppButton(
                    text: 'Clear Filter',
                    variant: AppButtonVariant.outline,
                    icon: Icons.clear_rounded,
                    onPressed: () {
                      _searchFilterController.clear();
                      _filterParties('');
                    },
                  ),
                  AppButton(
                    text: 'Close Search',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.close_rounded,
                    onPressed: () {
                      setState(() {
                        _isSearchMode = false;
                      });
                    },
                  ),
                ],
              );

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: actionButtons,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 12),
                        actionButtons,
                      ],
                    );
            },
          ),
        ),
        Expanded(
          child: _buildDataGridWidget(),
        ),
      ],
    );
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Basic Information',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final codeWidget = SizedBox(
                          width: constraints.maxWidth >= 1000 ? 100 : null,
                          child: AppTextField(
                            label: 'Code',
                            controller: _codeController,
                            enabled: false,
                            hintText: 'Auto',
                          ),
                        );

                        final typeWidget = Obx(
                          () => AppDropdown<String>(
                            label: 'Party Type *',
                            focusNode: _typeFocus,
                            nextFocusNode: _nameFocus,
                            isEnabled: _isEnabled,
                            value: dropdownItems.any((item) => item.value == _selectedType.value)
                                ? _selectedType.value
                                : null,
                            items: dropdownItems,
                            hintText: 'Select Type',
                            onChanged: (val) {
                              _selectedType.value = val ?? '';
                            },
                          ),
                        );

                        final nameWidget = AppTextField(
                          label: 'Party Name *',
                          controller: _nameController,
                          focusNode: _nameFocus,
                          nextFocusNode: _contactPersonFocus,
                          enabled: _isEnabled,
                          hintText: 'Enter Full Party Name',
                        );

                        final contactPersonWidget = AppTextField(
                          label: 'Contact Person',
                          controller: _contactPersonController,
                          focusNode: _contactPersonFocus,
                          nextFocusNode: _locationFocus,
                          enabled: _isEnabled,
                          hintText: 'Contact Name',
                        );

                        final locationWidget = AppTextField(
                          label: 'City / Location',
                          controller: _locationController,
                          focusNode: _locationFocus,
                          nextFocusNode: _addressFocus,
                          enabled: _isEnabled,
                          hintText: 'City or Region',
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
                          controller: _mobileNoController,
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
                          nextFocusNode: _emailFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.phone,
                          hintText: 'Telephone',
                        );

                        final emailWidget = AppTextField(
                          label: 'Email ID',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocusNode: _websiteFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'example@company.com',
                        );

                        final websiteWidget = AppTextField(
                          label: 'Website',
                          controller: _websiteController,
                          focusNode: _websiteFocus,
                          nextFocusNode: _panFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.url,
                          hintText: 'www.example.com',
                        );

                        final activeWidget = Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _isActive,
                                activeColor: AppColors.primary,
                                onChanged: _isEnabled
                                    ? (val) {
                                        setState(() {
                                          _isActive = val ?? true;
                                        });
                                      }
                                    : null,
                              ),
                              const Text('Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
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
                                  Expanded(flex: 2, child: typeWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 3, child: nameWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: contactPersonWidget),
                                  const SizedBox(width: 12),
                                  activeWidget,
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: locationWidget),
                                  const SizedBox(width: 12),
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
                                  Expanded(flex: 2, child: emailWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: websiteWidget),
                                  const SizedBox(width: 12),
                                  const Spacer(flex: 4),
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
                                  Expanded(flex: 1, child: codeWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: typeWidget),
                                  const SizedBox(width: 12),
                                  activeWidget,
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: nameWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: contactPersonWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: locationWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: addressWidget),
                                ],
                              ),
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
                                  Expanded(child: emailWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: websiteWidget),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 85, child: codeWidget),
                                  const SizedBox(width: 10),
                                  Expanded(child: typeWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              nameWidget,
                              const SizedBox(height: 12),
                              contactPersonWidget,
                              const SizedBox(height: 12),
                              locationWidget,
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
                              emailWidget,
                              const SizedBox(height: 12),
                              websiteWidget,
                              const SizedBox(height: 8),
                              activeWidget,
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

            // Card 2: Tax & Identification
            Card(
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final panWidget = AppTextField(
                          label: 'PAN No',
                          controller: _panController,
                          focusNode: _panFocus,
                          nextFocusNode: _aadharFocus,
                          enabled: _isEnabled,
                          hintText: 'ABCDE1234F',
                        );

                        final aadharWidget = AppTextField(
                          label: 'Aadhaar No',
                          controller: _aadharController,
                          focusNode: _aadharFocus,
                          nextFocusNode: _cgstFocus,
                          enabled: _isEnabled,
                          keyboardType: TextInputType.number,
                          hintText: '12-digit Aadhaar',
                        );

                        final cgstWidget = AppTextField(
                          label: 'CGST (%)',
                          controller: _cgstController,
                          focusNode: _cgstFocus,
                          nextFocusNode: _sgstFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.0',
                        );

                        final sgstWidget = AppTextField(
                          label: 'SGST (%)',
                          controller: _sgstController,
                          focusNode: _sgstFocus,
                          nextFocusNode: _igstFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.0',
                        );

                        final igstWidget = AppTextField(
                          label: 'IGST (%)',
                          controller: _igstController,
                          focusNode: _igstFocus,
                          nextFocusNode: _faxFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.0',
                        );

                        final faxWidget = AppTextField(
                          label: 'Fax',
                          controller: _faxController,
                          focusNode: _faxFocus,
                          nextFocusNode: _bankFocus,
                          enabled: _isEnabled,
                          hintText: 'Fax Number',
                        );

                        if (constraints.maxWidth >= 950) {
                          return Row(
                            children: [
                              Expanded(flex: 2, child: panWidget),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: aadharWidget),
                              const SizedBox(width: 12),
                              Expanded(flex: 1, child: cgstWidget),
                              const SizedBox(width: 12),
                              Expanded(flex: 1, child: sgstWidget),
                              const SizedBox(width: 12),
                              Expanded(flex: 1, child: igstWidget),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: faxWidget),
                            ],
                          );
                        } else if (constraints.maxWidth >= 600) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: panWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: aadharWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: faxWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: cgstWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: sgstWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: igstWidget),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: panWidget),
                                  const SizedBox(width: 10),
                                  Expanded(child: aadharWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: cgstWidget),
                                  const SizedBox(width: 8),
                                  Expanded(child: sgstWidget),
                                  const SizedBox(width: 8),
                                  Expanded(child: igstWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              faxWidget,
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

            // Card 3: Banking & Accounts
            Card(
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
                          'Banking Details & Opening Balance',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                          nextFocusNode: _accountNoFocus,
                          enabled: _isEnabled,
                          hintText: 'Branch',
                        );

                        final accountNoWidget = AppTextField(
                          label: 'Account No',
                          controller: _accountNoController,
                          focusNode: _accountNoFocus,
                          nextFocusNode: _ifscFocus,
                          enabled: _isEnabled,
                          hintText: 'A/C Number',
                        );

                        final ifscWidget = AppTextField(
                          label: 'IFSC Code',
                          controller: _ifscController,
                          focusNode: _ifscFocus,
                          nextFocusNode: _bankAddressFocus,
                          enabled: _isEnabled,
                          hintText: 'IFSC Code',
                        );

                        final bankAddressWidget = AppTextField(
                          label: 'Bank Address',
                          controller: _bankAddressController,
                          focusNode: _bankAddressFocus,
                          nextFocusNode: _creditFocus,
                          enabled: _isEnabled,
                          hintText: 'Bank Branch Address',
                        );

                        final creditWidget = AppTextField(
                          label: 'Credit Op Bal (₹)',
                          controller: _creditController,
                          focusNode: _creditFocus,
                          nextFocusNode: _creditDollarFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.00',
                        );

                        final creditDollarWidget = AppTextField(
                          label: 'Credit Op Bal (\$)',
                          controller: _creditControllerDollor,
                          focusNode: _creditDollarFocus,
                          nextFocusNode: _debitFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.00',
                        );

                        final debitWidget = AppTextField(
                          label: 'Debit Op Bal (₹)',
                          controller: _debitController,
                          focusNode: _debitFocus,
                          nextFocusNode: _debitDollarFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.00',
                        );

                        final debitDollarWidget = AppTextField(
                          label: 'Debit Op Bal (\$)',
                          controller: _debitControllerDollor,
                          focusNode: _debitDollarFocus,
                          nextFocusNode: _sortIdFocus,
                          enabled: _isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hintText: '0.00',
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
                                  Expanded(flex: 2, child: creditWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: creditDollarWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: debitWidget),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: debitDollarWidget),
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
                                  Expanded(child: creditWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: creditDollarWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: debitWidget),
                                  const SizedBox(width: 12),
                                  Expanded(child: debitDollarWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(width: 160, child: sortIdWidget),
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
                                  Expanded(child: creditWidget),
                                  const SizedBox(width: 10),
                                  Expanded(child: creditDollarWidget),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: debitWidget),
                                  const SizedBox(width: 10),
                                  Expanded(child: debitDollarWidget),
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
            ),
            const SizedBox(height: 16),

            // Bottom Action Bar
            _buildActionBar(),

            const SizedBox(height: 16),

            // Embedded DataGrid Card
            Card(
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
                                'Party Directory (${partyGridList.length})',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        );

                        final filterWidget = SizedBox(
                          width: isNarrow ? double.infinity : 260,
                          child: AppTextField(
                            label: 'Quick Filter',
                            controller: _searchFilterController,
                            hintText: 'Filter name, code...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 16),
                            onChanged: _filterParties,
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
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DATAGRID COMPONENT ====================
  Widget _buildDataGridWidget() {
    return Obx(
      () => AppDataGrid(
        controller: _dataGridController,
        source: PartyDataGridSource(partyGridList),
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
            columnName: 'Type',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'Name',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'Contact Person',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Contact Person', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'Address',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'Location',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'CGST',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('CGST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'SGST',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('SGST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'IGST',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('IGST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          GridColumn(
            columnName: 'Sort Id',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Sort Id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        // Clicking the row that is already selected does not fire
        // onSelectionChanged, so load that row again here.
        onCellTap: (details) {
          final int dataRowIndex = details.rowColumnIndex.rowIndex - 1;
          final selected = _dataGridController.selectedRow;
          if (dataRowIndex >= 0 &&
              selected != null &&
              _dataGridController.selectedIndex == dataRowIndex) {
            _loadPartyFromRow(selected);
          }
        },
        onSelectionChanged: (addedRows, _) {
          if (addedRows.isNotEmpty) {
            _loadPartyFromRow(addedRows.first);
          }
        },
        columnWidthMode: ColumnWidthMode.auto,
        frozenColumnsCount: 1,
      ),
    );
  }

  // ==================== BOTTOM ACTION BAR ====================
  Widget _buildActionBar() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 8.0 : 16.0, vertical: 12.0),
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

            // Save Button
            Obx(
              () => AppButton(
                text: 'Save',
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

            // Search Toggle Button
            AppButton(
              text: 'Search Mode',
              icon: Icons.search_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                setState(() {
                  _isSearchMode = !_isSearchMode;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
