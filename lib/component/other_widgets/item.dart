import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_colors.dart';
import '../image/common_image.dart';
import '../text/common_text.dart';

class Item extends StatelessWidget {
  const Item({
    super.key,
    this.icon,
    required this.title,
    this.imageSrc = "",
    this.disableDivider = false,
    this.onTap,
    this.color = AppColors.black,
    this.vertical = 8,
    this.horizontal = 4,
    this.disableIcon = false,
    this.badgeText, // ✅ new
  });

  final IconData? icon;
  final String title;
  final String imageSrc;
  final bool disableDivider;
  final bool disableIcon;
  final VoidCallback? onTap;
  final Color color;
  final double vertical;
  final double horizontal;
  final String? badgeText; // ✅ optional badge

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.symmetric(
        horizontal: horizontal.w,
        vertical: vertical.h,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            /// Icon / Image + Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                icon != null
                    ? Icon(icon, color: color)
                    : CommonImage(imageSrc: imageSrc),

                /// ✅ Badge (optional)
                if (badgeText != null && badgeText!.isNotEmpty)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// Title
            CommonText(
              text: title,
              color: color,
              fontWeight: FontWeight.w400,
              fontSize: 18,
              left: 16,
            ),

            const Spacer(),

            /// Arrow Icon
            disableIcon
                ? const SizedBox()
                : Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
