import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class ClickerDialog extends StatefulWidget {
  final Function(String) onApply;

  const ClickerDialog({super.key, required this.onApply});

  @override
  State<ClickerDialog> createState() => _ClickerDialogState();
}

class _ClickerDialogState extends State<ClickerDialog> {
  // ✅ default "All" selected
  String selectedClicker = "All";

  final HomeController controller = Get.find<HomeController>();

  final List<String> clickerOptions = [
    "All",
    "Great Vibes",
    "Off Vibes",
    "Charming Gentleman",
    "Lovely Lady",
  ];

  @override
  void initState() {
    super.initState();
    // ✅ আগে কোনো clicker select করা থাকলে restore করবে,
    //    না থাকলে "All" default থাকবে
    if (controller.clickerCount.value != null &&
        controller.clickerCount.value!.isNotEmpty) {
      selectedClicker = controller.clickerCount.value!;
    } else {
      selectedClicker = "All";
    }
  }

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
            // ─── Title Row ───
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

            // ─── Clicker Options ───
            ...clickerOptions.map((option) {
              final bool isSelected = selectedClicker == option;
              return InkWell(
                onTap: () => setState(() => selectedClicker = option),
                borderRadius: BorderRadius.circular(8.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                      vertical: 12.h, horizontal: 12.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // ✅ "All" এর জন্য special icon
                          Icon(
                            option == "All"
                                ? Icons.public
                                : option == "Great Vibes"
                                ? Icons.sentiment_very_satisfied
                                : option == "Off Vibes"
                                ? Icons.sentiment_dissatisfied
                                : option == "Charming Gentleman"
                                ? Icons.person
                                : Icons.favorite,
                            size: 18.sp,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: Colors.blue, size: 20.sp),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 20.h),

            // ─── Apply Button — সবসময় active ───
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(selectedClicker);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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