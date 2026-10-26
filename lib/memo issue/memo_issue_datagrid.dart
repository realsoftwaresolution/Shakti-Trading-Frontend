import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/memo%20issue/memo_issue_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemoIssueDataGridSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  final DefaultController defaultController = Get.find<DefaultController>();

  MemoIssueDataGridSource(RxList<MemoIssueModel> memoIssueList) {
    _dataGridRows = memoIssueList
        .where((e) => e.companyCode == defaultController.companyCode.value)
        .toList()
        .map<DataGridRow>((purchase) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'ID', value: purchase.memoIssueMstID),
        // DataGridCell<String>(
        //     columnName: 'Invoice No', value: purchase.invoiceNo),
        DataGridCell<String>(
            columnName: 'Invoice Date',
            value: formatDateWithTime(purchase.sDate!)),
        // DataGridCell<String>(
        //     columnName: 'Rec Date', value: purchase.recdate),
        DataGridCell<String>(
            columnName: 'Party', value: getPartyName(purchase.partyCode)),
        DataGridCell<String>(
            columnName: 'Broker', value: getPartyName(purchase.brokerCode)),
        // DataGridCell<double>(columnName: 'Rs /\$', value: purchase.addFixRs),
        // DataGridCell<double>(columnName: 'Exchange', value: purchase.exchange),
        DataGridCell<double>(columnName: 'Tot Wt', value: purchase.tWeight),
        DataGridCell<double>(
            columnName: 'Tot Amt Rs', value: purchase.totRsAmt),
        // DataGridCell<double>(columnName: 'Tot Amt (\$)', value: purchase.totAmtDollar),
        // DataGridCell<String>(columnName: 'Bill Type', value: purchase.bIllType),
        // DataGridCell<double>(columnName: 'Lin Fix Rs', value: purchase.linFixRs),
        // DataGridCell<double>(columnName: 'Tot Exp Fix Rs', value: purchase.totExpFixRs),
        // DataGridCell<double>(columnName: 'Add Fix Rs', value: purchase.addFixRs),
        // DataGridCell<double>(columnName: 'Less Fix Rs', value: purchase.lessFixRs),
        // DataGridCell<double>(columnName: 'Final Net Amt Dollar', value: purchase.finalNetAmtDollar),
        // DataGridCell<double>(columnName: 'Final Net Amt Rs', value: purchase.finalNetAmtRs),
      ]);
    }).toList();
  }

  String formatDateWithTime(String date) {
    // Parse the date string into a DateTime object
    DateTime parsedDate = DateTime.parse(date);

    // Format the DateTime object into the desired format
    String formattedDate =
        DateFormat('dd-MM-yyyy hh:mm:ss a').format(parsedDate);

    return formattedDate;
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    // Check if it's the first column to show "Total" label
    bool isFirstColumn = rowColumnIndex.columnIndex == 0;

    return Container(
      alignment: /*isFirstColumn ? Alignment.centerLeft : */
      Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Text(
        /*isFirstColumn ? 'Total' :*/
        summaryValue,
        // isFirstColumn ? summaryValue : double.tryParse(summaryValue)!.toStringAsFixed(2), // 'Total' in the first column
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
    // Alternate row colors based on the index of the row
    int rowIndex = rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex % 2 == 0
          ? AppColors.tableRowAlt
          : AppColors.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            dataGridCell.value.toString(),
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
