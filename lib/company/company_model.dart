/// Model representing a Company record from `/rough-entry/company`
class CompanyMstModel {
  int? companyMstID;
  int? companyCode;
  String? companyName;
  String? address;
  String? mobileNo;
  String? phone;
  String? fax;
  String? email;
  String? webSite;
  String? gstNo;
  String? cstNo;
  String? tinNo;
  String? bankName;
  String? branchName;
  String? bankAddress;
  String? ifscCode;
  String? bankAcNo;
  String? insurance;
  String? invCode; // FinalAmt
  String? memoInvoicePrefix; // Memo Issue No prefix e.g. 'ML/'
  String? memoInvoiceSuffix; // Memo Issue No suffix e.g. '/AK2000'
  String? invoicePrefix; // Polish Sale Invoice No prefix
  String? invoiceSuffix; // Polish Sale Invoice No suffix
  String? fromDate; // FromYear / FromDate
  String? toDate; // ToYear / ToDate
  dynamic sortID;
  bool? active;
  String? sflag;
  String? sdate;
  dynamic logID;
  dynamic pcID;
  int? ever;

  CompanyMstModel({
    this.companyMstID,
    this.companyCode,
    this.companyName,
    this.address,
    this.mobileNo,
    this.phone,
    this.fax,
    this.email,
    this.webSite,
    this.gstNo,
    this.cstNo,
    this.tinNo,
    this.bankName,
    this.branchName,
    this.bankAddress,
    this.ifscCode,
    this.bankAcNo,
    this.insurance,
    this.invCode,
    this.memoInvoicePrefix,
    this.memoInvoiceSuffix,
    this.invoicePrefix,
    this.invoiceSuffix,
    this.fromDate,
    this.toDate,
    this.sortID,
    this.active,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
  });

  factory CompanyMstModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final int? mstId = parseInt(json['CompanyMstID'] ??
        json['CompanyMstId'] ??
        json['companyMstId'] ??
        json['companyMstID'] ??
        json['ID'] ??
        json['Id'] ??
        json['id']);

    final int? code = parseInt(json['CompanyCode'] ??
        json['companyCode'] ??
        json['Code'] ??
        json['code'] ??
        mstId);

    return CompanyMstModel(
      companyMstID: mstId,
      companyCode: code,
      companyName: json['CompanyName']?.toString() ??
          json['companyName']?.toString() ??
          json['Name']?.toString() ??
          json['name']?.toString(),
      address: json['Address']?.toString() ?? json['address']?.toString(),
      mobileNo: json['MobileNo']?.toString() ??
          json['Mobileno']?.toString() ??
          json['mobileNo']?.toString() ??
          json['mobileno']?.toString(),
      phone: json['Phone']?.toString() ?? json['phone']?.toString(),
      fax: json['Fax']?.toString() ?? json['fax']?.toString(),
      email: json['EmailID']?.toString() ??
          json['Email']?.toString() ??
          json['emailID']?.toString() ??
          json['email']?.toString(),
      webSite: json['WebSite']?.toString() ??
          json['Web']?.toString() ??
          json['webSite']?.toString() ??
          json['web']?.toString(),
      gstNo: json['GstNo']?.toString() ??
          json['GSTNo']?.toString() ??
          json['gstNo']?.toString(),
      cstNo: json['CstNo']?.toString() ??
          json['CSTNo']?.toString() ??
          json['cstNo']?.toString(),
      tinNo: json['TinNo']?.toString() ??
          json['TINNo']?.toString() ??
          json['tinNo']?.toString(),
      bankName: json['BankName']?.toString() ??
          json['Bank']?.toString() ??
          json['bankName']?.toString() ??
          json['bank']?.toString(),
      branchName: json['BranchName']?.toString() ??
          json['Branch']?.toString() ??
          json['branchName']?.toString() ??
          json['branch']?.toString(),
      bankAddress: json['BankAddress']?.toString() ??
          json['BankAdd']?.toString() ??
          json['bankAddress']?.toString() ??
          json['bankAdd']?.toString(),
      ifscCode: json['IFSCCode']?.toString() ??
          json['IFSC']?.toString() ??
          json['iFSCCode']?.toString() ??
          json['ifscCode']?.toString(),
      bankAcNo: json['BankAcNo']?.toString() ??
          json['AccNo']?.toString() ??
          json['bankAcNo']?.toString() ??
          json['accNo']?.toString(),
      insurance: json['Insurance']?.toString() ?? json['insurance']?.toString(),
      invCode: json['InvCode']?.toString() ??
          json['FinalAmt']?.toString() ??
          json['invCode']?.toString() ??
          json['finalAmt']?.toString(),
      memoInvoicePrefix: json['MemoInvoicePrefix']?.toString() ??
          json['memoInvoicePrefix']?.toString(),
      memoInvoiceSuffix: json['MemoInvoiceSuffix']?.toString() ??
          json['memoInvoiceSuffix']?.toString(),
      invoicePrefix: json['InvoicePrefix']?.toString() ??
          json['invoicePrefix']?.toString(),
      invoiceSuffix: json['InvoiceSuffix']?.toString() ??
          json['invoiceSuffix']?.toString(),
      fromDate: json['FromDate']?.toString() ??
          json['FromYear']?.toString() ??
          json['fromDate']?.toString() ??
          json['fromYear']?.toString(),
      toDate: json['ToDate']?.toString() ??
          json['ToYear']?.toString() ??
          json['toDate']?.toString() ??
          json['toYear']?.toString(),
      sortID: json['SortID'] ?? json['SortId'] ?? json['sortID'] ?? json['sortId'],
      active: json['Active'] is bool
          ? json['Active']
          : (json['Active'] == 1 || json['Active'] == '1' || json['Active'] == 'true'),
      sflag: json['Sflag']?.toString() ?? json['sflag']?.toString(),
      sdate: json['Sdate']?.toString() ?? json['sdate']?.toString(),
      logID: json['LogID'] ?? json['logId'] ?? json['LogId'],
      pcID: json['PcID'] ?? json['pcId'] ?? json['PcId'],
      ever: parseInt(json['Ever'] ?? json['ever']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': companyName,
      'Address': address,
      'MobileNo': mobileNo,
      'Phone': phone,
      'Fax': fax,
      'Email': email,
      'Web': webSite,
      'GSTNo': gstNo,
      'CSTNo': cstNo,
      'TINNo': tinNo,
      'Bank': bankName,
      'Branch': branchName,
      'BankAdd': bankAddress,
      'IFSC': ifscCode,
      'AccNo': bankAcNo,
      'Insurance': insurance,
      'FinalAmt': invCode,
      'MemoInvoicePrefix': memoInvoicePrefix,
      'MemoInvoiceSuffix': memoInvoiceSuffix,
      'InvoicePrefix': invoicePrefix,
      'InvoiceSuffix': invoiceSuffix,
      'FromDate': fromDate,
      'ToDate': toDate,
      'SortID': sortID,
      'Active': active,
    };
  }
}

typedef CompanyModel = CompanyMstModel;
