class SaleDetailsModel {
  int? polishSaleDetID;
  int? polishSaleMstID;
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

  SaleDetailsModel(
      {this.polishSaleDetID,
      this.polishSaleMstID,
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
      this.description});

  SaleDetailsModel.fromJson(Map<String, dynamic> json) {
    polishSaleDetID = _parseInt(json['PolishSaleDetID']);
    polishSaleMstID = _parseInt(json['PolishSaleMstID']);
    srNo = _parseInt(json['SrNo']);
    clarityCode = _parseInt(json['ClarityCode']);
    charniCode = _parseInt(json['CharniCode']);
    shapeCode = _parseInt(json['ShapeCode']);
    colorCode = _parseInt(json['ColorCode']);
    qualityCode = _parseInt(json['QualityCode']);
    pcs = _parseInt(json['Pcs']);
    carats = json['Carats'];
    rateRs = json['RateRs'];
    amountRs = json['AmountRs'];
    rateD = json['RateD'];
    amountD = json['AmountD'];
    penCarats = json['PenCarats'];
    type = json['Type'];
    invNo = json['InvNo']?.toString();
    roughPurMstID = _parseInt(json['RoughPurMstID']);
    roughTypeCode = _parseInt(json['RoughTypeCode']);
    description = json['Description'];
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PolishSaleDetID'] = polishSaleDetID;
    data['PolishSaleMstID'] = polishSaleMstID;
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
    return data;
  }
}
