import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    ),
    body: InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
              child:
              CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (_, __, ___) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded,
                  color: Colors.white54, size: 64),
              SizedBox(height: 12),
              Text('Image unavailable',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    ),
  );
}