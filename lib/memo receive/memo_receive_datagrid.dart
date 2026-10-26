import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/memo%20receive/memo_rec_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemoReceiveDataGridSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  final DefaultController defaultController = Get.find<DefaultController>();

  MemoReceiveDataGridSource(RxList<MemoRecModel> memoRecList) {
    _dataGridRows = memoRecList
        .where((e) => e.companyCode == defaultController.companyCode.value)
        .toList()
        .map<DataGridRow>((purchase) {
      final details = defaultController.memoRecDetailsList
          .where((d) => d.memoRecMstID == purchase.memoRecMstID)
          .toList();

      int packet;
      double issWt;
      int recPcs;
      double recWt;
      double saleWt;
      double outWt;
      double lossWt;
      double totalWt;
      double amtRs;
      double amtDollar;

      if (details.isNotEmpty) {
        packet = details.fold<int>(0, (sum, d) => sum + (d.pcs ?? 0));
        issWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.carats?.toString() ?? '0') ?? 0.0));
        recPcs = details.fold<int>(0, (sum, d) => sum + (d.recPcs ?? 0));
        recWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.recCarats?.toString() ?? '0') ?? 0.0));
        saleWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.saleCarats?.toString() ?? '0') ?? 0.0));
        outWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.outCarats?.toString() ?? '0') ?? 0.0));
        lossWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.lossCarats?.toString() ?? '0') ?? 0.0));
        totalWt = details.fold<double>(0.0, (sum, d) => sum + (double.tryParse(d.totalCarats?.toString() ?? '0') ?? 0.0));
        if (totalWt == 0.0) {
          totalWt = recWt + saleWt + outWt + lossWt;
        }
        amtRs = details.fold<double>(0.0, (sum, d) {
          final rWt = double.tryParse(d.recCarats?.toString() ?? '0') ?? 0.0;
          final rate = double.tryParse(d.rateRs?.toString() ?? '0') ?? 0.0;
          return sum + (rWt * rate);
        });
        if (amtRs == 0.0) {
          amtRs = double.tryParse(purchase.totRsAmt?.toString() ??
                  purchase.finalRsAmount?.toString() ??
                  purchase.tAmount?.toString() ??
                  '0') ??
              0.0;
        }
        amtDollar = details.fold<double>(0.0, (sum, d) {
          final rWt = double.tryParse(d.recCarats?.toString() ?? '0') ?? 0.0;
          final rateD = double.tryParse(d.rateD?.toString() ?? '0') ?? 0.0;
          return sum + (rWt * rateD);
        });
        if (amtDollar == 0.0) {
          amtDollar = double.tryParse(purchase.totUsdAmt?.toString() ??
                  purchase.finalUsdAmount?.toString() ??
                  purchase.tDAmount?.toString() ??
                  '0') ??
              0.0;
        }
      } else {
        packet = purchase.tPcs ?? 0;
        issWt = double.tryParse(purchase.issWt?.toString() ?? '0') ?? 0.0;
        recPcs = purchase.recPcs ?? 0;
        recWt = double.tryParse(purchase.recWt?.toString() ?? '0') ?? 0.0;
        saleWt = double.tryParse(purchase.saleWt?.toString() ?? '0') ?? 0.0;
        outWt = double.tryParse(purchase.outWt?.toString() ?? '0') ?? 0.0;
        lossWt = double.tryParse(purchase.lossWt?.toString() ?? '0') ?? 0.0;
        totalWt = double.tryParse(purchase.totalWt?.toString() ??
                purchase.tWeight?.toString() ??
                '0') ??
            0.0;
        amtRs = double.tryParse(purchase.totRsAmt?.toString() ??
                purchase.finalRsAmount?.toString() ??
                purchase.tAmount?.toString() ??
                '0') ??
            0.0;
        amtDollar = double.tryParse(purchase.totUsdAmt?.toString() ??
                purchase.finalUsdAmount?.toString() ??
                purchase.tDAmount?.toString() ??
                '0') ??
            0.0;
      }

      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'ID', value: purchase.memoRecMstID),
        DataGridCell<String>(
            columnName: 'Date',
            value: purchase.invoiceDate != null && purchase.invoiceDate!.isNotEmpty
                ? formatDateWithTime(purchase.invoiceDate!)
                : ''),
        DataGridCell<String>(
            columnName: 'Party', value: getPartyName(purchase.partyCode)),
        DataGridCell<String>(
            columnName: 'Broker', value: getPartyName(purchase.brokerCode)),
        DataGridCell<int>(columnName: 'Packet', value: packet),
        DataGridCell<double>(columnName: 'Iss Wt', value: issWt),
        DataGridCell<int>(columnName: 'Rec Pcs', value: recPcs),
        DataGridCell<double>(columnName: 'Rec Wt', value: recWt),
        DataGridCell<double>(columnName: 'Sale Wt', value: saleWt),
        DataGridCell<double>(columnName: 'Out Wt', value: outWt),
        DataGridCell<double>(columnName: 'Loss Wt', value: lossWt),
        DataGridCell<double>(columnName: 'Total Wt', value: totalWt),
        DataGridCell<double>(columnName: 'Tot Amt Rs', value: amtRs),
        DataGridCell<double>(columnName: 'Tot Amt Dollar', value: amtDollar),
      ]);
    }).toList();
  }

  String formatDateWithTime(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy hh:mm:ss a').format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    if (summaryColumn == null) {
      if (rowColumnIndex.columnIndex == 0) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            summaryRow.title ?? 'Total',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return null;
    }

    String displayValue = summaryValue;
    final doubleVal = double.tryParse(summaryValue);

    if (doubleVal != null) {
      if (summaryColumn.name == 'SumPacket' || summaryColumn.name == 'SumRecPcs') {
        displayValue = doubleVal.toInt().toString();
      } else if (summaryColumn.name == 'SumTotAmtRs') {
        displayValue = '₹ ${doubleVal.toStringAsFixed(2)}';
      } else if (summaryColumn.name == 'SumTotAmtDollar') {
        displayValue = '\$ ${doubleVal.toStringAsFixed(2)}';
      } else {
        // Iss Wt, Rec Wt, Sale Wt, Out Wt, Loss Wt, Total Wt
        displayValue = doubleVal.toStringAsFixed(3);
      }
    }

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        displayValue,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex % 2 == 0 ? AppColors.tableRowAlt : AppColors.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        final colName = dataGridCell.columnName;
        final val = dataGridCell.value;

        Alignment alignment = Alignment.centerLeft;
        String text = '';

        if (colName == 'ID' || colName == 'Date') {
          alignment = Alignment.center;
          text = val?.toString() ?? '';
        } else if (colName == 'Party' || colName == 'Broker') {
          alignment = Alignment.centerLeft;
          text = val?.toString() ?? '';
        } else if (colName == 'Packet' || colName == 'Rec Pcs') {
          alignment = Alignment.centerRight;
          final numVal = (val is num) ? val.toInt() : (int.tryParse(val?.toString() ?? '0') ?? 0);
          text = '$numVal';
        } else if (colName == 'Tot Amt Rs') {
          alignment = Alignment.centerRight;
          final numVal = (val is num) ? val.toDouble() : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
          text = '₹ ${numVal.toStringAsFixed(2)}';
        } else if (colName == 'Tot Amt Dollar') {
          alignment = Alignment.centerRight;
          final numVal = (val is num) ? val.toDouble() : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
          text = '\$ ${numVal.toStringAsFixed(2)}';
        } else {
          // Iss Wt, Rec Wt, Sale Wt, Out Wt, Loss Wt, Total Wt
          alignment = Alignment.centerRight;
          final numVal = (val is num) ? val.toDouble() : (double.tryParse(val?.toString() ?? '0') ?? 0.0);
          text = numVal.toStringAsFixed(3);
        }

        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
