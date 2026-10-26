import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_web_rough_entry_system/app_theme.dart';
import 'package:real_web_rough_entry_system/common/company_select_dialog.dart';
import 'package:real_web_rough_entry_system/common/login_dialog.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';
import 'package:real_web_rough_entry_system/controllers/theme_controller.dart';
import 'package:real_web_rough_entry_system/main/company_mst_model.dart';
import 'package:real_web_rough_entry_system/party/party_model.dart';
import 'package:real_web_rough_entry_system/party/party_type_model.dart';
import 'package:real_web_rough_entry_system/payment/payment_form_screen.dart';
import 'package:real_web_rough_entry_system/purchase/outstanding_purchase_details.dart';
import 'package:real_web_rough_entry_system/purchase/purchase_details_model.dart';
import 'package:real_web_rough_entry_system/rough/rough_details_model.dart';
import 'package:real_web_rough_entry_system/rough/rough_model.dart';
import 'package:real_web_rough_entry_system/sale/sale_details_model.dart';
import 'package:real_web_rough_entry_system/sale/sale_model.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_controller.dart';
import 'package:real_web_rough_entry_system/tab-view-dashboard/tab_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DefaultController defaultController = Get.find<DefaultController>();
final TabControllerX tabController = Get.find<TabControllerX>();

Future<void> infoDialog({required String messageText}) async {
  if (Get.overlayContext == null) return;
  try {
    Get.defaultDialog(
      title: 'Alert',
      content: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true, // Automatically listens for keyboard events
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            Get.back(); // Close dialog on Enter key press
          }
        },
        child: Text(messageText),
      ),
      barrierDismissible: false,
      // Prevent closing by tapping outside
      onConfirm: () {
        Get.back(); // Close the dialog on button press
      },
      textConfirm: 'OK',
    );
  } catch (_) {}
}

Future<void> successDialog({required String messageText}) async {
  if (Get.overlayContext == null) return;
  try {
    Get.defaultDialog(
      title: 'Success',
      content: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true, // Automatically listens for keyboard events
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            Get.back(); // Close dialog on Enter key press
          }
        },
        child: Text(messageText),
      ),
      barrierDismissible: false,
      // Prevent closing by tapping outside
      onConfirm: () {
        Get.back(); // Close the dialog on button press
      },
      textConfirm: 'OK',
    );
  } catch (_) {}
}

Future<void> errorDialog({required String messageText}) async {
  if (Get.overlayContext == null) return;
  try {
    Get.defaultDialog(
      title: 'Error',
      content: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true, // Automatically listens for keyboard events
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            Get.back(); // Close dialog on Enter key press
          }
        },
        child: Text(messageText),
      ),
      barrierDismissible: false,
      // Prevent closing by tapping outside
      onConfirm: () {
        Get.back(); // Close the dialog on button press
      },
      textConfirm: 'OK',
    );
  } catch (_) {}
}

Widget buildTextField(String label, TextEditingController? controller,
    {List<TextInputFormatter>? inputFormatterList,
    VoidCallback? onTap,
    bool? readOnly,
    bool? isEnabled,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    FocusNode? focusNode,
    required bool excludeFieldValidation}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 12, // Font size for the label
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          // width: 30,
          child: TextFormField(
            readOnly: readOnly ?? false,
            onTap: onTap,
            controller: controller,
            keyboardType: TextInputType.number,
            enabled: isEnabled,
            focusNode: focusNode,
            textInputAction: TextInputAction.next,
            inputFormatters: inputFormatterList,
            decoration: const InputDecoration(
              errorStyle: TextStyle(
                height: 0, // Hides the error message
                fontSize: 0, // Ensures no space is taken by the error message
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  // Red border when focused with an error
                  width: 1.0, // Thin border width
                ),
                borderRadius: BorderRadius.zero, // Squared corners
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  // Red border for errors
                  width: 1.0, // Thin border width
                ),
                borderRadius: BorderRadius.zero, // Squared corners
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  // Black border when focused without error
                  width: 1.0, // Thin border width
                ),
                borderRadius: BorderRadius.zero, // Squared corners
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  // Light grey border when enabled
                  width: 1.0, // Thin border width
                ),
                borderRadius: BorderRadius.zero, // Squared corners
              ),
              // filled: true,
              // Fill the background
              // fillColor: Colors.white,
              // White background
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ), // Remove top padding, minimal horizontal padding
            ),
            cursorColor: AppColors.primary,
            // Black cursor color
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12, // Consistent font size with label
            ),
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            validator: (value) {
              if (excludeFieldValidation) {
                return null; // Skip validation for this field
              }
              if (value == null || value.isEmpty) {
                return ''; // Validation still occurs, but no message is shown
              }
              return null;
            },
          ),
        ),
      ),
    ],
  );
}

Widget buildTextField2(String label, TextEditingController? controller,
    {List<TextInputFormatter>? inputFormatterList,
    VoidCallback? onTap,
    bool? isEnabled,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode}) {
  return TextFormField(
    onTap: onTap,
    controller: controller,
    keyboardType: TextInputType.number,
    enabled: isEnabled,
    focusNode: focusNode,
    textInputAction: TextInputAction.next,
    inputFormatters: inputFormatterList,
    decoration: const InputDecoration(
      border: InputBorder.none,
      errorStyle: TextStyle(
        height: 0, // Hides the error message
        fontSize: 0, // Ensures no space is taken by the error message
      ),
      // focusedErrorBorder: UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.red,
      //     // Red border when focused with an error
      //     width: 1.0, // Thin border width
      //   ),
      //   borderRadius: BorderRadius.zero, // Squared corners
      // ),
      // errorBorder: UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.red,
      //     // Red border for errors
      //     width: 1.0, // Thin border width
      //   ),
      //   borderRadius: BorderRadius.zero, // Squared corners
      // ),
      // focusedBorder: UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.blue,
      //     // Black border when focused without error
      //     width: 1.0, // Thin border width
      //   ),
      //   borderRadius: BorderRadius.zero, // Squared corners
      // ),
      // enabledBorder: UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.grey,
      //     // Light grey border when enabled
      //     width: 1.0, // Thin border width
      //   ),
      //   borderRadius: BorderRadius.zero, // Squared corners
      // ),
      // filled: true,
      // Fill the background
      // fillColor: Colors.white,
      // White background
      isDense: true,
      // Reduces the overall height of the TextField
      contentPadding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ), // Remove top padding, minimal horizontal padding
    ),
    cursorColor: AppColors.primary,
    // Black cursor color
    style: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 12, // Consistent font size with label
    ),
    onChanged: onChanged,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return ''; // Validation still occurs, but no message is shown
      }
      return null;
    },
  );
}

Widget buildBottomButton(
    {required String text,
    required VoidCallback? onPressed,
    double width = 65}) {
  return SizedBox(
    width: width, // Adjust width as per your requirement
    height: 25, // Adjust height to match the TextField's height
    child: OutlinedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // side: const BorderSide(color: Colors.blue), // Border color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5), // Padding similar to TextField
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold), // Same font size as TextFormField
      ),
    ),
  );
}

String getRoughName(String? typeCode) {
  if (typeCode == null || typeCode.trim().isEmpty) return '';
  final parsed = int.tryParse(typeCode.trim());
  if (parsed == null) return typeCode;
  final party = defaultController.roughModel.firstWhere(
      (p) => p.roughTypeCode == parsed,
      orElse: () => RoughModel(roughTypeName: typeCode));
  return party.roughTypeName ?? typeCode;
}

String getPartyName(int? partyCode) {
  final party = defaultController.partyMstList.firstWhere(
      (p) => p.partyCode == partyCode,
      orElse: () => PartyMstModel(partyName: 'Unknown'));
  return party.partyName ?? 'Unknown';
}

String getQualityName(dynamic qualityCode) {
  if (qualityCode == null || qualityCode.toString().isEmpty) return '-';
  final item = defaultController.qualityModelList.firstWhereOrNull(
      (q) => q.qualityCode.toString() == qualityCode.toString() ||
             q.qualityMstID.toString() == qualityCode.toString());
  return item?.qualityName ?? qualityCode.toString();
}

String getCharniName(dynamic charniCode) {
  if (charniCode == null || charniCode.toString().isEmpty) return '-';
  final item = defaultController.charniModelList.firstWhereOrNull(
      (c) => c.charniCode.toString() == charniCode.toString() ||
             c.charniMstID.toString() == charniCode.toString());
  return item?.charniName ?? charniCode.toString();
}

String getPolishTypeName(dynamic code) {
  if (code == null || code.toString().isEmpty) return '-';
  final item = defaultController.polishTypeModelList.firstWhereOrNull(
      (p) => p.polishTypeCode.toString() == code.toString() ||
             p.polishTypeMstId.toString() == code.toString() ||
             p.polishTypeName?.toLowerCase() == code.toString().toLowerCase());
  return item?.polishTypeName ?? code.toString();
}

String getShapeName(dynamic code) {
  if (code == null || code.toString().isEmpty) return '-';
  final item = defaultController.shapeModelList.firstWhereOrNull(
      (s) => s.shapeCode.toString() == code.toString() ||
             s.shapeMstId.toString() == code.toString() ||
             s.shapeName?.toLowerCase() == code.toString().toLowerCase());
  return item?.shapeName ?? code.toString();
}

String getClarityName(dynamic code) {
  if (code == null || code.toString().isEmpty) return '-';
  final item = defaultController.clarityModelList.firstWhereOrNull(
      (c) => c.clarityMstID.toString() == code.toString() ||
             c.clarityName?.toLowerCase() == code.toString().toLowerCase());
  return item?.clarityName ?? code.toString();
}

String getColorName(dynamic code) {
  if (code == null || code.toString().isEmpty) return '-';
  final item = defaultController.colorModelList.firstWhereOrNull(
      (c) => c.colorCode.toString() == code.toString() ||
             c.colorMstID.toString() == code.toString() ||
             c.colorName?.toLowerCase() == code.toString().toLowerCase());
  return item?.colorName ?? code.toString();
}

String getPartyType(int? typeCode) {
  final partyType = defaultController.partyTypeMstList.firstWhere(
      (pt) => pt.typeCode == typeCode,
      orElse: () => PartyTypeMstModel(typeName: 'Unknown'));
  return partyType.typeName ?? 'Unknown';
}

String getCompanyName(int? cmpCode) {
  final partyType = defaultController.companies.firstWhere(
      (pt) => pt.companyCode == cmpCode,
      orElse: () => CompanyMst(
        companyCode: cmpCode ?? 3,
        companyName: 'Abhinandan Diamond',
        address: '204 Shraddhajyot Building, Mahidharpura, Surat',
        mobileno: '8926555111',
      ));
  return partyType.companyName ?? 'Abhinandan Diamond';
}

dynamic getTotalWeight(String? invNo) {
  final partyType = defaultController.purchaseDataList.firstWhere(
    (pt) => pt.invoiceNo == invNo,
  );
  return partyType.tWeight ?? 'Unknown';
}

CompanyMst getCompanyDetails(int? cmpCode) {
  final partyType = defaultController.companies.firstWhere(
      (pt) => pt.companyCode == cmpCode,
      orElse: () => CompanyMst(
        companyCode: cmpCode ?? 3,
        companyName: 'Abhinandan Diamond',
        address: '204 Shraddhajyot Building, Mahidharpura, Surat',
        mobileno: '8926555111',
        emailID: 'contact@abhinandandiamond.com',
      ));
  return partyType;
}

Future<String?> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username'); // Get the saved username
}

String formatDate(dynamic date, {bool showDayOfWeek = false}) {
  if (date == null) return '';
  final str = date.toString().trim();
  if (str.isEmpty) return '';
  DateTime? parsedDate = DateTime.tryParse(str);
  if (parsedDate == null) {
    try {
      parsedDate = DateFormat('yyyy-MM-dd').parse(str);
    } catch (_) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(str);
      } catch (_) {
        return str;
      }
    }
  }
  String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
  if (showDayOfWeek) {
    String dayOfWeek = DateFormat('EEEE').format(parsedDate);
    String formattedDateWithDay = '$formattedDate     $dayOfWeek';
    return formattedDateWithDay;
  }
  return formattedDate;
}

String formatDateWithTime(dynamic date) {
  if (date == null) return '';
  final str = date.toString().trim();
  if (str.isEmpty) return '';
  DateTime? parsedDate = DateTime.tryParse(str);
  if (parsedDate == null) {
    try {
      parsedDate = DateFormat('dd-MM-yyyy').parse(str);
    } catch (_) {
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parse(str);
      } catch (_) {
        return str;
      }
    }
  }
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
}

String formatDateFromString(String date) {
  // Parse the date string into a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Format the DateTime object into the desired format
  String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

  return formattedDate;
}

String formatDateToddMMMyyyy(String date) {
  // Parse the date string into a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Format the DateTime object into the desired format: "dd MMMM, yyyy"
  String formattedDate = DateFormat('dd MMM, yyyy').format(parsedDate);

  return formattedDate;
}

String formatDateFromDateTime(DateTime date) {
  String formattedDate = DateFormat('dd-MM-yyyy').format(date);
  return formattedDate;
}

String? formatToIsoUtc(dynamic date) {
  if (date == null) return null;
  DateTime? dt;
  if (date is DateTime) {
    dt = date;
  } else if (date is String) {
    final str = date.trim();
    if (str.isEmpty) return null;
    dt = DateTime.tryParse(str);
    if (dt == null) {
      try {
        dt = DateFormat('dd-MM-yyyy').parse(str);
      } catch (_) {
        try {
          dt = DateFormat('yyyy-MM-dd').parse(str);
        } catch (_) {
          try {
            dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(str);
          } catch (_) {
            return str;
          }
        }
      }
    }
  } else {
    dt = DateTime.tryParse(date.toString());
  }

  if (dt == null) return date.toString();

  // If local date has zero time component (midnight local: 00:00:00.000),
  // attaching current local time preserves the calendar date when converting to UTC.
  if (!dt.isUtc &&
      dt.hour == 0 &&
      dt.minute == 0 &&
      dt.second == 0 &&
      dt.millisecond == 0 &&
      dt.microsecond == 0) {
    final now = DateTime.now();
    dt = DateTime(
      dt.year,
      dt.month,
      dt.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );
  }

  final utc = dt.toUtc();
  // Ensure exactly 3 digits for milliseconds and 'Z' suffix (no microseconds)
  final cleanUtc = DateTime.utc(
    utc.year,
    utc.month,
    utc.day,
    utc.hour,
    utc.minute,
    utc.second,
    utc.millisecond,
  );
  return cleanUtc.toIso8601String();
}

double getTotalAssortWt(String invoiceNo, bool isFromEdit, int id) {
  double totalAssortWt = 0.0;
  var transactions = defaultController.roughAssortMstList
      .where((trn) => trn.invoiceNo == invoiceNo)
      .toList();

  totalAssortWt = transactions.fold(0.0, (previousValue, trn) {
    return previousValue + (trn.assortWt ?? 0);
  });

  double totalAssortWtForEditEntry = transactions.where((trn)=> trn.roughAssortMstID == id).fold(0.0,  (previousValue, trn) {
    return previousValue + (trn.assortWt ?? 0);
  });

  totalAssortWt = totalAssortWt - totalAssortWtForEditEntry;
  
  log(totalAssortWtForEditEntry.toStringAsFixed(2));
  // }).toList();
  return totalAssortWt;
  // var transactionDetails = defaultController.roughAssortMstDetList
  //     .where((trnDet) => trnDet.roughAssortMstID == partyType.roughPurMstID)
  //     .toList();
  //
}

double getSelectedPartyBalance(
    {PartyMstModel? selectedParty, bool? isFromEdit, int? partyCode}) {
  if (isFromEdit != null && partyCode != null) {
    var partyTransactions = defaultController.creditDebitDataList
        .where((cd) => cd.partyCode == partyCode)
        .toList();

    var selectedParty = defaultController.partyMstList.firstWhere(
      (partyType) => partyType.partyCode == partyCode,
    );

    double sumCredit = partyTransactions.fold(0.0, (previousValue, cd) {
      return previousValue + (cd.creditRs ?? 0);
    });

    double sumDebit = partyTransactions.fold(0.0, (previousValue, cd) {
      return previousValue + (cd.debitRs ?? 0);
    });

    // Calculate the final balance
    double balance = (sumCredit - sumDebit) +
        ((selectedParty.creditOpBalRs ?? 0) - (selectedParty.debitOpBalRs ?? 0))
            .abs();

    return balance;
  } else if (selectedParty != null) {
    var partyTransactions = defaultController.creditDebitDataList
        .where((cd) => cd.partyCode == selectedParty.partyCode)
        .toList();

    // Sum credits and debits
    double sumCredit = partyTransactions.fold(0.0, (previousValue, cd) {
      return previousValue + (cd.creditRs ?? 0);
    });

    double sumDebit = partyTransactions.fold(0.0, (previousValue, cd) {
      return previousValue + (cd.debitRs ?? 0);
    });

    // Calculate the final balance
    double balance = (sumCredit - sumDebit) +
        ((selectedParty.creditOpBalRs ?? 0) - (selectedParty.debitOpBalRs ?? 0))
            .abs();

    return balance;
  }
  return 0.00;
}

void showCompanySelectionDialog({required bool isFromSwitchCompany}) {
  Get.dialog(
    CompanySelectionDialog(
      isSwitchCompany: isFromSwitchCompany,
    ),
    barrierDismissible: isFromSwitchCompany,
    barrierColor: Colors.transparent,
  );
}

void showLoginDialog() {
  Get.dialog(
    const LoginDialog(),
    barrierDismissible: false,
    barrierColor: Colors.transparent,
  );
}

DateTime dateFormat(dynamic date) {
  if (date == null) return DateTime.now();
  final str = date.toString().trim();
  if (str.isEmpty) return DateTime.now();
  DateTime? parsedDate = DateTime.tryParse(str);
  if (parsedDate != null) return parsedDate;
  try {
    return DateFormat('yyyy-MM-dd').parse(str);
  } catch (_) {
    try {
      return DateFormat('dd-MM-yyyy').parse(str);
    } catch (_) {
      return DateTime.now();
    }
  }
}

List<String> reportList = [
  'STOCK',
  'MEMO PENDING',
  'PURCHASE OUTSTANDING',
  'SALE OUTSTANDING',
  // 'TOTAL PURCHASE OUTSTANDING',
  // 'TOTAL SALE OUTSTANDING'
];

Widget buildRow(List<Widget> children) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: children
        .map(
          (child) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child,
            ),
          ),
        )
        .toList(),
  );
}

Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// void showInvoiceDetails(BuildContext context, OutstandingPurchaseSaleDetails payment) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("Invoice Details: ${payment.invNo}"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Party Name: ${payment.partyName}"),
//             Text("Transaction Type: ${payment.trnType}"),
//             Text("Due Date: ${payment.dueDate}"),
//             Text("Base Amount: ₹${payment.bAmtRs!.toStringAsFixed(2)}"),
//             Text("Overdue: ${getDueStatusText(payment.dueDate!)}"),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("Close"),
//           ),
//         ],
//       );
//     },
//   );
// }

void showPurchaseInvoiceDetails(
    BuildContext context,
    OutstandingPurchaseSaleDetails payment,
    List<PurchaseDetailsModel> purchaseDetailsList,
    List<RoughDetailsModel> roughDetailsList,
    bool isHighlighted,
    bool isSale,
    bool isOverdue) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Filter relevant purchase details
      final relevantPurchaseDetails = purchaseDetailsList.where((detail) {
        return detail.invoiceNo == payment.invNo; // Assuming 'invNo' matches
      });

      // Filter relevant rough details
      final relevantRoughDetails = roughDetailsList.where((detail) {
        return detail.roughPurMstID ==
            payment.mstID; // Assuming 'invNo' matches
      }).toList();

      final paymentHistory = defaultController.creditDebitDataList
          .where((e) =>
              e.invoiceNo.toString() == payment.invNo &&
              e.entryType == 'PAYMENT')
          .toList()
        ..sort((a, b) =>
            DateTime.parse(b.invDate!).compareTo(DateTime.parse(a.invDate!)));

      return AlertDialog(
        // title: Text("Invoice Details: ${payment.invNo}"),
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? isSale
                          ? Colors.purple[50]
                          : Colors.yellow[50]
                      : isOverdue
                          ? Colors.red[50]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHighlighted
                        ? isSale
                            ? Colors.purpleAccent
                            : Colors.orangeAccent
                        : isOverdue
                            ? Colors.transparent
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                              color: isHighlighted
                                  ? isSale
                                      ? Colors.purple[600]
                                      : Colors.orange[600]
                                  : isOverdue
                                      ? Colors.white70
                                      : Colors.grey[100]),
                          child: Row(
                            children: [
                              Icon(isSale ? Icons.sell : Icons.shopping_bag,
                                  size: 18,
                                  color: isHighlighted
                                      ? Colors.white
                                      : isSale
                                          ? Colors.purple[600]
                                          : Colors.orange[600]),
                              const SizedBox(width: 4),
                              Text(
                                payment.trnType ?? "N/A",
                                style: TextStyle(
                                    color: isHighlighted
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              getDueStatusText(payment.dueDate!),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          isHighlighted
                              ? Icons.warning_amber_rounded
                              : isOverdue
                                  ? Icons.error_outline_rounded
                                  : Icons.receipt_long_rounded,
                          color: isHighlighted
                              ? isSale
                                  ? Colors.purpleAccent
                                  : Colors.orangeAccent
                              : isOverdue
                                  ? Colors.redAccent
                                  : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            payment.invNo!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${payment.bAmtRs!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isHighlighted || isOverdue
                                ? Colors.redAccent
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 20 /**/, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            payment.partyName!.toUpperCase(),
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          formatDateToddMMMyyyy(payment.orgInvDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    if (relevantRoughDetails.isNotEmpty) ...[
                      // const Text(
                      //   "Rough Details",
                      //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildCell("Rough Type",
                                      isHeader: true, isCenterLeft: true),
                                  _buildCell("Carats", isHeader: true),
                                  _buildCell("Rate (₹)", isHeader: true),
                                  _buildCell("Amount (₹)",
                                      isHeader: true, isLastColumn: true),
                                ],
                              ),
                            ),
                            // Table Rows
                            ...relevantRoughDetails.map((detail) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildCell(
                                        getRoughName(
                                            detail.roughTypeCode.toString()),
                                        isCenterLeft: true),
                                    _buildCell(detail.wt!.toStringAsFixed(2)),
                                    _buildCell(
                                        detail.rateRs!.toStringAsFixed(2)),
                                    _buildCell(detail.amtRs!.toStringAsFixed(2),
                                        isLastColumn: true),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    const Divider(thickness: 1),
                    if (paymentHistory.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          const Text(
                            'Payment History',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Table Rows
                          SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: paymentHistory.map((details) {
                                  int index = paymentHistory.indexOf(details);
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Timeline indicator
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 5,
                                            backgroundColor:
                                                details.creditRs! > 0.00
                                                    ? Colors.green
                                                    : Colors.blue,
                                          ),
                                          if (index !=
                                              paymentHistory.length - 1)
                                            Container(
                                              width: 2,
                                              height: 65,
                                              // Adjust height based on spacing
                                              color: Colors.grey.shade300,
                                              // margin: const EdgeInsets.only(top: 0), // Align the line to touch the dot
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      // Timeline content
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    formatDateToddMMMyyyy(
                                                        details.invDate!),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    details.creditRs! > 0.00
                                                        ? '₹${details.creditRs!.toStringAsFixed(2)} Cr'
                                                        : '₹${details.debitRs!.toStringAsFixed(2)} Dr',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: details.creditRs! >
                                                              0.00
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors
                                                              .blue.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                getPartyName(
                                                    details.perPartyCode),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                    if (paymentHistory.isEmpty) ...[
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'No payment records were found for this invoice.',
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))
                    ],
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const OutlinedButton(
                            onPressed: null, child: Text('Print')),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Get.back();
                              tabController.isReportForm.value = false;

                              // Example: Add a new Purchase view tab
                              tabController.addTab(TabItem(
                                  view: const PaymentFormScreen(
                                      showHeader: false),
                                  label: 'Payment',
                                  icon: const Icon(Icons.payment)));
                            },
                            child: const Text('Payment')),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close')),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.of(context).pop(),
        //     child: const Text("Close"),
        //   ),
        // ],
      );
    },
  );
}

void showSaleInvoiceDetails(
    BuildContext context,
    OutstandingPurchaseSaleDetails payment,
    List<PolishSaleModel> saleDetailsList,
    List<SaleDetailsModel> roughDetailsList,
    bool isHighlighted,
    bool isSale,
    bool isOverdue) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Filter relevant purchase details
      final relevantPurchaseDetails = saleDetailsList.where((detail) {
        return detail.invNo.toString() ==
            payment.invNo; // Assuming 'invNo' matches
      }).toList();

      // Filter relevant rough details
      final relevantRoughDetails = roughDetailsList.where((detail) {
        return detail.polishSaleMstID ==
            payment.mstID; // Assuming 'invNo' matches
      }).toList();

      final paymentHistory = defaultController.creditDebitDataList
          .where((e) =>
              e.invoiceNo.toString() == payment.invNo &&
              e.entryType == 'PAYMENT')
          .toList()
        ..sort((a, b) =>
            DateTime.parse(b.invDate!).compareTo(DateTime.parse(a.invDate!)));

      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? isSale
                          ? Colors.purple[50]
                          : Colors.yellow[50]
                      : isOverdue
                          ? Colors.red[50]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHighlighted
                        ? isSale
                            ? Colors.purpleAccent
                            : Colors.orangeAccent
                        : isOverdue
                            ? Colors.transparent
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                              color: isHighlighted
                                  ? isSale
                                      ? Colors.purple[600]
                                      : Colors.orange[600]
                                  : isOverdue
                                      ? Colors.white70
                                      : Colors.grey[100]),
                          child: Row(
                            children: [
                              Icon(isSale ? Icons.sell : Icons.shopping_bag,
                                  size: 18,
                                  color: isHighlighted
                                      ? Colors.white
                                      : isSale
                                          ? Colors.purple[600]
                                          : Colors.orange[600]),
                              const SizedBox(width: 4),
                              Text(
                                payment.trnType ?? "N/A",
                                style: TextStyle(
                                    color: isHighlighted
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              getDueStatusText(payment.dueDate!),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          isHighlighted
                              ? Icons.warning_amber_rounded
                              : isOverdue
                                  ? Icons.error_outline_rounded
                                  : Icons.receipt_long_rounded,
                          color: isHighlighted
                              ? isSale
                                  ? Colors.purpleAccent
                                  : Colors.orangeAccent
                              : isOverdue
                                  ? Colors.redAccent
                                  : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            payment.invNo!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${payment.bAmtRs!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isHighlighted || isOverdue
                                ? Colors.redAccent
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 20 /**/, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            payment.partyName!.toUpperCase(),
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          formatDateToddMMMyyyy(payment.orgInvDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    if (relevantRoughDetails.isNotEmpty) ...[
                      // const Text(
                      //   "Rough Details",
                      //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildCell("Rough Type",
                                      isHeader: true, isCenterLeft: true),
                                  _buildCell("Carats", isHeader: true),
                                  _buildCell("Rate (₹)", isHeader: true),
                                  _buildCell("Amount (₹)",
                                      isHeader: true, isLastColumn: true),
                                ],
                              ),
                            ),
                            // Table Rows
                            ...relevantRoughDetails.map((detail) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildCell(
                                        getRoughName(
                                            detail.roughTypeCode.toString()),
                                        isCenterLeft: true),
                                    _buildCell(
                                        detail.carats!.toStringAsFixed(2)),
                                    _buildCell(
                                        detail.rateRs!.toStringAsFixed(2)),
                                    _buildCell(
                                        detail.amountRs!.toStringAsFixed(2),
                                        isLastColumn: true),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    const Divider(thickness: 1),
                    if (paymentHistory.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          const Text(
                            'Payment History',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Table Rows
                          SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: paymentHistory.map((details) {
                                  int index = paymentHistory.indexOf(details);
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Timeline indicator
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 5,
                                            backgroundColor:
                                                details.creditRs! > 0.00
                                                    ? Colors.green
                                                    : Colors.blue,
                                          ),
                                          if (index !=
                                              paymentHistory.length - 1)
                                            Container(
                                              width: 2,
                                              height: 65,
                                              // Adjust height based on spacing
                                              color: Colors.grey.shade300,
                                              // margin: const EdgeInsets.only(top: 0), // Align the line to touch the dot
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      // Timeline content
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    formatDateToddMMMyyyy(
                                                        details.invDate!),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    details.creditRs! > 0.00
                                                        ? '₹${details.creditRs!.toStringAsFixed(2)} Cr'
                                                        : '₹${details.debitRs!.toStringAsFixed(2)} Dr',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: details.creditRs! >
                                                              0.00
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors
                                                              .blue.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                getPartyName(
                                                    details.perPartyCode),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                    if (paymentHistory.isEmpty) ...[
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'No payment records were found for this invoice.',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))
                    ],
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const OutlinedButton(
                            onPressed: null, child: Text('Print')),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Get.back();
                              tabController.isReportForm.value = false;

                              // Example: Add a new Purchase view tab
                              tabController.addTab(TabItem(
                                  view: const PaymentFormScreen(
                                      showHeader: false),
                                  label: 'Payment',
                                  icon: const Icon(Icons.payment)));
                            },
                            child: const Text('Payment')),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close')),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   ElevatedButton(
        //     onPressed: () => Navigator.of(context).pop(),
        //     child: const Text("Make Payment"),
        //   ),
        // ],
      );
    },
  );
}

String getDueStatusText(String dueDate) {
  final dueDateTime = DateTime.parse(dueDate);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day); // Stripping time
  final dueDay = DateTime(
      dueDateTime.year, dueDateTime.month, dueDateTime.day); // Stripping time

  final difference = dueDay.difference(today).inDays;

  if (difference == 0) {
    return "Due Today";
  } else if (difference == -1) {
    return "Due Yesterday";
  } else if (difference == 1) {
    return "Due Tomorrow";
  } else if (difference > 1) {
    return "Due in $difference days";
  } else {
    return "Overdue by ${difference.abs()} days";
  }
}

Widget _buildCell(String text,
    {bool isHeader = false,
    bool isLastColumn = false,
    bool isCenterLeft = false}) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: isLastColumn
            ? const Border() // No border for the last column
            : (isHeader
                ? const Border(
                    right: BorderSide(color: Colors.white, width: 0.5),
                  )
                : Border(
                    right: BorderSide(color: Colors.grey.shade400, width: 0.5),
                  )),
      ),
      alignment: isCenterLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: isHeader
            ? const TextStyle(fontWeight: FontWeight.bold)
            : const TextStyle(fontSize: 14),
      ),
    ),
  );
}

Widget getBottomItem({
  required BuildContext context,
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.0), // Rounded corners for the dialog
        ),
        contentPadding: const EdgeInsets.all(20), // Padding around content
        content: SizedBox(
          height: 250, // Adjusted height for better spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Align content to start
            children: [
              // Title
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Title color
                ),
              ),
              const SizedBox(height: 20),
              // Spacing between title and options

              // Theme & Appearance (Light / Dark)
              Obx(() {
                final isDark = ThemeController.isInitialized
                    ? ThemeController.to.isDarkMode.value
                    : false;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFFFBBF24) : AppColors.primary).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                      color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    isDark ? 'Dark theme enabled' : 'Light theme enabled',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (val) {
                      ThemeController.to.setDarkMode(val);
                    },
                  ),
                );
              }),
              const Divider(),

              // Toggle Dashboard
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Enable Advanced Dashboard',
                  style: TextStyle(
                      fontSize: 16), // Consistent font size for options
                ),
                trailing: Obx(
                  () => Switch(
                    value: defaultController.enabledAdvancedDashboard.value,
                    onChanged: (value) {
                      Get.back();
                      defaultController.enabledAdvancedDashboard.value = value;
                    },
                  ),
                ),
              ),
              const Divider(), // Divider for separation between options

              // Add more settings here if needed, e.g. feature toggles
              // Example:
              // ListTile(
              //   title: const Text('Enable Feature X'),
              //   trailing: Obx(
              //     () => Switch(
              //       value: dashboardController.isFeatureEnabled.value,
              //       onChanged: (value) {
              //         dashboardController.toggleFeature();
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        actions: [
          // Close Button with rounded corners and modern design
          OutlinedButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Widget buildBottomButton(String text) {
//   return OutlinedButton(
//     onPressed: () {},
//     child: Text(text),
//   );
// }

Color getPartyTypeColor(int typeCode) {
  switch (typeCode) {
    case 1:
      return Colors.orange; // Purchase
    case 2:
      return Colors.purple; // Sale
    case 3:
      return Colors.lightBlueAccent; // Other
    case 4:
      return Colors.teal; // Special
    case 5:
      return Colors.blueAccent; // Service
    case 6:
      return Colors.amber; // Vendor
    case 7:
      return Colors.pinkAccent; // Client
    case 8:
      return Colors.indigo; // Distributor
    case 9:
      return Colors.lime; // Retailer
    case 10:
      return Colors.cyan; // Supplier
    default:
      return Colors.grey; // Default color for unclassified types
  }
}

IconData getPartyTypeIcon(int typeCode) {
  switch (typeCode) {
    case 1:
      return Icons.shopping_bag; // Purchase
    case 2:
      return Icons.sell; // Sale
    case 3:
      return Icons.currency_rupee; // Other
    case 4:
      return Icons.account_balance; // Special
    case 5:
      return Icons.real_estate_agent; // Service
    case 6:
      return Icons.assured_workload; // Vendor
    case 7:
      return Icons.corporate_fare; // Client
    case 8:
      return Icons.manage_accounts; // Distributor
    case 9:
      return Icons.person_3; // Retailer
    case 10:
      return Icons.currency_exchange; // Supplier
    default:
      return Icons.error; // Default color for unclassified types
  }
}
