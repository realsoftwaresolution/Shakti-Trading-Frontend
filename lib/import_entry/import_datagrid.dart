import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/import_entry/import_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Search list of the Import screen.
class ImportDataGridSource extends DataGridSource {
  List<DataGridRow> _rows = [];
  final String Function(int? managerId) managerName;

  ImportDataGridSource(List<ImportMstModel> list, {required this.managerName}) {
    final sorted = List<ImportMstModel>.from(list)
      ..sort((a, b) => (b.importDate ?? '').compareTo(a.importDate ?? ''));
    _rows = sorted.map<DataGridRow>((m) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'ID', value: m.importMstID ?? 0),
        DataGridCell<String>(columnName: 'Date', value: _date(m.importDate)),
        DataGridCell<String>(
            columnName: 'Manager',
            value: (m.managerName?.trim().isNotEmpty ?? false) ? m.managerName : managerName(m.managerId)),
        DataGridCell<String>(columnName: 'Kapan No', value: m.kapanNo ?? ''),
        DataGridCell<int>(columnName: 'Pcs', value: m.totPcs),
        DataGridCell<double>(columnName: 'Wt', value: m.totWt),
        DataGridCell<double>(columnName: 'Less Amount', value: m.totLessAmt),
        DataGridCell<double>(columnName: 'Amount', value: m.totAmount),
        DataGridCell<double>(columnName: 'Final Amount', value: m.totFinalAmt),
        DataGridCell<double>(columnName: 'Round Of', value: m.totRoundOf),
      ]);
    }).toList();
  }

  static String _date(String? s) {
    if (s == null || s.trim().isEmpty) return '';
    final p = DateTime.tryParse(s);
    return p == null ? s : DateFormat('dd-MMM-yy').format(p.toLocal());
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex, String summaryValue) {
    if (summaryColumn == null) return null;
    final v = double.tryParse(summaryValue);
    String text = summaryValue;
    if (v != null) {
      if (summaryColumn.name == 'count' || summaryColumn.name == 'Pcs') {
        text = v.toInt().toString();
      } else if (summaryColumn.name == 'Wt') {
        text = NumberFormat('#,##0.000').format(v);
      } else {
        text = NumberFormat('#,##0.00').format(v);
      }
    }
    return Container(
      alignment: summaryColumn.name == 'count' ? Alignment.center : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final i = _rows.indexOf(row);
    return DataGridRowAdapter(
      color: i.isEven ? AppColors.tableRowAlt : AppColors.surface,
      cells: row.getCells().map<Widget>((c) {
        final v = c.value;
        String text;
        Alignment align = Alignment.centerRight;
        switch (c.columnName) {
          case 'ID':
          case 'Date':
            align = Alignment.center;
            text = v?.toString() ?? '';
            break;
          case 'Manager':
          case 'Kapan No':
            align = Alignment.centerLeft;
            text = v?.toString() ?? '';
            break;
          case 'Pcs':
            text = v?.toString() ?? '0';
            break;
          case 'Wt':
            text = ((v as num?) ?? 0).toStringAsFixed(3);
            break;
          default:
            text = ((v as num?) ?? 0).toStringAsFixed(2);
        }
        return Container(
          alignment: align,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(text, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        );
      }).toList(),
    );
  }
}
