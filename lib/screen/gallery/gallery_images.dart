import 'dart:ui';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/screen/gallery/provider/image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_images.dart';
import '../../../core/app_Commanbar.dart';
import 'package:bellamarble/core/widgets/shimmer_loading.dart';
import 'package:bellamarble/core/widgets/app_network_image.dart';

class GalleryImages extends StatelessWidget {
  const GalleryImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: CommonAppBar(
        title: "Gallery",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.darkblue,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<GalleryImagesProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// 🔍 SEARCH
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.search,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppImages.search),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: provider.searchController,
                                onChanged: provider.filterProducts,
                                decoration: InputDecoration(
                                  hintText: "Search Anything...",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: provider.toggleListening,
                              child: Icon(
                                provider.isListening
                                    ? Icons.mic
                                    : Icons.mic_none,
                                color: provider.isListening
                                    ? Colors.red
                                    : AppColors.darkblue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: provider.isLoading
                          ? const ProductGridShimmer(itemCount: 8)
                          : provider.filteredProducts.isEmpty
                          ? const Center(child: Text("No products found"))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.filteredProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.68,
                                  ),
                              itemBuilder: (context, index) {
                                final item = provider.filteredProducts[index];
                                return _productCard(item, provider);
                              },
                            ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),

              /// IMAGE PREVIEW
              if (provider.selectedImage != null)
                GestureDetector(
                  onTap: provider.clearSelectedImage,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                      alignment: Alignment.center,
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AppNetworkImage(
                            url: provider.selectedImage!,
                            width: MediaQuery.of(context).size.width * 0.95,
                            fit: BoxFit.contain,
                            fullSize: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _productCard(Product item, GalleryImagesProvider provider) {
    return GestureDetector(
      onTap: () {
        if (item.image.isNotEmpty) {
          provider.selectImage(item.image);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.search, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: item.image, width: 200),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    if (item
                        .availability
                        .isNotEmpty) // Use availability or create generic code if not available
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Text(
                          item.availability,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'PlayfairDisplay'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
