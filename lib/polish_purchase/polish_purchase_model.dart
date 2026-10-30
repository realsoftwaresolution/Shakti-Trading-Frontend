class PolishPurchaseModel {
  int? polishPurMstID;
  String? invoiceNo;
  String? invoiceDate;
  int? partyCode;
  String? partyName;
  int? brokerCode;
  String? brokerName;
  int? dueDay;
  String? dueDate;
  String? rdType;
  dynamic exchange;
  String? type;
  int? totPcs;
  dynamic totWt;
  dynamic rateRs;
  dynamic totAmtRs;
  dynamic rateDollar;
  dynamic totAmtDollar;
  dynamic netAmtDollar;
  dynamic netAmtRs;
  String? remarks;
  dynamic finalAmtRs;
  dynamic finalAmtD;
  dynamic roundOfRs;
  dynamic roundOfD;
  bool? chkBroker;
  dynamic brokerPer;
  dynamic brokerFixDollar;
  dynamic brokerFixRs;
  bool? chkAdd;
  dynamic addPer;
  dynamic addFixDollar;
  dynamic addFixRs;
  bool? chkLess;
  dynamic lessPer;
  dynamic lessFixDollar;
  dynamic lessFixRs;
  int? companyCode;
  int? logId;
  String? pcId;
  int? ever;
  String? sDate;
  int? crId;

  PolishPurchaseModel({
    this.polishPurMstID,
    this.crId,
    this.invoiceNo,
    this.invoiceDate,
    this.partyCode,
    this.partyName,
    this.brokerCode,
    this.brokerName,
    this.dueDay,
    this.dueDate,
    this.rdType,
    this.exchange,
    this.type,
    this.totPcs,
    this.totWt,
    this.rateRs,
    this.totAmtRs,
    this.rateDollar,
    this.totAmtDollar,
    this.netAmtDollar,
    this.netAmtRs,
    this.remarks,
    this.finalAmtRs,
    this.finalAmtD,
    this.roundOfRs,
    this.roundOfD,
    this.chkBroker,
    this.brokerPer,
    this.brokerFixDollar,
    this.brokerFixRs,
    this.chkAdd,
    this.addPer,
    this.addFixDollar,
    this.addFixRs,
    this.chkLess,
    this.lessPer,
    this.lessFixDollar,
    this.lessFixRs,
    this.companyCode,
    this.logId,
    this.pcId,
    this.ever,
    this.sDate,
  });

  factory PolishPurchaseModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    bool parseIsFix(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final str = v.toString().trim().toUpperCase();
      return str == 'FIX' || str == '1' || str == 'TRUE' || str == 'Y';
    }

    return PolishPurchaseModel(
      polishPurMstID: parseInt(json['PolishPurMstID'] ?? json['polishPurMstID'] ?? json['ID'] ?? json['id']),
      invoiceNo: json['InvoiceNo']?.toString() ?? json['invoiceNo']?.toString() ?? json['Invoice No']?.toString(),
      invoiceDate: json['InvoiceDate']?.toString() ?? json['invoiceDate']?.toString(),
      partyCode: parseInt(json['PartyCode'] ?? json['partyCode']),
      partyName: json['PartyName']?.toString() ?? json['partyName']?.toString() ?? json['Party']?.toString(),
      brokerCode: parseInt(json['BrokerCode'] ?? json['brokerCode']),
      brokerName: json['BrokerName']?.toString() ?? json['brokerName']?.toString() ?? json['Broker']?.toString(),
      dueDay: parseInt(json['DueDay'] ?? json['dueDay'] ?? json['DueDays']),
      dueDate: json['DueDate']?.toString() ?? json['dueDate']?.toString(),
      rdType: json['RDType']?.toString() ?? json['rdType']?.toString() ?? json['Rs / \$']?.toString() ?? 'RS',
      exchange: json['Exchange'] ?? json['exchange'] ?? 0.0,
      type: json['Type']?.toString() ?? json['type']?.toString() ?? 'LOOSE',
      totPcs: parseInt(json['TPc'] ?? json['TotPcs'] ?? json['totPcs']),
      totWt: json['TWeight'] ?? json['TotWt'] ?? json['totWt'] ?? 0.0,
      rateRs: json['TRateRs'] ?? json['RateRs'] ?? json['rateRs'] ?? json['AvgRate'] ?? 0.0,
      totAmtRs: json['TAmtRs'] ?? json['TotAmtRs'] ?? json['totAmtRs'] ?? 0.0,
      rateDollar: json['TRateDollar'] ?? json['RateDollar'] ?? json['rateDollar'] ?? json['Rate (\$)'] ?? 0.0,
      totAmtDollar: json['TAmtDollar'] ?? json['TotAmtDollar'] ?? json['totAmtDollar'] ?? json['Tot Amt (\$)'] ?? 0.0,
      netAmtDollar: json['NetAmtDollar'] ?? json['netAmtDollar'] ?? 0.0,
      netAmtRs: json['NetAmtRs'] ?? json['netAmtRs'] ?? 0.0,
      remarks: json['Remarks']?.toString() ?? json['remarks']?.toString() ?? '',
      finalAmtRs: json['FinalAmtRs'] ?? json['finalAmtRs'] ?? 0.0,
      finalAmtD: json['FinalAmtD'] ?? json['finalAmtD'] ?? json['Final Amt \$'] ?? 0.0,
      roundOfRs: json['RoundOfRs'] ?? json['roundOfRs'] ?? 0.0,
      roundOfD: json['RoundOfD'] ?? json['roundOfD'] ?? json['Round Of \$'] ?? 0.0,
      chkBroker: parseIsFix(json['ChkBro'] ?? json['ChkBroker'] ?? json['chkBroker']),
      brokerPer: json['BroPer'] ?? json['BrokerPer'] ?? json['brokerPer'] ?? 0.0,
      brokerFixDollar: json['BroDollar'] ?? json['BrokerFixDollar'] ?? json['brokerFixDollar'] ?? 0.0,
      brokerFixRs: json['BroRs'] ?? json['BrokerFixRs'] ?? json['brokerFixRs'] ?? 0.0,
      chkAdd: parseIsFix(json['ChkAdd'] ?? json['chkAdd']),
      addPer: json['AddPer'] ?? json['addPer'] ?? 0.0,
      addFixDollar: json['AddDollar'] ?? json['AddFixDollar'] ?? json['addFixDollar'] ?? 0.0,
      addFixRs: json['AddRs'] ?? json['AddFixRs'] ?? json['addFixRs'] ?? 0.0,
      chkLess: parseIsFix(json['ChkLess'] ?? json['chkLess']),
      lessPer: json['LessPer'] ?? json['lessPer'] ?? 0.0,
      lessFixDollar: json['LessDollar'] ?? json['LessFixDollar'] ?? json['lessFixDollar'] ?? 0.0,
      lessFixRs: json['LessRs'] ?? json['LessFixRs'] ?? json['lessFixRs'] ?? 0.0,
      companyCode: parseInt(json['CompanyCode'] ?? json['companyCode']),
      logId: parseInt(json['LogID'] ?? json['logId']),
      pcId: json['PCID']?.toString() ?? json['pcId']?.toString(),
      ever: parseInt(json['Ever'] ?? json['ever']),
      sDate: json['SDate']?.toString() ?? json['sDate']?.toString(),
      crId: parseInt(json['CrId'] ?? json['crId'] ?? json['CRID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PolishPurMstID': polishPurMstID,
      'CrId': crId,
      'InvoiceNo': invoiceNo,
      'InvoiceDate': invoiceDate,
      'PartyCode': partyCode,
      'PartyName': partyName,
      'BrokerCode': brokerCode,
      'BrokerName': brokerName,
      'DueDay': dueDay,
      'DueDate': dueDate,
      'RDType': rdType,
      'Exchange': exchange,
      'Type': type,
      'TotPcs': totPcs,
      'TotWt': totWt,
      'RateRs': rateRs,
      'TotAmtRs': totAmtRs,
      'RateDollar': rateDollar,
      'TotAmtDollar': totAmtDollar,
      'NetAmtDollar': netAmtDollar,
      'NetAmtRs': netAmtRs,
      'Remarks': remarks,
      'FinalAmtRs': finalAmtRs,
      'FinalAmtD': finalAmtD,
      'RoundOfRs': roundOfRs,
      'RoundOfD': roundOfD,
      'ChkBroker': chkBroker,
      'BrokerPer': brokerPer,
      'BrokerFixDollar': brokerFixDollar,
      'BrokerFixRs': brokerFixRs,
      'ChkAdd': chkAdd,
      'AddPer': addPer,
      'AddFixDollar': addFixDollar,
      'AddFixRs': addFixRs,
      'ChkLess': chkLess,
      'LessPer': lessPer,
      'LessFixDollar': lessFixDollar,
      'LessFixRs': lessFixRs,
      'CompanyCode': companyCode,
      'LogID': logId,
      'PCID': pcId,
      'Ever': ever,
      'SDate': sDate,
    };
  }

  /// Formats the model to match the exact backend API payload for POST / PUT
  Map<String, dynamic> toApiMasterJson() {
    return {
      if (polishPurMstID != null && polishPurMstID! > 0) 'PolishPurMstID': polishPurMstID,
      if (crId != null && crId! > 0) 'CrId': crId,
      'InvoiceNo': invoiceNo ?? '',
      'InvoiceDate': invoiceDate ?? '',
      'PartyCode': partyCode ?? 0,
      'BrokerCode': brokerCode ?? 0,
      'DueDay': dueDay ?? 0,
      'DueDate': (dueDate != null && dueDate!.isNotEmpty) ? dueDate! : (invoiceDate ?? ''),
      'RDType': rdType ?? 'RS',
      'Exchange': exchange ?? 0,
      'TPc': totPcs ?? 0,
      'TWeight': totWt ?? 0,
      'TAmtRs': totAmtRs ?? 0,
      'TRateRs': rateRs ?? 0,
      'TRateDollar': rateDollar ?? 0,
      'TAmtDollar': totAmtDollar ?? 0,
      'ChkBro': (chkBroker == true) ? 'Fix' : 'Per',
      'BroPer': brokerPer ?? 0,
      'BroDollar': brokerFixDollar ?? 0,
      'BroRs': brokerFixRs ?? 0,
      'ChkAdd': (chkAdd == true) ? 'Fix' : 'Per',
      'AddPer': addPer ?? 0,
      'AddDollar': addFixDollar ?? 0,
      'AddRs': addFixRs ?? 0,
      'ChkLess': (chkLess == true) ? 'Fix' : 'Per',
      'LessPer': lessPer ?? 0,
      'LessDollar': lessFixDollar ?? 0,
      'LessRs': lessFixRs ?? 0,
      'NetAmtDollar': netAmtDollar ?? 0,
      'NetAmtRs': netAmtRs ?? 0,
      'LogID': logId ?? 2,
      'PCID': pcId ?? '551776',
      'Ever': ever ?? 22,
      'SDate': sDate ?? DateTime.now().toIso8601String().split('T').first,
      'CompanyCode': companyCode,
      'AvgRate': rateRs ?? 0,
      'Remarks': remarks ?? '',
      'Type': (type != null && type!.isNotEmpty) ? type! : 'LOOSE',
      'FinalAmtRs': finalAmtRs ?? 0,
      'FinalAmtD': finalAmtD ?? 0,
      'RoundOfRs': roundOfRs ?? 0,
      'RoundOfD': roundOfD ?? 0,
    };
  }
}

class PolishPurchaseDetailModel {
  int? polishPurDetID;
  int? polishPurMstID;
  int? srNo;
  dynamic polishTypeCode;
  String? polishType;
  dynamic shapeCode;
  String? shape;
  dynamic clarityCode;
  String? clarity;
  dynamic charniCode;
  String? charni;
  int? pcs;
  dynamic wt;
  dynamic rateRs;
  dynamic amountRs;
  dynamic rateDollar;
  dynamic amountDollar;
  int? packetID;
  String? packetNo;
  dynamic colorCode;
  dynamic cutCode;
  dynamic polishCode;
  dynamic symmetryCode;
  dynamic fluoCode;
  dynamic diaMinW;
  dynamic diaMaxL;
  dynamic diaHeightD;
  dynamic tableMM;
  dynamic tableDepth;
  dynamic ca;
  dynamic ch;
  dynamic pa;
  dynamic ph;
  dynamic girdlePer;
  String? girdle;
  String? gia;
  String? igi;
  String? ha;
  dynamic ratio;
  String? remarks;
  dynamic rs;
  dynamic disc;
  dynamic amount;
  dynamic nattsDisc;
  dynamic netAmount;
  dynamic rapaportMstID;
  dynamic discountMstID;
  dynamic rate;
  String? kno;

  PolishPurchaseDetailModel({
    this.polishPurDetID,
    this.polishPurMstID,
    this.srNo,
    this.polishTypeCode,
    this.polishType,
    this.shapeCode,
    this.shape,
    this.clarityCode,
    this.clarity,
    this.charniCode,
    this.charni,
    this.pcs,
    this.wt,
    this.rateRs,
    this.amountRs,
    this.rateDollar,
    this.amountDollar,
    this.packetID,
    this.packetNo,
    this.colorCode,
    this.cutCode,
    this.polishCode,
    this.symmetryCode,
    this.fluoCode,
    this.diaMinW,
    this.diaMaxL,
    this.diaHeightD,
    this.tableMM,
    this.tableDepth,
    this.ca,
    this.ch,
    this.pa,
    this.ph,
    this.girdlePer,
    this.girdle,
    this.gia,
    this.igi,
    this.ha,
    this.ratio,
    this.remarks,
    this.rs,
    this.disc,
    this.amount,
    this.nattsDisc,
    this.netAmount,
    this.rapaportMstID,
    this.discountMstID,
    this.rate,
    this.kno,
  });

  factory PolishPurchaseDetailModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return PolishPurchaseDetailModel(
      polishPurDetID: parseInt(json['PolishPurDetID'] ?? json['polishPurDetID'] ?? json['id']),
      polishPurMstID: parseInt(json['PolishPurMstID'] ?? json['polishPurMstID']),
      srNo: parseInt(json['Srno'] ?? json['SrNo'] ?? json['srNo']),
      polishTypeCode: parseInt(json['PolishTypeCode'] ?? json['polishTypeCode']),
      polishType: json['PolishTypeName']?.toString() ?? json['PolishType']?.toString() ?? json['polishType']?.toString(),
      shapeCode: parseInt(json['ShapeCode'] ?? json['shapeCode']),
      shape: json['ShapeName']?.toString() ?? json['Shape']?.toString() ?? json['shape']?.toString(),
      clarityCode: parseInt(json['ClarityCode'] ?? json['clarityCode']),
      clarity: json['ClarityName']?.toString() ?? json['Clarity']?.toString() ?? json['clarity']?.toString(),
      charniCode: parseInt(json['CharniCode'] ?? json['charniCode']),
      charni: json['CharniName']?.toString() ?? json['Charni']?.toString() ?? json['charni']?.toString(),
      pcs: parseInt(json['Pc'] ?? json['pcs'] ?? json['Pcs']) ?? 0,
      wt: json['Wt'] ?? json['wt'] ?? 0.0,
      rateRs: json['RateRs'] ?? json['rateRs'] ?? 0.0,
      amountRs: json['AmtRs'] ?? json['AmountRs'] ?? json['amountRs'] ?? 0.0,
      rateDollar: json['RateDollar'] ?? json['rateDollar'] ?? json['Rate (\$)'] ?? 0.0,
      amountDollar: json['AmtDollar'] ?? json['AmountDollar'] ?? json['amountDollar'] ?? json['Amount (\$)'] ?? 0.0,
      packetID: parseInt(json['PacketID'] ?? json['packetID']),
      packetNo: json['PacketNo']?.toString() ?? json['packetNo']?.toString(),
      colorCode: json['ColorCode'] ?? json['colorCode'],
      cutCode: json['CutCode'] ?? json['cutCode'],
      polishCode: json['PolishCode'] ?? json['PolCode'] ?? json['polishCode'],
      symmetryCode: json['SymmetryCode'] ?? json['SymmCode'] ?? json['symmetryCode'],
      fluoCode: json['FluoCode'] ?? json['FLCode'] ?? json['fluoCode'],
      diaMinW: json['DiaMin_W'] ?? json['diaMinW'],
      diaMaxL: json['DiaMax_L'] ?? json['diaMaxL'],
      diaHeightD: json['DiaHeight_D'] ?? json['diaHeightD'],
      tableMM: json['TableMM'] ?? json['tableMM'],
      tableDepth: json['TableDepth'] ?? json['tableDepth'],
      ca: json['CA'] ?? json['ca'],
      ch: json['CH'] ?? json['ch'],
      pa: json['PA'] ?? json['pa'],
      ph: json['PH'] ?? json['ph'],
      girdlePer: json['GirdlePer'] ?? json['girdlePer'],
      girdle: json['Girdle']?.toString() ?? json['girdle']?.toString(),
      gia: json['GIA']?.toString() ?? json['gia']?.toString(),
      igi: json['IGI']?.toString() ?? json['igi']?.toString(),
      ha: json['HA']?.toString() ?? json['ha']?.toString(),
      ratio: json['Ratio'] ?? json['ratio'],
      remarks: json['Remarks']?.toString() ?? json['remarks']?.toString(),
      rs: json['RS'] ?? json['rs'],
      disc: json['Disc'] ?? json['disc'],
      amount: json['Amount'] ?? json['amount'],
      nattsDisc: json['NattsDisc'] ?? json['nattsDisc'],
      netAmount: json['NetAmount'] ?? json['netAmount'],
      rapaportMstID: parseInt(json['RapaportMstID'] ?? json['rapaportMstID']),
      discountMstID: parseInt(json['DiscountMstID'] ?? json['discountMstID']),
      rate: json['Rate'] ?? json['rate'],
      kno: json['Kno']?.toString() ?? json['kno']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PolishPurDetID': polishPurDetID,
      'PolishPurMstID': polishPurMstID,
      'SrNo': srNo,
      'PolishTypeCode': polishTypeCode,
      'PolishType': polishType,
      'ShapeCode': shapeCode,
      'Shape': shape,
      'ClarityCode': clarityCode,
      'Clarity': clarity,
      'CharniCode': charniCode,
      'Charni': charni,
      'Pcs': pcs,
      'Wt': wt,
      'RateRs': rateRs,
      'AmountRs': amountRs,
      'RateDollar': rateDollar,
      'AmountDollar': amountDollar,
      'PacketID': packetID,
      'PacketNo': packetNo,
      'ColorCode': colorCode,
      'CutCode': cutCode,
      'PolishCode': polishCode,
      'SymmetryCode': symmetryCode,
      'FluoCode': fluoCode,
      'DiaMin_W': diaMinW,
      'DiaMax_L': diaMaxL,
      'DiaHeight_D': diaHeightD,
      'TableMM': tableMM,
      'TableDepth': tableDepth,
      'CA': ca,
      'CH': ch,
      'PA': pa,
      'PH': ph,
      'GirdlePer': girdlePer,
      'Girdle': girdle,
      'GIA': gia,
      'IGI': igi,
      'HA': ha,
      'Ratio': ratio,
      'Remarks': remarks,
      'RS': rs,
      'Disc': disc,
      'Amount': amount,
      'NattsDisc': nattsDisc,
      'NetAmount': netAmount,
      'RapaportMstID': rapaportMstID,
      'DiscountMstID': discountMstID,
      'Rate': rate,
      'Kno': kno,
    };
  }

  /// Formats the line detail to match the exact backend API payload with ONLY the required 45 keys
  Map<String, dynamic> toApiDetailJson({bool isUpdate = false}) {
    return {
      'PolishPurDetID': polishPurDetID ?? 0,
      'PolishPurMstID': polishPurMstID ?? 0,
      'Srno': srNo ?? 1,
      'ShapeCode': shapeCode ?? 0,
      'ClarityCode': clarityCode ?? 0,
      'CharniCode': charniCode ?? 0,
      'Pc': pcs ?? 0,
      'Wt': wt ?? 0,
      'RateRs': rateRs ?? 0,
      'AmtRs': amountRs ?? 0,
      'RateDollar': rateDollar ?? 0,
      'AmtDollar': amountDollar ?? 0,
      'PolishTypeCode': polishTypeCode ?? 0,
      'PacketID': packetID,
      'PacketNo': packetNo,
      'ColorCode': colorCode,
      'CutCode': cutCode,
      'PolishCode': polishCode,
      'SymmetryCode': symmetryCode,
      'FluoCode': fluoCode,
      'DiaMin_W': diaMinW ?? 0,
      'DiaMax_L': diaMaxL ?? 0,
      'DiaHeight_D': diaHeightD ?? 0,
      'TableMM': tableMM ?? 0,
      'TableDepth': tableDepth ?? 0,
      'CA': ca ?? 0,
      'CH': ch ?? 0,
      'PA': pa ?? 0,
      'PH': ph ?? 0,
      'GirdlePer': girdlePer ?? 0,
      'Girdle': girdle ?? 0,
      'GIA': gia,
      'IGI': igi,
      'HA': ha ?? 0,
      'Ratio': ratio ?? 0,
      'Remarks': remarks,
      'RS': rs,
      'Disc': disc ?? 0,
      'Amount': amount ?? amountRs ?? 0,
      'NattsDisc': nattsDisc ?? 0,
      'NetAmount': netAmount ?? amountRs ?? 0,
      'RapaportMstID': rapaportMstID ?? 0,
      'DiscountMstID': discountMstID ?? 0,
      'Rate': rate ?? rateRs ?? 0,
      'Kno': kno ?? 0,
    };
  }
}
