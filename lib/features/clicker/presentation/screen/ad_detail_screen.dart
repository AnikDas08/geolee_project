import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/clicker/data/addbanner_model.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import '../widget/webview_screen.dart';

class AdDetailScreen extends StatefulWidget {
  final AdBannerModel ad;

  const AdDetailScreen({super.key, required this.ad});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  String get _imageUrl {
    if (widget.ad.image.startsWith('http')) return widget.ad.image;
    return '${ApiEndPoint.imageUrl}/${widget.ad.image}';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F4F1),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(position: _slideUp, child: _buildBody()),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ─── Sliver AppBar with full-bleed hero image ────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340.h,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A1A1A),
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: _GlassButton(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            Hero(
              tag: 'ad_image_${widget.ad.image}',
              child: Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2A2A2A),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            ),
            // Gradient overlay — bottom fade into content
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Title overlaid at bottom of image
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 24.h,
              child: Text(
                widget.ad.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.25,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Body content ─────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business card
          if (widget.ad.businessName != null &&
              widget.ad.businessName!.isNotEmpty)
            _BusinessCard(ad: widget.ad),

          SizedBox(height: 20.h),

          // Description
          if (widget.ad.description != null &&
              widget.ad.description!.isNotEmpty)
            _DescriptionCard(description: widget.ad.description!),

          SizedBox(height: 20.h),

          // Contact chips row
          _buildContactChips(),
        ],
      ),
    );
  }

  Widget _buildContactChips() {
    final hasPhone = widget.ad.phone != null && widget.ad.phone!.isNotEmpty;
    final hasWeb =
        widget.ad.websiteUrl != null && widget.ad.websiteUrl!.isNotEmpty;

    if (!hasPhone && !hasWeb) return const SizedBox.shrink();

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        if (hasPhone)
          _InfoChip(
            icon: Icons.phone_rounded,
            label: widget.ad.phone!,
            color: const Color(0xFF2ECC71),
          ),
        if (hasWeb)
          _InfoChip(
            icon: Icons.language_rounded,
            label: 'Website',
            color: AppColors.primaryColor,
          ),
      ],
    );
  }

  // ─── Bottom action bar ────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final hasPhone = widget.ad.phone != null && widget.ad.phone!.isNotEmpty;
    final hasWeb =
        widget.ad.websiteUrl != null && widget.ad.websiteUrl!.isNotEmpty;

    if (!hasPhone && !hasWeb) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (hasPhone) ...[
            Expanded(
              child: _ActionButton(
                label: 'Call Now',
                icon: Icons.phone_rounded,
                isPrimary: true,
                onTap: () {
                  // TODO: call phone number
                },
              ),
            ),
            if (hasWeb) SizedBox(width: 12.w),
          ],
          if (hasWeb)
            Expanded(
              child: _ActionButton(
                label: 'Visit Website',
                icon: Icons.language_rounded,
                isPrimary: !hasPhone,
                onTap: () {
                  Get.to(
                    () => CommonWebViewScreen(
                      url: widget.ad.websiteUrl!,
                      title: widget.ad.title,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _BusinessCard extends StatelessWidget {
  final AdBannerModel ad;

  const _BusinessCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle with gradient
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 26.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.businessName!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                if (ad.businessType != null && ad.businessType!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        ad.businessType!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: AppColors.primaryColor,
            size: 22.r,
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'About this offer',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.7,
              color: const Color(0xFF555555),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryColor : Colors.transparent,
          border: isPrimary
              ? null
              : Border.all(color: AppColors.primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primaryColor,
              size: 18.r,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppColors.primaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted glass back button
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
