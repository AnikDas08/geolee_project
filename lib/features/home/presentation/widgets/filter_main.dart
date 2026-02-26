import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  // ─── Hour Options only ───
  final List<int> hourOptions = [3, 6, 9, 12, 15, 18, 21, 24];

  String? selectedPeriod;

  DateTime? pickedStartDate;
  DateTime? pickedEndDate;

  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (controller.selectedPeriod.value.isNotEmpty &&
        controller.selectedPeriod.value != 'Custom Range') {
      selectedPeriod = controller.selectedPeriod.value;
      _tabController.index = 0;
    } else if (controller.selectedPeriod.value == 'Custom Range') {
      pickedStartDate = controller.startDate.value;
      pickedEndDate = controller.endDate.value;
      _tabController.index = 1;
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
    if (_tabController.index == 0) {
      if (selectedPeriod == null) {
        Get.snackbar('Notice', 'Please select a time period',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      controller.applyPeriodFilter(selectedPeriod!);
      Get.back();
    } else {
      if (pickedStartDate == null || pickedEndDate == null) {
        Get.snackbar('Notice', 'Please select both start and end date',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      widget.onApply('Custom Range', pickedStartDate!, pickedEndDate!);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(10.w),
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
                              horizontal: 15.w, vertical: 6.h),
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

            // ─── Tab Bar ───
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle:
                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 15.sp),
                        SizedBox(width: 6.w),
                        const Text('Active Period'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.date_range, size: 15.sp),
                        SizedBox(width: 6.w),
                        const Text('Date Range'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ─── Tab Content ───
            SizedBox(
              height: 205.h,
              child: TabBarView(
                controller: _tabController,
                children: [_buildPeriodTab(), _buildDateRangeTab()],
              ),
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  // ─── Tab 1: Hours only ───
  Widget _buildPeriodTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 15.sp, color: Colors.blue),
            SizedBox(width: 6.w),
            Text(
              'Select Hours',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: hourOptions.map((h) {
            final label = '${h}h';
            final isSelected = selectedPeriod == label;
            return _chipItem(
              label: label,
              isSelected: isSelected,
              onTap: () => setState(() => selectedPeriod = label),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _chipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ─── Tab 2: Custom date range pickers ───

  Widget _buildDateRangeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select date range',
          style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12.h),
        Text('Start Date',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        InkWell(onTap: _pickStartDate, child: _buildDateField(pickedStartDate)),
        SizedBox(height: 12.h),
        Text('End Date',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: pickedStartDate != null ? _pickEndDate : null,
          child: Opacity(
            opacity: pickedStartDate != null ? 1.0 : 0.4,
            child: _buildDateField(pickedEndDate),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(DateTime? date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: date != null ? Colors.blue : Colors.grey.shade300,
          width: date != null ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null
                ? DateFormat('dd MMM yyyy').format(date)
                : 'Select date',
            style: TextStyle(
                fontSize: 14.sp,
                color: date != null ? Colors.black87 : Colors.grey),
          ),
          Icon(Icons.calendar_today,
              size: 20.sp, color: date != null ? Colors.blue : Colors.grey),
        ],
      ),
    );
  }
}