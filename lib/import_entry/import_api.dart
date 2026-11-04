import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/import_entry/import_model.dart';
import 'package:real_web_rough_entry_system/services/api_service.dart';

/// API calls of the Import screen (single-save pattern, same as the other
/// transaction screens):
///   GET    rough-entry/import?companyCode=   -> list (masters)
///   GET    rough-entry/import/:id            -> { master, items }
///   POST   rough-entry/import/save           -> body { master, items }
///   PUT    rough-entry/import/save/:id       -> body { master, items }
///   DELETE rough-entry/import/full/:id
///
/// The backend for these routes is not made yet - until then saving shows the
/// server's error message.
class ImportApi {
  ImportApi._();
  static final ImportApi to = ImportApi._();

  final RxList<ImportMstModel> importList = <ImportMstModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleteLoading = false.obs;

  DefaultController get _dc => Get.find<DefaultController>();
  String get _base => '${ApiService.to.baseUrl}rough-entry/import';

  String _errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (data is String && data.trim().isNotEmpty) return data;
      if (error.response?.statusCode == 404) {
        return '$fallback (Import API is not available on the server yet)';
      }
    }
    return fallback;
  }

  List<dynamic> _listOf(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  /// Import list of the selected company (Search screen).
  Future<void> getImportList({bool force = false}) async {
    if (!force && importList.isNotEmpty) return;
    try {
      final res = await ApiService.to.dio.get(
        _base,
        queryParameters: {'companyCode': _dc.companyCode.value},
      );
      importList.assignAll(_listOf(res.data)
          .whereType<Map>()
          .map((e) => ImportMstModel.fromJson(Map<String, dynamic>.from(e))));
    } catch (e) {
      log('getImportList error: $e');
      importList.clear();
    }
  }

  /// One Import with its items, or null.
  Future<ImportFull?> getImportById(int id) async {
    try {
      final res = await ApiService.to.dio.get('$_base/$id');
      final data = (res.data is Map && res.data['data'] is Map) ? res.data['data'] : res.data;
      if (data is! Map) return null;
      final masterJson = data['master'] is Map ? data['master'] : data;
      final itemsJson = data['items'] ?? data['details'] ?? const [];
      return ImportFull(
        master: ImportMstModel.fromJson(Map<String, dynamic>.from(masterJson as Map)),
        items: (itemsJson as List)
            .whereType<Map>()
            .map((e) => ImportDetModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      log('getImportById error: $e');
      await errorDialog(messageText: _errorMessage(e, 'Could not load Import $id'));
      return null;
    }
  }

  Map<String, dynamic> _masterJson(ImportMstModel m) => {
        if (m.importMstID != null && m.importMstID! > 0) 'ImportMstID': m.importMstID,
        'ImportDate': m.importDate,
        'ManagerId': m.managerId,
        'KapanNo': m.kapanNo,
        'TotPcs': m.totPcs,
        'TotWt': double.parse(m.totWt.toStringAsFixed(3)),
        'TotLessRate': double.parse(m.totLessRate.toStringAsFixed(2)),
        'TotLessAmt': double.parse(m.totLessAmt.toStringAsFixed(2)),
        'TotRate': double.parse(m.totRate.toStringAsFixed(2)),
        'TotAmount': double.parse(m.totAmount.toStringAsFixed(2)),
        'TotFinalAmt': double.parse(m.totFinalAmt.toStringAsFixed(2)),
        'TotRoundOf': double.parse(m.totRoundOf.toStringAsFixed(2)),
        'CompanyCode': _dc.companyCode.value,
        'LogID': _dc.currentUserId.value,
        'PcID': _dc.currentPcId.value.trim().isNotEmpty ? _dc.currentPcId.value.trim() : 'WEB',
      };

  Map<String, dynamic> _itemJson(ImportDetModel d) => {
        if (d.importDetID != null && d.importDetID! > 0) 'ImportDetID': d.importDetID,
        'SrNo': d.srNo,
        'KapanNo': d.kapanNo,
        'PolishTypeCode': d.polishTypeCode,
        'ShapeCode': d.shapeCode,
        'ClarityCode': d.clarityCode,
        'CharniCode': d.charniCode,
        'ColorCode': d.colorCode,
        'Pcs': d.pcs,
        'Wt': double.parse(d.wt.toStringAsFixed(3)),
        'LessRate': double.parse(d.lessRate.toStringAsFixed(2)),
        'LessAmount': double.parse(d.lessAmount.toStringAsFixed(2)),
        'Rate': double.parse(d.rate.toStringAsFixed(2)),
        'Amount': double.parse(d.amount.toStringAsFixed(2)),
        'FinalAmount': double.parse(d.finalAmount.toStringAsFixed(2)),
        'RoundOf': double.parse(d.roundOf.toStringAsFixed(2)),
      };

  /// Save (add when id is empty, else update) master + items in one request.
  Future<bool> saveImport(ImportMstModel master, List<ImportDetModel> items) async {
    final bool isEdit = master.importMstID != null && master.importMstID! > 0;
    isLoading.value = true;
    try {
      final body = {
        'master': _masterJson(master),
        'items': items.map(_itemJson).toList(),
      };
      final res = isEdit
          ? await ApiService.to.dio.put('$_base/save/${master.importMstID}', data: body)
          : await ApiService.to.dio.post('$_base/save', data: body);
      final msg = (res.data is Map && res.data['message'] != null)
          ? res.data['message'].toString()
          : (isEdit ? 'Import Updated Successfully' : 'Import Saved Successfully');
      await successDialog(messageText: msg);
      await getImportList(force: true);
      return true;
    } catch (e) {
      log('saveImport error: $e');
      await errorDialog(messageText: _errorMessage(e, 'Failed to save Import'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteImport(int id) async {
    isDeleteLoading.value = true;
    try {
      final res = await ApiService.to.dio.delete('$_base/full/$id');
      final msg = (res.data is Map && res.data['message'] != null)
          ? res.data['message'].toString()
          : 'Import Deleted Successfully';
      await successDialog(messageText: msg);
      await getImportList(force: true);
      return true;
    } catch (e) {
      log('deleteImport error: $e');
      await errorDialog(messageText: _errorMessage(e, 'Failed to delete Import'));
      return false;
    } finally {
      isDeleteLoading.value = false;
    }
  }
}
