import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: widget.images[index],
                ),
              );
            },
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 60.w,
                height: 60.h,
                child: CircularProgressIndicator(
                  value: event == null
                      ? null
                      : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
                  strokeWidth: 4,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          /// ❌ Close button
          Positioned(
            top: 40.h,
            right: 20.w,
            child: IconButton(onPressed: (){
              Get.back();
            }, icon: const Icon(
              size: 30,
              Icons.cancel_rounded,color: Colors.grey,)),
          ),

          /// 🔢 Image counter
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
