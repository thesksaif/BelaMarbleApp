import 'package:bellamarble/core/app_colors.dart';
import 'package:bellamarble/core/app_commanbar.dart';
import 'package:bellamarble/core/app_images.dart';
import 'package:bellamarble/screen/gallery/provider/gallery_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'gallery_images.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: const CommonAppBar(title: "Explore Gallery"),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 22),

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
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: provider.searchController,
                            onChanged: provider.filterCategories,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Search Anything...",
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
                            color: AppColors.darkblue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// 🧱 GRID
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.filteredCategories.isEmpty
                          ? const Center(child: Text("No categories found"))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.filteredCategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) {
                                final item = provider.filteredCategories[index];
                                return _categoryItem(
                                  context,
                                  title: item.categoryName,
                                  logo: item.logo,
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _categoryItem(
    BuildContext context, {
    required String title,
    required String logo,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GalleryImages()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey[200],
          image: logo.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(logo),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.black26, // Overlay for readability
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 2,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
