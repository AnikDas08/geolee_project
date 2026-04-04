import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../controller/home_controller.dart';

class FilterDialog extends StatefulWidget {
  final Function(String period, DateTime start, DateTime end) onApply;

  const FilterDialog({super.key, required this.onApply});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── Hour Options + Custom Range ───
  final List<String> periodOptions = [
    '3h', '6h', '9h', '12h', '15h', '18h', '21h', '24h', 'Custom Range'
  ];

  // ✅ Default = "24h"
  String selectedPeriod = '24h';

  DateTime? pickedStartDate;
  DateTime? pickedEndDate;


  bool get isCustomRange => selectedPeriod == 'Custom Range';

  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);

    // Restore previous selection
    if (controller.selectedPeriod.value.isNotEmpty) {
      selectedPeriod = controller.selectedPeriod.value;
    }
    if (controller.selectedPeriod.value == 'Custom Range') {
      pickedStartDate = controller.startDate.value;
      pickedEndDate = controller.endDate.value;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        pickedStartDate = picked;
        if (pickedEndDate != null && picked.isAfter(pickedEndDate!)) {
          pickedEndDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickedEndDate ?? (pickedStartDate ?? DateTime.now()),
      firstDate: pickedStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => pickedEndDate = picked);
    }
  }

  void _applyFilter() {
    if (isCustomRange) {
      if (pickedStartDate == null || pickedEndDate == null) {
        Get.snackbar('Notice', 'Please select both start and end date',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final DateTime startWithTime = DateTime(
        pickedStartDate!.year,
        pickedStartDate!.month,
        pickedStartDate!.day,
      );
      final DateTime endWithTime = DateTime(
        pickedEndDate!.year,
        pickedEndDate!.month,
        pickedEndDate!.day,
        23, 59, 59,
      );
      widget.onApply('Custom Range', startWithTime, endWithTime);
    } else {
      controller.applyPeriodFilter(selectedPeriod);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
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
                  'Filter Options',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Obx(
                          () => controller.isDateFilterActive.value
                          ? GestureDetector(
                        onTap: () {
                          controller.clearDateFilter();
                          Get.back();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close,
                                  size: 14.sp, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text('Clear',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24.sp),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ─── Section label ───
            Row(
              children: [
                Icon(Icons.schedule, size: 15.sp, color: Colors.blue),
                SizedBox(width: 6.w),
                Text(
                  'Select Period',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // ─── Period Chips ───
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: periodOptions.map((option) {
                final isSelected = selectedPeriod == option;
                final isCustomOption = option == 'Custom Range';
                return _chipItem(
                  label: option,
                  isSelected: isSelected,
                  isCustom: isCustomOption,
                  onTap: () {
                    setState(() {
                      selectedPeriod = option;
                      if (!isCustomOption) {
                        pickedStartDate = null;
                        pickedEndDate = null;
                      }
                    });
                    if (!isCustomOption) {
                      Get.back(); // close dialog first
                      controller.applyPeriodFilter(selectedPeriod); // then fetch
                    }
                  },
                );
              }).toList(),
            ),

            // ─── Custom Range Date Pickers (animated show/hide) ───
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: isCustomRange
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Divider(color: Colors.grey.shade200, height: 1),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          size: 15.sp, color: Colors.blue),
                      SizedBox(width: 6.w),
                      Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Start + End side by side
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            InkWell(
                              onTap: _pickStartDate,
                              child: _buildDateField(pickedStartDate),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            InkWell(
                              onTap: pickedStartDate != null
                                  ? _pickEndDate
                                  : null,
                              child: Opacity(
                                opacity:
                                pickedStartDate != null ? 1.0 : 0.4,
                                child: _buildDateField(pickedEndDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: 20.h),

            // ─── Apply Button ───
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  'Apply Filter',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipItem({
    required String label,
    required bool isSelected,
    required bool isCustom,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCustom ? 16.w : 14.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCustom ? Colors.indigo : Colors.blue)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? (isCustom ? Colors.indigo : Colors.blue)
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: (isCustom ? Colors.indigo : Colors.blue)
                  .withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom)
              Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 11.sp,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(DateTime? date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: date != null ? Colors.blue : Colors.grey.shade300,
          width: date != null ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.r),
        color: date != null ? Colors.blue.withValues(alpha: 0.04) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null
                ? DateFormat('dd MMM yyyy').format(date)
                : 'Select',
            style: TextStyle(
                fontSize: 12.sp,
                color: date != null ? Colors.black87 : Colors.grey),
          ),
          Icon(Icons.calendar_today,
              size: 16.sp,
              color: date != null ? Colors.blue : Colors.grey),
        ],
      ),
    );
  }
}