import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) {
                // Fancy circular loader
                return Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(

                        value: event == null
                            ? null
                            : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                        strokeWidth: 6,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
