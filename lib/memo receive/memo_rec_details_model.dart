class MemoRecDetailsModel {
  int? memoRecDetID;
  int? memoRecMstID;
  int? memoIssueDetID;
  int? srNo;

  int? clarityCode;
  int? charniCode;
  int? shapeCode;
  int? colorCode;
  int? qualityCode;
  int? pcs;
  int? recPcs;
  dynamic carats;
  dynamic recCarats;
  dynamic saleCarats;
  dynamic outCarats;
  dynamic lossCarats;
  dynamic totalCarats;
  dynamic rateRs;
  dynamic amountRs;
  dynamic rateD;
  dynamic amountD;
  dynamic penCarats;
  String? type;
  String? invNo;
  int? roughTypeCode;
  String? description;

  MemoRecDetailsModel({
    this.memoRecDetID,
    this.memoRecMstID,
    this.memoIssueDetID,
    this.srNo,
    this.clarityCode,
    this.charniCode,
    this.shapeCode,
    this.colorCode,
    this.qualityCode,
    this.pcs,
    this.recPcs,
    this.carats,
    this.recCarats,
    this.saleCarats,
    this.outCarats,
    this.lossCarats,
    this.totalCarats,
    this.rateRs,
    this.amountRs,
    this.rateD,
    this.amountD,
    this.penCarats,
    this.type,
    this.invNo,
    this.roughTypeCode,
    this.description,
  });

  MemoRecDetailsModel.fromJson(Map<String, dynamic> json) {
    memoRecDetID = json['MemoRecDetID'];
    memoRecMstID = json['MemoRecMstID'];
    memoIssueDetID = json['MemoIssueDetID'];
    srNo = json['SrNo'];
    clarityCode = json['ClarityCode'];
    charniCode = json['CharniCode'];
    shapeCode = json['ShapeCode'];
    colorCode = json['ColorCode'];
    qualityCode = json['QualityCode'];
    pcs = json['Pcs'];
    recPcs = json['RecPcs'];
    carats = json['Carats'];
    recCarats = json['RecCarats'];
    saleCarats = json['SaleCarats'];
    outCarats = json['OutCarats'];
    lossCarats = json['LossCarats'];
    totalCarats = json['TotalCarats'];
    rateRs = json['RateRs'];
    amountRs = json['AmountRs'];
    rateD = json['RateD'];
    amountD = json['AmountD'];
    penCarats = json['PenCarats'];
    type = json['Type'];
    invNo = json['InvNo'];
    roughTypeCode = json['RoughTypeCode'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MemoRecDetID'] = memoRecDetID;
    data['MemoRecMstID'] = memoRecMstID;
    data['MemoIssueDetID'] = memoIssueDetID;
    data['SrNo'] = srNo;
    data['ClarityCode'] = clarityCode;
    data['CharniCode'] = charniCode;
    data['ShapeCode'] = shapeCode;
    data['ColorCode'] = colorCode;
    data['QualityCode'] = qualityCode;
    data['Pcs'] = pcs;
    data['RecPcs'] = recPcs;
    data['Carats'] = carats;
    data['RecCarats'] = recCarats;
    data['SaleCarats'] = saleCarats;
    data['OutCarats'] = outCarats;
    data['LossCarats'] = lossCarats;
    data['TotalCarats'] = totalCarats;
    data['RateRs'] = rateRs;
    data['AmountRs'] = amountRs;
    data['RateD'] = rateD;
    data['AmountD'] = amountD;
    data['PenCarats'] = penCarats;
    data['Type'] = type;
    data['InvNo'] = invNo;
    data['RoughTypeCode'] = roughTypeCode;
    data['Description'] = description;
    return data;
  }
}
