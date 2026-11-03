
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class OutstandingSaleReportDataGridSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  final DefaultController defaultController = Get.find<DefaultController>();

  // Filters
  DateTime? fromDate;
  DateTime? toDate;
  // int? selectedParty;
  List<int>? selectedParties; // Change to a list
  List<int>? selectedBrokers; // Change to a list
  List<int>? selectedRoughs; // Change to a list
  // int? selectedBroker;
  // String? selectedRoughType;

  OutstandingSaleReportDataGridSource() {
    _updateDataGridRows();
  }

  Future<void> exportToPdf(BuildContext context) async {
    if (_dataGridRows.isEmpty) {
      infoDialog(messageText: 'No Data Available');
      return;
    }
    _updateDataGridRows();
    // Create PDF document and add a page
    final PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    final PdfPage page = document.pages.add();

    // Get graphics of the page to draw text
    final PdfGraphics graphics = page.graphics;

    // Define title text and style
    String title = '.:: Sale Outstanding ::.';
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final Size titleSize = titleFont.measureString(title);

    // Draw the title at the top center of the page
    graphics.drawString(
      title,
      titleFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(
        (page.getClientSize().width - titleSize.width) / 2, // Center align
        0, // Position from the top
        titleSize.width,
        titleSize.height,
      ),
    );

    // Create PDF Grid
    final PdfGrid pdfGrid = PdfGrid();
    pdfGrid.columns.add(count: _dataGridRows[0].getCells().length);

    // Add Header Row
    _addHeaderRow(pdfGrid);

    // Add Data Rows
    _addDataRows(pdfGrid);
    _addSummaryRow(pdfGrid);

    // Apply Grid Style (No Padding)
    _applyNoPaddingGridStyle(pdfGrid);

    // Draw the grid below the title
    pdfGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, titleSize.height + 5, page.getClientSize().width, page.getClientSize().height),
    );

    // Add footer at the bottom of the page
    // const String pageText = 'Page No.: 1                User : A'; // Footer text
    // final PdfFont footerFont = PdfStandardFont(PdfFontFamily.helvetica, 10); // Font for footer
    // final Size footerSize = footerFont.measureString(pageText); // Measure footer width

    // Draw the footer text at the bottom center
    // graphics.drawString(
    //   pageText,
    //   footerFont,
    //   brush: PdfBrushes.black,
    //   bounds: Rect.fromLTWH(
    //     (page.getClientSize().width - footerSize.width) / 2, // Center align footer
    //     page.getClientSize().height - footerSize.height - 10, // Position near bottom
    //     footerSize.width,
    //     footerSize.height,
    //   ),
    // );

    // Save and display the PDF
    await _saveAndDisplayPdf(document);
  }

  void _addSummaryRow(PdfGrid pdfGrid) {
    // Create a summary row (adjust column count and values as needed)
    final PdfGridRow summaryRow = pdfGrid.rows.add();

    // Add your summary data, for example, total values
    double invAmount = 0.0;
    double outAmount = 0.0;
    double totalOutAmount = 0.0;
    for (var row in _dataGridRows) {
      final invAmt = row.getCells()[5].value; // Assuming column index 4 contains the 'Amount' value
      final outAmt = row.getCells()[6].value; // Assuming column index 4 contains the 'Amount' value
      final totOutAmt = row.getCells()[7].value; // Assuming column index 4 contains the 'Amount' value
      if (invAmt != null) {
        invAmount += invAmt;
      }
      if (outAmt != null) {
        outAmount += outAmt;
      }
      if (totOutAmt != null) {
        totalOutAmount += totOutAmt;
      }
    }

    // Set the summary row values
    summaryRow.cells[0].value = 'Total';  // First column (for label)
    summaryRow.cells[1].value = '';         // Empty column if not needed
    summaryRow.cells[2].value = '';         // Empty column if not needed
    summaryRow.cells[3].value = '';         // Empty column if not needed
    summaryRow.cells[4].value = '';  // Total Amount
    summaryRow.cells[5].value = invAmount.toStringAsFixed(2);  // Total Amount
    summaryRow.cells[6].value = outAmount.toStringAsFixed(2);  // Total Amount
    summaryRow.cells[7].value = totalOutAmount.toStringAsFixed(2);  // Total Amount

    // Customize the row style if needed
    summaryRow.style.backgroundBrush = PdfBrushes.lightGray;
    summaryRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
  }


  void _addHeaderRow(PdfGrid pdfGrid) {
    final PdfGridRow headerRow = pdfGrid.headers.add(1)[0];
    for (int i = 0; i < _dataGridRows[0].getCells().length; i++) {
      headerRow.cells[i].value = _dataGridRows[0].getCells()[i].columnName;
      headerRow.cells[i].style = PdfGridCellStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      );
    }
  }

  void _addDataRows(PdfGrid pdfGrid) {
    for (var row in _dataGridRows) {
      final PdfGridRow pdfRow = pdfGrid.rows.add();
      for (int i = 0; i < row.getCells().length; i++) {
        pdfRow.cells[i].value = row.getCells()[i].value?.toString() ?? '';
      }
    }
  }

  void _applyNoPaddingGridStyle(PdfGrid pdfGrid) {
    pdfGrid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 5, right: 5, top: 2, bottom: 2), // Remove all padding
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    );
  }

  Future<void> _saveAndDisplayPdf(PdfDocument document) async {
    // Save the PDF document
    final List<int> bytes = await document.save();
    document.dispose();

    // Convert to Uint8List and display using Printing package
    final Uint8List pdfData = Uint8List.fromList(bytes);
    await Printing.layoutPdf(
      onLayout: (pdf.PdfPageFormat format) async => pdfData,
    );
  }


  // Method to update DataGridRows based on current filters
  void _updateDataGridRows() {
    _dataGridRows =
        defaultController.outstandingPurchaseSaleDetailsList.where((entry) {
      // Apply from and to date filters
      if (fromDate != null || toDate != null) {
        DateTime entryDate = DateTime.parse(_getDate(entry.invNo!));
        if (fromDate != null && entryDate.isBefore(fromDate!)) {
          return false;
        }
        if (toDate != null &&
            entryDate.isAfter(toDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }
      // Apply party filter (check if selectedParties contains the party)
      if (selectedParties != null && selectedParties!.isNotEmpty) {
        int party = _getParty(entry.invNo!);
        if (!selectedParties!.contains(party)) {
          return false;
        }
      }
      // Apply broker filter
      if (selectedBrokers != null && selectedBrokers!.isNotEmpty) {
        int party = _getBroker(entry.invNo!);
        if (!selectedBrokers!.contains(party)) {
          return false;
        }
      }

      if (entry.trnType != 'Sale') {
        return false;
      }
      // Apply rough type filter
      // if (selectedRoughs != null && selectedRoughs!.isNotEmpty) {
      //   if (!selectedRoughs!.contains(entry.roughTypeCode)) {
      //     return false;
      //   }
      // }
      return true;
    }).map<DataGridRow>((entry) {
      int party = _getParty(entry.invNo!);
      int broker = _getBroker(entry.invNo!);
      String date = _getDate(entry.invNo!);
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'Inv No.', value: entry.invNo),
        DataGridCell<String>(
            columnName: 'Inv Date', value: formatDate(entry.orgInvDate!)),
        DataGridCell<int>(columnName: 'Due Days', value: entry.dueDays),
        DataGridCell<String>(
            columnName: 'Due Date', value: formatDate(entry.dueDate!)),
        DataGridCell<String>(columnName: 'Party', value: getPartyName(party)),
        // DataGridCell<String>(columnName: 'Broker', value: getPartyName(broker)),
        // DataGridCell<double>(columnName: 'Ct', value: entry.orgCt),
        DataGridCell<double>(columnName: 'Inv Amt Rs', value: entry.amtRs),
        DataGridCell<double>(columnName: 'Out Rs', value: entry.oAmtRs),
        DataGridCell<double>(columnName: 'Tot Out Rs', value: entry.bAmtRs),
      ]);
    }).toList();

    notifyListeners(); // Notify the DataGrid to refresh
  }

  // Methods to update the filters
  void setFromDate(DateTime? date) {
    fromDate = date;
    // print("SELECTED FROM DATE : $fromDate");
    _updateDataGridRows();
  }

  void setToDate(DateTime? date) {
    toDate = date;
    // print("SELECTED TO DATE : $toDate");
    _updateDataGridRows();
  }

  void setSelectedParties(List<int>? partyCodes) {
    selectedParties = partyCodes;
    // print("SELECTED Party CODE : $selectedParties");
    _updateDataGridRows();
  }

  // void setSelectedBroker(int? brokerCode) {
  //   selectedBroker = brokerCode;
  //   // print("SELECTED BROKER CODE : $selectedBroker");
  //   _updateDataGridRows();
  // }

  void setSelectedBrokers(List<int>? brokersCodes) {
    selectedBrokers = brokersCodes;
    // print("SELECTED Broker CODE : $selectedBrokers");
    _updateDataGridRows();
  }

  void setSelectedRoughs(List<int> roughCodes) {
    selectedRoughs = roughCodes;
    // print("SELECTED ROUGH CODE : $selectedRoughs");
    _updateDataGridRows();
  }

  void clearFilter() {
    fromDate = null;
    toDate = null;
    selectedParties = null; // Clear selected parties
    selectedBrokers = null;
    selectedRoughs = null;

    // print("All filters cleared.");

    _updateDataGridRows(); // Refresh the data grid rows after clearing the filters
  }

  // Fetch party code from memoIssueMstID
  int _getParty(String invNo) {
    final relevantDetails = defaultController.outstandingPurchaseSaleDetailsList
        .firstWhereOrNull((detail) => detail.invNo == invNo);
    return relevantDetails?.partyCode ?? 0;
  }

  // Fetch broker code from memoIssueMstID
  int _getBroker(String invNo) {
    final relevantDetails = defaultController.outstandingPurchaseSaleDetailsList
        .firstWhereOrNull((detail) => detail.invNo == invNo);
    return relevantDetails?.orgBrokerCode ?? 0;
  }

  // Fetch date from memoIssueMstID
  String _getDate(String invNo) {
    final relevantDetails = defaultController.outstandingPurchaseSaleDetailsList
        .firstWhereOrNull((detail) => detail.invNo == invNo);
    return relevantDetails?.dueDate ?? '';
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    // Check if it's the first column to show "Total" label
    // bool isFirstColumn = rowColumnIndex.columnIndex == 0;

    return Container(
      alignment: /*isFirstColumn ? Alignment.centerLeft : */
      Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Text(
        /*isFirstColumn ? 'Total' :*/
        summaryValue, // 'Total' in the first column
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
  DataGridRowAdapter? buildRow(DataGridRow row) {
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
