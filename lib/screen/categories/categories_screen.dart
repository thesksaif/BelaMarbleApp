import 'package:bellamarble/screen/categories/provider/categories_provider.dart';
import 'package:bellamarble/screen/categories/title_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_Commanbar.dart';
import '../../core/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: CommonAppBar(title: "Categories"),
      body: SingleChildScrollView(
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
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: provider.searchController,
                        onChanged: provider.filterCategories,
                        decoration: const InputDecoration(
                          hintText: "Search Anything...",
                          border: InputBorder.none,
                        ),
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
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : provider.filteredCategories.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("No categories found"),
                          ),
                        )
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

                            return categoryItem(
                              context,
                              title: item.categoryName,
                              logo: item.logo,
                              id: item.categoryId.toString(),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🟦 CATEGORY CARD (IMAGE TOP, NAME BOTTOM)
  Widget categoryItem(
    BuildContext context, {
    required String title,
    required String logo,
    required String id,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TileListScreen(title: title, categoryId: id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: logo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(logo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
            // Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              color: Colors.white,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkblue,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
