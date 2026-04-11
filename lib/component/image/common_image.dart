import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import '../../../utils/constants/app_images.dart';
import '../../../utils/log/error_log.dart';

class CommonImage extends StatelessWidget {
  final String imageSrc;
  final String defaultImage;
  final Color? imageColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final double? size;
  final BoxFit fill;
  final int? memCacheHeight;
  final int? memCacheWidth;

  const CommonImage({
    required this.imageSrc,
    this.imageColor,
    this.height,
    this.borderRadius = 0,
    this.width,
    this.size,
    this.fill = BoxFit.contain,
    this.defaultImage = AppImages.profile,
    this.memCacheHeight,
    this.memCacheWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSrc.isEmpty) {
      return _buildErrorWidget();
    }
    if (imageSrc.contains("assets/icons")) {
      return _buildSvgImage();
    } else if (imageSrc.contains("assets/images")) {
      return _buildPngImage();
    } else if (imageSrc.startsWith('file://') ||
        imageSrc.startsWith('/data/') ||
        imageSrc.startsWith('/storage/')) {
      // ✅ Fixed: existsSync() হটানো হয়েছে (UI thread block করত)
      return _buildFileImage();
    } else {
      return _buildNetworkImage();
    }
  }

  Widget _buildErrorWidget() {
    // ✅ Fixed: cache size দেওয়া হয়েছে
    return Image.asset(
      defaultImage,
      cacheWidth: memCacheWidth ?? 200,
      cacheHeight: memCacheHeight ?? 200,
    );
  }

  Widget _buildNetworkImage() {
    final String imageUrl = imageSrc.startsWith('http')
        ? imageSrc
        : imageSrc.isEmpty
        ? ""
        : imageSrc.startsWith('/')
        ? "${ApiEndPoint.imageUrl}$imageSrc"
        : "${ApiEndPoint.imageUrl}/$imageSrc";

    return CachedNetworkImage(
      height: size ?? height,
      width: size ?? width,
      imageUrl: imageUrl,
      fit: fill,
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      // ✅ Fixed: borderRadius 0 হলে extra Container avoid করা হচ্ছে
      imageBuilder: borderRadius > 0
          ? (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(image: imageProvider, fit: fill),
        ),
      )
          : null,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue,
            value: downloadProgress.progress,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildSvgImage() {
    return SvgPicture.asset(
      imageSrc,
      // ignore: deprecated_member_use
      color: imageColor,
      height: size ?? height,
      width: size ?? width,
      fit: fill,
    );
  }

  Widget _buildPngImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imageSrc,
        color: imageColor,
        height: size ?? height,
        width: size ?? width,
        cacheHeight: memCacheHeight,
        cacheWidth: memCacheWidth,
        fit: fill,
        errorBuilder: (context, error, stackTrace) {
          errorLog(error, source: "Common Image");
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildFileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(imageSrc),
        height: size ?? height,
        width: size ?? width,
        cacheHeight: memCacheHeight,
        cacheWidth: memCacheWidth,
        fit: fill,
        errorBuilder: (context, error, stackTrace) {
          errorLog(error, source: "Common Image - File");
          return _buildErrorWidget();
        },
      ),
    );
  }
}