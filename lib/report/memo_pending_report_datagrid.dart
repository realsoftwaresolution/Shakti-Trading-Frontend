// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:real_web_rough_entry_system/common/widgets.dart';
// import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// class MemoPendingReportDataGridSource extends DataGridSource {
//   List<DataGridRow> _dataGridRows = [];
//   final DefaultController defaultController = Get.find<DefaultController>();
//
//   MemoPendingReportDataGridSource() {
//     _dataGridRows = defaultController.memoIssueDetailsList
//         .where((e) => e.rec == 'N')
//         .map<DataGridRow>((entry) {
//       int party = _getParty(entry.memoIssueMstID!);
//       int broker = _getBroker(entry.memoIssueMstID!);
//       String date = _getDate(entry.memoIssueMstID!);
//       return DataGridRow(cells: [
//         DataGridCell<String>(
//             columnName: 'Id', value: entry.memoIssueDetID.toString()),
//         DataGridCell<String>(columnName: 'Date', value: formatDate(date)),
//         DataGridCell<String>(
//             columnName: 'Rough',
//             value: getRoughName(entry.roughTypeCode.toString())),
//         DataGridCell<double>(columnName: 'Iss Wt', value: entry.carats),
//         DataGridCell<double>(columnName: 'Rate', value: entry.rateRs),
//         DataGridCell<double>(columnName: 'Amount', value: entry.amountRs),
//         DataGridCell<String>(columnName: 'Party', value: getPartyName(party)),
//         DataGridCell<String>(columnName: 'Broker', value: getPartyName(broker)),
//       ]);
//     }).toList();
//   }
//
//   int _getParty(int mstId) {
//     final relevantDetails = defaultController.memoIssueList
//         .firstWhere((detail) => detail.memoIssueMstID == mstId);
//
//     return relevantDetails.partyCode!;
//   }
//
//   int _getBroker(int mstId) {
//     final relevantDetails = defaultController.memoIssueList
//         .firstWhere((detail) => detail.memoIssueMstID == mstId);
//
//     return relevantDetails.brokerCode!;
//   }
//
//   String _getDate(int mstId) {
//     final relevantDetails = defaultController.memoIssueList
//         .firstWhere((detail) => detail.memoIssueMstID == mstId);
//
//     return relevantDetails.invoiceDate!;
//   }
//
//   @override
//   List<DataGridRow> get rows => _dataGridRows;
//
//   @override
//   DataGridRowAdapter? buildRow(DataGridRow row) {
//     int rowIndex = rows.indexOf(row);
//     return DataGridRowAdapter(
//       color: rowIndex % 2 == 0
//           ? Colors.grey[200] // Light color for even rows
//           : null,
//       cells: row.getCells().map<Widget>((dataGridCell) {
//         return Container(
//           alignment: Alignment.centerLeft,
//           padding: const EdgeInsets.symmetric(horizontal: 5.0),
//           child: Text(
//             dataGridCell.value.toString(),
//             style: const TextStyle(fontSize: 12),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemoPendingReportDataGridSource extends DataGridSource {
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

  MemoPendingReportDataGridSource() {
    _updateDataGridRows();
  }

  // Method to update DataGridRows based on current filters
  void _updateDataGridRows() {
    _dataGridRows = defaultController.memoIssueDetailsList
        .where((e) => e.rec == 'N')
        .where((entry) {
      // Apply from and to date filters
      if (fromDate != null || toDate != null) {
        DateTime entryDate = DateTime.parse(_getDate(entry.memoIssueMstID!));
        if (fromDate != null && entryDate.isBefore(fromDate!)) {
          return false;
        }
        if (toDate != null && entryDate.isAfter(toDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }
      // Apply party filter (check if selectedParties contains the party)
      if (selectedParties != null && selectedParties!.isNotEmpty) {
        int party = _getParty(entry.memoIssueMstID!);
        if (!selectedParties!.contains(party)) {
          return false;
        }
      }
      // Apply broker filter
      if (selectedBrokers != null && selectedBrokers!.isNotEmpty) {
        int party = _getBroker(entry.memoIssueMstID!);
        if (!selectedBrokers!.contains(party)) {
          return false;
        }
      }
      // Apply rough type filter
      if (selectedRoughs != null && selectedRoughs!.isNotEmpty) {
        if (!selectedRoughs!.contains(entry.roughTypeCode)) {
          return false;
        }
      }
      return true;
    })
        .map<DataGridRow>((entry) {
      int party = _getParty(entry.memoIssueMstID!);
      int broker = _getBroker(entry.memoIssueMstID!);
      String date = _getDate(entry.memoIssueMstID!);
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'Id', value: entry.memoIssueDetID.toString()),
        DataGridCell<String>(columnName: 'Date', value: formatDate(date)),
        DataGridCell<String>(
            columnName: 'Rough',
            value: getRoughName(entry.roughTypeCode.toString())),
        DataGridCell<dynamic>(columnName: 'Iss Wt', value: entry.carats),
        DataGridCell<dynamic>(columnName: 'Rate', value: entry.rateRs),
        DataGridCell<dynamic>(columnName: 'Amount', value: entry.amountRs),
        DataGridCell<String>(columnName: 'Party', value: getPartyName(party)),
        DataGridCell<String>(columnName: 'Broker', value: getPartyName(broker)),
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
  int _getParty(int mstId) {
    final relevantDetails = defaultController.memoIssueList
        .firstWhereOrNull((detail) => detail.memoIssueMstID == mstId);
    return relevantDetails?.partyCode ?? 0;
  }

  // Fetch broker code from memoIssueMstID
  int _getBroker(int mstId) {
    final relevantDetails = defaultController.memoIssueList
        .firstWhereOrNull((detail) => detail.memoIssueMstID == mstId);
    return relevantDetails?.brokerCode ?? 0;
  }

  // Fetch date from memoIssueMstID
  String _getDate(int mstId) {
    final relevantDetails = defaultController.memoIssueList
        .firstWhereOrNull((detail) => detail.memoIssueMstID == mstId);
    return relevantDetails?.invoiceDate ?? '';
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
