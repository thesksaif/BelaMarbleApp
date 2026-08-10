import 'package:bellamarble/core/app_colors.dart';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/screen/categories/details_Screen.dart';
import 'package:bellamarble/screen/categories/title_list_screen.dart';
import 'package:bellamarble/screen/home/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bellamarble/core/widgets/app_network_image.dart';

class SearchResultsScreen extends StatelessWidget {
  final String initialQuery;

  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider()..search(initialQuery),
      child: Scaffold(
        backgroundColor: AppColors.background2,
        appBar: AppBar(
          backgroundColor: AppColors.appbar,
          title: Text(
            "Search Results",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          elevation: 0,
        ),
        body: Consumer<SearchProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                const SizedBox(height: 16),

                /// Search Bar
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
                            autofocus: false,
                            onSubmitted: (value) => provider.search(value),
                            decoration: const InputDecoration(
                              hintText: "Search products or categories...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (provider.searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: provider.clearSearch,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Results
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            provider.errorMessage,
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        )
                      : provider.searchResponse == null
                      ? Center(
                          child: Text(
                            "Enter a search query",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        )
                      : _buildResults(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchProvider provider) {
    final response = provider.searchResponse!;
    final hasCategories = response.data.categories.isNotEmpty;
    final hasProducts = response.data.products.isNotEmpty;

    if (!hasCategories && !hasProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No results found for \"${response.keyword}\"",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search Summary
            Text(
              "Found ${response.total.categories} categories and ${response.total.products} products",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            /// Categories Section
            if (hasCategories) ...[
              Text(
                "Categories (${response.total.categories})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...response.data.categories.map((category) {
                return _categoryCard(context, category);
              }).toList(),
              const SizedBox(height: 24),
            ],

            /// Products Section
            if (hasProducts) ...[
              Text(
                "Products (${response.total.products})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: response.data.products.length,
                itemBuilder: (context, index) {
                  return _productCard(context, response.data.products[index]);
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TileListScreen(
              title: category.categoryName,
              categoryId: category.categoryId.toString(),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.search, width: 1),
        ),
        child: Row(
          children: [
            /// Category Logo
            SizedBox(
              width: 60,
              height: 60,
              child: AppNetworkImage(
                url: category.logo,
                width: 60,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),

            /// Category Name
            Expanded(
              child: Text(
                category.categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, product) {
    // Convert SearchProduct to Product for navigation
    Product productForDetails = Product(
      productId: product.productId,
      categoryId: product.categoryId,
      name: product.name,
      size: '',
      description: '',
      tags: '',
      quantity: '',
      price: product.price,
      availability: product.availability,
      position: 0,
      image: product.image,
      createdAt: '',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TileDetailScreen(
              title: product.name,
              product: productForDetails,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.search, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Expanded(
              child: AppNetworkImage(
                url: product.image,
                width: 200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),

            /// Product Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.availability.isNotEmpty
                        ? product.availability
                        : "Stock status not available",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
