import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClickerDialog extends StatefulWidget {
  final Function(String) onApply;

  const ClickerDialog({super.key, required this.onApply});

  @override
  State<ClickerDialog> createState() => _ClickerDialogState();
}

class _ClickerDialogState extends State<ClickerDialog> {
  String? selectedClicker;

  final List<String> clickerOptions = [
    "All",
    "Great Vibes",
    "Off Vibes",
    "Charming Gentleman",
    "Lovely Lady"
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Clicker Type',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Clicker Options List
            ...clickerOptions.map((option) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedClicker = option;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: selectedClicker == option
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: selectedClicker == option
                          ? Colors.blue
                          : Colors.grey.shade300,
                      width: selectedClicker == option ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: selectedClicker == option
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selectedClicker == option
                              ? Colors.blue
                              : Colors.black87,
                        ),
                      ),
                      if (selectedClicker == option)
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 20.h),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedClicker == null
                    ? null
                    : () {
                  widget.onApply(selectedClicker!);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Apply Selection',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}