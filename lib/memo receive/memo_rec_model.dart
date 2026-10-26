class MemoRecModel {
  int? memoRecMstID;
  String? polishDate;
  String? invoiceNo;
  int? invNo;
  String? invoiceDate;
  int? dueDay;
  String? dueDate;
  String? invCode;
  String? saleType;
  String? insuranceName;
  dynamic sGstPer;
  dynamic cGstPer;
  dynamic iGstPer;
  dynamic sGstAmont;
  dynamic cGstAmont;
  dynamic iGstAmont;
  dynamic sGstUsdAmont;
  dynamic cGstUsdAmont;
  dynamic iGstUsdAmont;
  dynamic totRsAmt;
  dynamic totUsdAmt;
  dynamic roundRs;
  dynamic roundUsd;
  dynamic netUsdAmount;
  dynamic netRsAmount;
  String? rdType;
  dynamic dollarRate;
  String? paymentRec;
  dynamic broPer;
  dynamic broRsAmount;
  dynamic broUSDAmount;
  int? brokerCode;
  int? bankCode;
  int? partyCode;
  dynamic finalRsAmount;
  dynamic finalUsdAmount;
  int? tPcs;
  dynamic tWeight;
  dynamic tRate;
  dynamic tAmount;
  dynamic tDRate;
  dynamic tDAmount;
  String? sflag;
  String? sDate;
  int? logID;
  String? pCID;
  int? ever;
  int? companyCode;
  int? recPcs;
  dynamic issWt;
  dynamic recWt;
  dynamic saleWt;
  dynamic outWt;
  dynamic lossWt;
  dynamic totalWt;

  MemoRecModel(
      {this.memoRecMstID,
        this.polishDate,
        this.invoiceNo,
        this.invNo,
        this.invoiceDate,
        this.dueDay,
        this.dueDate,
        this.invCode,
        this.saleType,
        this.insuranceName,
        this.sGstPer,
        this.cGstPer,
        this.iGstPer,
        this.sGstAmont,
        this.cGstAmont,
        this.iGstAmont,
        this.sGstUsdAmont,
        this.cGstUsdAmont,
        this.iGstUsdAmont,
        this.totRsAmt,
        this.totUsdAmt,
        this.roundRs,
        this.roundUsd,
        this.netUsdAmount,
        this.netRsAmount,
        this.rdType,
        this.dollarRate,
        this.paymentRec,
        this.broPer,
        this.broRsAmount,
        this.broUSDAmount,
        this.brokerCode,
        this.bankCode,
        this.partyCode,
        this.finalRsAmount,
        this.finalUsdAmount,
        this.tPcs,
        this.tWeight,
        this.tRate,
        this.tAmount,
        this.tDRate,
        this.tDAmount,
        this.sflag,
        this.sDate,
        this.logID,
        this.pCID,
        this.ever,
        this.companyCode,
        this.recPcs,
        this.issWt,
        this.recWt,
        this.saleWt,
        this.outWt,
        this.lossWt,
        this.totalWt});

  MemoRecModel.fromJson(Map<String, dynamic> json) {
    memoRecMstID = json['MemoRecMstID'];
    polishDate = json['PolishDate'];
    invoiceNo = json['InvoiceNo'];
    invNo = json['InvNo'];
    invoiceDate = json['InvoiceDate'];
    dueDay = json['DueDay'];
    dueDate = json['DueDate'];
    invCode = json['InvCode'];
    saleType = json['SaleType'];
    insuranceName = json['InsuranceName'];
    sGstPer = json['SGstPer'];
    cGstPer = json['CGstPer'];
    iGstPer = json['IGstPer'];
    sGstAmont = json['SGstAmont'];
    cGstAmont = json['CGstAmont'];
    iGstAmont = json['IGstAmont'];
    sGstUsdAmont = json['SGstUsdAmont'];
    cGstUsdAmont = json['CGstUsdAmont'];
    iGstUsdAmont = json['IGstUsdAmont'];
    totRsAmt = json['TotRsAmt'];
    totUsdAmt = json['TotUsdAmt'];
    roundRs = json['RoundRs'];
    roundUsd = json['RoundUsd'];
    netUsdAmount = json['NetUsdAmount'];
    netRsAmount = json['NetRsAmount'];
    rdType = json['RdType'];
    dollarRate = json['DollarRate'];
    paymentRec = json['PaymentRec'];
    broPer = json['BroPer'];
    broRsAmount = json['BroRsAmount'];
    broUSDAmount = json['BroUSDAmount'];
    brokerCode = json['BrokerCode'];
    bankCode = json['BankCode'];
    partyCode = json['PartyCode'];
    finalRsAmount = json['FinalRsAmount'];
    finalUsdAmount = json['FinalUsdAmount'];
    tPcs = json['TPcs'];
    tWeight = json['TWeight'];
    tRate = json['TRate'];
    tAmount = json['TAmount'];
    tDRate = json['TDRate'];
    tDAmount = json['TDAmount'];
    sflag = json['Sflag'];
    sDate = json['SDate'];
    logID = json['LogID'];
    pCID = json['PCID'];
    ever = json['Ever'];
    companyCode = json['CompanyCode'];
    recPcs = json['RecPcs'];
    issWt = json['IssWt'];
    recWt = json['RecWt'] ?? json['RecCarats'];
    saleWt = json['SaleWt'] ?? json['SaleCarats'];
    outWt = json['OutWt'] ?? json['OutCarats'];
    lossWt = json['LossWt'] ?? json['LossCarats'];
    totalWt = json['TotalWt'] ?? json['TotalCarats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MemoRecMstID'] = memoRecMstID;
    data['PolishDate'] = polishDate;
    data['InvoiceNo'] = invoiceNo;
    data['InvNo'] = invNo;
    data['InvoiceDate'] = invoiceDate;
    data['DueDay'] = dueDay;
    data['DueDate'] = dueDate;
    data['InvCode'] = invCode;
    data['SaleType'] = saleType;
    data['InsuranceName'] = insuranceName;
    data['SGstPer'] = sGstPer;
    data['CGstPer'] = cGstPer;
    data['IGstPer'] = iGstPer;
    data['SGstAmont'] = sGstAmont;
    data['CGstAmont'] = cGstAmont;
    data['IGstAmont'] = iGstAmont;
    data['SGstUsdAmont'] = sGstUsdAmont;
    data['CGstUsdAmont'] = cGstUsdAmont;
    data['IGstUsdAmont'] = iGstUsdAmont;
    data['TotRsAmt'] = totRsAmt;
    data['TotUsdAmt'] = totUsdAmt;
    data['RoundRs'] = roundRs;
    data['RoundUsd'] = roundUsd;
    data['NetUsdAmount'] = netUsdAmount;
    data['NetRsAmount'] = netRsAmount;
    data['RdType'] = rdType;
    data['DollarRate'] = dollarRate;
    data['PaymentRec'] = paymentRec;
    data['BroPer'] = broPer;
    data['BroRsAmount'] = broRsAmount;
    data['BroUSDAmount'] = broUSDAmount;
    data['BrokerCode'] = brokerCode;
    data['BankCode'] = bankCode;
    data['PartyCode'] = partyCode;
    data['FinalRsAmount'] = finalRsAmount;
    data['FinalUsdAmount'] = finalUsdAmount;
    data['TPcs'] = tPcs;
    data['TWeight'] = tWeight;
    data['TRate'] = tRate;
    data['TAmount'] = tAmount;
    data['TDRate'] = tDRate;
    data['TDAmount'] = tDAmount;
    data['Sflag'] = sflag;
    data['SDate'] = sDate;
    data['LogID'] = logID;
    data['PCID'] = pCID;
    data['Ever'] = ever;
    data['CompanyCode'] = companyCode;
    data['RecPcs'] = recPcs;
    data['IssWt'] = issWt;
    data['RecWt'] = recWt;
    data['SaleWt'] = saleWt;
    data['OutWt'] = outWt;
    data['LossWt'] = lossWt;
    data['TotalWt'] = totalWt;
    return data;
  }
}
