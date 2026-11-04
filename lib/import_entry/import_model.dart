// Import (Polish Import) - master + item models.
//
// Field names follow the planned backend (same style as the other screens):
//   ImportMst : ImportMstID, ImportDate, ManagerId, KapanNo, TotPcs, TotWt,
//               TotLessRate, TotLessAmt, TotRate, TotAmount, TotFinalAmt, TotRoundOf, CompanyCode, ...
//   ImportDet : ImportDetID, ImportMstID, SrNo, KapanNo, PolishTypeCode,
//               ShapeCode, ClarityCode, CharniCode, ColorCode, Pcs, Wt,
//               LessRate, LessAmount, Rate, Amount, FinalAmount, RoundOf

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int? _i(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

class ImportMstModel {
  int? importMstID;
  String? importDate;
  int? managerId;
  String? managerName;
  String? kapanNo;
  int totPcs;
  double totWt;
  double totLessRate;
  double totLessAmt;
  double totRate;
  double totAmount;
  double totFinalAmt;
  double totRoundOf;
  int? companyCode;

  ImportMstModel({
    this.importMstID,
    this.importDate,
    this.managerId,
    this.managerName,
    this.kapanNo,
    this.totPcs = 0,
    this.totWt = 0,
    this.totLessRate = 0,
    this.totLessAmt = 0,
    this.totRate = 0,
    this.totAmount = 0,
    this.totFinalAmt = 0,
    this.totRoundOf = 0,
    this.companyCode,
  });

  factory ImportMstModel.fromJson(Map<String, dynamic> j) => ImportMstModel(
        importMstID: _i(j['ImportMstID'] ?? j['importMstID']),
        importDate: (j['ImportDate'] ?? j['importDate'])?.toString(),
        managerId: _i(j['ManagerId'] ?? j['managerId'] ?? j['LogID']),
        managerName: (j['ManagerName'] ?? j['managerName'])?.toString(),
        kapanNo: (j['KapanNo'] ?? j['kapanNo'])?.toString(),
        totPcs: _i(j['TotPcs'] ?? j['totPcs']) ?? 0,
        totWt: _d(j['TotWt'] ?? j['totWt']),
        totLessRate: _d(j['TotLessRate'] ?? j['totLessRate']),
        totLessAmt: _d(j['TotLessAmt'] ?? j['totLessAmt']),
        totRate: _d(j['TotRate'] ?? j['totRate']),
        totAmount: _d(j['TotAmount'] ?? j['totAmount']),
        totFinalAmt: _d(j['TotFinalAmt'] ?? j['totFinalAmt']),
        totRoundOf: _d(j['TotRoundOf'] ?? j['totRoundOf']),
        companyCode: _i(j['CompanyCode'] ?? j['companyCode']),
      );
}

class ImportDetModel {
  int? importDetID;
  int? importMstID;
  int? srNo;
  String? kapanNo;
  int? polishTypeCode;
  int? shapeCode;
  int? clarityCode;
  int? charniCode;
  int? colorCode;
  int pcs;
  double wt;
  double lessRate;
  double lessAmount;
  double rate;
  double amount;
  double finalAmount;
  double roundOf;

  ImportDetModel({
    this.importDetID,
    this.importMstID,
    this.srNo,
    this.kapanNo,
    this.polishTypeCode,
    this.shapeCode,
    this.clarityCode,
    this.charniCode,
    this.colorCode,
    this.pcs = 0,
    this.wt = 0,
    this.lessRate = 0,
    this.lessAmount = 0,
    this.rate = 0,
    this.amount = 0,
    this.finalAmount = 0,
    this.roundOf = 0,
  });

  factory ImportDetModel.fromJson(Map<String, dynamic> j) => ImportDetModel(
        importDetID: _i(j['ImportDetID'] ?? j['importDetID']),
        importMstID: _i(j['ImportMstID'] ?? j['importMstID']),
        srNo: _i(j['SrNo'] ?? j['srNo']),
        kapanNo: (j['KapanNo'] ?? j['kapanNo'])?.toString(),
        polishTypeCode: _i(j['PolishTypeCode'] ?? j['polishTypeCode']),
        shapeCode: _i(j['ShapeCode'] ?? j['shapeCode']),
        clarityCode: _i(j['ClarityCode'] ?? j['clarityCode']),
        charniCode: _i(j['CharniCode'] ?? j['charniCode']),
        colorCode: _i(j['ColorCode'] ?? j['colorCode']),
        pcs: _i(j['Pcs'] ?? j['pcs']) ?? 0,
        wt: _d(j['Wt'] ?? j['wt']),
        lessRate: _d(j['LessRate'] ?? j['lessRate']),
        lessAmount: _d(j['LessAmount'] ?? j['lessAmount']),
        rate: _d(j['Rate'] ?? j['rate']),
        amount: _d(j['Amount'] ?? j['amount']),
        finalAmount: _d(j['FinalAmount'] ?? j['finalAmount']),
        roundOf: _d(j['RoundOf'] ?? j['roundOf']),
      );
}

/// One Import with its items (GET /import/:id).
class ImportFull {
  final ImportMstModel master;
  final List<ImportDetModel> items;

  ImportFull({required this.master, required this.items});
}
