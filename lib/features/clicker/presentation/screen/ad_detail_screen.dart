import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/clicker/data/addbanner_model.dart';
import '../widget/webview_screen.dart';

class AdDetailScreen extends StatelessWidget {
  final AdBannerModel ad;

  const AdDetailScreen({super.key, required this.ad});

  String getImageUrl() {
    if (ad.image.startsWith('http')) return ad.image;
    return '${ApiEndPoint.imageUrl}/${ad.image}';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = ad.phone != null && ad.phone!.isNotEmpty;
    final hasWeb = ad.websiteUrl != null && ad.websiteUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(ad.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 8,right: 8,top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            Card(
              color: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    getImageUrl(),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Divider(height: 2,color: Colors.grey,),
            

            const SizedBox(height: 16),

            /// Title
            Text("Title: ${ad.title}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            /// Business Name
            if (ad.businessName != null && ad.businessName!.isNotEmpty)
              Text(
                ad.businessName!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

            const SizedBox(height: 6),

            /// Description
            if (ad.description != null && ad.description!.isNotEmpty)
              Text("Description :${ad.description!}", style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 20),

            /// Phone Button
            if (hasPhone)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text("Call Now"),
                  onPressed: () {
                    // TODO call phone
                  },
                ),
              ),

            const SizedBox(height: 10),

            //Website Button===============================
            if (hasWeb)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.language),
                  label: const Text("Visit Website"),
                  onPressed: () {
                    Get.to(
                      () => CommonWebViewScreen(
                        url: ad.websiteUrl!,
                        title: ad.title,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
