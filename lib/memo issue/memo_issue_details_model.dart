class MemoIssueDetailsModel {
  int? memoIssueDetID;
  int? memoIssueMstID;
  int? srNo;
  int? clarityCode;
  int? charniCode;
  int? shapeCode;
  int? colorCode;
  int? qualityCode;
  int? pcs;
  dynamic carats;
  dynamic rateRs;
  dynamic amountRs;
  dynamic rateD;
  dynamic amountD;
  dynamic penCarats;
  String? type;
  String? invNo;
  int? roughPurMstID;
  int? roughTypeCode;
  String? description;
  String? rec;

  MemoIssueDetailsModel({
    this.memoIssueDetID,
    this.memoIssueMstID,
    this.srNo,
    this.clarityCode,
    this.charniCode,
    this.shapeCode,
    this.colorCode,
    this.qualityCode,
    this.pcs,
    this.carats,
    this.rateRs,
    this.amountRs,
    this.rateD,
    this.amountD,
    this.penCarats,
    this.type,
    this.invNo,
    this.roughPurMstID,
    this.roughTypeCode,
    this.description,
    this.rec,
  });

  MemoIssueDetailsModel.fromJson(Map<String, dynamic> json) {
    memoIssueDetID = json['MemoIssueDetID'];
    memoIssueMstID = json['MemoIssueMstID'];
    srNo = json['SrNo'];
    clarityCode = _parseInt(json['ClarityCode'] ?? json['clarityCode']);
    charniCode = _parseInt(json['CharniCode'] ?? json['charniCode']);
    shapeCode = _parseInt(json['ShapeCode'] ?? json['shapeCode']);
    colorCode = _parseInt(json['ColorCode'] ?? json['colorCode']);
    qualityCode = _parseInt(json['QualityCode'] ?? json['qualityCode'] ?? json['RoughQualityCode']);
    pcs = json['Pcs'];
    carats = json['Carats'];
    rateRs = json['RateRs'];
    amountRs = json['AmountRs'];
    rateD = json['RateD'];
    amountD = json['AmountD'];
    penCarats = json['PenCarats'];
    type = json['Type'];
    invNo = json['InvNo']?.toString();
    roughPurMstID = json['RoughPurMstID'];
    roughTypeCode = json['RoughTypeCode'];
    description = json['Description'];
    rec = json['Rec'];
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MemoIssueDetID'] = memoIssueDetID;
    data['MemoIssueMstID'] = memoIssueMstID;
    data['SrNo'] = srNo;
    data['ClarityCode'] = clarityCode;
    data['CharniCode'] = charniCode;
    data['ShapeCode'] = shapeCode;
    data['ColorCode'] = colorCode;
    data['QualityCode'] = qualityCode;
    data['Pcs'] = pcs;
    data['Carats'] = carats;
    data['RateRs'] = rateRs;
    data['AmountRs'] = amountRs;
    data['RateD'] = rateD;
    data['AmountD'] = amountD;
    data['PenCarats'] = penCarats;
    data['Type'] = type;
    data['InvNo'] = invNo;
    data['RoughPurMstID'] = roughPurMstID;
    data['RoughTypeCode'] = roughTypeCode;
    data['Description'] = description;
    data['Rec'] = rec;
    return data;
  }
}
