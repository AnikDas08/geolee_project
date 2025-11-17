import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/home/presentation/widgets/success_message.dart';
import 'package:giolee78/services/api/api_service.dart';

class OfferDialog {
  static void show(
    BuildContext context, {
    required num budget,
    required DateTime serviceDate,
    required String serviceTime,
    required VoidCallback onSubmit,
    required String chatId,
    required String serviceId,
  }) {
    final TextEditingController budgetController = TextEditingController(
      text: budget.toStringAsFixed(0),
    );

    final TextEditingController dateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy').format(serviceDate),
    );

    final TextEditingController timeController = TextEditingController(
      text: serviceTime,
    );

    DateTime selectedDate = serviceDate;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + Close Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Custom Offer',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Budget Field
                    TextField(
                      controller: budgetController,
                      decoration: InputDecoration(
                        labelText: 'Budget',
                        hintText: budget.toString(),
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.h),

                    // Service Date Field
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Service Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                          dateController.text = DateFormat(
                            'dd MMMM yyyy',
                          ).format(pickedDate);
                        }
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Service Time Field
                    TextField(
                      controller: timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Service Time',
                        suffixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          // Format time as "10.00 AM"
                          final hour = pickedTime.hourOfPeriod == 0
                              ? 12
                              : pickedTime.hourOfPeriod;
                          final minute = pickedTime.minute.toString().padLeft(
                            2,
                            '0',
                          );
                          final period = pickedTime.period == DayPeriod.am
                              ? 'AM'
                              : 'PM';
                          timeController.text = '$hour.$minute $period';
                        }
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Validate fields
                                if (budgetController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter budget',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                if (timeController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select service time',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  // Remove $ sign and parse budget
                                  String budgetText = budgetController.text
                                      .replaceAll('\$', '')
                                      .replaceAll(',', '')
                                      .trim();

                                  num customPrice =
                                      num.tryParse(budgetText) ?? 0;

                                  // Format date to ISO 8601 format
                                  String formattedDate = selectedDate
                                      .toUtc()
                                      .toIso8601String();

                                  var body = {
                                    "chatId": chatId,
                                    "service": serviceId,
                                    "customPrice": customPrice,
                                    "serviceDate": formattedDate,
                                    "serviceTime": timeController.text,
                                  };

                                  debugPrint("Sending offer: $body");

                                  final response = await ApiService.post(
                                    ApiEndPoint
                                        .customOffer, // Adjust endpoint as needed
                                    body: body,
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });

                                  if (response.statusCode == 200) {
                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    // Show success dialog
                                    SuccessCustomOffer.show(
                                      context,
                                      title: 'Offer sent successfully!',
                                    );

                                    // Call the original onSubmit callback
                                    onSubmit();
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      response.data['message'] ??
                                          'Failed to send offer',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });

                                  debugPrint('Error sending offer: $e');
                                  Get.snackbar(
                                    'Error',
                                    'Failed to send offer: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
